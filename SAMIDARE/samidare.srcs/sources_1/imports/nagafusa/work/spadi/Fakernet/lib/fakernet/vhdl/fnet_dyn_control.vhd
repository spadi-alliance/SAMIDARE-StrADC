-- Copyright (c) 2022, Haakan T. Johansson
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
use ieee.numeric_std.all;

use work.fnet_records.all;

entity fnet_dyn_control is
  port (clk          : in  std_logic;
        --
        cfg_gen_rarp : in  std_logic;
        cfg_gen_bootp: in  std_logic;
        cfg_gen_dhcp : in  std_logic;
        --
        in_stat      : in  dync_in_stat;
        gen_stat     : in  dync_gen_stat;
        --
        stat         : out dync_control_stat;
        --
        drive_lfsr   : in std_logic;
        timeout_tick : in std_logic
        );
end fnet_dyn_control;

-- We are responsible for dynamic reconfiguration requests once in
-- a while.  Strategy:
--
-- - On any incoming ARP packet, we may generate the requests,
--   given that:
--
-- - Enough time passed since the last request.
--
-- - If we get responses to the RARP/BOOTP queries, the time interval
--   is set to about a minute.  Otherwise, requests are issued every
--   few seconds.

architecture RTL of fnet_dyn_control is

  signal state : dync_control_stat := (dyn_ip            => (others => '0'),
                                       dyn_ip_set        => '0',
                                       pending_rarp      => '0',
                                       pending_bootp     => '0',
                                       pending_dhcp_disc => '0',
                                       pending_dhcp_req  => '0',
                                       expect_rarp_resp  => '0',
                                       expect_bootp_resp => '0',
                                       expect_dhcp_offer => '0',
                                       expect_dhcp_ack   => '0',
                                       bootp_xid         => (others => '0'),
                                       dhcp_xid          => (others => '0'),
                                       dhcp_offer_ip      => (others => '0'),
                                       dhcp_offer_serv_ip => (others => '0'));

  -- Count of number of queries sent.
  signal bootp_count : unsigned(5 downto 0) := (others => '0');
  signal dhcp_count  : unsigned(5 downto 0) := (others => '0');

  -- Running counter.
  signal counter       : unsigned(7 downto 0) := (others => '0');
  signal lfsr          : unsigned(30 downto 0) := (others => '1');
  signal lfsr_next     : unsigned(30 downto 0) := (others => '0');
  signal bootp_latched : unsigned(23 downto 0) := (others => '0');
  signal dhcp_latched  : unsigned(23 downto 0) := (others => '0');

  -- Has a dynamic response been seen for any of the last three requests.
  signal dyn_response_seen : unsigned(1 downto 0) := "00";
  -- Downcount of timeout ticks.  Another request will not be generated
  -- until the counter reaches 0.
  signal downcount         : unsigned(5 downto 0) := (others => '0');
  -- Helper to check for 0 by subtraction overflow.
  signal next_downcount    : unsigned(downcount'left+1 downto 0) :=
    (others => '0');

  signal dhcp_retry : unsigned(1 downto 0) := "00";
  
begin

  next_downcount <= ('0' & downcount) - 1;

  -- The 2nd bit is fixed '1' to never have a fully zero XID (not that
  -- it matters, but still).  The first bit could make it easy to
  -- distinguish is a response is bootp or dhcp.
  state.bootp_xid( 7 downto 0) <= std_logic_vector(bootp_count) & "10";
  state.dhcp_xid ( 7 downto 0) <= std_logic_vector(dhcp_count)  & "11";
  -- Latched value of a running counter to give random value.
  state.bootp_xid(31 downto 8) <= std_logic_vector(bootp_latched);
  state.dhcp_xid (31 downto 8) <= std_logic_vector(dhcp_latched);

  -- LFSR with period 2^31-1.  Taps at bits 30 and 2.
  lfsr_next(30 downto 1) <= lfsr(29 downto 0);
  lfsr_next(0) <= lfsr(30) xor lfsr(2);

  process(clk)
  begin
    if (rising_edge(clk)) then

      if (timeout_tick = '1') then
        if (next_downcount(next_downcount'left) = '0') then
          downcount <= next_downcount(downcount'range);
        end if;
      end if;

      -- Update the LFSR on new_packet signal.  Thus it is harder to
      -- predict.
      if (drive_lfsr = '1') then
        lfsr <= lfsr_next;
      end if;

      counter <= counter + 1;

      -- If we see another ARP message (which means someone is looking
      -- for some IP, which may be our dynamic address), and we have
      -- not generated a dynamic request (RARP/BOOTP) for a while,
      -- then do so.
      if (in_stat.any_arp = '1' and -- We got another ARP.
          next_downcount(next_downcount'left) = '1') then
        if (cfg_gen_rarp = '1') then
          state.pending_rarp  <= '1';
        end if;
        if (cfg_gen_bootp = '1') then
          state.pending_bootp <= '1';
          bootp_count <= bootp_count + 1;
          bootp_latched <= lfsr(15 downto 0) & counter;
        end if;
        if (cfg_gen_dhcp = '1') then
          if (dhcp_retry = 0) then
            state.pending_dhcp_disc <= '1';
          else
            state.pending_dhcp_req <= '1';
            dhcp_retry <= dhcp_retry - 1;
          end if;
          dhcp_count <= dhcp_count + 1;
          dhcp_latched <= lfsr(15 downto 0) & counter;
        end if;

        if (dyn_response_seen = "00") then
          -- Dynamic response not seen recently, make dynamic requests
          -- more often.
          downcount <= to_unsigned(4, downcount'length);
        else
          -- Dynamic response seen not too long ago.
          downcount <= (others => '1'); -- Max value.
          -- Move towards forgetting the response.
          dyn_response_seen <= dyn_response_seen - 1;
        end if;
      end if;

      -- TODO: limit generation of these requests.  E.g. by requiring
      -- transaction ID to match, and failing further matches after
      -- offer packet seen.
      if (in_stat.good_dhcp_offer  = '1' and
          state.expect_dhcp_offer  = '1') then
        state.pending_dhcp_req  <= '1';

        state.dhcp_offer_ip      <= in_stat.offer_ip;
        state.dhcp_offer_serv_ip <= in_stat.offer_serv_ip;
      end if;

      if ((in_stat.good_rarp       = '1' and
           state.expect_rarp_resp  = '1') or
          (in_stat.good_bootp      = '1' and
           state.expect_bootp_resp = '1') or
          (in_stat.good_dhcp_ack   = '1' and
           state.expect_dhcp_ack   = '1')) then
        -- Dynamic response seen.
        dyn_response_seen <= "11";

        -- We have gotten ourselves a new(?) IP address!
        state.dyn_ip <= in_stat.offer_ip;
        -- Note that this can be set also when cfg_dyn_ip is 0,
        -- but would not be used.
        state.dyn_ip_set <= '1';
      end if;

      if (in_stat.good_dhcp_ack   = '1' and
          state.expect_dhcp_ack   = '1') then
        -- After we get an DHCP ACK, we will try just request (no discovery)
        -- a few times.
        dhcp_retry <= (others => '1');
      end if;

      -- Only allow one (successful) response by no longer expecting
      -- responses.
      if (in_stat.good_rarp = '1') then
        state.expect_rarp_resp <= '0';
      end if;
      if (in_stat.good_bootp = '1') then
        state.expect_bootp_resp <= '0';
      end if;
      if (in_stat.good_dhcp_offer = '1') then
        state.expect_dhcp_offer <= '0';
      end if;
      if (in_stat.good_dhcp_ack = '1') then
        state.expect_dhcp_ack <= '0';
      end if;

      -- Reset pending state when packets are generated.
      if (gen_stat.gen_rarp = '1') then
        state.pending_rarp <= '0';
        state.expect_rarp_resp <= '1';
      end if;
      if (gen_stat.gen_bootp = '1') then
        state.pending_bootp <= '0';
        state.expect_bootp_resp <= '1';
      end if;
      if (gen_stat.gen_dhcp_disc = '1') then
        state.pending_dhcp_disc <= '0';
        state.expect_dhcp_offer <= '1';
      end if;
      if (gen_stat.gen_dhcp_req = '1') then
        state.pending_dhcp_req <= '0';
        state.expect_dhcp_ack <= '1';
      end if;
    end if;    
  end process;

  stat <= state;

end RTL;
