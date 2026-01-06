-- Copyright (c) 2020, Haakan T. Johansson
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
--use std.textio.all;
--use ieee.std_logic_textio.all;

use work.fnet_records.all;

entity fnet_tcp_prepare is
  generic (data_bufsize_addrbits : natural);
  port (clk            : in  std_logic;

        ram_stat_tcp_template : in  ram_stat_block;
        ram_stat_tcp_prep0    : in  ram_stat_block;
        ram_stat_tcp_prep1    : in  ram_stat_block;
        ram_cons_tcp_template : out ram_cons_block;
        ram_prod_tcp_prep0    : out ram_prod_block;
        ram_prod_tcp_prep1    : out ram_prod_block;
        dp_ram_tcp_template_porti : in  ram_block_porti_a11d16;
        dp_ram_tcp_template_porto : out ram_block_porto_a11d16 := rbpo_zero;
        dp_ram_tcp_prep0_porti : in  ram_block_porti_a11d16;
        dp_ram_tcp_prep0_porto : out ram_block_porto_a11d16 := rbpo_zero;
        dp_ram_tcp_prep1_porti : in  ram_block_porti_a11d16;
        dp_ram_tcp_prep1_porto : out ram_block_porto_a11d16 := rbpo_zero;

        data_port_b_addr  : out std_logic_vector;
        data_port_b_rd    : out std_logic;
        data_port_b_rdata : in  std_logic_vector;

        stat           : in  tcp_control_stat;
        astat          : in  tcp_state_async_stat;
        packet_req     : in  tcp_packet_req;
        packet_done    : out tcp_packet_done;

        max_packet_payload : in integer;

        -- Testing
        tc_limit_tcp_payload : in std_logic_vector(10 downto 0);

        debug_state    : out std_logic_vector(5 downto 0)
        );
end fnet_tcp_prepare;

-- Two prepare buffers are kept such that we can prepare
-- the next while the first is being sent.  Generally,
-- we prepare faster (or as fast) as buffers are being sent.
-- Due to the need to calculate the checksums, we need an
-- intermediate stage before transmission, i.e. the
-- preparation buffer(s).
-- Due to wanting to be able to deliver packets at full rate,
-- dual buffers are needed.

-- TODO: try to get rid of the discard (packet_req.discard_cur_prepare)
-- instead just do not mark at end?
--
-- This is a small optimisation lost,
-- but that should simplify code flow understanding.
-- Note: discard is still required in the sense that the tcp control
-- may have e.g gotten an ack for old data, such that repeat is no
-- longer required.

-- We avoid sending small packets.  If data has already been sent (but
-- not yet acknowledged), then we only transmit a new packet if either
-- half the RTT has passed, or we have enough data available to send a
-- full payload.

-- When do send packets?  Especially considering corner cases (keep-alive
-- and such).
--
-- state            => packet_req
--                  (in tcp_control)
-- ...............  ..................  ...........  ..........
-- con sst nrp nka  syn  dat  rep  klv  alr frs win  p1  p2 dec
--
-- CLO x   x   x    0    0    0    0    x   x   x    K
-- S_R x   x   x    1    0    0    0    x   x   x    0   0  -+-  S
-- S_S x   x   x    0    0    0    0    x   x   x    K

-- CON 0   x   0    0    1    0    0    0   0   x    0f  0  ---
-- CON 0   x   0    0    1    0    0    0   >0  <=0  >0f 0  ---
-- CON 0   x   0    0    1    0    0    0   >0  >0   >0f >0 +--  S

-- CON 1   0   0    0    1    0    0    >0  0   x    0f  0  ---
-- CON 1   0   0    0    1    0    0    >0  >0  <=0  >0f 0  ---
-- CON 1   0   0    0    1    0    0    >0  >0  >0   >0f >0 +--  S

-- CON 1   1   0    0    1    1    0    >0  0   <=0  >0a 0  ---
-- CON 1   1   0    0    1    1    0    >0  0   >0   >0a >0 +--  S
-- CON 1   1   0    0    1    1    0    >0  >0  <=0  >0a 0  ---
-- CON 1   1   0    0    1    1    0    >0  >0  >0   >0a >0 +--  S

-- CON 0   x   1    0    1    0    1    0   0   x    0f  0  --+  S
-- CON 0   x   1    0    1    0    1    0   >0  <=0  >0f 0  --+  S
-- CON 0   x   1    0    1    0    1    0   >0  >0   >0f >0 +-+  S

-- CON 1   0   1    0    1    0    1    >0  0   x    0f  0  --+  S
-- CON 1   0   1    0    1    0    1    >0  >0  <=0  >0f 0  --+  S
-- CON 1   0   1    0    1    0    1    >0  >0  >0   >0f >0 +-+  S

-- CON 1   1   1    0    1    1    1    >0  0   x    >0a 0  --+  S
-- CON 1   1   1    0    1    1    1    >0  >0  <=0  >0a 0  --+  S
-- CON 1   1   1    0    1    1    1    >0  >0  >0   >0a >0 +-+  S
--
-- conn = connection : [ CLOSED | SYN_RECEIVED | SYN_SENT | CONNECTED ]
-- sst = some_sent
-- nrp = need_repeat (= RTT timer expired)
-- nka = need_keepalive (= keep-alive timer expired)
--
-- alr = already sent (base .. sent)
-- frs = fresh avail  (sent .. avail)
--
-- p1 = payload len after IDLE  (- means packet send not happening)
--      a coming from alr, f coming from frs
-- p2 = payload len after window length comparison
--      w limited by window
--
-- dec = decision to send (len non-zero, syn packet, keep-alive)
--
-- The situation when the receiving end has reported zero window size,
-- is a bit different.  If we have already sent some data, then
-- the repeat timer will cause resends (as long as there is window enough
-- for some data sent.)
--
-- If we have not yet sent any data in a zero window, then only the
-- keep-alive timer will make packets come through.




architecture RTL of fnet_tcp_prepare is
  signal a : tcp_prepare_async_state;

  signal s : tcp_prepare_state :=
        (state => PSM_IDLE,
         get_data => (others => '0'),
         accum_cksum => '0',
         wcksum => (others => '0'),
         payload_len => (others => '0'),
         cur_address => (others => '0'),
         drd_address => (others => '0'),
         drd => '0',
         drd_rdata => (others => '0'),
         payload_limited => '0',
         repeat => '0',
         keepalive => '0',
         packet_count => (others => '0')
         );

  signal w : std_logic_vector(15 downto 0);

  signal off         : std_logic_vector(10 downto 0) :=
    (0 => '0', others => '1');
  signal offp2       : std_logic_vector(10 downto 0);
  signal off_stored  : std_logic_vector(10 downto 0) := (others => '0');

  signal read_data_pipeline : std_logic_vector(31 downto 0) := (others => '0');

  signal actual_woff  : std_logic_vector(10 downto 0);
  signal actual_wdata : std_logic_vector(15 downto 0);
  signal actual_wr    : std_logic;

  signal dly_accum_cksum   : std_logic;

  signal fold_wcksum       : std_logic_vector(16 downto 0);
  signal accum_wcksum      : std_logic_vector(16 downto 0);
  signal wdata_accum_cksum : std_logic_vector(15 downto 0);
  signal keep_wcksum       : std_logic_vector(15 downto 0);

  signal tmp_wcksum : std_logic_vector(16 downto 0);

  signal x_already_sent : std_logic_vector(16 downto 0);
  signal x_already_sent_over_2k : std_logic;
  signal already_sent : std_logic_vector(16 downto 0);
  signal already_sent_over_2k : std_logic;

  signal x_fresh_avail : std_logic_vector(31 downto 0);
  signal x_fresh_avail_over_2k : std_logic;
  signal fresh_avail : std_logic_vector(31 downto 0);
  signal fresh_avail_over_2k : std_logic;

  signal xx_window_left : std_logic_vector(16 downto 0);
  signal x_window_left : std_logic_vector(16 downto 0);
  signal x_window_left_over_2k : std_logic;
  signal x_window_left_negative : std_logic;
  signal window_left : std_logic_vector(16 downto 0);
  --signal window_left_over_2k : std_logic;
  signal window_left_negative : std_logic;

  signal cur_tcp_prep : std_logic := '0';

  -- Latched comparisons

  signal is_s_payload_len_gt_window_left : std_logic;
  signal is_s_payload_len_ge_max_payload : std_logic;
  signal is_s_payload_len_ge_tc_limit_tcp_payload : std_logic;

  signal x_is_s_payload_len_gt_window_left : std_logic;
  signal x_is_s_payload_len_ge_max_payload : std_logic;
  signal x_is_s_payload_len_ge_tc_limit_tcp_payload : std_logic;

  -- Control
  signal max_payload : std_logic_vector(10 downto 0);

  -- Testing
  signal round_tc_limit_tcp_payload : std_logic_vector(10 downto 0);

  -- For debugging
  signal state_no : integer := 0;

  signal x_done : std_logic;
  signal x_done_keepalive : std_logic;

begin

  offp2 <= off + 2;

  fold_wcksum <= ('0' & s.wcksum(15 downto 0)) + s.wcksum(16);

  accum_wcksum <= fold_wcksum;

  -- Avoid a.wdata, which is a complicated device.
  -- Instead take latched value.
  -- Means we are one cycle later, so clearing also moved a cycle later.
  wdata_accum_cksum <=
    actual_wdata when (dly_accum_cksum = '1') else (w'range => '0');

  tmp_wcksum <= accum_wcksum + wdata_accum_cksum;

  x_already_sent <= stat.max_sent - stat.base_seqno(16 downto 0);

  x_already_sent_over_2k <=
    '0' when (x_already_sent(x_already_sent'left downto 11) =
              (x_already_sent'left downto 11 => '0')) else '1';

  x_fresh_avail <= astat.unsent; -- packet_req.fresh_avail;

  x_fresh_avail_over_2k <=
    '0' when (x_fresh_avail(x_fresh_avail'left downto 11) =
              (x_fresh_avail'left downto 11 => '0')) else '1';

  -- Note: window_left may be negative in case client retracts
  -- (it is not really allowed).  Or in case testing reduces it
  -- (which we may do).
  xx_window_left <=
    ('0' & stat.window_sz) - ('0' & astat.cur_off) when (s.repeat = '0') else
    ('0' & stat.window_sz);

  -- For the comparisons, we use the latched window_left.
  -- Ok, since it does not change while we prepare the packet.
  x_window_left_over_2k <=
    '0' when (x_window_left(x_window_left'left downto 11) =
              (x_window_left'left downto 11 => '0')) else '1';
  x_window_left_negative <= x_window_left(16);

  x_is_s_payload_len_gt_window_left <=
    '1' when (x_window_left_over_2k = '0' and
              s.payload_len > x_window_left(10 downto 0)) else '0';

  -- Round to an even value.
  max_payload <= std_logic_vector(to_unsigned(max_packet_payload/2,
                                              max_payload'length-1)) & '0';

  x_is_s_payload_len_ge_max_payload <=
    '1' when (s.payload_len >= max_payload) else '0';

  round_tc_limit_tcp_payload <= tc_limit_tcp_payload(10 downto 1) & '0';

  x_is_s_payload_len_ge_tc_limit_tcp_payload <=
    '1' when (round_tc_limit_tcp_payload /= 0 and
              s.payload_len >= round_tc_limit_tcp_payload) else '0';

  process (s,ram_stat_tcp_template,ram_stat_tcp_prep0,ram_stat_tcp_prep1,
           astat,stat,off,w,
           cur_tcp_prep,packet_req,
           window_left,window_left_negative,
           is_s_payload_len_gt_window_left,
           max_payload,
           is_s_payload_len_ge_max_payload,
           round_tc_limit_tcp_payload,
           is_s_payload_len_ge_tc_limit_tcp_payload,
           fresh_avail_over_2k,fresh_avail,
           already_sent_over_2k,already_sent,
           keep_wcksum)
  begin

    a <= (wdata => w,
          next_state => PSM_IDLE,
          reset => '0',
          off_update => POU_INCREASE,
          off_store => '0',
          wr => '1',
          early_done => '0',
          no_discard => '0',
          done => '0',
          cipcksum => '0',
          wipcksum => '0',
          ctcpcksum => '0',
          wtcpcksum => '0',
          next_accum_cksum => '1',
          payload_len => s.payload_len,
          cur_address => s.cur_address,
          drd_address => s.drd_address + 2, -- One of the actual assignments.
          drd => '0',
          payload_limited => s.payload_limited,
          repeat => s.repeat,
          keepalive => s.keepalive);

    case s.state is

      -------------------------------------------------------------
      -- Ethernet

      when PSM_IDLE =>
        a.next_state <= PSM_IDLE;
        -- We prepare a new packed if we are directed to do so,
        -- and if there is an empty prepare buffer.

        -- How much (if any) data are we allowed to send?
        -- 1. We can be limited by the amount of available data.
        -- 2. We can be limited by the window given by the
        --    receiving tcp side.
        -- 3. Maximum packet length.

        -- We here set the payload length to the maximum data.
        -- The next states will reduce it in case the window length
        -- allows less.
        -- A later stage will abort the packet altogether if it
        -- is length zero (and not requested as some kind of
        -- keep-alive).

        a.repeat <= '0';
        a.keepalive <= '0';

        -- Do we have somewhere to put the packet?
        if ((cur_tcp_prep = '0' and ram_stat_tcp_prep0.hasdata = '0') or
            (cur_tcp_prep = '1' and ram_stat_tcp_prep1.hasdata = '0')) then
          -- Do we have a request to produce a packet?
          if (packet_req.send_syn = '1') then
            a.next_state <= PSM_FIRST;
            -- No payload
            a.payload_len <= (others => '0');
          end if;
          if (packet_req.send_data = '1') then
            a.next_state <= PSM_FIRST;
          end if;
        end if;

        a.payload_limited <= '0';
        a.repeat <= packet_req.send_repeat;
        a.keepalive <= packet_req.send_keepalive;

        if (packet_req.send_repeat = '0') then
          a.cur_address <= stat.max_sent(16 downto 0);
        else
          a.cur_address <= stat.base_seqno(16 downto 0);
        end if;

        a.off_update <= POU_RESET;
        a.reset <= '1';
        a.wr <= '0';
        a.next_accum_cksum <= '0';

        -- Note: already_sent, already_sent_over_2k,
        -- fresh_avail, fresh_avail_over_2k are calculated in this
        -- cycle.  Used and assigned in next.

      when PSM_FIRST => -- off = -2 in this cycle
        a.next_state <= PSM_HEADER_0;
        a.wr <= '0';
        a.next_accum_cksum <= '0';
        a.cipcksum <= '1';

        -- if (packet_req.send_repeat = '1') then
        if (s.repeat = '1') then
          -- For a repeat packet we never send more than we have sent
          -- earlier.  Thus max_sent never moves in tcp_control
          -- for this case.
          if (already_sent_over_2k = '1') then
            -- We set max_packet_payload instead of all 1, as
            -- it will anyhow be clamped to this below (and
            -- then the assignments are the same).
            a.payload_len <= max_payload;
          else
            -- May still be limited by max payload below.
            a.payload_len <= already_sent(10 downto 0);
          end if;
        else
          -- Payload definitely limited by available unsent data.
          if (fresh_avail_over_2k = '1') then
            a.payload_len <= max_payload;
          else
            -- May still be limited by max payload below.
            a.payload_len <= fresh_avail(10 downto 0);
          end if;
        end if;

        -------------------------------------------------------------

      when PSM_HEADER_0 =>
        a.next_state <= PSM_HEADER_2;
        a.next_accum_cksum <= '0';

        -- Calculation of is_s_payload_len_gt_window_left and
        -- window_left_negative.
        -- Check in next cycle.

      when PSM_HEADER_2 =>
        a.next_state <= PSM_HEADER_4;
        a.next_accum_cksum <= '0';

        if (window_left_negative = '1') then
          a.payload_len <= (others => '0');
        elsif (is_s_payload_len_gt_window_left = '1') then
          a.payload_len <= window_left(10 downto 0);
        end if;

        -- Note: the window check is done before the packet size
        -- checks.  This is such that we do not detoriate into sending
        -- small packets at the end of a small (and slowly moving
        -- window).  It is avoided since the packet size will then not
        -- be clamped by the packet size limitations below, as it has
        -- already been more clamped by the available window size.

        -------------------------------------------------------------

      when PSM_HEADER_4 =>
        a.next_state <= PSM_HEADER_6;
        a.next_accum_cksum <= '0';

        -- Calculation of is_s_payload_len_gt_max_payload.
        -- Check in next cycle.

      when PSM_HEADER_6 =>
        a.next_state <= PSM_HEADER_8;
        a.next_accum_cksum <= '0';

        if (is_s_payload_len_ge_max_payload = '1') then
          a.payload_len <= max_payload;
          a.payload_limited <= '1';
        end if;

        -------------------------------------------------------------

      when PSM_HEADER_8 =>
        a.next_state <= PSM_HEADER_10;
        a.next_accum_cksum <= '0';

        -- Calculation of is_s_payload_len_gt_tc_limit_tcp_payload.
        -- Check in next cycle.

      when PSM_HEADER_10 =>
        a.next_state <= PSM_HEADER_12;
        a.next_accum_cksum <= '0';

        if (is_s_payload_len_ge_tc_limit_tcp_payload = '1') then
          a.payload_len <= round_tc_limit_tcp_payload;
          a.payload_limited <= '1';
        end if;

      -------------------------------------------------------------

      when PSM_HEADER_12 =>
        a.next_state <= PSM_IPV4_14;

      when PSM_IPV4_14 =>
        a.next_state <= PSM_IPV4_16;

      -------------------------------------------------------------

      when PSM_IPV4_16 => -- Total length
        a.next_state <= PSM_IPV4_18;
        a.wdata <= "00000" & (s.payload_len + (20 + 20)); -- IPv4 + TCP headers

        -- Unless it is a keepalive or a SYN packet, then we kill
        -- the transmission if:
        -- - the payload is 0.
        -- - or it is a small packet (non-payload limited) and we
        --   are not allowing small packets, and it is not a repeat.

        if ((s.payload_len = (s.payload_len'range => '0') or
             (s.payload_limited = '0' and
              packet_req.send_small = '0' and
              s.repeat = '0')) and
            packet_req.send_syn = '0' and
            s.keepalive = '0') then
          -- There is no payload to send.  Abort packet.
          a.next_state <= PSM_IDLE;
        end if;

      when PSM_IPV4_18 =>
        a.next_state <= PSM_IPV4_20;
        -- Low octet of identification is packet count.
        a.wdata(7 downto 0) <= s.packet_count;

      when PSM_IPV4_20 =>
        a.next_state <= PSM_IPV4_22;

      when PSM_IPV4_22 =>
        a.next_state <= PSM_IPV4_24;

      when PSM_IPV4_24 => -- Checksum
        a.next_state <= PSM_IPV4_26;
        a.wdata <= (others => '0');

      when PSM_IPV4_26 =>
        a.next_state <= PSM_IPV4_28;

      when PSM_IPV4_28 =>
        a.next_state <= PSM_IPV4_30;

      when PSM_IPV4_30 =>
        a.next_state <= PSM_IPV4_32;

      when PSM_IPV4_32 =>
        a.next_state <= PSM_IPV4_CK1;

      when PSM_IPV4_CK1 =>
        a.next_state <= PSM_IPV4_CK2;
        a.wr <= '0';

      when PSM_IPV4_CK2 =>
        a.next_state <= PSM_IPV4_CK3;
        a.wr <= '0';

      when PSM_IPV4_CK3 =>
        a.next_state <= PSM_PSTCP_LEN;
        a.wdata <= keep_wcksum;
        a.wipcksum <= '1';

        -- Rewind write position, for pseudo-header overwrite below.
        a.off_update <= POU_SET_26;

      -------------------------------------------------------------

      when PSM_PSTCP_LEN =>
        a.next_state <= PSM_PSTCP_26;
        a.wdata <= "00000" & (s.payload_len + (20 + 20)); -- IPv4 + TCP headers
        a.wr <= '0';
        a.ctcpcksum <= '1';

        -- Simply repeat words that are also included in the TCP
        -- pseudo header.
      when PSM_PSTCP_26 =>
        a.next_state <= PSM_PSTCP_28;

      when PSM_PSTCP_28 =>
        a.next_state <= PSM_PSTCP_30;

      when PSM_PSTCP_30 =>
        a.next_state <= PSM_PSTCP_32;

      when PSM_PSTCP_32 =>
        a.next_state <= PSM_TCP_34;

      when PSM_TCP_34 => -- Actual TCP header.
        a.next_state <= PSM_TCP_36;

      when PSM_TCP_36 =>
        a.next_state <= PSM_TCP_38;

      when PSM_TCP_38 => -- Sequence number (hi)
        a.next_state <= PSM_TCP_40;
        if (s.repeat = '1' or
            stat.max_sent(16) = stat.base_seqno(16)) then
          a.wdata <= stat.base_seqno(31 downto 16);
        else
          a.wdata <= astat.base_seqno_hi_plus_1;
        end if;

      when PSM_TCP_40 => -- Sequence number (lo)
        a.next_state <= PSM_TCP_42;
        if (packet_req.send_syn = '1') then -- Sending SYN=first packet
          -- TODO: change to 16#000f# when starting TCP seq at 16 instead of 4.
          a.wdata <= (0 => '1', 1 => '1', others => '0');
        else
          if (s.repeat = '0') then
            a.wdata <= stat.max_sent(15 downto 0);
          else
            a.wdata <= stat.base_seqno(15 downto 0);
          end if;
        end if;

      when PSM_TCP_42 => -- Ack number (hi)
        a.next_state <= PSM_TCP_44;

      when PSM_TCP_44 => -- Ack number (lo)
        a.next_state <= PSM_TCP_46;
        -- Get the address to read.
        -- Handled in separate counter, since we do the reads several
        -- cycles in advance, in order to pipeline well between us and
        -- a possibly large and spread out memory area...
        a.drd <= '1';
        a.drd_address <=
          (31 downto s.cur_address'left+1 => '0') & s.cur_address;

      when PSM_TCP_46 => -- Data off, 000, flags
        a.next_state <= PSM_TCP_48;
        -- 5 for the header length; 4x5=20
        -- Always giving ACK flag, SYN when such packet.
        a.wdata <= "0101" & "000" & "0000100" & packet_req.send_syn & "0";
        --
        a.drd <= '1';
        a.drd_address <= s.drd_address + 2;

      when PSM_TCP_48 => -- Window size
        a.next_state <= PSM_TCP_50;
        --
        a.drd <= '1';
        a.drd_address <= s.drd_address + 2;

      when PSM_TCP_50 => -- Checksum
        a.next_state <= PSM_TCP_52;
        a.wdata <= (others => '0');
        --
        a.drd <= '1';
        a.drd_address <= s.drd_address + 2;

      when PSM_TCP_52 =>
        a.next_state <= PSM_DATA;
        --
        a.drd <= '1';
        a.drd_address <= s.drd_address + 2;

        -------------------------------------------------------------

      when PSM_DATA =>
        a.next_state <= PSM_DATA;
        if (s.payload_len = 0) then
          if (off < 60) then
            a.next_state <= PSM_PAD;
          else
            a.next_state <= PSM_CK1;
          end if;
          a.wr <= '0';
          a.off_update <= POU_NONE;
          a.wdata <= (others => '0');
        else
          if (s.cur_address(1) = '0') then
            a.wdata <= s.drd_rdata(31 downto 16);
          else
            a.wdata <= s.drd_rdata(15 downto 0);
          end if;
          a.cur_address <= s.cur_address + 2;
        end if;
        -- The following are harmless even if we are at payload_len == 0.
        a.drd <= '1';
        a.payload_len <= s.payload_len - 2;
        a.drd_address <= s.drd_address + 2;

        -------------------------------------------------------------

      when PSM_PAD =>
        a.next_state <= PSM_PAD;
        if (off = 58) then
          a.next_state <= PSM_CK1;
        end if;
        a.wdata <= (others => '0');

      when PSM_CK1 =>
        a.next_state <= PSM_CK2;
        a.off_update <= POU_NONE;
        a.wr <= '0';
        a.early_done <= '1';
        a.no_discard <= '1';

      when PSM_CK2 =>
        a.next_state <= PSM_CK3;
        a.off_update <= POU_NONE;
        a.wr <= '0';
        a.no_discard <= '1';

      when PSM_CK3 =>
        a.next_state <= PSM_DONE;
        a.wdata <= keep_wcksum;
        a.wtcpcksum <= '1';
        a.no_discard <= '1';

      when PSM_DONE =>
        a.next_state <= PSM_IDLE;
        a.done <= '1';
        a.wr <= '0';
        a.no_discard <= '1';

    end case;
  end process;

  process (clk)
  begin
    if (rising_edge(clk)) then
      s.state <= a.next_state;
      s.payload_len <= a.payload_len;
      s.cur_address <= a.cur_address;
      s.drd <= a.drd;
      s.drd_address <= a.drd_address;
      s.payload_limited <= a.payload_limited;
      s.repeat <= a.repeat;
      s.keepalive <= a.keepalive;
      s.packet_count <= s.packet_count + a.done;

      if (packet_req.discard_cur_prepare = '1' and
          a.no_discard = '0') then
        s.state <= PSM_IDLE;
      end if;

      if (a.off_update = POU_NONE) then
      elsif (a.off_update = POU_RESET) then
        -- -2 (first read is then at 0)
        off <= (0 => '0', others => '1');
      elsif (a.off_update = POU_INCREASE) then
        off <= offp2;
      elsif (a.off_update = POU_SET_26)  then
        off <= std_logic_vector(to_unsigned(24,11));
      end if;

      if (a.off_store = '1') then
        off_stored <= off;
      end if;

      if (a.cipcksum = '1') then
        s.wcksum <= (others => '0'); -- regacc_stat_aux.checksum;
      elsif (a.ctcpcksum = '1') then
        -- Init checksum for TCP pseudo header.
        -- Directly apply the correction for the length.
        s.wcksum <= "11111111111110000";
      else
        s.wcksum <= tmp_wcksum;
      end if;

      keep_wcksum <= not fold_wcksum(15 downto 0);

      s.accum_cksum <= a.next_accum_cksum;
      dly_accum_cksum <= s.accum_cksum;

      actual_woff <= off;
      if (a.wipcksum = '1') then
        actual_woff <= std_logic_vector(to_unsigned(24,11));
      end if;
      if (a.wtcpcksum = '1') then
        actual_woff <= std_logic_vector(to_unsigned(50,11));
      end if;
      actual_wdata <= a.wdata;
      actual_wr <= a.wr;

      if (a.done = '1') then
        cur_tcp_prep <= not cur_tcp_prep;
      end if;
      -- We send the early_done, which is two cycles earlier.
      -- This such that the tcp_control has a chance to update state and
      -- prepare a new request (and in particular withdraw the current one)
      -- such that we do not send e.g. a syn packet two times.
      packet_done.done <= a.early_done;

      -- Pipeline the address going out to the data buffer.
      data_port_b_addr <= s.drd_address(data_port_b_addr'left + 2 downto 2);
      data_port_b_rd <= s.drd;
      -- Pipeline the data coming in from the data buffer
      s.drd_rdata        <= read_data_pipeline;
      read_data_pipeline <= data_port_b_rdata;
      -- Pipeline
      already_sent <= x_already_sent;
      already_sent_over_2k <= x_already_sent_over_2k;

      fresh_avail <= x_fresh_avail;
      fresh_avail_over_2k <= x_fresh_avail_over_2k;

      x_window_left <= xx_window_left;
      window_left <= x_window_left;
      window_left_negative <= x_window_left_negative;

      is_s_payload_len_gt_window_left <= x_is_s_payload_len_gt_window_left;
      is_s_payload_len_ge_max_payload <= x_is_s_payload_len_ge_max_payload;
      is_s_payload_len_ge_tc_limit_tcp_payload <=
        x_is_s_payload_len_ge_tc_limit_tcp_payload;
    end if;
  end process;

  packet_done.payload_limited <= s.payload_limited;
  packet_done.cur_address <= s.cur_address;
  packet_done.repeated <= s.repeat;
  packet_done.keepalive <= s.keepalive;

  ram_prod_tcp_prep0.set_hasdata <= a.done and (not cur_tcp_prep);
  ram_prod_tcp_prep0.set_broadcast <= '0';
  ram_prod_tcp_prep0.set_drop_dly  <= '0';
  ram_prod_tcp_prep0.set_words <= off(10 downto 0);
  ram_prod_tcp_prep1.set_hasdata <= a.done and (    cur_tcp_prep);
  ram_prod_tcp_prep1.set_broadcast <= '0';
  ram_prod_tcp_prep1.set_drop_dly  <= '0';
  ram_prod_tcp_prep1.set_words <= off(10 downto 0);

  dp_ram_tcp_template_porto.addr <= offp2(10 downto 1);
  dp_ram_tcp_template_porto.rd <= not a.reset;
  w <= dp_ram_tcp_template_porti.rdata;

  dp_ram_tcp_prep0_porto.addr  <= actual_woff(10 downto 1);
  dp_ram_tcp_prep0_porto.wdata <= actual_wdata;
  dp_ram_tcp_prep0_porto.wr    <= actual_wr and (not cur_tcp_prep);
  dp_ram_tcp_prep1_porto.addr  <= actual_woff(10 downto 1);
  dp_ram_tcp_prep1_porto.wdata <= actual_wdata;
  dp_ram_tcp_prep1_porto.wr    <= actual_wr and (    cur_tcp_prep);

  -- For debugging
  process (clk)
  begin
    if (rising_edge(clk)) then
      case s.state is
        when PSM_IDLE      => state_no <=     1;
        when PSM_FIRST     => state_no <=     2;
        when PSM_HEADER_0  => state_no <=     3;
        when PSM_HEADER_2  => state_no <=     4;
        when PSM_HEADER_4  => state_no <=     5;
        when PSM_HEADER_6  => state_no <=     6;
        when PSM_HEADER_8  => state_no <=     7;
        when PSM_HEADER_10 => state_no <=     8;
        when PSM_HEADER_12 => state_no <=     9;
        when PSM_IPV4_14   => state_no <=    10;
        when PSM_IPV4_16   => state_no <=    11;
        when PSM_IPV4_18   => state_no <=    12;
        when PSM_IPV4_20   => state_no <=    13;
        when PSM_IPV4_22   => state_no <=    14;
        when PSM_IPV4_24   => state_no <=    15;
        when PSM_IPV4_26   => state_no <=    16;
        when PSM_IPV4_28   => state_no <=    17;
        when PSM_IPV4_30   => state_no <=    18;
        when PSM_IPV4_32   => state_no <=    19;
        when PSM_IPV4_CK1  => state_no <=    20;
        when PSM_IPV4_CK2  => state_no <=    21;
        when PSM_IPV4_CK3  => state_no <=    22;
        when PSM_PSTCP_LEN => state_no <=    23;
        when PSM_PSTCP_26  => state_no <=    24;
        when PSM_PSTCP_28  => state_no <=    25;
        when PSM_PSTCP_30  => state_no <=    26;
        when PSM_PSTCP_32  => state_no <=    27;
        when PSM_TCP_34    => state_no <=    28;
        when PSM_TCP_36    => state_no <=    29;
        when PSM_TCP_38    => state_no <=    30;
        when PSM_TCP_40    => state_no <=    31;
        when PSM_TCP_42    => state_no <=    32;
        when PSM_TCP_44    => state_no <=    33;
        when PSM_TCP_46    => state_no <=    34;
        when PSM_TCP_48    => state_no <=    35;
        when PSM_TCP_50    => state_no <=    36;
        when PSM_TCP_52    => state_no <=    37;
        when PSM_DATA      => state_no <=    38;
        when PSM_PAD       => state_no <=    39;
        when PSM_CK1       => state_no <=    40;
        when PSM_CK2       => state_no <=    41;
        when PSM_CK3       => state_no <=    42;
        when PSM_DONE      => state_no <=    43;
      end case;
    end if;
  end process;

  debug_state <= std_logic_vector(to_unsigned(state_no,6));

  x_done           <= a.early_done;
  x_done_keepalive <= s.keepalive;

  --process (clk)
  --  variable l : line;
  --begin
  --  if (falling_edge(clk)) then
  --    write (l, String'("PREP_CKSUM: "));
  --    hwrite (l, "000" & s.wcksum);
  --    write (l, String'(" "));
  --    hwrite (l, "000" & fold_wcksum);
  --    write (l, String'("  "));
  --    hwrite (l, a.wdata);
  --    write (l, String'(" "));
  --    hwrite (l, actual_wdata);
  --    write (l, String'("  "));
  --    hwrite (l, wdata_accum_cksum);
  --    write (l, String'(" "));
  --    hwrite (l, "000" & tmp_wcksum);
  --    write (l, String'("  "));
  --    hwrite (l, keep_wcksum);
  --    write (l, String'(" "));
  --    write (l, dly_accum_cksum);
  --    write (l, String'(" "));
  --    write (l, a.wipcksum);
  --    write (l, String'(" "));
  --    write (l, a.wtcpcksum);
  --    writeline (output, l);
  --  end if;
  --end process;

end RTL;
