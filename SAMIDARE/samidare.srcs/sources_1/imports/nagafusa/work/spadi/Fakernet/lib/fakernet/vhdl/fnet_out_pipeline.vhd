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

use work.fnet_util_pkg.all;

entity fnet_out_pipeline is
  port (clk           : in  std_logic;
        --
        out_r_word    : in  std_logic_vector(15 downto 0);
        out_r_ena     : in  std_logic;
        out_r_payload : in  std_logic;
        out_r_taken   : out std_logic := '0';
        --
        out_word      : out std_logic_vector(15 downto 0);
        out_ena       : out std_logic;
        out_payload   : out std_logic;
        out_taken     : in  std_logic
        );
end fnet_out_pipeline;

architecture RTL of fnet_out_pipeline is

  signal reg_word     : std_logic_vector(15 downto 0) := (others => '0');
  signal reg_ena      : std_logic := '0';
  signal reg_payload  : std_logic := '0';

  signal reg0_word    : std_logic_vector(15 downto 0) := (others => '0');
  signal reg0_ena     : std_logic := '0';
  signal reg0_payload : std_logic := '0';

  signal reg1_word    : std_logic_vector(15 downto 0) := (others => '0');
  signal reg1_ena     : std_logic := '0';
  signal reg1_payload : std_logic := '0';

  signal pick         : std_logic := '0';
  signal pick_prev    : std_logic := '0';

  signal taken_prev   : std_logic := '0';

begin

  process (clk)
  begin
    if (rising_edge(clk)) then

      taken_prev <= out_taken;

      pick_prev  <= pick;

      if (out_taken = '1') then
        pick <= not pick;

        if (pick = '0') then
          reg_word    <= reg0_word;
          reg_ena     <= reg0_ena;
          reg_payload <= reg0_payload;
        else
          reg_word    <= reg1_word;
          reg_ena     <= reg1_ena;
          reg_payload <= reg1_payload;
        end if;
      end if;

      if (taken_prev = '1') then
        if (pick_prev = '0') then
          reg0_word    <= out_r_word;
          reg0_ena     <= out_r_ena;
          reg0_payload <= out_r_payload;
        else
          reg1_word    <= out_r_word;
          reg1_ena     <= out_r_ena;
          reg1_payload <= out_r_payload;
        end if;
      end if;

    end if;
  end process;

  out_r_taken <= taken_prev;

  out_word    <= reg_word;
  out_ena     <= reg_ena;
  out_payload <= reg_payload;

end RTL;
