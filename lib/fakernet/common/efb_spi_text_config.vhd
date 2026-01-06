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

entity efb_spi_text_config is
  port (
    clk            : in  std_logic; -- Clock from board

    i_base_addr    : in  std_logic_vector(23 downto 0);

    -- SPI read interface.
    o_spi_addr     : out std_logic_vector(23 downto 0);
    o_spi_start    : out std_logic;
    i_spi_data     : in  std_logic_vector(7 downto 0) := (others => '0');
    i_spi_has_data : in  std_logic := '0';

    -- Output value (one at a time).
    o_value        : out std_logic_vector(47 downto 0) := (others => '0');
    o_value_index  : out std_logic_vector( 8 downto 0) := (others => '0');
    o_has_value    : out std_logic := '0';
    -- Overall completion status.
    o_done         : out std_logic := '0';
    o_fail         : out std_logic := '0';
    o_fail_offset  : out std_logic_vector( 9 downto 0) := (others => '0');
    o_fail_code    : out std_logic_vector( 3 downto 0) := (others => '0');
    -- Debug output.
    o_dbg_reset_parse   : out std_logic := '0';
    o_dbg_active        : out std_logic := '0';
    o_dbg_has_data_pend : out std_logic := '0';
    o_dbg_state_code    : out std_logic_vector( 4 downto 0) := (others => '0')
    );

end efb_spi_text_config;

-- Drive the text configuration parser by requesting character (byte)
-- reads from SPI flash and sending them to the parser.
--
-- TODO: continuous reads, i.e. make SPI reader able to deliver further
-- characters without starting a new transaction.

architecture RTL of efb_spi_text_config is

  type st_state is (ST_WAIT_START,
                    ST_SPI_DUMMY_REQUEST_CHAR,
                    ST_SPI_DUMMY_WAIT_CHAR,
                    ST_PARSE_WAIT_REQUEST_CHAR,
                    ST_SPI_WAIT_CHAR,
                    ST_DONE);

  signal state        : st_state := ST_WAIT_START;

  -- Keep track of active state, and reset.
  -- (Only one of them would be enough.)
  signal active       : std_logic := '0';
  signal reset_parse  : std_logic := '0';

  -- Data is available, and we are active.
  signal has_data_active : std_logic := '0';

  -- The next address to read SPI at.
  signal next_address : unsigned(23 downto 0) := (others => '0');

  -- Tell SPI to do a read.
  signal spi_start    : std_logic := '0';

  -- Parser wants another character.
  signal want_char    : std_logic := '0';

  -- Parser is done.
  signal done         : std_logic := '0';

begin

  has_data_active <= i_spi_has_data and active;

  parser: entity work.efb_text_config_parse
    port map (
      clk           => clk,

      i_reset_parse => reset_parse,
      i_data        => i_spi_data,
      i_has_data    => has_data_active,

      o_value       => o_value,
      o_value_index => o_value_index,
      o_has_value   => o_has_value,

      o_wait_char   => want_char,

      o_done        => done,
      o_fail        => o_fail,
      o_fail_code   => o_fail_code,

      o_dbg_has_data_pend => o_dbg_has_data_pend,
      o_dbg_state_code    => o_dbg_state_code);

  process (clk)
  begin
    if (rising_edge(clk)) then
      reset_parse <= '0';
      spi_start <= '0';

      case state is
        when ST_WAIT_START =>
          -- Wait for the SPI reader to finish its startup generation
          -- of dummy sck cycles.
          if (i_spi_has_data = '1') then
            -- Initialise the address.
            next_address <= unsigned(i_base_addr);
            -- First we issue a dummy read to SPI.
            state <= ST_SPI_DUMMY_REQUEST_CHAR;
          end if;

          -- Seems some SPI flash memory does not do the first read
          -- correctly, so we issue a dummy read first.
          -- Problem could be elsewhere, but this helps for the
          -- AX516 board.
        when ST_SPI_DUMMY_REQUEST_CHAR =>
          spi_start <= '1';
          state <= ST_SPI_DUMMY_WAIT_CHAR;

        when ST_SPI_DUMMY_WAIT_CHAR =>
          -- Wait until the SPI reader provides the character.
          if (i_spi_has_data = '1') then
            -- Go live.
            reset_parse <= '1';
            active <= '1';
            -- Start the actual reads!
            state <= ST_PARSE_WAIT_REQUEST_CHAR;
          end if;

        when ST_PARSE_WAIT_REQUEST_CHAR =>
          -- Wait until parser requests a new character.
          if (want_char = '1') then
            spi_start <= '1';
            state <= ST_SPI_WAIT_CHAR;
          end if;

          if (done = '1') then
            state <= ST_DONE;
          end if;

        when ST_SPI_WAIT_CHAR =>
          -- Wait until the SPI reader provides the character.
          -- (The parser listens to this signal directly also.)
          if (i_spi_has_data = '1') then
            state <= ST_PARSE_WAIT_REQUEST_CHAR;
            -- Update the address.
            next_address <= next_address + 1;
          end if;

        when ST_DONE =>
          -- We are done!
          null;
      end case;

    end if;
  end process;

  -- Towards SPI reader.
  o_spi_start <= spi_start;
  o_spi_addr  <= std_logic_vector(next_address);

  -- Towards outside.
  o_done <= done;

  o_dbg_reset_parse <= reset_parse;
  o_dbg_active      <= active;

end RTL;
