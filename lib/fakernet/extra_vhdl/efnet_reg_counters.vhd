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

use work.fnet_records.all;
use work.fnet_util_pkg.all;

entity efnet_reg_counters is
  generic(
    base_wr_regs  : natural := 0;
    base_rd_regs  : natural := 0;
    base_counters : natural := 0
    );
  port (
    clk            : in  std_logic;
    --
    reg_addr       : in  std_logic_vector(24 downto 0);
    reg_data_wr    : in  std_logic_vector(31 downto 0);
    reg_data_rd    : out std_logic_vector(31 downto 0) := (others=>'0');
    reg_write      : in  std_logic;
    reg_read       : in  std_logic;
    reg_done       : out std_logic;
    reg_cnt        : in  std_logic_vector(3 downto 0);
    --
    wr_regs        : out word32_array;
    wr_regs_strobe : out std_logic_vector;
    rd_regs        : in  word32_array;
    counters       : in  std_logic_vector
    );

end efnet_reg_counters;

architecture RTL of efnet_reg_counters is

  constant num_wr_regs  : natural := wr_regs'length;
  constant num_rd_regs  : natural := rd_regs'length;
  constant num_counters : natural := counters'length;

  constant bits_wr_regs  : natural := fnet_log2(num_wr_regs -1)+1;
  constant bits_rd_regs  : natural := fnet_log2(num_rd_regs -1)+1;
  constant bits_counters : natural := fnet_log2(num_counters-1)+1;

  constant addr_base_wr_regs : std_logic_vector(reg_addr'range) :=
    std_logic_vector(to_unsigned(base_wr_regs, reg_addr'length));
  constant addr_base_rd_regs : std_logic_vector(reg_addr'range) :=
    std_logic_vector(to_unsigned(base_rd_regs, reg_addr'length));

  signal wr_regs_array : word32_array(wr_regs'range) :=
    (others => (others => '0'));

begin

  process (clk)
  begin
    if (rising_edge(clk)) then
      -- Default: no register access.
      reg_data_rd <= (others => '0');
      reg_done <= '0';

      -- Default: no strobe.
      wr_regs_strobe <= (others => '0');

      -- Write to setup registers.
      for i in 0 to num_wr_regs-1 loop
        if (reg_write = '1' and
            reg_addr(reg_addr'high downto bits_wr_regs) =
            addr_base_wr_regs(reg_addr'high downto bits_wr_regs) and
            to_integer(unsigned(reg_addr(bits_wr_regs-1 downto 0))) = i) then
          wr_regs_array(i) <= reg_data_wr;
          wr_regs_strobe(i) <= '1';
          reg_done <= '1';
        end if;
      end loop;

      -- Readback should be from a RAM block instead.
      -- Cheaper than a big multiplxer.
      if (reg_read = '1' and
          reg_addr(reg_addr'high downto bits_wr_regs) =
          addr_base_wr_regs(reg_addr'high downto bits_wr_regs)) then
        reg_data_rd <=
          wr_regs_array(to_integer(unsigned(reg_addr(bits_wr_regs-1 downto
                                                     0))));
        reg_done <= '1';
      end if;

      -- Read an info/status word.
      if (reg_read = '1' and
          reg_addr(reg_addr'high downto bits_rd_regs) =
          addr_base_rd_regs(reg_addr'high downto bits_rd_regs)) then
        reg_data_rd <=
          rd_regs(to_integer(unsigned(reg_addr(bits_rd_regs-1 downto 0))));
        reg_done <= '1';
      end if;

    end if;
  end process;

  wr_regs <= wr_regs_array;

end RTL;
