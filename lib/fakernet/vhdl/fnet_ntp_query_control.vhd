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

entity fnet_ntp_query_control is
  port (clk          : in  std_logic;
        --
        cfg_gen_ntpq : in  std_logic;
        --
        ntpq_req     : in  std_logic;
        ntpq_mac     : in  std_logic_vector(47 downto 0);
        ntpq_ip      : in  std_logic_vector(31 downto 0);
        ntpq_tm_hi   : in  std_logic_vector(31 downto 0) := (others => '0');
        ntpq_tm_lo   : out std_logic_vector(31 downto 0);
        ntpq_sent    : out std_logic;
        --
        in_stat      : in  dync_in_stat;
        gen_stat     : in  dync_gen_stat;
        --
        stat         : out ntpq_control_stat;
        --
        timeout_tick : in std_logic
        );
end fnet_ntp_query_control;

-- Interval counting note.  Inprinciple, we could count the time
-- between packets form the actual transmission.  But this is more
-- complicated.  Instead we just count time from whenever we set the
-- pending requests.  This does not matter, since the time counting is
-- just for control purposes.  Does not affect the precision of the
-- measurements.

architecture RTL of fnet_ntp_query_control is

  signal state : ntpq_control_stat := (pending_ntp_query   => '0',
                                       block_non_ntpq      => '0',
                                       ntpq_mac => (others => '0'),
                                       ntpq_ip  => (others => '0'),
                                       ntpq_tm  => (others => '0'));

  -- Mark when the query has been transmitted (and actual time(clks) latched).
  signal ntpq_sent_mark : std_logic := '0';

  -- Count of number of queries sent.
  signal query_count : unsigned(15 downto 0) := (others => '0');

  -- Number of clock cycles used for first query.
  -- (We allow at most ~10 ms, which is 1000000 at 100 MHz, 20 bits).
  signal response_clks : unsigned(19 downto 0) := (others => '0');

  -- Number of clock cycles to wait until sending next query.
  -- (Divided by 2 each time.)
  signal next_wait_clks : unsigned(19 downto 0) := (others => '0');

  -- Number of clock cycles remaining in current wait period.
  signal cur_wait_clks : unsigned(19 downto 0) := (others => '0');

  -- Do we want to send more requests.
  signal more_requests : std_logic := '0';

  -- Are we waiting for the first response.
  signal first_wait : std_logic := '0';

  -- Are we waiting for the final response(s).
  signal final_wait : std_logic := '0';

begin

  state.ntpq_mac <= ntpq_mac;
  state.ntpq_ip  <= ntpq_ip;
  state.ntpq_tm(63 downto 32) <= ntpq_tm_hi;
  state.ntpq_tm(31 downto 16) <= (others => '0');
  state.ntpq_tm(15 downto  0) <= std_logic_vector(query_count);

  process(clk)
  begin
    if (rising_edge(clk)) then

      -- Count time until first response.
      response_clks <= response_clks + ("" & first_wait);
      cur_wait_clks <= cur_wait_clks - 1;

      if (cfg_gen_ntpq = '1') then
        if (ntpq_req = '1') then
          -- Issue first query.
          state.pending_ntp_query <= '1';
          -- Start counting time until response.  (Start at 1).
          response_clks <= (0 => '1', others => '0');
          -- We want to send more requests.
          more_requests <= '1';
          -- We are waiting for the first response.
          first_wait <= '1';
        end if;
      end if;

      if (to_integer(cur_wait_clks) = 0) then
        final_wait <= '0';
      end if;

      if (more_requests = '1') then
        -- TODO: good_ntpr needs to check that the packet was for us,
        -- e.g. by validating some part of the TM value
        if (in_stat.good_ntpr = '1') then
          if (first_wait = '1') then
            -- We have received the first response.
            first_wait <= '0';
            -- Issue another request.
            state.pending_ntp_query <= '1';
            -- Send next request after same time.
            next_wait_clks <=
              "00" & response_clks(response_clks'left downto 2);
            cur_wait_clks  <=
              "0"  & response_clks(response_clks'left downto 1);
          end if;
        end if;

        if (first_wait = '0' and
            to_integer(cur_wait_clks) = 0) then
          -- We have a timeout to send next request.
          if (state.pending_ntp_query = '1') then
            -- We did not yet manage to send previous request,
            -- so we are now trying too often.  Give up.
            more_requests <= '0';
            -- Do the final wait where we block transmissions.
            final_wait <= '1';
            -- Final wait is as long as it took to get the first response.
            cur_wait_clks <= response_clks;
          else
            -- Issue another request.
            state.pending_ntp_query <= '1';
            -- Reduce the time to wait until next request.
            -- New timeout = 3/4 previous timeout.
            next_wait_clks <=
              next_wait_clks -
              ("00" & next_wait_clks(next_wait_clks'left downto 2));
            cur_wait_clks  <= next_wait_clks;
          end if;
        end if;
      end if;

      if (first_wait = '1' and
          to_integer(response_clks) = 0) then
        -- Counter of time until response overflowed.  Give up.
        more_requests <= '0';
      end if;

      -- Reset pending state when packets have been generated (and sent!).
      if (gen_stat.gen_ntp_query = '1') then
        state.pending_ntp_query <= '0';
      end if;
      -- Report to logging that query was sent after transmission
      -- (such that transmission time has been latched).
      ntpq_sent_mark <= gen_stat.gen_ntp_query;

      -- Count the query one cycle later, such that value is updated
      -- after monitoring data sent (latched outside by ntpq_sent).
      query_count <= query_count + ("" & ntpq_sent_mark);
    end if;
  end process;

  state.block_non_ntpq <= more_requests or final_wait;

  stat <= state;
  ntpq_tm_lo <= state.ntpq_tm(31 downto 0);
  ntpq_sent <= ntpq_sent_mark;

end RTL;
