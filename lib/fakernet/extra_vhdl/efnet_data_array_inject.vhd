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
use ieee.numeric_std.all;

use work.fnet_records.all; -- For word32_array.
use work.fnet_util_pkg.all;

-- This entity provides an alternative interface to inject data
-- into the data buffer for TCP transmission.
--
-- The user provides an array of 32-bit values, and a bit-mask that
-- signals each time an updated value is available.  The routine will
-- latch the value when the bitmask signals a new value, and emit it
-- as soon as possible.  Note: if a value is provided again before the
-- old has been written, the old will be lost.
--
-- There is no guarantee on the ordering of items, except:
--
-- If several values in adjacent slots are provided at the same time
-- they *will* be written in order.  This allows to distinguish
-- between different data words using only unique bit patterns in the
-- first item, and use the full 32-bits of data in following items.
--
-- NOTE: careful: if a block of data consist of more than one word,
-- then a new block cannot be issued until the last word has been
-- written (no longer is pending).  Otherwise, a partial block may be
-- generated!
--
-- NOTE: be careful if has_data is set in a clock process.  Then it
-- would not see a pending value being set (by itself) due to a write
-- in last cycle.
--
-- With an array of size 1, it can act as a simple FIFO interface.
-- In that case, the pending values can be ignored as long as
-- data_free allows more items to be written.

entity efnet_data_array_inject is
  Port (
    -- Clock from board, must be at least xxx MHz.
    clk        : in  std_logic;

    -- These ports must all have the same number of entries.
    data_array : in  word32_array;
    has_data   : in  std_logic_vector;
    pending    : out std_logic_vector;

    -- Connect these signals to the fakernet module.
    data_word      : out std_logic_vector(31 downto 0);
    data_offset    : out std_logic_vector;
    data_write     : out std_logic;
    data_commit_len: out std_logic_vector;
    data_commit    : out std_logic;
    data_free      : in  std_logic;
    data_reset     : in  std_logic
  );
end efnet_data_array_inject;

architecture behavioral of efnet_data_array_inject is

  -- Number of entries in the array.
  constant num_entries : integer := data_array'length;

  -- Number of bits needed to describe selected entry.
  constant num_idx_bits : integer := fnet_log2(num_entries-1)+1;

  -- Array of values to store.
  signal latch_array : word32_array(0 to num_entries-1) :=
    (others => (others => '0'));

  -- Entries with values pending.
  -- One index more, since we check for next item, which may be outside array.
  signal to_write : std_logic_vector(num_entries+1-1 downto 0) :=
    (others => '0');

  -- Index of value to write.
  signal low_idx : unsigned(num_idx_bits-1 downto 0) :=
    (others => '0');
  signal low_idx_plus_1 : unsigned(num_idx_bits-1 downto 0) :=
    (others => '0');

begin

  data_offset <= (others => '0');
  data_commit_len <= std_logic_vector(to_unsigned(1, data_commit_len'length));

  low_idx_plus_1 <= low_idx + 1;

  process(clk)
  begin
    if (rising_edge(clk)) then
      -- Choose next entry to deal with.  (Can be overridden below.)
      low_idx <= to_unsigned(find_lowest(to_write),
                             low_idx'length);

      -- Defaults.
      data_write <= '0';
      data_commit <= '0';

      -- Check if we still have a value, since the selection of
      -- low index may have been due to the item that was written.
      -- Or if no item, defaulting to index 0.
      if (data_free = '1' and
          to_write(to_integer(low_idx)) = '1') then
        -- The output can accept another word (at least).
        -- Write the data.
        data_word   <= latch_array(to_integer(low_idx));
        data_write  <= '1';
        data_commit <= '1';
        -- Value was written, do not use again (unless new value given).
        for i in 0 to num_entries-1 loop
          if (to_integer(low_idx) = i) then
            to_write(i) <= '0';
          end if;
        end loop;

        -- If next entry has data, then we will write that next.
        -- Two advantages: may find new item in next cycle.
        -- Will always write in sequence, when given in sequence.
        if (to_write(to_integer(low_idx_plus_1)) = '1') then
          low_idx <= low_idx_plus_1;
        end if;
      elsif (to_write(to_integer(low_idx)) = '1') then
        -- Do not take the updated value above.  This index is still
        -- pending.  (Might have been next entry that is to be in order.)
        low_idx <= low_idx;
      end if;

      -- The data is latched here below the write, such that a new value
      -- can reactivate the to_write array if given in the same cycle.
      for i in 0 to num_entries-1 loop
        if (has_data(i) = '1') then
          latch_array(i) <= data_array(i);
          to_write(i)    <= '1';
        end if;
        if (data_reset = '1') then
          to_write(i)    <= '0';
        end if;
      end loop;

    end if;
  end process;

  -- Adapt to output array.
  copy_out: for i in 0 to num_entries-1 generate
    pending(i) <= to_write(i);
  end generate;

end behavioral;
