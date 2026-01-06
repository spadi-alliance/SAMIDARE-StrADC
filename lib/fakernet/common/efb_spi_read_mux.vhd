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

-- Multiplex between several SPI data requesters.

entity efb_spi_read_mux is
  port (
    clk          : in  std_logic; -- Clock from board

    o_addr       : out std_logic_vector(23 downto 0) := (others => '0');
    o_start      : out std_logic := '0';
    i_data       : in  std_logic_vector(7 downto 0);
    i_has_data   : in  std_logic;

    i_a_addr     : in  std_logic_vector(23 downto 0);
    i_a_start    : in  std_logic;
    o_a_data     : out std_logic_vector(7 downto 0) := (others => '0');
    o_a_has_data : out std_logic := '0';

    i_b_addr     : in  std_logic_vector(23 downto 0);
    i_b_start    : in  std_logic;
    o_b_data     : out std_logic_vector(7 downto 0) := (others => '0');
    o_b_has_data : out std_logic := '0'
    );

end efb_spi_read_mux;

architecture RTL of efb_spi_read_mux is
  -- Start with a as active such that it is told when the dummy cycles
  -- have finished.  The SPI reader then signals has_data.
  signal a_active : std_logic := '1';
  signal b_active : std_logic := '0';

  signal any_active : std_logic := '0';

  signal a_new_active : std_logic := '0';
  signal b_new_active : std_logic := '0';

begin
  -- Is anyone active?
  any_active <= a_active or b_active;

  -- When no-one is active, we can activate a new transfer.
  -- Port a has priority.
  a_new_active <= (not any_active) and      i_a_start;
  b_new_active <= (not any_active) and (not i_a_start) and i_b_start;

  process (clk)
  begin
    if (rising_edge(clk)) then
      -- When data got reported, then all become inactive.
      if (i_has_data = '1') then
        a_active <= '0';
        b_active <= '0';
      end if;
      -- Anyone started?
      if (a_new_active = '1') then
        a_active <= '1';
      end if;
      if (b_new_active = '1') then
        b_active <= '1';
      end if;
    end if;
  end process;

  -- Start whenever someone starts.
  o_start <= a_new_active or b_new_active;

  -- Select which address to send (is pass-through).
  o_addr <=
    i_a_addr when (a_new_active = '1') else
    i_b_addr;

  -- Data is signaled for whoever is active.
  o_a_has_data <= i_has_data and a_active;
  o_b_has_data <= i_has_data and b_active;

  -- Data is pass-through.
  o_a_data <= i_data;
  o_b_data <= i_data;
end RTL;
