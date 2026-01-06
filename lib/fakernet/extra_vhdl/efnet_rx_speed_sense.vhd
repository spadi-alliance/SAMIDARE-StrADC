-- Copyright (c) 2023, Haakan T. Johansson
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

use work.fnet_util_pkg.all;

entity efnet_rx_speed_sense is
  generic (clk_freq : integer);
  port (
    -- Clock from board, must be at least 63 MHz.
    clk         : in  std_logic;
    -- RC clock from PHY.
    eth_rx_clk  : in  std_logic;
    -- Determined speed.
    o_mode_gmii : out std_logic := '0'
  );

end efnet_rx_speed_sense;

-- To determine if we are in 1000 or 100/10-mode, a bit toggling by
-- the RX clock is generated.  This is counted by the system clock.
--
-- In gigabit mode, it gives 125/16 = 15.625 MHz.
-- In 100-mode, it would toggle at 25/16 = 3.125 MHz.
--
-- The mode is considered as 1000 if more than 8 toggles are counted
-- within n system cycles.

architecture RTL of efnet_rx_speed_sense is

  -- Breakpoint speed is set to 50 MHz.

  -- How many system clock cycles are needed to see 4 flips at a speed
  -- of ~50 MHz?
  constant clk_cycles_check : integer := clk_freq / (50000000 / 8 / 4);

  constant clk_counter_bits : integer := fnet_log2(clk_cycles_check-1)+1;

  -- Count 0 to 15, flips every 8 cycles.
  signal toggle_counter : unsigned(3 downto 0) := (others => '0');

  signal buf1_toggle : std_logic := '0';
  signal buf2_toggle : std_logic := '0';
  signal buf3_toggle : std_logic := '0';

  signal toggle_prev : std_logic := '0';

  signal toggle_flip : std_logic := '0';

  signal clk_toggle_counter      : unsigned(1 downto 0) := (others => '0');
  signal clk_toggle_counter_next : unsigned(2 downto 0) := (others => '0');

  signal clk_toggle_overflow : std_logic := '0';

  signal clk_counter      : unsigned(clk_counter_bits-1 downto 0) :=
    (others => '0');
  signal clk_counter_next : unsigned(clk_counter'high + 1 downto 0) :=
    (others => '0');

  signal clk_speed1000 : std_logic := '0';
  
begin

  -- Generate media speed indicator.
  process (eth_rx_clk)
  begin
    if (rising_edge(eth_rx_clk)) then
      toggle_counter <= toggle_counter + 1;
    end if;
  end process;

  toggle_flip <= buf3_toggle xor toggle_prev;

  clk_toggle_counter_next <=
    ('0' & clk_toggle_counter) + ("" & toggle_flip);

  clk_counter_next <=
    ('0' & clk_counter) - 1;

  -- Detection of media speed.
  process (clk)
  begin
    if (rising_edge(clk)) then
      -- First latch into (system) clk domain.
      buf1_toggle <= toggle_counter(3);
      -- Second and third latches.
      buf2_toggle <= buf1_toggle;
      buf3_toggle <= buf2_toggle;
      -- Value in previous cycle.
      toggle_prev <= buf3_toggle;
      -- Counter in the system domain.
      clk_toggle_counter <=
        clk_toggle_counter_next(clk_toggle_counter'range);
      -- Did the counter overflow (i.e. count at least 8)
      clk_toggle_overflow <= clk_toggle_overflow or
        clk_toggle_counter_next(clk_toggle_counter_next'high);
      -- Counter of system domain cycles.
      clk_counter <= clk_counter_next(clk_counter'range);

      -- The the system counter wraps below 0, we check if we had an
      -- overflow in the toggle counter.  If so, it was counting fast.
      if (clk_counter_next(clk_counter_next'high) = '1') then
        clk_speed1000 <= clk_toggle_overflow;
        -- Reset counters.
        clk_toggle_counter  <= (others => '0');
        clk_toggle_overflow <= '0';

        clk_counter <= to_unsigned(clk_cycles_check-1, clk_counter'length);
      end if;
    end if;
  end process;

  -- Note: this is generated in the clk domain.
  o_mode_gmii <= clk_speed1000;

end RTL;
