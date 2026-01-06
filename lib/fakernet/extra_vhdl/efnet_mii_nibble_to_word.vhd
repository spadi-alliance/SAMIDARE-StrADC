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

-- Take clock and data valid and make two octet words each.
-- Need to think of final words that are not necessarily completed...
-- Maybe if invalid and start found, then finish words (add zeros) and
-- say words ready.

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
--use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity efnet_mii_nibble_to_word is
  Port (
    -- Clock from board, must be at least xxx MHz.
    clk        : in  std_logic;
    -- Input signals from Ethernet PHY.
    -- They are to be direct input pins, and are assumed to all have
    -- the same delay from the PHY.
    eth_rx_clk : in std_logic;
    eth_rx_dv  : in std_logic;
    eth_rxd    : in std_logic_vector(3 downto 0);
    -- Output.
    o_word_1   : out std_logic_vector(7 downto 0); -- The octets that make up
    o_word_2   : out std_logic_vector(7 downto 0); -- the 16 bit word.
    o_words_ready  : out std_logic; -- High when both words have been received.
    o_packet_start : out std_logic; -- High if SFD detected.
    o_packet_ended : out std_logic  -- High for one cycle if ended.
  );

end efnet_mii_nibble_to_word;

architecture behavioral of efnet_mii_nibble_to_word is

  -- First input latch.
  signal buf1_rx_clk : std_logic;
  signal buf1_rx_dv  : std_logic;
  signal buf1_rxd    : std_logic_vector(3 downto 0);

  -- Second input latch.
  signal buf2_rx_clk : std_logic;
  signal buf2_rx_dv  : std_logic;
  signal buf2_rxd    : std_logic_vector(3 downto 0);

  -- Third input latch.
  signal buf3_rx_clk : std_logic;
  signal buf3_rx_dv  : std_logic;
  signal buf3_rxd    : std_logic_vector(3 downto 0);

  -- Is data reception ongoing.
  signal start_found  : std_logic := '0';

  -- Mark packet start and end.
  signal packet_start : std_logic := '0';
  signal packet_end   : std_logic := '0';

  -- Shift register for the nibble data to build a full 16-bit word.
  signal word : std_logic_vector(15 downto 0) := (others => '0');
  signal nibble_counter : std_logic_vector(1 downto 0) := "01";
  signal word_completed : std_logic := '0';

  -- Rising edge detection for PHY RX clk signal.
  signal buf3_rx_clk_prev   : std_logic := '0';

begin

  -- Timing strategy:
  --
  -- The rxd and rx_dv lines are according to IEEE 802.3 valid at
  -- least 10 ns before and at least 10 ns after the rising edge of
  -- the rx_clk signal, which has a 40 ns nominal period at 100 Mbps.
  -- The rx_clk duty shall also be in the interval between 35 % and 65 %.
  --
  -- We latch all signals through two stages, against metastability.
  -- The first latch of the rx_clk signal is however by the sampling
  -- clock falling edge, i.e. half a clock cycle later.  Thus the rxd
  -- and rx_dv samples are half a clock cycle earlier than the
  -- corresponding buffered rx_clk value.
  --
  -- When the rising edge of rx_clk is detected, we are in the
  -- interval [0,1] sampling clock period later than the actual rising
  -- edge.  (0 when the rx_clk sampling happens just after the rx_clk
  -- rising edge, and 1 when the previous rx_clk sampling happened
  -- just before the rx_clk rising edge.)  With the samples of the
  -- data lines half a cycle earlier, those are therefore in the
  -- interval [-0.5,+0.5] sampling clock periods before and after the
  -- actual rx_clk rising edge.  Given the [-10 ns,+10 ns] interval
  -- limits, this would allow an 20 ns sampling clock period.
  --
  -- The sampling clock must however also be able to detect the rx_clk
  -- edges, i.e. see at least one 0 and 1 each period.  With the duty
  -- cycle requirements, this limits the period to be at most 14 ns.

  -- transitions:      / \ X      0, 1:   _ ^   unknown: x
  -- clock transition: |          0 or 1: =
  --
  -- rxd          xxxxxxxxxxX===================Xxxxxxxxxxx
  -- rx_clk       ____________________/^^^^^^^^^^^^^^^^^^^^
  --
  -- case 0 (clock falling just after rx_clk rising):
  --
  -- clk          ^|____|^^^^|____|^^^^|____|^^^^|____|^^^^
  -- buf1_rx_clk  _____________________/^^^^^^^^^^^^^^^^^^^
  -- buf1_rxd     xxxxxxxxxxxxxxxxX===================Xxxxx
  -- buf2_rx_clk  __________________________/^^^^^^^^^^^^^^
  -- buf2_rxd     xxxxxxxxxxxxxxxxxxxxxxxxxxX==============
  --
  -- case 0.5 (in-between):
  --
  -- clk          ^^^^^|____|^^^^|____|^^^^|____|^^^^|____|
  -- buf1_rx_clk  _________________________/^^^^^^^^^^^^^^^
  -- buf1_rxd     xxxxxxxxxxxxxxxxxxxxX===================X
  -- buf2_rx_clk  ______________________________/^^^^^^^^^^
  -- buf2_rxd     xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxX==========
  --
  -- case 1 (clock falling just before rx_clk rising):
  --
  -- clk          ____|^^^^|____|^^^^|____|^^^^|____|^^^^|_
  -- buf1_rx_clk  _____________________________/^^^^^^^^^^^
  -- buf1_rxd     xxxxxxxxxxxxxxX===================Xxxxxxx
  -- buf2_rx_clk  __________________________________/^^^^^^
  -- buf2_rxd     xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxX======

  process (clk)
  begin
    if (rising_edge(clk)) then
      -- First latch for the data lines.
      buf1_rx_dv  <= eth_rx_dv;
      buf1_rxd    <= eth_rxd;
    end if;
    if (falling_edge(clk)) then
      -- First latch for the clock line.
      -- Half a cycle after the data lines.
      buf1_rx_clk <= eth_rx_clk;
    end if;
    if (rising_edge(clk)) then
      -- Second latch on usual edge.
      buf2_rx_clk <= buf1_rx_clk;
      buf2_rx_dv  <= buf1_rx_dv;
      buf2_rxd    <= buf1_rxd;
      -- Third latch.
      buf3_rx_clk <= buf2_rx_clk;
      buf3_rx_dv  <= buf2_rx_dv;
      buf3_rxd    <= buf2_rxd;
    end if;
  end process;

  process (clk)
  begin
    if (rising_edge(clk)) then
      word_completed <= '0';
      packet_start <= '0';

      -- All input data is handled in the sampling clock cycle when
      -- rx_clk rising edge is detected.
      if (buf3_rx_clk = '1' and buf3_rx_clk_prev = '0' and
          buf3_rx_dv = '1') then
        -- Shift in input data.
        word <= buf3_rxd & word(15 downto 4);

        -- Note: this acts on nibble collected in previous cycles.
        if (word = "1101010101010101") then
          -- SFD found!
          start_found <= '1';

          if (start_found = '0') then
            packet_start <= '1';
          end if;
        end if;

        if (start_found = '1') then
          if (nibble_counter = "11") then
            word_completed <= '1';
          end if;
          nibble_counter <= nibble_counter + 1;
        else
          -- Reset while start not found.
          nibble_counter <= "01";
        end if;
      end if;

      if (buf3_rx_dv = '0') then
        -- Start all over on invalid data.
        start_found <= '0';

        -- Invalidate the data, such that we do not 'find' an SFD with
        -- some partial previous data.
        word <= (others => '0');

        if (start_found = '1') then
          packet_end <= '1';
        end if;
      end if;

      -- For the rising edge detection.
      buf3_rx_clk_prev <= buf3_rx_clk;

    end if;
  end process;

  o_word_1 <= word(7 downto 0);
  o_word_2 <= word(15 downto 8);

  o_words_ready <= word_completed;

  o_packet_start <= packet_start;
  o_packet_ended <= packet_end;

end behavioral;

-- Cycles (only considering when we get data, i.e. after rising edge).
-- Values shown are as they are held since last cycle, i.e. results
-- of assignments are seen in the following cycle.

-- a-j are the actual Ethernet payload frame data nibbles.

-- [input]-------------------  word  start_found
-- HEX  binary  descr                    nibble_counter
--                                           word_completed

-- 0x5  0101    preamble7:lo   5555  0   1   0
-- 0x5  0101    preamble7:hi   5555  0   1   0
-- 0x5  0101    SFD:lo         5555  0   1   0
-- 0xD  1101    SFD:hi         5555  0   1   0
-- (a)          frame1:lo      D555  0   1   0
-- (b)          frame1:hi      aD55  1   1   0
-- (c)          frame2:lo      baD5  1   2   0
-- (d)          frame2:hi      cbaD  1   3   0
-- (e)          frame3:lo      dcba  1   0   1  -- Output sees 'dcba'
-- (f)          frame3:hi      edcb  1   1   0
-- (g)          frame4:lo      fedc  1   2   0
-- (h)          frame4:hi      gfed  1   3   0
-- (i)          frame5:lo      hgfe  1   0   1  -- Output sees 'hgfe'
-- (j)          frame5:hi      ihgf  1   1   0
