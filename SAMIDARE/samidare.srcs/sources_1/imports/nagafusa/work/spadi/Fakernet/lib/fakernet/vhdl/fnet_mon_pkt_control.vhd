-- Copyright (c) 2022, Haakan T. Johansson
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

entity fnet_mon_pkt_control is
  port (clk          : in  std_logic;
        --
        cfg_gen_mon  : in  std_logic;
        --
        mon_mac      : in  std_logic_vector(47 downto 0);
        mon_ip       : in  std_logic_vector(31 downto 0);
        mon_port     : in  std_logic_vector(15 downto 0);
        --
        in_stat      : in  dync_in_stat;
        gen_stat     : in  dync_gen_stat;
        --
        stat         : out mon_control_stat;
        --
        timeout_tick : in std_logic
        );
end fnet_mon_pkt_control;

architecture RTL of fnet_mon_pkt_control is

  signal state : mon_control_stat := (pending_mon         => '0',
                                      mon_mac  => (others => '0'),
                                      mon_ip   => (others => '0'),
                                      mon_port => (others => '0'));

begin

  state.mon_mac  <= mon_mac;
  state.mon_ip   <= mon_ip;
  state.mon_port <= mon_port;

  process(clk)
  begin
    if (rising_edge(clk)) then

      if ((cfg_gen_mon = '1') and
          (timeout_tick = '1')) then
        state.pending_mon <= '1';
      end if;

      -- Reset pending state when packets are generated.
      if (gen_stat.gen_mon = '1') then
        state.pending_mon <= '0';
      end if;
    end if;
  end process;

  stat <= state;

end RTL;
