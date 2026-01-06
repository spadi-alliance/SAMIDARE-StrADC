-- Copyright (c) 2020, Haakan T. Johansson
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.fnet_records.all;

entity ram_block_a11d16 is
  port (clk          : in  std_logic;
        porti_a      : out ram_block_porti_a11d16;
        porto_a      : in  ram_block_porto_a11d16;
        porti_b      : out ram_block_porti_a11d16;
        porto_b      : in  ram_block_porto_a11d16
        );
end ram_block_a11d16;

architecture RTL of ram_block_a11d16 is

  constant size  : integer := 2**10;
  constant width : integer := 16;

  type array_type is array(0 to size-1) of std_logic_vector(width-1 downto 0);

  signal ram : array_type := (others => (others => '0'));

  signal en_a : std_logic;
  signal en_b : std_logic;
  signal wr_a : std_logic;
  --signal wr_b : std_logic;

  -- To expose in gtkwave
  signal tmp_a_addr : std_logic_vector(9 downto 0) := (others => '0');
  signal tmp_b_addr : std_logic_vector(9 downto 0) := (others => '0');

  signal tmp_a_wdata : std_logic_vector(15 downto 0) := (others => '0');

  signal tmp_a_rdata : std_logic_vector(15 downto 0) := (others => '0');
  signal tmp_b_rdata : std_logic_vector(15 downto 0) := (others => '0');

begin

  wr_a <= porto_a.wr;
  --wr_b <= ports.port_b.wr;

  en_a <= porto_a.rd or porto_a.wr;
  en_b <= porto_b.rd or porto_b.wr;

  -- For gtkwave debug:
  tmp_a_addr  <= porto_a.addr;
  tmp_b_addr  <= porto_b.addr;
  tmp_a_wdata <= porto_a.wdata;

  process(clk)
  begin
    if (rising_edge(clk)) then
      -- tmp_a_rdata <= (others => '0');
      -- Read before write
      if (en_a = '1') then
        tmp_a_rdata <= ram(conv_integer(tmp_a_addr));
        if (wr_a = '1') then
          ram(conv_integer(tmp_a_addr)) <= tmp_a_wdata;
        end if;
      end if;
    end if;
  end process;

  porti_a.rdata <= tmp_a_rdata;

  process(clk)
  begin
    if (rising_edge(clk)) then
      -- tmp_b_rdata <= (others => '0');
      if (en_b = '1') then
        tmp_b_rdata <= ram(conv_integer(tmp_b_addr));
        --if (wr_b = '1') then
        --  ram(conv_integer(tmp_b_addr)) <= tmp_b_wdata;
        --end if;
      end if;
    end if;
  end process;

  porti_b.rdata <= tmp_b_rdata;

end RTL;
