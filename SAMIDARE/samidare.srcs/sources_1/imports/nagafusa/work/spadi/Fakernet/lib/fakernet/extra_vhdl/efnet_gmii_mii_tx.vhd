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

entity efnet_gmii_mii_tx is
  port (
    -- Board clock.
    clk             : in  std_logic;
    -- (Buffered) clock driving the transmission.
    -- In GMII mode, this is a 125 MHz clock.
    -- In MII mode, this is eth_tx_clk.
    buf_eth_gtx_clk : in  std_logic;
    -- In- and output signals from/to Ethernet PHY.
    eth_gtx_clk     : out std_logic;
    eth_tx_en       : out std_logic := '0';
    eth_txd         : out std_logic_vector;
    -- Debug signals.
    spy_tx_en       : out std_logic;
    spy_txd         : out std_logic_vector(7 downto 0);
    -- PHY mode.
    i_mode_gmii     : in  std_logic;
    -- Internal interface.
    out_ena         : in  std_logic;
    out_word        : in  std_logic_vector(15 downto 0);
    out_taken       : out std_logic := '0'
  );
                      
end efnet_gmii_mii_tx;

architecture RTL of efnet_gmii_mii_tx is

  -- Before ODDR buffered output
  signal eth_txd_tmp   : std_logic_vector(7 downto 0);
  signal eth_tx_en_tmp : std_logic_vector(0 downto 0);

  -- Output network traffic
  signal out_fifo_word      : std_logic_vector(15 downto 0) :=
    std_logic_vector(to_unsigned(16#dead#,16));
  signal out_fifo_ena       : std_logic := '0';
  signal out_fifo_many      : std_logic := '0';
  signal out_fifo_taken     : std_logic := '0';

begin

  tx_fifo : entity work.efnet_word_out_fifo
    port map(
      clk_for_in      => clk,
      clk_for_out     => buf_eth_gtx_clk,

      in_ena          => out_ena,
      in_word         => out_word,
      in_taken        => out_taken,

      out_ena         => out_fifo_ena,
      out_word        => out_fifo_word,
      out_many        => out_fifo_many,
      out_taken       => out_fifo_taken
      );

  tx : entity work.efnet_word_to_octet
    port map(
      eth_gtx_clk     => buf_eth_gtx_clk,
      eth_tx_en       => eth_tx_en_tmp(0),
      eth_txd         => eth_txd_tmp,

      i_mode_gmii     => i_mode_gmii,

      out_ena         => out_fifo_ena,
      out_word        => out_fifo_word,
      out_many        => out_fifo_many,
      out_taken       => out_fifo_taken
      );

  -- Note!  These are in the buf_eth_gtx_clk clock domain!
  spy_tx_en <= eth_tx_en_tmp(0);
  spy_txd   <= eth_txd_tmp;

  -- Emit the clock with '01' pattern, such that the signals (txd,
  -- tx_en) are stable at the rising edge.
  outddr_tx_clk: entity work.efnet_hw_oddr
    port map (
      q  => eth_gtx_clk,
      c  => buf_eth_gtx_clk,
      d1 => '0',
      d2 => '1'
      );

--  outddr_tx_en: entity work.efnet_hw_oddr
--    port map (
--      q  => eth_tx_en,
--      c  => buf_eth_gtx_clk,
--      d1 => eth_tx_en_tmp(0),
--      d2 => eth_tx_en_tmp(0)
--      );

--  outddr_txd: entity work.efnet_hw_oddr_vector
--    port map (
--      q  => eth_txd,
--      c  => buf_eth_gtx_clk,
--      d1 => eth_txd_tmp(eth_txd'range),
--      d2 => eth_txd_tmp(eth_txd'range)
--      );

     eth_tx_en <= eth_tx_en_tmp(0);
     eth_txd(7 downto 0) <= eth_txd_tmp(7 downto 0);

end RTL;
