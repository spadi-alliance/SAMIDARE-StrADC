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

use work.fnet_records.all; -- For word32_array.
use work.fnet_util_pkg.all;

-- The input buffer has events:
--
-- First 32-word of each event is an internal header:
--
-- 15.. 0  Length of payload (in 32-bit words) (not including timestamp).
-- 19..16  Trigger.
-- 21..20  Two-bit event count.
-- 22      Has-timestamp mark.
-- 23      Timestamp error bit.
-- 31..24  Timestamp ID (8 bits).
--
-- When timestamp is present, the next two 32-bit words provide the
-- timestamp.  Low 32-bits first.  They are not counted in the payload
-- length.

entity efb_lmd_format_events is
  port (
    clk             : in  std_logic;

    -- Input (from RAM block).
    avail_words     : in  std_logic_vector;
    in_word         : in  std_logic_vector(31 downto 0);
    consume_word    : out std_logic;

    -- Semi-static info to write in output.
    subev_type_subtype      : in  std_logic_vector(31 downto 0);
    subev_procid_crate_ctrl : in  std_logic_vector(31 downto 0);
    subev_ts_id             : in  std_logic_vector( 7 downto 0);

    -- Flush the LMD buffer.
    i_flush         : in  std_logic;

    -- Output.
    data_word       : out std_logic_vector(31 downto 0);
    data_offset     : out std_logic_vector;
    data_write      : out std_logic;
    data_commit_len : out std_logic_vector;
    data_commit     : out std_logic;
    data_free       : in  std_logic;
    data_reset      : in  std_logic;

    -- Info output.
    info_bufno      : out std_logic_vector(31 downto 0);
    info_evcnt      : out std_logic_vector(31 downto 0)
    );

end efb_lmd_format_events;

architecture RTL of efb_lmd_format_events is

  constant ev_words_bits     : natural := 8; -- 0..511
  constant ev_words          : natural := (2 ** ev_words_bits);

  constant bufwords_bits     : natural := 9; -- 16384
  constant bufwords          : natural := (2 ** bufwords_bits);
  constant bufsize           : natural := (bufwords*4);

  -- Going from buffer size 4096 to 16384 saves ~20 % CPU in ucesb
  -- network input thread.

  -- Number of words in the word multiplexer.
  constant num_open_info    : integer := 4;  --  0- 3
  constant num_buf_header   : integer := 12; --  4-15
  constant num_event_header : integer := 4;  -- 16-19
  constant num_subev_header : integer := 3;  -- 20-22
  constant num_ts_wr        : integer := 5;  -- 23-27 Good if ends aligned 4.
  constant num_payload      : integer := 1;  -- 28
  constant num_pad          : integer := 1;  -- 29

  -- Offsets of words in the word multiplexer.
  constant off_open_info    : integer := 0;
  constant off_buf_header   : integer := off_open_info    + num_open_info;
  constant off_event_header : integer := off_buf_header   + num_buf_header;
  constant off_subev_header : integer := off_event_header + num_event_header;
  constant off_ts_wr        : integer := off_subev_header + num_subev_header;
  constant off_payload      : integer := off_ts_wr        + num_ts_wr;
  constant off_pad          : integer := off_payload      + num_payload;

  type wrk_state is (PREPARE_OPEN,
                     START_BUFFER,
                     WAIT_EVENT,
                     READ_EVENT_HEADER,
                     ACCEPT_EVENT,
                     PREPARE_EVENT,
                     READ_TS_LOW,
                     READ_TS_HIGH,
                     PREPARE_EV_HEADER,
                     WRITE_EV_HEADER,
                     COPY_PAYLOAD,
                     PREPARE_PAD,
                     WRITE_PAD,
                     PREPARE_BUF_HEADER,
                     WRITE_BUF_HEADER,
                     FAILED_INPUT);

  signal state : wrk_state := PREPARE_OPEN;

  -- From outside
  signal has_in_word : std_logic := '1';
  signal use_in_word : std_logic := '0';

  -- Input event header (internal format).
  signal inevh_payload_words : unsigned(ev_words_bits-1 downto 0) :=
    (others => '0');
  signal inevh_trig   : unsigned(3 downto 0) := (others => '0');
  signal inevh_cnt    : unsigned(1 downto 0) := (others => '0');
  signal inevh_ts_has : std_logic := '0';
  signal inevh_ts_err : std_logic := '0';

  -- Latched info about current event.
  signal cur_ev_words : unsigned(ev_words_bits-1 downto 0) :=
    (others => '0');
  signal cur_ev_trig  : unsigned(3 downto 0) := (others => '0');
  signal cur_ev_cnt   : unsigned(1 downto 0) := (others => '0');
  -- Latched timestamp info.
  signal ts_has  : std_logic := '0';
  signal ts_err  : std_logic := '0';
  signal ts_full : std_logic_vector(63 downto 0) := (others => '0');

  -- For the buffer header.
  signal bufh_no    : unsigned(31 downto 0) := (others => '0');
  signal bufh_used  : unsigned(15 downto 0) := (others => '0');
  signal bufh_evcnt : unsigned(31 downto 0) := (others => '0');

  -- For the event header.
  signal evh_dlen_words : unsigned(ev_words_bits-1 downto 0) :=
    (others => '0');
  signal evh_dlen : unsigned(31 downto 0) := (others => '0');
  signal evh_trig : std_logic_vector(3 downto 0) := (others => '0');
  signal evh_type_subtype : std_logic_vector(31 downto 0) :=
    i2slv16(1) & i2slv16(10);
  signal evh_eventno : unsigned(31 downto 0) := (others => '0');

  -- For the subevent header.
  signal sevh_dlen_words : unsigned(ev_words_bits-1 downto 0) :=
    (others => '0');
  signal sevh_dlen : unsigned(31 downto 0) := (others => '0');
  signal sevh_type_subtype : std_logic_vector(31 downto 0) := (others => '0');
  signal sevh_procid_crate_ctrl : std_logic_vector(31 downto 0) :=
    (others => '0');

  -- Latch for payload word.
  signal in_word_prev : std_logic_vector(31 downto 0) := (others => '0');

  -- Multiplexer of words to generate.
  signal mda : word32_array(31 downto 0) :=
    (others => (others=>'0'));

  -- Where to pick input words from word multiplexer.
  signal mux_offset : unsigned( 4 downto 0) := (others => '0');
  signal mux_offset_prev : unsigned(mux_offset'range) := (others => '0');

  -- Where (and when) to write data.
  signal out_offset : unsigned(bufwords_bits-1+1 downto 0) := (others => '0');
  signal out_write  : std_logic := '0';
  signal out_offset_prev : unsigned(out_offset'range) := (others => '0');

  -- Commit the written buffer (or open info).
  signal out_commit : std_logic := '0';
  -- Preparing a buffer (else open info).
  signal is_buffer  : std_logic := '0';

  -- Further items to process in current state.
  signal count      : unsigned(ev_words_bits-1   downto 0) := (others => '0');
  signal count_next : unsigned(ev_words_bits-1+1 downto 0) := (others => '0');
  signal count_wrap : std_logic := '0';

  -- Number of words left for use in current buffer.
  signal buf_words_left      : unsigned(bufwords_bits-1   downto 0) :=
    (others => '0');
  signal buf_words_left_next : unsigned(bufwords_bits-1+1 downto 0) :=
    (others => '0');
  signal buf_words_left_wrap : std_logic := '0';

  -- Number of words used in current buffer.
  -- Header means we never reach 2^n.
  signal buf_words_used : unsigned(bufwords_bits-1 downto 0) :=
    (others => '0');
  -- Number of events in current buffer.
  signal buf_events     : unsigned(15 downto 0) := (others => '0');

begin

  -- Open info.
  mda(off_open_info+0) <= i2slv32(      1); --  0: Test bit (1);
  mda(off_open_info+1) <= i2slv32(bufsize); --  4: Buffers size (16384).
  mda(off_open_info+2) <= i2slv32(      1); --  8: Buffers per stream (1).
  mda(off_open_info+3) <= i2slv32(      0); -- 12: Dummy (0);
  --                                           16  Total length (bytes).

  -- Prepare for buffer header.
  bufh_used(bufh_used'left downto buf_words_used'left+2) <= (others => '0');
  bufh_used(buf_words_used'left + 1 downto 1) <= buf_words_used;
  bufh_evcnt(bufh_evcnt'left downto buf_events'left+1) <= (others => '0');
  bufh_evcnt(buf_events'left downto 0) <= buf_events;

  -- Buffer header.
  mda(off_buf_header+ 0) <= i2slv32((bufsize-48)/2);   --  0: l_dlen
  mda(off_buf_header+ 1) <= i2slv16(1) & i2slv16(10);  --  4: i_type &i_subtype
  mda(off_buf_header+ 2) <= i2slv16(0) &               --     h_end & h_begin
                            std_logic_vector(bufh_used);  --  8: i_used
  mda(off_buf_header+ 3) <= std_logic_vector(bufh_no);    -- 12: l_buf
  mda(off_buf_header+ 4) <= std_logic_vector(bufh_evcnt); -- 16: l_evt
  mda(off_buf_header+ 5) <= i2slv32(   0); -- 20: l_current_i
  mda(off_buf_header+ 6) <= i2slv32(   0); -- 24: l_time[0]
  mda(off_buf_header+ 7) <= i2slv32(   0); -- 28: l_time[1]
  mda(off_buf_header+ 8) <= i2slv32(   1); -- 32: l_free[0] endian mark
  mda(off_buf_header+ 9) <= i2slv32(   0); -- 26: l_free[1]
  mda(off_buf_header+10) <= i2slv32(   0); -- 40: l_free[2]
  mda(off_buf_header+11) <= i2slv32(   0); -- 44: l_free[3]
  --                                          48  Total length (bytes).

  -- Prepare for event header.
  evh_dlen(evh_dlen_words'left+1 downto 1) <= evh_dlen_words;
  evh_trig <= std_logic_vector(cur_ev_trig);

  -- Event header
  mda(off_event_header+ 0) <= std_logic_vector(evh_dlen);    --  0: l_dlen
  mda(off_event_header+ 1) <= evh_type_subtype;         -- i_type & i_subtype
  mda(off_event_header+ 2) <= i2slv16(0) &                   --  8: i_dummy &
                              "00000000"&"0000" & evh_trig;  --     i_trig
  mda(off_event_header+ 3) <= std_logic_vector(evh_eventno); -- 12: l_dlen
  --                                                            16  Total.

  -- Prepare for subevent header.
  sevh_dlen(evh_dlen_words'left+1 downto 1) <= sevh_dlen_words;
  sevh_type_subtype      <= subev_type_subtype;
  sevh_procid_crate_ctrl <= subev_procid_crate_ctrl;

  -- Subevent header
  mda(off_subev_header+ 0) <= std_logic_vector(sevh_dlen);   --  0: l_dlen
  mda(off_subev_header+ 1) <= sevh_type_subtype;       -- i_type & i_subtype
  mda(off_subev_header+ 2) <= sevh_procid_crate_ctrl;        --  8 i_procid&...
  --                                                            12  Total.

  -- WR (White Rabbit) timestamp mark.
  mda(off_ts_wr+ 0)        <= "00000000" & "0000000" & ts_err &
                              subev_ts_id & "00000000";
  mda(off_ts_wr+ 1)        <= i2slv16(16#03e1#) & ts_full(15 downto  0);
  mda(off_ts_wr+ 2)        <= i2slv16(16#04e1#) & ts_full(31 downto 16);
  mda(off_ts_wr+ 3)        <= i2slv16(16#05e1#) & ts_full(47 downto 32);
  mda(off_ts_wr+ 4)        <= i2slv16(16#06e1#) & ts_full(63 downto 48);

  -- Event payload.
  mda(off_payload)         <= in_word_prev;

  -- Buffer padding.
  mda(off_pad)             <= i2slv16(16#8050#) & i2slv16(16#4144#); -- .PAD

  -- Are more words available from the input?
  has_in_word <= '1' when (avail_words /= (avail_words'range => '0')) else '0';

  -- Prepare values for counters (that check wrap).
  count_next <= ("0" & count) - 1;
  count_wrap <= count_next(count_next'high);

  buf_words_left_next <= ("0" & buf_words_left) - 1;
  buf_words_left_wrap <= buf_words_left_next(buf_words_left_next'high);

  -- Alias input event header word.
  inevh_payload_words <=
    unsigned(in_word(inevh_payload_words'range)); -- 15..0
  inevh_trig          <= unsigned(in_word(19 downto 16));
  inevh_cnt           <= unsigned(in_word(21 downto 20));
  inevh_ts_has        <= in_word(22);
  inevh_ts_err        <= in_word(23);

  process (clk)
  begin
    if (rising_edge(clk)) then
      -- Default, no write.
      out_write  <= '0';
      out_commit <= '0';

      -- By default count down.
      count <= count_next(count'range);

      case (state) is

        when PREPARE_OPEN =>
          -- Source data.
          mux_offset <= to_unsigned(off_open_info, mux_offset'length);
          -- Start write at current offset.
          out_offset <= (others => '0');
          count <= to_unsigned(4, count'length);
          -- Commit the correct length.
          is_buffer <= '0';
          -- Explicitly do *not* reset the buffer or event counters.
          -- bufh_no     <= (others => '0');
          -- evh_eventno <= (others => '0');

          -- Use the buffer header writer.
          -- In both cases next thing is a fresh buffer.
          state <= WRITE_BUF_HEADER;

        when START_BUFFER =>
          -- Start write at current offset.
          out_offset <= (others => '0');
          -- Reserve space for the buffer header.
          buf_words_left <= to_unsigned(bufsize - 12, buf_words_left'length);
          out_offset <= to_unsigned(12, out_offset'length);
          buf_words_used <= (others => '0');
          buf_events <= (others => '0');
          -- Commit the correct length.
          is_buffer <= '1';
          -- Wait until output space is available.
          if (data_free = '1') then
            -- Check/wait for an event to become available.
            state <= WAIT_EVENT;
          end if;

        when WAIT_EVENT =>
          -- We cannot process data until there is at least one word
          -- in the event buffer (the internal header).
          if (has_in_word = '1') then
            state <= READ_EVENT_HEADER;
          elsif (i_flush = '1') then
            state <= PREPARE_PAD;
          end if;

        when READ_EVENT_HEADER =>
          -- Latch the internal header data.  One cycle later to allow the
          -- write to the RAM block to have completed.
          cur_ev_words <= inevh_payload_words;
          cur_ev_trig  <= inevh_trig;
          cur_ev_cnt   <= inevh_cnt;
          ts_has       <= inevh_ts_has;
          ts_err       <= inevh_ts_err;
          state <= PREPARE_EVENT;

        when PREPARE_EVENT =>
          -- Validate the info.  The length must be less or equal than
          -- the number of words available.  Else there is a
          -- malfunction.
          if (false) then
          end if;
          -- Does the event fit in the current buffer?
          -- Count with the worst case header (including timestamp).
          if (cur_ev_words + (4+3+5) > buf_words_left) then
            state <= PREPARE_PAD;
          else
            state <= ACCEPT_EVENT;
          end if;

        when ACCEPT_EVENT =>
          -- This state is to report the header word as used at this
          -- point-of-no-return, where the event *will* be formatted.
          if (ts_has = '1') then
            state <= READ_TS_LOW;
          else
            state <= PREPARE_EV_HEADER;
          end if;

        when READ_TS_LOW =>
          ts_full(31 downto 0) <= in_word;
          state <= READ_TS_HIGH;

        when READ_TS_HIGH =>
          ts_full(63 downto 32) <= in_word;
          state <= PREPARE_EV_HEADER;

        when PREPARE_EV_HEADER =>
          -- Increment counters.
          buf_events      <= buf_events + 1;
          evh_eventno     <= evh_eventno + 1;

          mux_offset <= to_unsigned(off_event_header, mux_offset'length);

          if (ts_has = '1') then
            -- Timestamp info, format as WR timestamp in subevent.
            -- Seven header words plus five WR words.
            count <= to_unsigned(4+3+5, count'length);
            -- Note: the WR words follow directly after the subevent
            -- header in the template, so only difference is how much
            -- data is copied.
            evh_dlen_words  <= cur_ev_words + (7-2+5);
            sevh_dlen_words <= cur_ev_words + (3-2+5);
          else
            -- No timestamp. Seven header words to be emitted.
            count <= to_unsigned(4+3, count'length);
            evh_dlen_words  <= cur_ev_words + (7-2);
            sevh_dlen_words <= cur_ev_words + (3-2);
          end if;

          state <= WRITE_EV_HEADER;

        when WRITE_EV_HEADER =>
          -- Write the event + subevent header words, and timestamp.
          mux_offset <= mux_offset + 1;

          if (count_wrap = '1') then
            mux_offset <= to_unsigned(off_payload, mux_offset'length);
            count <= cur_ev_words;
            state <= COPY_PAYLOAD;
          else
            out_offset <= out_offset + 1;
            out_write  <= '1';

            buf_words_left <= buf_words_left_next(buf_words_left'range);
            buf_words_used <= buf_words_used + 1;
          end if;

        when COPY_PAYLOAD =>
          if (count_wrap = '1') then
            state <= WAIT_EVENT;
          else
            -- mux_offset does not change!
            out_offset <= out_offset + 1;
            out_write  <= '1';

            buf_words_left <= buf_words_left_next(buf_words_left'range);
            buf_words_used <= buf_words_used + 1;
          end if;

        when PREPARE_PAD =>
          mux_offset <= to_unsigned(off_pad, mux_offset'length);
          state <= WRITE_PAD;

        when WRITE_PAD =>
          -- TODO: use count for downcounting.
          if (buf_words_left_wrap = '1') then
            state <= PREPARE_BUF_HEADER;
          else
            out_offset <= out_offset + 1;
            out_write  <= '1';
          end if;
          -- Will not be used beyond end, so can always be done.
          buf_words_left <= buf_words_left_next(buf_words_left'range);

        when PREPARE_BUF_HEADER =>
          mux_offset <= to_unsigned(off_buf_header, mux_offset'length);
          out_offset <= (others => '0');
          count <= to_unsigned(12, count'length);
          -- Increase buffer number.
          bufh_no <= bufh_no + 1;

          state <= WRITE_BUF_HEADER;

        when WRITE_BUF_HEADER =>
          mux_offset <= mux_offset + 1;

          -- If we latch these sevral times does not matter, the
          -- values are constant.  We latch them for two reasons:
          -- to have a latch stage, to reduce timing issues.  And
          -- nice to latch when buffer has been emitted.
          info_bufno <= std_logic_vector(bufh_no);
          info_evcnt <= std_logic_vector(evh_eventno);

          if (count_wrap = '1') then
            out_commit <= '1';
            state <= START_BUFFER;
          else
            out_offset <= out_offset + 1;
            out_write  <= '1';
          end if;

        when FAILED_INPUT =>
          null;

      end case;

      if (data_reset = '1') then
        state <= PREPARE_OPEN;
      end if;

      -- The picking of the data by the multiplexer is done one cycle
      -- later (such that payload memory reading can keep up).
      mux_offset_prev <= mux_offset;
      out_offset_prev <= out_offset;

      in_word_prev <= in_word;

      data_word   <= mda(to_integer(mux_offset_prev));
      data_offset <= std_logic_vector(out_offset_prev);
      data_write  <= out_write;
      -- Thus also the commit one cycle later.  With the appropriate size.
      data_commit_len <= (others => '0');
      data_commit_len(bufwords_bits) <=     is_buffer;
      data_commit_len(2)             <= not is_buffer;
      data_commit <= out_commit;
    end if;
  end process;

  -- Calculate asynchronously, in order to be one cycle quicker.
  use_in_word <=
    '1' when ((state = ACCEPT_EVENT) or
              (state = READ_TS_LOW) or
              (state = READ_TS_HIGH) or
              ((state = COPY_PAYLOAD) and (count_wrap = '0'))) else '0';

  consume_word <= use_in_word;
end RTL;
