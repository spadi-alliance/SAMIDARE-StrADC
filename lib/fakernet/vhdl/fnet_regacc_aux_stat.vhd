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

entity fnet_regacc_aux_stat is
  port (clk          : in  std_logic;
        stat         : out regacc_aux_stat;
        prod         : in  regacc_aux_prod
        );
end fnet_regacc_aux_stat;

architecture RTL of fnet_regacc_aux_stat is

  signal s_stat : regacc_aux_stat :=
    (reg_idp => '0',
     reg_ch => 0,
     end_words => (others => '0'),
     checksum => (others => '0'));

begin

  process(clk)
  begin
    if (rising_edge(clk)) then
      if (prod.set_reg_ch = '1') then
        s_stat.reg_idp <= prod.v.reg_idp;
        s_stat.reg_ch  <= prod.v.reg_ch;
      end if;
      if (prod.set_end_words = '1') then
        s_stat.end_words <= prod.v.end_words;
      end if;
      if (prod.set_checksum = '1') then
        s_stat.checksum <= prod.v.checksum;
      end if;
    end if;
  end process;

  stat <= s_stat;

end RTL;
