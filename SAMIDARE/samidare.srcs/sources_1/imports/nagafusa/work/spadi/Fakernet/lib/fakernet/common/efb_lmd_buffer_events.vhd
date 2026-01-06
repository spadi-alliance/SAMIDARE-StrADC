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

use work.fnet_records.all;
use work.fnet_util_pkg.all;

-- Note: maximum commit len must be < buffer size / 4.
-- (Free will only be reported if at least 3 more events fit!)

entity efb_lmd_buffer_events is
  port (
    clk              : in  std_logic;
    -- Input.
    event_word       : in  std_logic_vector(31 downto 0);
    event_offset     : in  std_logic_vector;
    event_write      : in  std_logic;
    event_commit_len : in  std_logic_vector;
    event_commit     : in  std_logic;
    event_free       : out std_logic;
    event_reset      : out std_logic;

    -- Semi-static info to write in output.
    subev_type_subtype      : in  std_logic_vector(31 downto 0);
    subev_procid_crate_ctrl : in  std_logic_vector(31 downto 0);
    subev_ts_id             : in  std_logic_vector( 7 downto 0);

    -- Force the LMD buffer to be emitted.
    flush            : in  std_logic;

    -- Output.
    data_word        : out std_logic_vector(31 downto 0);
    data_offset      : out std_logic_vector;
    data_write       : out std_logic;
    data_commit_len  : out std_logic_vector;
    data_commit      : out std_logic;
    data_free        : in  std_logic;
    data_reset       : in  std_logic;

    -- Info output.
    info_bufno      : out std_logic_vector(31 downto 0);
    info_evcnt      : out std_logic_vector(31 downto 0)
    );

end efb_lmd_buffer_events;

architecture RTL of efb_lmd_buffer_events is

  constant event_bufsize_addrbits : natural := 8;

  constant addrbits : natural := 8;
  constant databits : natural := 32;

  constant max_commit_plus_1 : integer :=
    (2**(fnet_max(event_commit_len'length,
                  event_offset'length)));

  constant buffer_words : integer := 2**addrbits;

  -- RAM block interface.
  signal data_port_a_addr  : std_logic_vector(addrbits-1 downto 0);
  signal data_port_a_rd    : std_logic;
  signal data_port_a_wr    : std_logic;
  signal data_port_a_wdata : std_logic_vector(databits-1 downto 0);
  signal data_port_a_rdata : std_logic_vector(databits-1 downto 0);

  signal data_port_b_addr  : std_logic_vector(addrbits-1 downto 0);
  signal data_port_b_rd    : std_logic;
  signal data_port_b_rdata : std_logic_vector(databits-1 downto 0);

  -- Pipelined input signals.
  signal event_pre_word       : std_logic_vector(31 downto 0) :=
    (others => '0');
  signal event_pre_offset     : std_logic_vector(event_offset'range) :=
    (others => '0');
  signal event_pre_write      : std_logic := '0';
  signal event_pre_commit_len : std_logic_vector(event_commit_len'range) :=
    (others => '0');
  signal event_pre_commit     : std_logic := '0';

  -- Next word from RAm block.
  signal next_word    : std_logic_vector(31 downto 0);
  -- Next word was consumer.  (TODO: should be is consumed).
  signal consume_word : std_logic;

  -- Current fill location (base address; offset will be added).
  signal base_fill    : unsigned(addrbits-1 downto 0) := (others => '0');
  -- Next fill location (if committed).
  signal next_commit  : unsigned(addrbits-1 downto 0) := (others => '0');
  -- Current read location.
  signal read_at_word : unsigned(addrbits-1 downto 0) := (others => '0');
  signal read_at_word_next : unsigned(read_at_word'range) := (others => '0');
  -- Number of filled words.
  signal filled_words : unsigned(addrbits-1 downto 0);
  signal filled_words_slv : std_logic_vector(filled_words'range);
  -- Number of unused (not yet committed) words.
  signal free_words  : unsigned(addrbits+1-1 downto 0);

  -- Is one (/ three) maximum commit lengths available as free.
  signal event_pst_free   : std_logic := '0';
  signal event_pst_free3  : std_logic := '0';

  -- Have the user attempted to overrun the buffer?
  signal commit_overrun : std_logic := '0';
  signal write_overrun  : std_logic := '0';

begin

  event_reset <= data_reset;

  -- Largely borrowed from fnet_tcp_buffer.

  next_commit <= base_fill + unsigned(event_pre_commit_len);

  -- Note: the buffer never runs full, since commits will be denied
  -- when less than one maximum commit length is available.
  filled_words <= base_fill - read_at_word;

  free_words <=
    to_unsigned(buffer_words, free_words'length) - filled_words;

  read_at_word_next <= read_at_word + ("" & consume_word);

  process (clk)
  begin
    if (rising_edge(clk)) then
      -- Pipeline stage.
      event_pre_write      <= event_write;
      event_pre_word       <= event_word;
      event_pre_offset     <= event_offset;
      event_pre_commit     <= event_commit;
      event_pre_commit_len <= event_commit_len;

      -- Take commit.
      if (event_pre_commit = '1') then
        if (event_pst_free = '1') then
          -- Furthermore, we will not accept any data commits if
          -- we had any overrun condition.
          if (commit_overrun = '0' and
              write_overrun = '0') then
            base_fill <= next_commit;
          end if;
        else
          -- Attempt was made to commit data when free space was
          -- not announced.
          commit_overrun <= '1';
        end if;
      end if;

      -- Is write attempted with no free space available?
      if (event_pre_write = '1' and
          event_pst_free = '0') then
        -- Attempt was made to write data when free space was
        -- not announced.
        write_overrun <= '1';
      end if;

      -- See discussion in fnet_tcp_buffer about requiring space for
      -- three events when reporting free space to outside.
      event_pst_free  <= '0';
      event_pst_free3 <= '0';
      if (free_words >= max_commit_plus_1) then
        event_pst_free  <= '1';
      end if;
      if (free_words >= 3*max_commit_plus_1) then
        event_pst_free3 <= '1';
      end if;

      -- Advance read pointer.
      read_at_word <= read_at_word_next;

      -- Reset of the output buffer resets also us.
      if (data_reset = '1') then
        -- Reset pointers.
        base_fill <= (others => '0');
        read_at_word <= (others => '0');
        -- Reset fail markers.
        write_overrun <= '0';
        commit_overrun <= '0';
        -- No space available during reset.
        event_pst_free3 <= '0';
      end if;

      -- Map the filling to the RAM block input interface.
      -- Latch the stuff going to the memory, such that it has maximum
      -- tolerance against timing.
      data_port_a_addr  <= std_logic_vector(base_fill +
                                            unsigned(event_pre_offset));
      data_port_a_rd    <= '0';
      data_port_a_wr    <= event_pre_write and event_pst_free;
      data_port_a_wdata <= event_pre_word;

      -- Another event can be inserted by the user.
      event_free <= event_pst_free3;

      -- Type conversion (and delay such that the write is completed before
      -- the read is performed).
      filled_words_slv <= std_logic_vector(filled_words);
    end if;
  end process;

  -- Map the reading to the RAM block output interface.
  data_port_b_addr <= std_logic_vector(read_at_word_next);
  data_port_b_rd   <= '1';
  next_word <= data_port_b_rdata;

  -- RAM block.
  dpdp_ram_data : entity work.fnet_ram_block_data
    generic map(addrbits => addrbits)
    port map (
      clk          => clk,
      port_a_addr  => data_port_a_addr,
      port_a_rd    => data_port_a_rd,
      port_a_wr    => data_port_a_wr,
      port_a_wdata => data_port_a_wdata,
      port_a_rdata => data_port_a_rdata,

      port_b_addr  => data_port_b_addr,
      port_b_rd    => data_port_b_rd,
      port_b_rdata => data_port_b_rdata
      );

  -- The LMD buffer + event formatter.
  fmt: entity work.efb_lmd_format_events
    port map (
      clk             => clk,

      avail_words     => filled_words_slv,
      in_word         => next_word,
      consume_word    => consume_word,

      subev_type_subtype      => subev_type_subtype,
      subev_procid_crate_ctrl => subev_procid_crate_ctrl,
      subev_ts_id             => subev_ts_id,

      i_flush         => flush,

      data_word       => data_word,
      data_offset     => data_offset,
      data_write      => data_write,
      data_commit     => data_commit,
      data_commit_len => data_commit_len,
      data_free       => data_free,
      data_reset      => data_reset,

      info_bufno      => info_bufno,
      info_evcnt      => info_evcnt
      );

end RTL;
