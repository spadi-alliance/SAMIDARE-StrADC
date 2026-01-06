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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.fnet_records.all;

-- FIFO to be used between the PHY interface and fakernet internals.
--

entity fnet_async_fifo is
  generic(width     : integer;
          -- Report many available if (2^many_bits)-1 words are available.
          many_bits : integer := 0);
  port (-- The write side:
        clk_a        : in  std_logic;
        input_a      : in  std_logic_vector(width-1 downto 0);
        in_has_a     : in  std_logic;        -- Data available this cycle.
        in_used_a    : out std_logic := '0'; -- Data taken this cycle.
        -- The read side:
        clk_b        : in  std_logic;
        output_b     : out std_logic_vector(width-1 downto 0) := (others=>'0');
        out_has_b    : out std_logic := '0'; -- Data delivered this cycle.
        out_many_b   : out std_logic := '0';
        out_used_b   : in  std_logic;        -- Data taken this cycle.
        -- Debug info:
        debug_fifo   : out std_logic_vector(11 downto 0)
        );
end fnet_async_fifo;

-- Delay from input to output:
--
-- cycle 0, item is      available.
-- cycle 1, wr_ptr_a     updated.  (written)
-- cycle 2, wr_ptr_gr_a  updated.
-- cycle 3, wr_ptr_gr0_b latched.
-- cycle 4, wr_ptr_gr_b  latched.
-- cycle 5, wr_ptr_b     updated.
-- cycle 6, items_b      calculated.
-- cycle 7, has_items    set.  (read)
--
-- It then takes as many cycles for the updated read pointer to
-- reach the write side, such that the slot can be reused.
-- Therefore at least 16 slots are needed to handle one value
-- per cycle.

architecture RTL of fnet_async_fifo is

  -- Number of bits to describe the slots.
  constant sbits : integer := 4;
  -- Number of slots.
  constant size  : integer := 2**sbits;

  -- One bit more in counters, to be able to separate full from empty.
  constant xbits : integer := sbits+1;

  -- Type of the FIFO RAM block.
  type array_type is array(0 to size-1) of std_logic_vector(width-1 downto 0);
  -- The FIFO RAM block itself.
  signal ram : array_type := (others => (others => '0'));

  -- Side a maintains the write pointer.  Read pointer is received.
  signal wr_ptr_a     : std_logic_vector(xbits-1 downto 0) := (others => '0');
  signal wr_ptr_gr_a  : std_logic_vector(xbits-1 downto 0) := (others => '0');
  signal rd_ptr_gr0_a : std_logic_vector(xbits-1 downto 0) := (others => '0');
  signal rd_ptr_gr_a  : std_logic_vector(xbits-1 downto 0) := (others => '0');
  signal rd_ptr_bin_a : std_logic_vector(xbits-1 downto 0) := (others => '0');
  signal rd_ptr_a     : std_logic_vector(xbits-1 downto 0) := (others => '0');
  -- Number of used slots, as seen by side a.
  signal items_a      : std_logic_vector(xbits-1 downto 0) := (others => '0');
  signal has_free_a   : std_logic := '0';

  signal do_write_a   : std_logic := '0';

  -- Side b maintains the read pointer.  Write pointer is received.
  signal rd_ptr_b     : std_logic_vector(xbits-1 downto 0) := (others => '0');
  signal rd_ptr_b_next: std_logic_vector(xbits-1 downto 0) := (others => '0');
  signal rd_ptr_gr_b  : std_logic_vector(xbits-1 downto 0) := (others => '0');
  signal wr_ptr_gr0_b : std_logic_vector(xbits-1 downto 0) := (others => '0');
  signal wr_ptr_gr_b  : std_logic_vector(xbits-1 downto 0) := (others => '0');
  signal wr_ptr_bin_b : std_logic_vector(xbits-1 downto 0) := (others => '0');
  signal wr_ptr_b     : std_logic_vector(xbits-1 downto 0) := (others => '0');
  -- Number of used slots, as seen by side b.
  signal items_b      : std_logic_vector(xbits-1 downto 0) := (others => '0');
  signal has_many_b   : std_logic := '0';
  signal has_items_b  : std_logic := '0';

  signal do_read_b    : std_logic := '0';

  signal cnt1 : std_logic_vector(3 downto 0) := (others => '0');
  signal cnt2 : std_logic_vector(3 downto 0) := (others => '0');

  signal output_b_r     : std_logic_vector(width-1 downto 0) := (others=>'0');
begin

  ----------------------------------------------------------------------
  -- Side a.  Write side.

  -- Convert the gray coded transfer value to a binary value.
  rd_ptr_bin_a(xbits-1) <= rd_ptr_gr_a(xbits-1);
  rd_ptr_gray2bin : for i in xbits-2 downto 0 generate
    rd_ptr_bin_a(i) <= rd_ptr_bin_a(i+1) xor rd_ptr_gr_a(i);
  end generate;

  -- How many items are used?
  items_a <= wr_ptr_a - rd_ptr_a;

  -- Are there free slots available.
  has_free_a <= '0' when (items_a(xbits-1) = '1') else '1';

  -- We insert an item if a new item is available, and there is a free slot.
  do_write_a <= has_free_a and in_has_a;

  process(clk_a)
  begin
    if (rising_edge(clk_a)) then
      -- If input data is available, and free space is available, use it.
      wr_ptr_a <= wr_ptr_a + ("" & do_write_a);

      -- Make the gray pointer version available (as flip-flops).
      -- Note that the previous value is used.
      -- Just means one more cycle of delay.
      wr_ptr_gr_a <= wr_ptr_a xor ('0' & wr_ptr_a(xbits-1 downto 1));

      -- Latch the read pointer from side b.  Twice to avoid metastability.
      rd_ptr_gr0_a <= rd_ptr_gr_b;
      rd_ptr_gr_a <= rd_ptr_gr0_a;

      -- The recovered read pointer.
      rd_ptr_a <= rd_ptr_bin_a;

      -- Update the RAM block if so instructed.
      if (do_write_a = '1') then
        ram(conv_integer(wr_ptr_a(sbits-1 downto 0))) <= input_a;
      end if;
    end if;
  end process;

  ----------------------------------------------------------------------
  -- Side b.  Read side.

  -- Convert the received gray coded transfer value to a binary value.
  wr_ptr_bin_b(xbits-1) <= wr_ptr_gr_b(xbits-1);
  wr_ptr_gray2bin : for i in xbits-2 downto 0 generate
    wr_ptr_bin_b(i) <= wr_ptr_bin_b(i+1) xor wr_ptr_gr_b(i);
  end generate;

  -- How many items are available.
  items_b <= wr_ptr_b - rd_ptr_b;
  -- Are there items available.
  has_items_b <= '0' when (conv_integer(items_b) = 0) else '1';
  -- We read if there are items available, and read side used the item.
  do_read_b <= has_items_b and out_used_b;

  -- Are all items available?  Useful to only start draining when
  -- it is known that more items will be directly available next cycle.
  has_many_b <=
    '0' when (conv_integer(items_b(xbits-1 downto many_bits)) = 0) else '1';

  -- If data is available, and the output wants it, we consume it.
  rd_ptr_b_next <= rd_ptr_b + ("" & do_read_b);

  process(clk_b)
  begin
    if (rising_edge(clk_b)) then
      -- Update read pointer.
      rd_ptr_b <= rd_ptr_b_next;

      -- Make the gray pointer version available (as flip-flops).
      rd_ptr_gr_b <= rd_ptr_b xor ('0' & rd_ptr_b(xbits-1 downto 1));

      -- Latch the write pointer from side a.  Twice to avoid metastability.
      wr_ptr_gr0_b <= wr_ptr_gr_a;
      wr_ptr_gr_b <= wr_ptr_gr0_b;

      -- The recovered write pointer.
      wr_ptr_b <= wr_ptr_bin_b;

      -- Always read.  If used this cycle, get next slot for next cycle.
      output_b_r <= ram(conv_integer(rd_ptr_b_next(sbits-1 downto 0)));
      
      -- one more clk
      output_b <= output_b_r;
    end if;
  end process;

  ----------------------------------------------------------------------

  in_used_a <= do_write_a;

  -- one more clk
  process(clk_b)
  begin
    if (rising_edge(clk_b)) then
      out_many_b <= has_many_b;
      out_has_b <= has_items_b;
    end if;
  end process;

  ----------------------------------------------------------------------
  -- Debugging.

  debug_fifo <= rd_ptr_b(3 downto 0) & cnt1 & cnt2;

  process(clk_b)
  begin
    if (rising_edge(clk_b)) then
      cnt1 <= cnt1 + ("" & do_read_b);
      cnt2 <= cnt2 + ("" & (in_has_a and input_a(0)));
    end if;
  end process;

end RTL;
