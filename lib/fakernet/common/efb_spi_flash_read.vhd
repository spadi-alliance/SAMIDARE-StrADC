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

-- Read a given number of bits from a SPI memory.
--
-- Simple approach:
--
-- - Read single (SPI command 0x13).
-- - Read at rather slow speed, 8 clock cycles / bit => 16.6 MHz at 125 MHz,
--   i.e. 64 ns sck period.
-- - A read consist of 1+3+n bytes: 1 command, 3 address and n data bytes.
--
-- Note: there will be an o_has_data signal after the initial dummy sck
-- cycles have been sent.

entity efb_spi_flash_read is
  port (
    clk          : in  std_logic; -- Clock from board

    -- SPI interface (inputs).
    spi_sdi      : in  std_logic;
    -- SPI interface (outputs).
    spi_csn      : out std_logic := '1';
    spi_sdo      : out std_logic := '1';
    spi_wpn      : out std_logic := '1';
    spi_hldn     : out std_logic := '1';
    spi_sck      : out std_logic := '1';

    -- Start a read sequence:
    i_addr       : in  std_logic_vector(23 downto 0);
    i_start      : in  std_logic;

    -- Output data (one byte).
    o_data       : out std_logic_vector(7 downto 0) := (others => '0');
    o_has_data   : out std_logic := '0'
    );

end efb_spi_flash_read;

architecture RTL of efb_spi_flash_read is

  -- Readout sequence.  Start generating dummy read cycles without cs;
  -- his issues (dummy) sck cycles.
  signal state      : unsigned(9 downto 0) := "11" & "00000" & "000";

  -- Issue dummy sck cycles at startup (no cs).
  -- This is useful when STARTUPE2 is used.  It will eat the first
  -- three cycles and not show them on the pin.
  signal dummy_cycles : std_logic := '1';

  -- Command and address (latched) register.
  signal cmd_addr   : std_logic_vector(8+24-1 downto 0) := (others => '0');

  signal cur_cmd_addr_bit : std_logic := '0';

  -- Pipelined di samples.
  signal spi_sdi_dly1 : std_logic := '0';
  signal spi_sdi_dly2 : std_logic := '0';

  -- Result register.
  signal shift_reg  : std_logic_vector(7 downto 0) := (others => '0');
  -- Is a byte ready to be consumed by the outside.
  signal has_data   : std_logic := '0';

  -- For debugging.
  signal shift_bit : std_logic := '0';

begin

  cmd_addr(31 downto 24) <= "00000011"; -- 3 (read)

  cur_cmd_addr_bit <= cmd_addr(31 - to_integer(state(7 downto 3)));

  -- The low three bits of state just is a count of how far we are
  -- inside the sck clock cycle.  Thus we can use the highest (bit two)
  -- as sck.
  --
  -- The next five bits provide a count within the cmd_address array.
  -- It also count the data bits as they are returned.
  --
  -- The high two bits of the state tell what we are doing:
  --
  -- 00 nothing (idle),
  -- 01 start (drive cs low),
  -- 02 send command and address,
  -- 03 read bits.

  -- state 234567012345670123456701234567012345670
  --           _______         _______         ___
  -- sck   ___/       \_______/       \_______/
  --       ___________ _______________ ___________
  -- sdo   ___________X_______________X___________  Change on falling edge.
  --          _               _               _
  -- sdi   XXX_XXXXXXXXXXXXXXX_XXXXXXXXXXXXXXX_XXX  Latched on rising edge.

  process(clk)
  begin
    if (rising_edge(clk)) then
      -- Default values:
      spi_csn  <= '1';
      spi_sck  <= '0';
      spi_sdo  <= '1';
      spi_wpn  <= '1';
      spi_hldn <= '1';

      has_data <= '0';

      shift_bit <= '0';

      state <= state + 1;

      case state(9 downto 8) is
        when "00" => -- Idle.
          if (i_start = '1') then
            -- Latch address and get started!
            cmd_addr(23 downto  0) <= i_addr;
            -- Start at a well-defined location.
            -- One bit-slot before the command transmission.
            state(9 downto 8) <= "01";
          else
            -- Make sure we stay in idle state.
            state(9 downto 8) <= "00";
          end if;
          -- When we start, we do that one half bit-slot before the command
          -- transmission.  For staying in idle this does not matter.
          state(7 downto 0) <= "11111" & "100";

        when "01" => -- Start by driving CS low.
          -- Start CS in middle of cycle.  (No clock yet!)
          spi_csn <= '0';

        when "10" => -- Send command and address.
          spi_csn <= '0';
          spi_sdo <= cur_cmd_addr_bit;
          spi_sck <= state(2);

        when "11" => -- Read data bits.
          spi_csn <= dummy_cycles; -- cs is active low.
          spi_sck <= state(2);

          if (state(2 downto 0) = "111") then
            -- Two cycles after the rising sck edge is presented.
            -- Latch the data which has now been sampled twice
            -- against metastability.
            -- Shift the data into the output register, MSB first.
            shift_reg(0) <= spi_sdi_dly2;
            shift_reg(7 downto 1) <= shift_reg(6 downto 0);
            shift_bit <= '1';
          end if;

          if (state(5 downto 0) = "111" & "111") then
            -- Last cycle of last bit of byte.  Report the data.
            has_data <= '1';
            -- Go to idle state.  Low bits do not matter.
            state(9 downto 8) <= "00";
            -- No more dummy cycles.
            dummy_cycles <= '0';
          end if;

        when others =>
          null;

      end case;

      -- Sample the input data twice against metastability.
      spi_sdi_dly1 <= spi_sdi;
      spi_sdi_dly2 <= spi_sdi_dly1;
    end if;
  end process;

  o_data     <= shift_reg;
  o_has_data <= has_data;
end RTL;
