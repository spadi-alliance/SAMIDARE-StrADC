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

entity fnet_ram_block_stat is
  port (clk          : in  std_logic;
        stat         : out ram_stat_block;
        prod         : in  ram_prod_block;
        prod2        : in  ram_prod2_block;
        cons         : in  ram_cons_block
        );
end fnet_ram_block_stat;

architecture RTL of fnet_ram_block_stat is

  signal s_stat : ram_stat_block :=
    (hasdata   => '0',
     broadcast => '0',
     drop_dly  => '0',
     words     => (others => '0'));

  signal tmp_set_hasdata   : std_logic;
  signal tmp_set_broadcast : std_logic;
  signal tmp_set_drop_dly  : std_logic;
  signal tmp_set_again     : std_logic;
  signal tmp_clear_hasdata : std_logic;
  signal tmp_hasdata       : std_logic;

begin

  tmp_set_hasdata   <= prod.set_hasdata;
  tmp_set_broadcast <= prod.set_broadcast;
  tmp_set_drop_dly  <= prod.set_drop_dly;
  tmp_set_again     <= prod2.set_again;
  tmp_clear_hasdata <= cons.clear_hasdata;
  tmp_hasdata       <= s_stat.hasdata;

  process(clk)
  begin
    if (rising_edge(clk)) then
      if (prod.set_hasdata = '1') then
        s_stat.hasdata   <= '1';
        s_stat.broadcast <= prod.set_broadcast;
        s_stat.drop_dly  <= prod.set_drop_dly;
        s_stat.words     <= prod.set_words;
      elsif (prod2.set_again = '1') then
        s_stat.hasdata   <= '1';
      elsif (cons.clear_hasdata = '1') then
        s_stat.hasdata   <= '0';
      end if;
    end if;
  end process;

  stat <= s_stat;

end RTL;
