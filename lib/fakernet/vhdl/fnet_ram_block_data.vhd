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

-- Note: addrbits applies to bytes, so goes downto 2

-- TODO: split storage into byte blocks, to have less (implicit)
-- multiplexers for output data.

-- TODO: combine with other data RAM blocks?  Wrappers?

-- TODO: parity calculations.  For output, parity should be handled
-- with a delay of one, since it is not urgent.

entity fnet_ram_block_data is
  generic (addrbits  : natural;
           databits  : natural := 32);
  port (clk          : in  std_logic;

        port_a_addr  : in  std_logic_vector(addrbits-1 downto 0);
        port_a_rd    : in  std_logic;
        port_a_wr    : in  std_logic;
        port_a_wdata : in  std_logic_vector(databits-1 downto 0);
        port_a_rdata : out std_logic_vector(databits-1 downto 0);

        port_b_addr  : in  std_logic_vector(addrbits-1 downto 0);
        port_b_rd    : in  std_logic;
        port_b_rdata : out std_logic_vector(databits-1 downto 0)
        );
end fnet_ram_block_data;

architecture RTL of fnet_ram_block_data is

  constant size : integer := 2**(addrbits);

  type array_type is array(0 to size-1) of
    std_logic_vector(databits-1 downto 0);

  signal ram : array_type := (others => (others => '0'));

  signal en_a : std_logic;
  signal en_b : std_logic;
  signal wr_a : std_logic;

  -- To expose in gtkwave (not really needed here since it is actual ports).
  signal tmp_a_addr : std_logic_vector(addrbits-1 downto 0) := (others => '0');
  signal tmp_b_addr : std_logic_vector(addrbits-1 downto 0) := (others => '0');

  signal tmp_a_wdata : std_logic_vector(databits-1 downto 0) := (others => '0');

  signal tmp_a_rdata : std_logic_vector(databits-1 downto 0) := (others => '0');
  signal tmp_b_rdata : std_logic_vector(databits-1 downto 0) := (others => '0');

begin

  wr_a <= port_a_wr;

  en_a <= port_a_wr or port_a_rd;
  en_b <=              port_b_rd;

  -- For gtkwave debug:
  tmp_a_addr <= port_a_addr;
  tmp_b_addr <= port_b_addr;
  tmp_a_wdata <= port_a_wdata;

  process(clk)
  begin
    if (rising_edge(clk)) then
      -- Read before write
      -- tmp_a_rdata <= (others => '0');
      if (en_a = '1') then
        tmp_a_rdata <= ram(conv_integer(tmp_a_addr));
        if (wr_a = '1') then
          ram(conv_integer(tmp_a_addr)) <= tmp_a_wdata;
        end if;
      end if;
    end if;
  end process;

  port_a_rdata <= tmp_a_rdata;

  process(clk)
  begin
    if (rising_edge(clk)) then
      -- tmp_b_rdata <= (others => '0');
      if (en_b = '1') then
        tmp_b_rdata <= ram(conv_integer(tmp_b_addr));
      end if;
    end if;
  end process;

  port_b_rdata <= tmp_b_rdata;

end RTL;
