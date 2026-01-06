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

entity efnet_gmii_mii_rx is
  generic (clk_freq : integer);
  port (
    -- Board clock.
    clk             : in  std_logic;
    -- (Buffered) input clock from Ethernet PHY
    buf_eth_rx_clk  : in  std_logic;
    -- Input signals from Ethernet PHY
    eth_rx_dv       : in  std_logic;
    eth_rxd         : in  std_logic_vector;
    -- PHY mode.
    o_mode_gmii     : out std_logic;
    -- To force the PHY mode.
    i_mode_gmii     : in  std_logic := '0'; -- Only for i_mode_gmii_set = '1'.
    i_mode_gmii_set : in  std_logic := '0';
    -- Output
    o_word_1        : out std_logic_vector(7 downto 0); -- The octets that make
    o_word_2        : out std_logic_vector(7 downto 0); -- up the 16 bit word.
    o_words_ready   : out std_logic; -- High when full word has been received.
    o_packet_start  : out std_logic;  -- High if SFD detected.
    o_packet_ended  : out std_logic   -- High for one cycle if ended.
  );
                      
end efnet_gmii_mii_rx;

architecture RTL of efnet_gmii_mii_rx is

  -- IDDR buffered input
  signal buf_eth_rx_dv    : std_logic;
  signal buf_eth_rxd      : std_logic_vector(7 downto 0) := (others => '0');

  signal buf_eth_rx_dv_q2 : std_logic;
  signal buf_eth_rxd_q2   : std_logic_vector(7 downto 0) := (others => '0');

  -- Determined interface speed/mode.
  signal mode_gmii_sense  : std_logic;
  signal mode_gmii        : std_logic;

  -- Input network traffic
  signal in_fifo_word       : std_logic_vector(15 downto 0) := (others => '0');
  signal in_fifo_got_word   : std_logic := '0';
  signal in_fifo_new_packet : std_logic := '0';
  signal in_fifo_end_packet : std_logic := '0';

begin
  
  -- Use the FPGA DDR input buffers, to sample at the input pins with
  -- the input clock.

  -- Use values sampled at rising edge, i.e. q1.
--  inddr_rx_dv: entity work.efnet_hw_iddr
--    port map (
--      d  => eth_rx_dv,
--      c  => buf_eth_rx_clk,
--      q1 => buf_eth_rx_dv,
--      q2 => buf_eth_rx_dv_q2
--      );

--  inddr_rxd: entity work.efnet_hw_iddr_vector
--    port map (
--      d  => eth_rxd,
--      c  => buf_eth_rx_clk,
--      q1 => buf_eth_rxd(eth_rxd'range),
--      q2 => buf_eth_rxd_q2(eth_rxd'range)
--      );
    
    buf_eth_rx_dv <= eth_rx_dv;  
    buf_eth_rxd(7 downto 0) <= eth_rxd(7 downto 0);



  -- Determine the PHY speed, by figuring out how fast the RX clock is
  -- ticking.  Requires knowledge of the frequency of the board clock
  -- (clk).

  rx_speed : entity work.efnet_rx_speed_sense
    generic map(
      clk_freq         => 100000000)
    port map(
      clk              => clk,
      eth_rx_clk       => buf_eth_rx_clk,

      o_mode_gmii      => mode_gmii_sense
      );

  mode_gmii <=
    i_mode_gmii when (i_mode_gmii_set = '1') else
    mode_gmii_sense;

  rx : entity work.efnet_octet_to_word
    port map(
      eth_rx_clk       => buf_eth_rx_clk,
      eth_rx_dv        => buf_eth_rx_dv,
      eth_rxd          => buf_eth_rxd,

      i_mode_gmii      => mode_gmii,

      o_word_1         => in_fifo_word(15 downto 8),
      o_word_2         => in_fifo_word(7 downto 0),
      o_words_ready    => in_fifo_got_word,
      o_packet_start   => in_fifo_new_packet,
      o_packet_ended   => in_fifo_end_packet
      );

  rx_fifo : entity work.efnet_word_in_fifo
    port map(
      clk_for_in       => buf_eth_rx_clk,
      clk_for_out      => clk,

      i_word_1         => in_fifo_word(15 downto 8),
      i_word_2         => in_fifo_word(7 downto 0),
      i_words_ready    => in_fifo_got_word,
      i_packet_start   => in_fifo_new_packet,
      i_packet_ended   => in_fifo_end_packet,

      o_word_1         => o_word_1,
      o_word_2         => o_word_2,
      o_words_ready    => o_words_ready,
      o_packet_start   => o_packet_start,
      o_packet_ended   => o_packet_ended

      --debug_fifo => debug_fifo
      );

  o_mode_gmii <= mode_gmii;
end RTL;
