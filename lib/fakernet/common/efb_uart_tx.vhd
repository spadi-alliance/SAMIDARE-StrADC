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

-- use work.fnet_util_pkg.all;

entity efb_uart_tx is
  port (
    clk          : in  std_logic; -- Clock from board
    -- Bit period (actually, +1 used, so give value -1).
    i_bit_period : in  std_logic_vector;
    -- Input signals.
    i_data       : in  std_logic_vector(7 downto 0);
    i_has_data   : in  std_logic;
    -- Output signals.
    o_taken      : out std_logic := '0';
    o_tx         : out std_logic := '0'
    );

end efb_uart_tx;

architecture RTL of efb_uart_tx is

  -- Number of bits needed for counter.
  constant count_len : integer := i_bit_period'length;

  -- Fast counter.  When it wraps, we switch to next bit.
  signal count      : unsigned(count_len-1 downto 0) := (others => '0');
  signal count_next : unsigned(count_len   downto 0) := (others => '0');

  -- Counter of which bit is being processed.
  signal slot       : unsigned(3 downto 0) := (others => '0');
  signal slot_next  : unsigned(3 downto 0) := (others => '0');

  -- Latched data, to be sent.
  signal data       : std_logic_vector(7 downto 0) := (others => '0');
  signal sending    : std_logic := '0';
  -- Did we just latch the data.
  signal taken      : std_logic := '0';

  -- Current bit value to be sent.
  signal value      : std_logic := '0';
  signal send       : std_logic := '0';

begin

  -- Update fast counter.
  count_next <= ("0" & count) - 1;

  -- Bit counter is updated with wrap bit of fast counter.
  slot_next <= slot + ("" & count_next(count_next'high));

  -- What bit to send?  0:1, 1-8:data, 9:0
  value <= '0' when ((to_integer(slot) > 8) or
                     (sending = '0')) else
           '1' when (to_integer(slot) = 0) else
           not data(to_integer(slot-1));

  process(clk)
  begin
    if (rising_edge(clk)) then
      -- Update counter values.
      if (count_next(count_next'high) = '1') then
        -- Wrapped.
        count <= unsigned(i_bit_period);
      else
        count <= count_next(count'range);
      end if;

      -- Default.
      taken <= '0';

      -- Only count as many slots as we have.
      if (to_integer(slot_next) = 11) then
        slot <= (others => '0');

        -- Latch the new data.
        sending <= i_has_data;
        data    <= i_data;

        -- We took data if there was data or not.
        -- This way this signal can be used to make progress.
        taken <= '1';
      else
        slot <= slot_next;
      end if;

      -- Always pick the bit value to transmit.
      send <= value;
    end if;
  end process;

  -- Alias to output variables.
  o_taken <= taken;
  o_tx    <= send;

end RTL;
