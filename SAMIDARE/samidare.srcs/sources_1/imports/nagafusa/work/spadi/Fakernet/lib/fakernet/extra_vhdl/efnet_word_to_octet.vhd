-- Copyright (c) 2021, Haakan T. Johansson
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
use IEEE.STD_LOGIC_UNSIGNED.all;
--use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity efnet_word_to_octet is
  Port (
    -- In GMII mode, this is a 125 MHz clock.
    -- In MII mode, this is eth_tx_clk.
    eth_gtx_clk : in  std_logic;
    -- In- and output signals from/to Ethernet PHY.
    eth_tx_en   : out std_logic := '0';
    eth_txd     : out std_logic_vector(7 downto 0);
    -- PHY mode.
    i_mode_gmii : in std_logic;
    -- Internal interface.
    out_ena     : in std_logic;
    out_word    : in std_logic_vector(15 downto 0);
    out_many    : in std_logic;
    out_taken   : out std_logic := '0'
  );
end efnet_word_to_octet;

architecture behavioral of efnet_word_to_octet is

  -- Data from FIFO.
  signal cur_word         : std_logic_vector(15 downto 0) := (others => '0');
  signal cur_ena          : std_logic := '0';

  -- Count the nibbles.
  signal nibble_counter   : std_logic_vector(1 downto 0) := "00";

  -- Word fetching logic.
  signal get_next         : std_logic := '0';
  signal cur_idle         : std_logic := '0';
  signal copy_word        : std_logic := '0';

  -- Prepared signals for next cycle.
  signal next_octet       : std_logic_vector(7 downto 0) := (others => '0');
  signal next_ena         : std_logic := '0';

  -- Data to send.
  signal send_octet       : std_logic_vector(7 downto 0) := (others => '0');
  signal send_octet_ena   : std_logic := '0';

  -- Mode can come from board clock domain, so needs latching.
  signal mode_gmii_p0 : std_logic;
  signal mode_gmii_p1 : std_logic;
  signal mode_gmii    : std_logic;

begin

  -- Is the current word idle data.
  cur_idle <= '1' when (cur_ena = '0' and cur_word(0) = '0') else '0';
  -- Get a new word when needed/requested, or always when idle
  -- provided there are enough items already in the queue to avoid
  -- running out of data while sending a packet.
  copy_word <= get_next or (cur_idle and out_many);
  -- Report when word is taken.
  out_taken <= copy_word;

  process (eth_gtx_clk)
  begin
    if (rising_edge(eth_gtx_clk)) then
      -- Pipeline mode.
      mode_gmii_p0 <= i_mode_gmii;
      mode_gmii_p1 <= mode_gmii_p0;
      mode_gmii    <= mode_gmii_p1;

      -- Pipeline output one cycle.  Time to reach ODDR block.
      send_octet_ena <= next_ena;
      send_octet     <= next_octet;

      -- The cases "01" and "11" are only used in MII mode, not GMII.
      -- In MII mode, only four lowest bits of next_octet, (3 downto 0),
      -- are used.
      -- We must however provide some bits for the high nibble.
      -- Give the same bits as the GMII selection, to make simple muxer.
      case nibble_counter is
        when "00" => --          GMII:                    GMII/MII:
          next_octet <= cur_word(15 downto 12) & cur_word(11 downto  8);
        when "01" => --          dummy                    GMII/MII:
          next_octet <= cur_word(15 downto 12) & cur_word(15 downto 12);
        when "10" => --          GMII:                    GMII/MII:
          next_octet <= cur_word( 7 downto  4) & cur_word( 3 downto  0);
        when "11" => --          dummy                    GMII/MII:
          next_octet <= cur_word( 7 downto  4) & cur_word( 7 downto  4);
        when others => -- Avoid XST toolchain complaint.
      end case;

      -- Is this next a transmission, or idle pattern?
      next_ena <= cur_ena;

      -- Default value.
      get_next <= '0';

      -- We will be using the next word in two cycles.
      -- Request it for next cycle.
      if ((mode_gmii = '1' and nibble_counter = "00") or
          (mode_gmii = '0' and nibble_counter = "10")) then
        -- Not if we are idling.  Due to delay cycle would
        -- go into infinite fetch.
        get_next <= not cur_idle;
      end if;

      -- Pick other octet next time.
      if (mode_gmii = '1') then
        nibble_counter(1) <= not nibble_counter(1);
        nibble_counter(0) <= '0';
      else
        nibble_counter <= nibble_counter + 1;
      end if;

      -- We requested a new word from the FIFO last cycle.  Get it.
      -- Or: We are (about to) send just idle (not the IGP), then we
      -- can fetch the next word immediately!  No need to go though
      -- one more octet cycle or three more nibble cycles.  Yank the
      -- nibble counter.
      if (copy_word = '1') then
        cur_ena  <= out_ena;
        cur_word <= out_word;

        nibble_counter <= "00";
      end if;

    end if;
  end process;

  eth_txd   <= send_octet;
  eth_tx_en <= send_octet_ena;

end behavioral;
