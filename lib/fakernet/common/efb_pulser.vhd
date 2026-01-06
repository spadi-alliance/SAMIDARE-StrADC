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

use work.fnet_records.all; -- For word32_array.

entity efb_pulser is
  port (
    clk           : in  std_logic;
    clk_x2        : in  std_logic;
    clk_x4        : in  std_logic;
    clk_x4_90     : in  std_logic;
    -- Signals to sample.
    o_output      : out std_logic_vector;
    -- Control word.
    i_control     : in  std_logic_vector(31 downto 0);
    -- The time counter.
    i_cycle_count : in  unsigned(31 downto 0)
    );

end efb_pulser;

architecture RTL of efb_pulser is

  signal hs1_prev  : std_logic := '0';
  signal hs2_delay : unsigned(7 downto 0) := (others => '0');
  signal hs2_value : std_logic := '0';

  signal hs1_extra_delay : unsigned(7 downto 0) := (others => '0');
  signal hs1_extra_count : unsigned(3 downto 0) := (others => '0');
  signal hs1_extra_value : std_logic := '0';

  signal hs1_flip  : std_logic := '0';
  signal hs2_flip  : std_logic := '0';

begin

  process (clk)
  begin
    if (rising_edge(clk)) then
      hs1_prev <= i_cycle_count(24);

      if (hs2_delay /= 0) then
        if (hs2_delay = 1) then
          hs2_value <= not hs2_value;
        end if;
        hs2_delay <= hs2_delay - 1;
      end if;

      if (hs1_extra_count /= 0) then
        if (hs1_extra_delay = 0) then
          hs1_extra_value <= not hs1_extra_value;
          hs1_extra_count <= hs1_extra_count - 1;
          hs1_extra_delay <= unsigned(i_control(7 downto 0));
        else
          hs1_extra_delay <= hs1_extra_delay - 1;
        end if;
      end if;

      if (hs1_prev /= i_cycle_count(24)) then
        hs2_delay <= i_cycle_count(26 downto 24) & "10000";
        if (i_control(8) = '1') then
          hs1_extra_delay <= unsigned(i_control(7 downto 0));
          hs1_extra_count <= "1110";
        end if;
      end if;

      hs1_flip <= hs1_prev;
      hs2_flip <= hs2_value;
    end if;
  end process;

  o_output(0) <= hs1_flip xor hs1_extra_value;
  o_output(1) <= hs2_flip;

end RTL;

-- At 125 MHz clock, Arty A7-35T board:
--
-- With control value 0x103 (i.e. 4 between flips, so period of 8
-- cycles = 64 ns), all pulses are registered with the sampler.
--
-- With control value 0x102 (period 48 ns), about half of the short
-- pulses are lost.
--
-- Control value 0x101 (period 32 ns) gives about the same losses, and
-- and control value 0x100 (period 16 ns) looses almost all short
-- pulses.  Those that survive have the interval reported as 32 ns.
--
-- Using output slew fast (default slow) or drive 16 (default 12) had
-- no effect.
