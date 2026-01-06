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

library UNISIM;
use UNISIM.VComponents.all;

-- Get the DNA bit string from a Xilinx DNA_PORT primitive.

-- CAUTION:
-- The DNA string is not necessarily unique for each FPGA chip!
-- The same DNA can be shared by up to 32 devices.

entity efb_xilinx_dna_port is
  generic (nbits : in  integer);
  port (
    clk          : in  std_logic; -- Clock from board
    -- Output
    dna          : out std_logic_vector(nbits-1 downto 0)
    );

end efb_xilinx_dna_port;

architecture RTL of efb_xilinx_dna_port is

  -- Readout sequence.
  signal state      : std_logic_vector(1 downto 0) := "00";

  -- Readout counter.
  signal count      : integer range 0 to nbits := nbits-1;

  -- Result register.
  signal shift_reg  : std_logic_vector(nbits-1 downto 0);

  -- Primitive interface.
  signal port_dout  : std_logic;
  signal port_read  : std_logic := '0';
  signal port_shift : std_logic := '0';

begin

  dna_prim : dna_porte2
    port map(
      clk   => clk,
      dout  => port_dout,
      din   => '0',
      read  => port_read,
      shift => port_shift);
  
  process(clk)
  begin
    if (rising_edge(clk)) then
      -- Default values:
      port_read <= '0';
      port_shift <= '0';
      
      case state is
        when "00" =>
          port_read <= '1';
          state <= "01";
          
        when "01" =>
          port_shift <= '1';
          state <= "10";

        when "10" =>
          if (count = 0) then
            state <= "11";
          else
            port_shift <= '1';
            count <= count - 1;
          end if;
          -- The least significant bit is delivered first.
          shift_reg <= port_dout & shift_reg(nbits-1 downto 1);

        when others =>
          null;
      end case;
    end if;
  end process;

  dna <= shift_reg;
end RTL;
