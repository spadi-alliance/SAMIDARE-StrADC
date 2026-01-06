-- Copyright (c) 2020, Haakan T. Johansson
-- Copyright (c) 2020, Anders Furufors
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--     * Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
--     * Neither the name of the authors nor the
--       names of its contributors may be used to endorse or promote products
--       derived from this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.fnet_records.all;

entity fnet_tcp_control is
  generic (data_bufsize_addrbits : natural);
  port (clk             : in  std_logic;
        --
        stat            : out tcp_control_stat;
        --
        astat           : in  tcp_state_async_stat;
        --
        recv            : in  tcp_control_recv;
        --
        packet_req      : out tcp_packet_req;
        packet_done     : in  tcp_packet_done;
        --
        tcp_reset       : in  std_logic;
        --
        slow_clock_tick : in std_logic;
        timeout_tick    : in  std_logic;
        --
        info_counts     : out tcp_control_info_counts;
        -- Testing
        tc_limit_tcp_window : in std_logic_vector(15 downto 0)
        );
end fnet_tcp_control;

-- The RTT is measured:
--
-- Every time max_sent is moved forward, we record the new location
-- as the measurement trip point, and the timing counter is reset.
-- If the transmission for any reason is restarted, the measurement
-- is aborted.
-- When the trip point is acknowledged, the measurement is taken.
-- The measurement is processed through two successive filters:
-- a min-of-four and then a max-of-four.

architecture RTL of fnet_tcp_control is

  constant s_stat_initval : tcp_control_stat :=
    (-- TODO: start at 16 and init with 15.
     -- Start the low sequence word at four, so we can init with 3.
     -- The higher parts could be more random, just selecting something.
     base_seqno => (20 => '1', 2 => '1', others => '0'),
     max_sent   => (2 => '1', others => '0'),
     window_sz  => (others => '0'),
     rtt_trip   => (others => '0'),
     same_ack   => "00",
     conn_state => CLOSED,
     rtt_est    => (others => '0'));

  signal s_stat : tcp_control_stat       := s_stat_initval;

  -- The timeout counters tick somewhere 2-20 times per max packet
  -- length.  To handle the difference from 1 Gbps to 10 Mbps we
  -- need another factor 100.  And then a factor 10 of safety.
  -- 20 * 100 * 10 = 2000 => 11 bits.  Use 12.

  signal meas_rtt       : std_logic := '0';
  signal take_rtt       : std_logic := '0';
  signal rtt_count_meas : std_logic_vector(11 downto 0) := (others => '0');

  signal rtt_taken      : std_logic_vector(3 downto 0) := (others => '0');
  signal rtt_max4       : std_logic_vector(11 downto 0) := (others => '1');
  signal rtt_max4_min4  : std_logic_vector(11 downto 0) := (others => '1');
  signal rtt_estimate   : std_logic_vector(11 downto 0) := (others => '1');

  signal rtt_counter    : std_logic_vector(12 downto 0) := (others => '1');
  signal rtt_small_counter : std_logic_vector(10 downto 0) := (others => '1');

  signal rtt_trip_m_ack_seqno : std_logic_vector(16 downto 0);

  signal allow_small    : std_logic := '0';

  signal need_repeat    : std_logic := '0';
  signal need_keepalive : std_logic_vector(1 downto 0) := (others => '0');

begin

  -- The location of max_sent and cur_sent only give the lower bits.
  -- They are absolute.  If the 17th bit matches the base_seqno, then
  -- they are for the same 64 ki page (16 high bits same), otherwise
  -- they are for the next page.

  -- Since all operations are controlled by the differences between
  -- the absolute pointer positions, it is ok to update all pointers
  -- in the same clock cycle.

  -- Due to us operating with counts that are relative to the base
  -- pointer, the available count is directly modified whenever we get
  -- an acknowledgement.


  -- We have passed the trip point when recv.ack_seqno > s_stat.rtt_trip.
  -- Since we know that both rtt_trip and ack_seqno are after base_seqno,
  -- i.e. that 0 <= s_stat.rtt_trip - s_stat.base_seqno < 64ki and
  -- 0 <= recv.ack_seqno - s_stat.base_seqno < 64ki, then a subtraction
  -- of x = s_stat.rtt_trip - recv.ack_seqno is -64ki < x < 64ki.
  -- We have passed the trip point when x < 0.  I.e. when the sign bit
  -- of x is set.

  rtt_trip_m_ack_seqno <= s_stat.rtt_trip - recv.ack_seqno;

  process(clk)
  begin
    if (rising_edge(clk)) then

      info_counts <= tsic_zero;

      if (slow_clock_tick = '1') then
        rtt_small_counter <= rtt_small_counter - 1;
        if (rtt_small_counter = 0) then
          allow_small <= '1';
          -- No need to reset this counter.  It will just trigger
          -- later.  The needed reset is below, when allow_small has
          -- been set to 0.
        end if;
      end if;

      -- There is no contention between updates for packets sent,
      -- which update max_sent, while updates for ack packets
      -- modify the base.  Thanks to the use of the 17th bit in
      -- max_sent, it is always well defined.  Any RTT measurement
      -- is also either started or stopped.

      if (s_stat.conn_state = CONNECTED) then
        -- Note: if we get this done, the packet has not been,
        -- nor can it be, discarded.
        if (packet_done.done = '1') then
          if (packet_done.repeated = '0') then
            -- Only if we did not repeat, the max_sent location has
            -- updated.  (This is why repeat packets never pass
            -- the sent location.)
            s_stat.max_sent <= packet_done.cur_address;
            -- And we only make a non-resend packet when there
            -- was some payload to send, so it did move.
            -- Unless it is a keep-alive.
            if (meas_rtt = '0' and
                packet_done.keepalive = '0') then
              -- First time we have sent this far,
              -- and no RTT measurement ongoing.
              meas_rtt <= '1';
              rtt_count_meas <= (0 => '1', others => '0');
              -- Measurement is done when we get an ack
              -- somewhere inside the just sent packet, i.e.
              -- anywhere after the start of this packet.
              s_stat.rtt_trip <= s_stat.max_sent;
              info_counts.start_meas_rtt <= '1';
            end if;
            -- We have sent a (fresh / non-repeat) data packet.
            -- Do not allow small packets until the small (half RTT)
            -- counter has triggered.
            -- But if the previous packet was full-size, we allow a
            -- small packet.
            allow_small <= packet_done.payload_limited;
            rtt_small_counter <= rtt_estimate(rtt_estimate'high downto 1);
          end if;
          if (packet_done.repeated = '1') then
            need_repeat <= '0';
            info_counts.did_repeat <= '1';

            -- Slowly increase the RTT estimate, such that repeats
            -- die down to a trickle...
            if (rtt_estimate /= (rtt_estimate'range => '1')) then
              rtt_estimate <= rtt_estimate + 1;
            end if;
          end if;
          if (packet_done.keepalive = '1') then
            info_counts.did_keepalive <= '1';
          end if;
          -- Any packet sent removes the need for a keep-alive.
          need_keepalive <= (others => '0');
        end if;
      end if;

      packet_req.discard_cur_prepare <= '0';
      take_rtt <= '0';

      if (recv.got_ack = '1') then
        info_counts.got_ack <= '1';
        -- We have received an ack, where the ack number is in the
        -- allowed window, i.e. 0 <= ack < 64 ki after current
        -- base.

        -- Take the window length.  But zero the lowest bit (also
        -- ensures that we never use full 64ki.
        s_stat.window_sz <= recv.window_len(15 downto 1) & '0';
        -- For testing (not used in normal production).
        if (tc_limit_tcp_window /= 0 and
            recv.window_len > tc_limit_tcp_window) then
          s_stat.window_sz <= tc_limit_tcp_window(15 downto 1) & '0';
        end if;

        -- The low 16 bits of the ack seq number we set directly.
        s_stat.base_seqno(15 downto 0) <= recv.ack_seqno(15 downto 0);

        -- Is it first time we got an ack passing the rtt trip point?
        if (meas_rtt = '1' and
            rtt_trip_m_ack_seqno(16) = '1') then
          -- We have a new RTT measurement.
          -- Deal with it next clock cycle.
          take_rtt <= '1';
          meas_rtt <= '0';

          info_counts.got_meas_rtt <= '1';
        end if;

        -- If the 17th bit is different, then we are to add one to the
        -- higher part.
        -- The receiver will have refused the ack if it is not for the
        -- correct high bits.
        -- It will also have refused the ack if it is further forward
        -- than we have sent.
        if (recv.ack_seqno(16) /= s_stat.base_seqno(16)) then
          s_stat.base_seqno(31 downto 16) <= astat.base_seqno_hi_plus_1;
        end if;

        s_stat.same_ack(1) <= s_stat.same_ack(0);
        s_stat.same_ack(0) <= '0';

        -- Was it the same ack?
        if (s_stat.base_seqno(16 downto 0) =
            recv.ack_seqno(16 downto 0)) then
          info_counts.same_ack <= '1';
          -- Have we now seen the same ack three times (incl. this)?
          if (s_stat.same_ack = "11") then
            info_counts.twice_same_ack <= '1';
            -- Start over
            need_repeat <= '1';
            packet_req.discard_cur_prepare <= '1';
            -- RTT measurement is hereby crap
            meas_rtt <= '0';
          else
            -- Accumulate more same-ack counts...
            s_stat.same_ack(0) <= '1';
          end if;
        elsif (need_repeat = '1') then
          info_counts.abort_repeat <= '1';
          -- It was an updated ack.  If we are currently doing
          -- a repeat, then abort that.  This is necessary since
          -- we are giving the area free for memory writes,
          -- and we may otherwise transmit new data at old location.
          need_repeat <= '0';
          packet_req.discard_cur_prepare <= '1';
        end if;

        if (s_stat.conn_state = SYN_SENT) then
          info_counts.connect <= '1';
          s_stat.conn_state <= CONNECTED;
          need_repeat <= '0';
        end if;
      end if;

      if (recv.got_syn = '1') then
        info_counts.got_syn <= '1';
        -- We were before in CLOSED (only then do in_state accept syn)
        s_stat.conn_state <= SYN_RECEIVED;
      end if;

      packet_req.send_syn <= '0';
      packet_req.send_data <= '0';
      packet_req.send_small <= '0';
      packet_req.send_repeat <= '0';
      packet_req.send_keepalive <= '0';
      if (s_stat.conn_state = SYN_RECEIVED) then
        packet_req.send_syn <= '1';
        if (packet_done.done = '1') then
          s_stat.conn_state <= SYN_SENT;
        end if;
      end if;
      if (s_stat.conn_state = CONNECTED) then
        packet_req.send_data <= '1';
        -- Allow transmission of small (non-full payload) if either
        -- we have not sent anything, or a (half-RTT) timer has expired.
        if (astat.some_sent = '0' or
            allow_small = '1') then
          packet_req.send_small <= '1';
        end if;
        if (astat.some_sent = '1') then
          -- Repeat packet only considered if something has been sent.
          packet_req.send_repeat <= need_repeat;
        end if;
        if (need_keepalive(1) = '1') then
          packet_req.send_keepalive <= '1';
        end if;
      end if;

      -- We make sure some TCP packet is issued (even if zero size)
      -- once in a while.  Is needed in case receiver has reported
      -- zero window size.  Even if receiver sends an ack with a
      -- non-zero window, that packet may get lost.  So we need
      -- to retry.
      if (timeout_tick = '1') then
        need_keepalive <= need_keepalive(0) & '1';
      end if;

      -- Maintain the RTT measurement counter

      if (slow_clock_tick = '1') then
        if (rtt_count_meas /= (rtt_count_meas'range => '1')) then
          rtt_count_meas <= rtt_count_meas + 1;
        end if;
      end if;

      if (take_rtt = '1') then
        -- Max of four, then min of four of those.
        if (rtt_count_meas > rtt_max4) then
          rtt_max4 <= rtt_count_meas;
        end if;
        if (rtt_taken(1 downto 0) = "00") then
          rtt_max4 <= rtt_count_meas;

          if (rtt_max4 < rtt_max4_min4) then
            rtt_max4_min4 <= rtt_max4;
          end if;
          if (rtt_taken(3 downto 2) = "00") then
            rtt_max4_min4 <= rtt_max4;

            rtt_estimate <= rtt_max4_min4;

            info_counts.new_rtt_est <= '1';
          end if;
        end if;

        rtt_taken <= rtt_taken + 1;
      end if;

      -- Maintain the RTT timer for ACK packages.

      if (recv.got_ack = '1') then
        -- We have seen an ACK package, reset timeout.
        -- Multiply by 2 as safety factor.
        rtt_counter <= rtt_estimate & '0';
      elsif (slow_clock_tick = '1') then
        rtt_counter <= rtt_counter - 1;
        if (rtt_counter = 0) then
          -- We have counted (two) RTT times, and not seen an
          -- ACK package.  Most likely it has been lost.
          -- Request transmission repetition.
          need_repeat <= '1';
          -- It actually could suffice with a short repeat packet,
          -- as this is a keep-alive, and thus would be noted by
          -- triple-ack.
          packet_req.discard_cur_prepare <= '1';
          -- Any RTT measurement is hearby affected.
          meas_rtt <= '0';
          -- And start counting again.
          rtt_counter <= rtt_estimate & '0';
        end if;
      end if;

      if (tcp_reset = '1') then
         s_stat <= s_stat_initval;

         -- Make the sequence counter jump by quite a lot,
         -- to avoid packets from previous connection to
         -- pollute us.  (They would need to have correct
         -- IP and port of other end as well.)
         s_stat.base_seqno(30 downto 28) <=
           s_stat.base_seqno(30 downto 28) + 1;

         meas_rtt <= '0';
         take_rtt <= '0';

         -- No need to reset the rtt measurement itself;
         -- given some transported data, it will refresh anyhow.

         need_repeat <= '0';
         need_keepalive <= (others => '0');

         -- If we are preparing a packet, loose that one.
         packet_req.discard_cur_prepare <= '1';
         -- No need to clear the other packet request members.  The
         -- discarding will kill anything which is not already almost
         -- finished (writing TCP checksum).
      end if;

      -- Just for local register (debug) access.
      s_stat.rtt_est <= rtt_estimate;
    end if;
  end process;

  stat  <= s_stat;

end RTL;
