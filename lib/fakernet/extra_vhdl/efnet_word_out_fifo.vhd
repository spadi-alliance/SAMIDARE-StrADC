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

entity efnet_word_out_fifo is
  Port (
    clk_for_in     : in  std_logic;
    clk_for_out    : in  std_logic;
    -- Input
    in_ena         : in  std_logic;
    in_word        : in  std_logic_vector(15 downto 0);
    in_taken       : out std_logic := '0';
    -- Output
    out_ena        : out std_logic := '0';
    out_word       : out std_logic_vector(15 downto 0) := (others => '0');
    out_many       : out std_logic := '0';
    out_taken      : in  std_logic := '0'
  );
                      
end efnet_word_out_fifo;

architecture behavioral of efnet_word_out_fifo is

  signal fifo_in  : std_logic_vector (16 downto 0) := (others => '0');
  signal fifo_out : std_logic_vector (16 downto 0) := (others => '0');

  signal fifo_in_has   : std_logic := '0';
  signal fifo_in_used  : std_logic := '0';

  signal fifo_out_has  : std_logic := '0';
  signal fifo_out_used : std_logic := '0';
  signal fifo_out_many : std_logic := '0';
    
begin
  
  -- We always insert data, also idle.
  -- Otherwise, latency is different dependent on if we recently provided
  -- a packet or not, since input side is faster.
  -- Latency jitter makes NTP responses less predictable.
  -- TODO: Still, word_to_octet accepts data faster for idle words.
  -- out_state would need to drop also in idle, unless known that
  -- word_to_octet has reached fast-accept mode.
  fifo_in_has          <= '1';
  fifo_in(16)          <= in_ena;
  fifo_in(15 downto 0) <= in_word;

  -- Data is taken.
  fifo_out_used        <= out_taken;

  fifo: entity work.fnet_async_fifo
    generic map(
      width     => 17,
      many_bits => 2   -- Signal when > 3 words are available.
      )
    port map(
      -- Write side.
      clk_a      => clk_for_in,
      input_a    => fifo_in,
      in_has_a   => fifo_in_has,
      in_used_a  => fifo_in_used,
      -- Read side.
      clk_b      => clk_for_out,
      output_b   => fifo_out,
      out_has_b  => fifo_out_has,
      out_many_b => fifo_out_many,
      out_used_b => fifo_out_used
      );

  -- Data was taken if used (this is only set if we gave fifo_in_has).
  in_taken <= fifo_in_used;

  -- Are there further data words already available.
  -- For consumer to avoid underflow.
  out_many <= fifo_out_many;

  -- Output data.
  out_ena  <= fifo_out(16);
  out_word <= fifo_out(15 downto 0);

  -- Note: when the word-to-octet consumers reads idle words, it may
  -- empty the fifo as it may be clocked (at most 2x) faster than the
  -- producer.  This is prevented by it not reading new data when idle
  -- if the many flag is not set.  As a consequence, it may duplicate
  -- idle words.

end behavioral;
