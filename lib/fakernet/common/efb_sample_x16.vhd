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

library xpm;
use xpm.vcomponents.all;

entity efb_sample_x16 is
  port (
    clk           : in  std_logic;
    clk_x2        : in  std_logic;
    clk_x4        : in  std_logic;
    clk_x4_90     : in  std_logic;
    -- Signals to sample.
    i_input       : in  std_logic;
    -- Output sample array (with two old in 17,16, newest is 0).
    o_samples     : out std_logic_vector(17 downto 0)
    );

end efb_sample_x16;

architecture RTL of efb_sample_x16 is

  signal saz : std_logic_vector(0 to 1) := (others => '0');
  signal sbz : std_logic_vector(0 to 1) := (others => '0');
  signal scz : std_logic_vector(0 to 1) := (others => '0');
  signal sdz : std_logic_vector(0 to 1) := (others => '0');

  signal sample_x4   : std_logic_vector(7  downto 0) := (others => '0');
  signal sample_x2_1 : std_logic_vector(7  downto 0) := (others => '0');
  signal sample_x2_2 : std_logic_vector(15 downto 0) := (others => '0');
  signal sample_x1   : std_logic_vector(17 downto 0) := (others => '0');

begin

  -- Sample the input data with x4 clock (e.g. 500 MHz when clk is
  -- 125 Mhz).  Oversample with factor 4, so actual sample rate is 2
  -- GHz (0.5 ns).
  hs: entity work.rataser_4phase_sample
    port map(clk       => clk_x4,
             clk90     => clk_x4_90,
             serial_in => i_input,
             saz       => saz,
             sbz       => sbz,
             scz       => scz,
             sdz       => sdz
             );

  -- Prepare the values of this and previous x4 clock cycle, such
  -- that the x2 clock get the 8 values of the one x2 cycle.
  sample_x4 <= saz(1) & sbz(1) & scz(1) & sdz(1) &
               saz(0) & sbz(0) & scz(0) & sdz(0);

  -- Forward from x4 to x2 clock domain.  XPM functions knows how to
  -- transfer with timing closure.
  x4x2: XPM_CDC_ARRAY_SINGLE
    generic map(width => 8)
    port map(
      src_clk  => clk_x4,
      dest_clk => clk_x2,
      src_in   => sample_x4,
      dest_out => sample_x2_1
      );

  process (clk_x2)
  begin
    if (rising_edge(clk_x2)) then
      -- Expand the 8 x2 samples to 16 samples, in preparation for
      -- x1 clock cycle.
      sample_x2_2 <= sample_x2_2(7 downto 0) & sample_x2_1;
    end if;
  end process;

  process (clk)
  begin
    if (rising_edge(clk)) then
      -- Bring the 16 samples into the x1 clock domain.
      -- Expand with the last 2 samples of the previous cycle,
      -- giving 18 samples in total.  Useful for edge detection.
      sample_x1 <= sample_x1(1 downto 0) & sample_x2_2;
    end if;
  end process;

  o_samples <= sample_x1;
  
end RTL;

