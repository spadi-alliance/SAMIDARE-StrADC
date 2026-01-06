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

-- Take clock and data-valid and make one words of two octets each.
-- Need to think of final word that is not necessarily completed.
-- Maybe if invalid and start found finish word (add zeros) and say word ready.

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
--use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity efnet_octet_to_word is
  Port (
    -- Input signals from Ethernet PHY
    eth_rx_clk : in std_logic;
    eth_rx_dv  : in std_logic;
    eth_rxd    : in std_logic_vector (7 downto 0);
    -- PHY mode.
    i_mode_gmii  : in std_logic;
    -- Output
    o_word_1   : out std_logic_vector(7 downto 0); -- The octets that make up
    o_word_2   : out std_logic_vector(7 downto 0); -- the 16 bit word.
    o_words_ready  : out std_logic; -- High when both words have been received.
    o_packet_start : out std_logic; -- High if SFD detected.
    o_packet_ended : out std_logic  -- High for one cycle if ended.
  );
                      
end efnet_octet_to_word;

architecture behavioral of efnet_octet_to_word is

  signal r_rx_dv : std_logic := '0';
  signal r_rxd   : std_logic_vector (7 downto 0) := (others => '0');

  signal word : std_logic_vector (15 downto 0) := (others => '0');
  signal start_found : std_logic := '0';
  signal nibble_counter : std_logic_vector (1 downto 0) := "01";
  signal word_completed : std_logic := '0';
  signal packet_start : std_logic := '0';
  signal packet_end : std_logic := '0';

  -- Mode can come from board clock domain, so needs latching.
  signal mode_gmii_p0 : std_logic;
  signal mode_gmii_p1 : std_logic;
  signal mode_gmii    : std_logic;

begin
  
  process (eth_rx_clk)
  begin
    if (rising_edge(eth_rx_clk)) then
      -- Pipeline inputs (against meta-stability).
      r_rx_dv <= eth_rx_dv;
      r_rxd   <= eth_rxd;

      -- Pipeline mode.
      mode_gmii_p0 <= i_mode_gmii;
      mode_gmii_p1 <= mode_gmii_p0;
      mode_gmii    <= mode_gmii_p1;

      -- Default values.
      word_completed <= '0';
      packet_start <= '0';
      
      -- On the clock, pick the values.
      if (r_rx_dv = '1') then
        -- Shift in input data.
        if (mode_gmii = '1') then
          word <= r_rxd & word(15 downto 8);
        else
          word <= r_rxd(3 downto 0) & word(15 downto 4);
        end if;

        -- Note: this acts on octets collected in previous cycles.
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
          if (mode_gmii = '1') then
            nibble_counter <= nibble_counter + 2;
          else
            nibble_counter <= nibble_counter + 1;
          end if;
        else
          -- Reset while start not found.
          if (mode_gmii = '1') then
            nibble_counter <= "11";
          else
            nibble_counter <= "01";
          end if;
        end if;
      end if;

      if (r_rx_dv = '0') then
        -- Start all over on invalid data.
        start_found <= '0';

        -- Invalidate the data, such that we do not 'find' an SFD with
        -- some partial previous data.
        word <= (others => '0');

        if (start_found = '1') then
          packet_end <= '1';
        end if;
      end if;

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

-- 0x55 01010101    preamble6  5555  0   3   0
-- 0x55 01010101    preamble7  5555  0   3   0
-- 0xD5 11010101    SFD        5555  0   3   0
-- (ba)             frame1     D555  0   3   0
-- (dc)             frame2     baD5  1   3   0
-- (fe)             frame3     dcba  1   1   1  -- Output sees 'dcba'
-- (hg)             frame4     fedc  1   3   0
-- (ji)             frame5     hgfe  1   1   1
