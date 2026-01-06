-- Copyright (c) 2021, Haakan T. Johansson
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

entity fnet_mdio is
  port (clk              : in  std_logic;
        --
        countdebug          : out unsigned(7 downto 0);
        statedebug          : out std_logic_vector(19 downto 0) := (others => '0');
        mdc_out          : out std_logic;
        mdc_ena          : out std_logic;
        mdio_in          : in  std_logic;
        mdio_out         : out std_logic;
        mdio_ena         : out std_logic;
        --
        -- Actual request (must be held constant while pending).
        a_req_data       : in  std_logic_vector(31 downto 0);
        -- A request is pending.
        a_request        : in  std_logic;
        -- The response data.  Bits 15-0 set on read.
        -- Bit 17 set when handled, bit 16 on error (bad request).
        a_resp_data      : out std_logic_vector(17 downto 0);
        -- The request has been performed.
        a_response       : out std_logic;
        -- Second request channel, same as above.
        b_req_data       : in  std_logic_vector(31 downto 0);
        b_request        : in  std_logic;
        b_resp_data      : out std_logic_vector(17 downto 0);
        b_response       : out std_logic
        );
end fnet_mdio;

-- The request data contains the full 32 bit word of:
--
-- st, op, pa, ra, ta, data, i.e.
-- start, operation, phy-addr, reg-addr, turn-around and data.
--
-- The response contains two status bits (done and success),
-- as well as the data.

architecture RTL of fnet_mdio is

  signal a : mdio_async_state;

  signal s : mdio_state :=
    (state    => MSM_IDLE,
     active_a => '0');

  -- The second lowest two bits of the count give the output clock.
  -- The lowest bit thus 90 degree clock cycle quadrants.
  signal count : unsigned(7 downto 0) := (others => '0'); -- count [63,0]
  signal count_next : unsigned(7 downto 0);

  signal count_wrap32 : std_logic;
  signal count_wrap16 : std_logic;
  signal count_wrap2  : std_logic;

  signal ticker      : unsigned(4 downto 0) := (others => '0');
  signal ticker_next : unsigned(5 downto 0) := (others => '0');
  signal ticker_wrap : std_logic := '0';

  -- The entire request to be performed (data only on write).
  signal st_op_pa_ra_ta_data : std_logic_vector(31 downto 0);

  -- Aliases from input.
  signal st : std_logic_vector(1 downto 0);
  signal op : std_logic_vector(1 downto 0);
  signal ta : std_logic_vector(1 downto 0);

  -- Output register.
  signal ta_data : std_logic_vector(17 downto 0);

  -- Sample MDIO input signal.
  signal sample : std_logic_vector(3 downto 0);
  signal sample_is_1 : std_logic;
  signal prev_sample : std_logic;

begin

  countdebug <= count;

  -- Alias the various parts of the request.
  st <= st_op_pa_ra_ta_data(31 downto 30);
  op <= st_op_pa_ra_ta_data(29 downto 28);
  -- PA and RA and data not used to control state machine.
  ta <= st_op_pa_ra_ta_data(17 downto 16);

  ticker_next  <= ("0" & ticker) + ("" & '1');
  ticker_wrap  <= ticker_next(ticker_next'high);

  count_next   <= count - ("" & '1');
  count_wrap32 <= count_next(7) xor count(7);
  count_wrap16 <= count_next(6) xor count(6);
  count_wrap2  <= count_next(3) xor count(3);

  process(s,
          a_request, b_request,
          st, op, ta,
          count, count_wrap32, count_wrap16,
          st_op_pa_ra_ta_data)
  begin
    a <= (next_state => s.state,
          active_a   => s.active_a,
          --count      => s.count,
          do_take_request => '0',
          do_sample  => '0',
          do_done    => '0',
          do_fail    => '0',
          mdc_ena    => '0',
          mdc_out    => '0',
          mdio_ena   => '0',
          mdio_out   => '0');

    case (s.state) is
      when MSM_IDLE =>
        statedebug(3 downto 0) <= "0001";
        if (a_request = '1' or
            b_request = '1') then
          -- We take the a_request if b_request is not present,
          -- or we last handled a.
          a.active_a <= (not b_request) or (not s.active_a);
          a.do_take_request <= '1';
          a.next_state <= MSM_CHECK_REQUEST;
        end if;

      when MSM_CHECK_REQUEST =>
        statedebug(3 downto 0) <= "0010";
        -- We validate that it is a request that we can handle /
        -- that fulfills the MDIO requirements.
        if (st = "01" and
            (((op = "01") and (ta = "10")) or      -- write
             ((op = "10") and (ta = "00")))) then  -- read
          a.next_state <= MSM_PREAMBLE;
        else
          a.do_fail <= '1';
          a.next_state <= MSM_RESPOND;
        end if;

      when MSM_PREAMBLE =>
        statedebug(3 downto 0) <= "0011";
        -- We drive the clock.
        a.mdc_ena <= '1';
        a.mdc_out <= count(1) xor count(0);
        -- We send data bits.
        a.mdio_ena <= '1';
        a.mdio_out <= '1';
        if (count_wrap32 = '1') then
          a.next_state <= MSM_PERFORM;
        end if;

      when MSM_PERFORM =>
        statedebug(3 downto 0) <= "0100";
        -- We drive the clock
        a.mdc_ena <= '1';
        a.mdc_out <= count(1) xor count(0);
        -- We send data bits
        a.mdio_ena <= '1';
        a.mdio_out <= st_op_pa_ra_ta_data(to_integer(count(6 downto 2)));
        if (op = "10" and -- read
            count(5 downto 0) = "001000") then
          a.next_state <= MSM_PERFORM_READ;
        end if;
        if (count_wrap32 = '1') then
          a.next_state <= MSM_RESPOND;
          a.do_done <= '1';
        end if;

      when MSM_PERFORM_READ =>
        statedebug(3 downto 0) <= "0101";
        -- We drive the clock
        a.mdc_ena <= '1';
        a.mdc_out <= count(1) xor count(0);
        -- The data bits are sampled in the middle of the last quadrant
        if (count(1 downto 0) = "00") then
          a.do_sample <= '1';
        end if;
        if (count_wrap32 = '1') then
          a.next_state <= MSM_RESPOND;
          a.do_done <= '1';
        end if;

      when MSM_RESPOND =>
        statedebug(3 downto 0) <= "0110";
        -- Drive the respond bit.

        a.next_state <= MSM_WAIT;

      when MSM_WAIT =>
        statedebug(3 downto 0) <= "0111";
        -- The requestor has this cycle to remove the request bit.
        -- This is only one clock cycle, we are not driven by the counter.

        a.next_state <= MSM_IDLE;

    end case;
  end process;

  -- When we read a data bit, we take a majority decision on the three
  -- most recent inout readings.  We do not use sample(0), that gives
  -- one cycle of anti-metastability.
  sample_is_1 <= ((sample(1) and sample(2)) or
                  (sample(1) and sample(3)) or
                  (sample(2) and sample(3)));

  process(clk)
  begin
    if (rising_edge(clk)) then
      -- Shift the sample data.
      sample(3 downto 1) <= sample(2 downto 0);
      sample(0) <= mdio_in;

      ticker <= ticker_next(ticker'range);

      -- Normally, we are not giving a response.
      a_response <= '0';
      b_response <= '0';

      -- State machine is updated at a slow rate.
      if (ticker_wrap = '1') then
        statedebug(7 downto 4) <= "0001";
        s.state    <= a.next_state;
        s.active_a <= a.active_a;

        count      <= count_next(count'range);

        if (a.do_take_request = '1') then
          if (a.active_a = '1') then
            st_op_pa_ra_ta_data <= a_req_data;
        statedebug(7 downto 4) <= "0010";
          else
            st_op_pa_ra_ta_data <= b_req_data;
        statedebug(7 downto 4) <= "0011";
          end if;
          count <= (others => '0');
        end if;

        if (a.do_sample = '1') then
        statedebug(7 downto 4) <= "0100";
          -- Shift the read data one step.
          ta_data(15 downto 1) <= ta_data(14 downto 0);
          -- Lowest bit.
          ta_data(0) <= prev_sample;
          -- Last sample shall not be used.
          prev_sample <= sample_is_1;
        end if;

        if (a.do_fail = '1') then
        statedebug(7 downto 4) <= "0101";
          -- Mark the access as failed (17 = done, 16 = success)
          ta_data <= "10" & "00000000" & "00000000";
        end if;
        if (a.do_done = '1') then
        statedebug(7 downto 4) <= "0110";
          -- Mark the access as done (17 = done, 16 = success)
          ta_data(17 downto 16) <= "11";
          -- The data bits (15 downto 0) have already been shifted in.
        end if;

        if (a.do_fail = '1' or
            a.do_done = '1') then
        statedebug(7 downto 4) <= "0111";
          -- It is a response to one of the channels.
          a_response <=     s.active_a;
          b_response <= not s.active_a;
        end if;

        mdc_out  <= a.mdc_out;
        mdc_ena  <= a.mdc_ena;
        mdio_out <= a.mdio_out;
        mdio_ena <= a.mdio_ena;
      end if;

    end if;
  end process;

  statedebug(19) <= a.mdc_out;
  statedebug(18) <= a.mdc_ena;
  statedebug(17) <= a.mdio_out;
  statedebug(16) <= a.mdio_ena;
  statedebug(15) <= ticker_wrap;

  -- Alias the response.
  a_resp_data <= ta_data;
  b_resp_data <= ta_data;

end;


