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

entity efnet_word_in_fifo is
  Port (
    clk_for_in     : in  std_logic;
    clk_for_out    : in  std_logic;
    -- Input
    i_word_1       : in  std_logic_vector(7 downto 0);
    i_word_2       : in  std_logic_vector(7 downto 0);
    i_words_ready  : in  std_logic;
    i_packet_start : in  std_logic;
    i_packet_ended : in  std_logic;
    -- Output
    o_word_1       : out std_logic_vector(7 downto 0);
    o_word_2       : out std_logic_vector(7 downto 0);
    o_words_ready  : out std_logic;
    o_packet_start : out std_logic;
    o_packet_ended : out std_logic;

    debug_fifo : out std_logic_vector(11 downto 0)
  );
                      
end efnet_word_in_fifo;

architecture behavioral of efnet_word_in_fifo is

  signal fifo_in  : std_logic_vector (16 downto 0) := (others => '0');
  signal fifo_out : std_logic_vector (16 downto 0) := (others => '0');

  signal fifo_in_has   : std_logic := '0';
  signal fifo_out_has  : std_logic := '0';
    
  signal packet_start2 : std_logic := '0';
  signal packet_end2   : std_logic := '0'; 

  signal word2 : std_logic_vector (15 downto 0) := (others => '0');
  signal word_completed2 : std_logic := '0';

begin
  
  -- Note: packet_start is a cycle before word_completed.
  -- They never appear in the same cycle.
  fifo_in_has          <= i_words_ready or i_packet_start;

  -- Need to use an additional bit to keep track of the packet start
  -- marker.
  fifo_in(16)          <= i_packet_start;
  fifo_in(15 downto 0) <= i_word_2 & i_word_1;

  fifo: entity work.fnet_async_fifo
    generic map(
      width     => 17
      )
    port map(
      -- Write side.
      clk_a      => clk_for_in,
      input_a    => fifo_in,
      in_has_a   => fifo_in_has,
      in_used_a  => open, -- The FIFO always have space (we assume).
      -- Read side.
      clk_b      => clk_for_out,
      output_b   => fifo_out,
      out_has_b  => fifo_out_has,
      out_many_b => open,
      out_used_b => '1', -- Consumer (fakernet) always can take data.

      debug_fifo => debug_fifo
      );

  packet_start2   <= fifo_out_has and     fifo_out(16);
  word_completed2 <= fifo_out_has and not fifo_out(16);
  word2           <= fifo_out(15 downto 0);

  --

  o_word_1 <= word2(7 downto 0);
  o_word_2 <= word2(15 downto 8);

  o_words_ready <= word_completed2;

  o_packet_start <= packet_start2;
  o_packet_ended <= packet_end2;

end behavioral;
