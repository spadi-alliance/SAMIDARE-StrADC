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

use work.fnet_util_pkg.all;

entity efb_uart_trace_mem is
  generic(
    width   : integer;
    samples : integer
    );
  port (
    clk        : in  std_logic; -- Clock from board
    -- Input signals.
    i_signals  : in  std_logic_vector(width-1 downto 0);
    i_insert   : in  std_logic;
    i_trigger  : in  std_logic;
    -- Data output interface.
    o_data     : out std_logic_vector(7 downto 0) := (others => '0');
    i_taken    : in  std_logic
    );

end efb_uart_trace_mem;

architecture RTL of efb_uart_trace_mem is

  constant addr_bits  : integer := fnet_log2(samples-1)+1;
  constant width_bits : integer := fnet_log2(width-1)+1;

  -- Decouple from input.
  signal signals    : std_logic_vector(i_signals'range) := (others => '0');
  signal insert     : std_logic := '0';
  signal trigger    : std_logic := '0';

  signal write_addr : unsigned(addr_bits-1 downto 0) := (others => '0');
  signal towrite    : unsigned(addr_bits-1 downto 0) := (others => '0');
  signal triggered  : std_logic := '0';
  signal writing    : std_logic := '1';

  signal read_offset      : unsigned(addr_bits+3-1 downto 0) :=
    (others => '0');
  signal read_offset_next : unsigned(addr_bits+3   downto 0) :=
    (others => '0');

  signal read_addr      : unsigned(addr_bits+3-1 downto 0) :=
    (others => '0');


  signal read_addr_row  : unsigned(addr_bits-1   downto 0) := (others => '0');
  signal read_addr_col  : unsigned(3-1           downto 0) := (others => '0');

  signal read_addr2_row : unsigned(addr_bits-1   downto 0) := (others => '0');
  signal read_addr2_col : unsigned(3-1           downto 0) := (others => '0');

  type array_type is
    array(0 to samples-1) of std_logic_vector(width-1 downto 0);
  signal ram : array_type := (others => (others => '0'));

  signal read_data_line : std_logic_vector(width-1 downto 0);
  signal read_data_wide : std_logic_vector(55 downto 0);
  signal read_data_expand : std_logic_vector(63 downto 0) := (others => '0');
  signal read_data_pick : std_logic := '1';
  signal read_data      : std_logic_vector(7 downto 0);

  signal read_addr2_low_zero : std_logic := '1';

begin

  read_offset_next <= ("0" & read_offset) + 1;

  read_addr_row <= read_addr(addr_bits+3-1 downto 3);
  read_addr_col <= read_addr(3-1           downto 0);

  read_data_wide(55) <= '0'; -- Mark for non-idle
  read_data_wide(54) <= '1'; -- Mark for trace dump
  read_data_wide(53 downto 32+addr_bits) <= (others => '0');
  read_data_wide(32+addr_bits-1 downto 32) <=
    std_logic_vector(read_addr2_row);
  read_data_wide(31 downto 0) <= read_data_line;

  rde: for i in 0 to 7 generate
    read_data_expand(i*8+6 downto i*8) <=
      read_data_wide(i*7+6 downto i*7);
  end generate;

  read_addr2_low_zero <=
    '1' when (to_integer(read_addr2_col) = 0) else '0';

  process(clk)
  begin
    if (rising_edge(clk)) then

      signals <= i_signals;
      insert  <= i_insert;
      trigger <= i_trigger;

      if (writing = '1' and
          insert = '1') then
        if (triggered = '1' and
            to_integer(towrite) = 0) then
          writing <= '0';
        end if;
        towrite <= towrite - 1;
        write_addr <= write_addr + 1;
      end if;

      if (trigger = '1' and
          triggered = '0') then
        triggered <= '1';
        towrite <= to_unsigned(samples/2, towrite'length);
      end if;

      read_data_pick <= '0';

      if (i_taken = '1') then
        if (writing = '1') then
          read_data <= "11111111"; -- IDLE pattern
        else
          -- Prepare the next address.
          read_offset <= read_offset_next(read_offset'range);

          -- Reading stops when we wrap.
          if (read_offset_next(read_offset_next'left) = '1') then
            -- We have sent all data, wait for the next trigger.
            writing <= '1';
            triggered <= '0';
          end if;

          -- In the next cycle, pick data from what was read in this
          -- cycle.  Note that the addition of offset and write
          -- pointer make it even the address as of previous cycle,
          -- which will be the same (offset updates above are many
          -- cycles apart).
          read_data_pick <= '1';
        end if;
      end if;

      -- Precalculate the read address.
      read_addr <= read_offset + (write_addr & "000");

      -- Read from the current location (wide).
      read_data_line <= ram(to_integer(read_addr_row));
      read_addr2_row <= read_addr_row;
      read_addr2_col <= read_addr_col;

      if (read_data_pick = '1') then
        -- Get our piece (one cycle later).
        -- Is ok, since the UART will take much more time from the
        -- cycle it reports taken, until it takes next word.
        read_data <=
          read_addr2_low_zero &
          read_data_expand((7-to_integer(read_addr2_col))*8+7-1 downto
                           (7-to_integer(read_addr2_col))*8);
      end if;

      -- Update RAM while we are writing.
      if (writing = '1') then
        ram(to_integer(write_addr)) <= signals;
      end if;

    end if;
  end process;

  -- Alias to output variables.
  o_data <= read_data;

end RTL;
