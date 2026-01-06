-- Copyright (c) 2020, Anders Furufors
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
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

use work.fnet_records.all; -- For word32_array.
use work.fnet_util_pkg.all; -- For fnet_or_reduction.

entity efb_xilinx_common_clk is
  generic (clkfbout_mult : integer;
           clkin_period  : real;
           gen_eth_ref_clk : boolean);
  port (
    -- Board oscillator.
    i_clk_in       : in  std_logic;
    o_clk_in_buf   : out std_logic;
    -- Output clocks.
    o_clk          : out std_logic;
    o_clk25        : out std_logic;
    o_clk125       : out std_logic;
    o_clk250       : out std_logic;
    o_clk500       : out std_logic;
    o_clk500_90    : out std_logic;
    -- ETH ref clock (25 MHz).
    eth_ref_clk    : out std_logic
    );

end efb_xilinx_common_clk;

architecture RTL of efb_xilinx_common_clk is

  -- Clock generation.
  signal clk_in_buf         : std_logic;
  signal clkfb              : std_logic;
  -- Clock signals from PLL.
  signal clk_pll            : std_logic;
  signal clk25_pll          : std_logic;
  signal clk125_pll         : std_logic;
  signal clk250_pll         : std_logic;
  signal clk500_pll         : std_logic;
  signal clk500_90_pll      : std_logic;
  -- Clock signals (buffered).
  signal clk                : std_logic;
  signal clk25              : std_logic;
  signal clk125             : std_logic;
  signal clk250             : std_logic;
  signal clk500             : std_logic;
  signal clk500_90          : std_logic;

begin

  -----------------------
  -- Clock generation. --
  -----------------------

  -- Buffer the input clock.
  clk_bufg: bufg
    port map (i => i_clk_in,
              o => clk_in_buf);

  o_clk_in_buf <= clk_in_buf;

  -- Clock generation (VCO at 1000 MHz).
  pll: PLL_BASE
    generic map (
      BANDWIDTH          => "OPTIMIZED",

      CLKFBOUT_MULT      => clkfbout_mult,
      CLKFBOUT_PHASE     => 0.0,

      CLKIN_PERIOD       => clkin_period,

      CLKOUT0_DIVIDE     => 8,  -- 125 MHz
      CLKOUT1_DIVIDE     => 40, -- 25  MHz
      CLKOUT2_DIVIDE     => 8,  -- 125 MHz
      CLKOUT3_DIVIDE     => 4,  -- 250 MHz
      CLKOUT4_DIVIDE     => 2,  -- 500 MHz
      CLKOUT5_DIVIDE     => 2,  -- 500 MHz (90 degrees)

      CLKOUT0_DUTY_CYCLE => 0.5,
      CLKOUT1_DUTY_CYCLE => 0.5,

      CLKOUT0_PHASE      => 0.0,
      CLKOUT1_PHASE      => 0.0,
      CLKOUT2_PHASE      => 0.0,
      CLKOUT3_PHASE      => 0.0,
      CLKOUT4_PHASE      => 0.0,
      CLKOUT5_PHASE      => 90.0,

      DIVCLK_DIVIDE      => 1
      )
    port map (
      CLKIN    => clk_in_buf,

      CLKFBOUT => clkfb,
      CLKFBIN  => clkfb,

      CLKOUT0  => clk_pll,
      CLKOUT1  => clk25_pll,
      CLKOUT2  => clk125_pll,
      CLKOUT3  => clk250_pll,
      CLKOUT4  => clk500_pll,
      CLKOUT5  => clk500_90_pll,

      LOCKED   => open,
      RST      => '0'
      );

  clk100_bufg: bufg
    port map (i => clk_pll,
              o => clk);
  clk25_bufg: bufg
    port map (i => clk25_pll,
              o => clk25);
  clk125_bufg: bufg
    port map (i => clk125_pll,
              o => clk125);
  clk250_bufg: bufg
    port map (i => clk250_pll,
              o => clk250);
  clk500_bufg: bufg
    port map (i => clk500_pll,
              o => clk500);
  clk500_90_bufg: bufg
    port map (i => clk500_90_pll,
              o => clk500_90);

  o_clk       <= clk;
  o_clk25     <= clk25;
  o_clk125    <= clk125;

  o_clk250    <= clk250;
  o_clk500    <= clk500;
  o_clk500_90 <= clk500_90;

  ------------------------------------------------
  -- Send clock signal to eth_ref_clk (25 MHz). --
  ------------------------------------------------

  ge: if (gen_eth_ref_clk) generate
    clock_fwd_ddr : ODDR
      generic map(
        DDR_CLK_EDGE => "SAME_EDGE",
        INIT         => '0',
        SRTYPE       => "SYNC")
      port map (
        Q  => eth_ref_clk,
        C  => clk25,
        CE => '1', R  => '0', S  => '0',
        D1 => '0', D2 => '1'
        );
  end generate;

end RTL;
