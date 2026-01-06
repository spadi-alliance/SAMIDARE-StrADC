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

entity efnet_mii_word_to_nibble is
  Port (
    -- Clock from board, must be at least xxx MHz.
    clk        : in  std_logic;
    -- In- and output signals from/to Ethernet PHY.
    -- They are to be direct in/output pins, and are assumed to all have
    -- short delays from/to the PHY.
    eth_tx_clk : in std_logic;
    eth_tx_en  : out std_logic;
    eth_txd    : out std_logic_vector(3 downto 0);
    -- Internal interface.
    out_ena    : in std_logic;
    out_word   : in std_logic_vector(15 downto 0);
    out_taken  : out std_logic
  );
end efnet_mii_word_to_nibble;

-- Distinguish different parts of the output words/octets:
-- (Note that preable and payload data cannot be distinguished.)
--
-- Preable:  out_ena = '1'
-- Data:     out_ena = '1'
-- IGP:      out_ena = '0'  out_word(0) = '1'
-- Idle:     out_ena = '0'  out_word(0) = '0'

architecture behavioral of efnet_mii_word_to_nibble is

  -- Synchronise to the rising edge of the PHY TX clk signal.
  signal buf_eth_tx_clk  : std_logic;
  signal buf_eth_tx_clk_prev : std_logic;

  -- Count the nibbles.
  signal nibble_counter  : std_logic_vector(1 downto 0) := "00";
  -- Update the next nibble to send?
  signal update_nibble   : std_logic;
  -- Prepared signals for next rising edge.
  signal next_nibble     : std_logic_vector(3 downto 0);
  signal next_nibble_ena : std_logic;
  -- Output signals.
  signal send_nibble     : std_logic_vector(3 downto 0);
  signal send_nibble_ena : std_logic;

begin

  -- Timing strategy:
  --
  -- The txd and tx_dv lines are according to IEEE 802.3 to be updated
  -- at earliest at the rising edge of the tx_clk signal, and at
  -- latest 25 ns after the tx_clk rising edge.
  --
  -- Since tx_clk comes from the PHY, and the txd/tx_dv shall reach
  -- the PHY, we have to within this 25 ns timing budget fit the
  -- transmission from the PHY, the detection of the rising edge,
  -- the update of the output signals, and their transmission to the
  -- PHY.
  --
  -- We first latch the tx_clk before actual use in the logic, for
  -- protection against metastability.  This is done on the falling
  -- edge of our working clock, i.e. half a clock cycle before use.
  -- The update of the signals is then done at the immediately
  -- following rising edge of the working clock.  The detection of the
  -- tx_clk rising edge is therefore delayed to be in the interval
  -- [0.5, 1.5] clock cycles later relative to the actual rising edge.
  --
  -- If 10 ns is set aside for transmission delays, this gives a
  -- requirement of a working clock with at most 10 ns clock period.
  --
  -- The update of the next nibble to send is done in the following
  -- clock cycle, based on a signal set when the current next values
  -- are latched for transmission.  The keeps the actual amount of
  -- logic driven by the rising-edge detection at a minimum, which
  -- actually eats into the half-cycle anti-metastability margin.

  process (clk)
  begin
    if (falling_edge(clk)) then
      -- Latch half a cycle early, for anti-metastability.
      buf_eth_tx_clk <= eth_tx_clk;
    end if;
  end process;

  process (clk)
  begin
    if (rising_edge(clk)) then
      -- Default value.
      update_nibble <= '0';

      if (buf_eth_tx_clk /= buf_eth_tx_clk_prev and
          buf_eth_tx_clk = '1') then
        -- Rising edge in the TX clk - update the output values,
        -- Data to send.
        send_nibble     <= next_nibble;
        -- Are we sending data?
        send_nibble_ena <= next_nibble_ena;

        -- Request next nibble.
        update_nibble <= '1';
      end if;

      -- For the rising edge detection.
      buf_eth_tx_clk_prev <= buf_eth_tx_clk;

      -- The update of the next nibble to transmit is done in the
      -- following cycle.  This to have as little load as possible on
      -- the buf_eth_tx_clk rising edge detection, which eats into the
      -- timing of the anti-metastability.

      -- Default value.
      out_taken <= '0';

      if (update_nibble = '1') then
        -- Select which nibble to emit next.
        case nibble_counter is
          when "00" => next_nibble <= out_word(11 downto  8);
          when "01" => next_nibble <= out_word(15 downto 12);
          when "10" => next_nibble <= out_word( 3 downto  0);
          when "11" => next_nibble <= out_word( 7 downto  4);
          when others => -- Avoid XST toolchain complaint.
        end case;

        -- Is this next a transmission, or idle pattern?
        next_nibble_ena <= out_ena;

        -- If we just latched the last nibble, ask Fakernet to give
        -- the next word to transmit.
        if (nibble_counter = "11") then
          out_taken <= '1';
        end if;

        -- Update the nibble counter.
        nibble_counter <= nibble_counter + 1;

        -- If we are sending just idle (not the IGP), then we can
        -- fetch the next word immediately!  No need to go though
        -- three more nibble cycles.  Yank the nibble counter.
        if (out_ena = '0' and out_word(0) = '0') then
          nibble_counter <= "11";
        end if;
      end if;
    end if;
  end process;

  eth_txd   <= send_nibble;
  eth_tx_en <= send_nibble_ena;
end behavioral;
