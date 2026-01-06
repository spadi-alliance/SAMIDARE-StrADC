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

-- use work.fnet_util_pkg.all;

entity efb_uart_rx is
  port (
    clk          : in  std_logic; -- Clock from board
    -- Bit period (actually, +1 used, so give value -1).
    i_bit_period : in  std_logic_vector;
    -- Input signals.
    i_rx         : in  std_logic;
    -- Output signals.
    o_data       : out std_logic_vector(7 downto 0) := (others => '0');
    o_has_data   : out std_logic := '0'
    );

end efb_uart_rx;

architecture RTL of efb_uart_rx is

  -- Number of bits needed for counter.
  constant count_len : integer := i_bit_period'length;

  -- Fast counter.  When it wraps, we switch to next bit.
  signal count      : unsigned(count_len-1 downto 0) := (others => '0');
  signal count_next : unsigned(count_len   downto 0) := (others => '0');

  -- Over-sample counter.  When it wraps, take next sample.
  signal count_sample      : unsigned(count_len-4-1 downto 0) := (others=>'0');
  signal count_sample_next : unsigned(count_len-4   downto 0) := (others=>'0');

  -- Counter of which bit is being processed.
  signal slot       : unsigned(3 downto 0) := (others => '0');
  signal slot_next  : unsigned(3 downto 0) := (others => '0');

  -- Over-sample control.
  signal do_sample  : std_logic_vector(1 downto 0) := "00";

  -- Input pipeline - for anti-metastability, and rising-edge detection.
  signal input_pipe : std_logic_vector(4 downto 1) := (others => '0');

  -- Signals received for oversampling.
  signal sample0    : std_logic := '0';
  signal sample1    : std_logic := '0';

  -- Majority decision for multiple samples.
  signal majority   : std_logic := '0';

  -- Rising-egde detection.
  signal input_rising_edge : std_logic := '0';

  -- Data being received.
  signal data       : std_logic_vector(7 downto 0) := (others => '0');
  -- Did we just complete the data.
  signal has_data   : std_logic := '0';
  -- Reception in progress.
  signal receiving  : std_logic := '0';

begin

  -- Update fast counter.
  count_next <= ("0" & count) - 1;

  -- Update sample counter.
  count_sample_next <= ("0" & count_sample) - 1;

  -- Bit counter is updated with wrap bit of fast counter.
  slot_next <= slot + ("" & count_next(count_next'high));

  -- Majority of three input samples.
  -- If any two agree on '1', it is '1'; otherwise '0'.
  majority <=
    (sample0 and sample1) or
    (sample0 and input_pipe(2)) or
    (sample1 and input_pipe(2));

  -- input_pipe(4) is two cycles older than input_pipe(2), i.e. still '0'
  -- if rising edge.
  input_rising_edge <= input_pipe(2) and input_pipe(3) and not input_pipe(4);

  process(clk)
  begin
    if (rising_edge(clk)) then
      -- For anti-metastability, pipeline the input data.
      input_pipe <= input_pipe(3 downto 1) & i_rx;

      -- Update counter values.
      if (count_next(count_next'high) = '1') then
        -- Wrapped.
        count <= unsigned(i_bit_period);
      else
        count <= count_next(count'range);
      end if;

      -- The slot-counter can be unconditionally updated.
      slot <= slot_next;

      -- Unless restarted below.
      count_sample <= count_sample_next(count_sample'range);

      -- Default, no data.
      has_data <= '0';

      -- During normal processing, we sample a bit three times, at
      -- 0.5, 0.5625, 0.625, i.e. 0.5, 0.5+1/16, 0.5+1/8

      if (count_next(count_next'high) = '1') then
        -- Note slot 0 is the start bit, so will be discarded.
        -- Always take samples.  If they are used is another matter.

        -- Start sampling procedure, take first sample.
        sample0 <= input_pipe(2);
        -- Bit period divided by 16 give the sample distance 0.0625.
        count_sample <= unsigned(i_bit_period(i_bit_period'left downto 4));
        -- Take two more samples.
        do_sample <= "10";

        -- Note: slot is updated this cycle, so for start bit it is 0,
        -- for first bit, it is 1, etc...

        -- When we are about to sample the 9th bit (i.e. are at mid-9,
        -- which is either parity bit (if present), or stop bit), then
        -- the 8th slot has been sampled (it was sampled 1/8th period
        -- after mid-8.
        if (to_integer(slot) = 9) then
          has_data <= receiving;
          receiving <= '0';
        end if;
      end if;

      if (count_sample_next(count_sample_next'high) = '1') then
        -- Restart counter.
        count_sample <= unsigned(i_bit_period(i_bit_period'left downto 4));
        -- Should we take second sample?
        if (do_sample = "10") then
          sample1 <= input_pipe(2);
          do_sample <= "01";
        end if;
        -- Third and final sample is directly used.
        if (do_sample = "01") then
          -- Shift data down (least significant bit first).
          data(6 downto 0) <= data(7 downto 1);
          -- Pick data value.
          data(7) <= not majority;
          -- No further samples.
          do_sample <= "00";
        end if;
      end if;

      -- Whenever we are not receiving, and see a rising edge,
      -- we start a receive cycle.
      if (receiving = '0' and
          input_rising_edge = '1') then
        -- We first count half the bit_period, to get into mid bit-slot.
        count <= '0' & unsigned(i_bit_period(i_bit_period'left downto 1));
        slot <= (others => '0');
        receiving <= '1';
      end if;

    end if;
  end process;

  -- Alias to output variables.
  o_data     <= data;
  o_has_data <= has_data;

end RTL;
