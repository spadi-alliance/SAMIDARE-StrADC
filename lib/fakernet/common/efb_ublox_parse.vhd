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

-- Since the protocol is binary, the sync characters can also occur
-- inside a message, as part of some other field.  Therefore, it is
-- also needed to count the characters of the messages in order to not
-- start decoding a message inside another message.  This is not
-- fool-proof, as in principle overlapping 'spurious' messages,
-- complete with headers and checksums can occur, which could then
-- stay out-of-sync forever.  Transmission errors could lead to such
-- situations.
--
-- One could consider only processing known messages.  That would
-- however be likely to lead to spuriously starting a 'known' message
-- inside a correct transmission of an unknown message.  Therefore all
-- messages are processed.  This only leads to problems with incorrect
-- transmissions.
--
-- Since the first ublox sync character is outside the NMEA range of
-- valid characters (0x20-0x7e), no special handling of NMEA messages
-- is needed.  A valid NMEA message cannot contain the ublox start
-- character.  It is harmless to search for the ublox start while
-- being served an NMEA message.

entity efb_ublox_parse is
  port (
    clk          : in  std_logic; -- Clock from board
    -- Input signals.
    i_data       : in  std_logic_vector(7 downto 0);
    i_has_data   : in  std_logic;
    -- Output signals.
    o_qerr          : out std_logic_vector(15 downto 0);
    o_has_qerr_data : out std_logic := '0';

    o_leap_info     : out std_logic_vector(1 downto 0);
    o_has_leap_info : out std_logic := '0'
    );

end efb_ublox_parse;

architecture RTL of efb_ublox_parse is

  subtype char  is unsigned(7 downto 0);

  type msg_state is (MSG_IDLE,
                     MSG_SYNC2,
                     MSG_MSG_CLASS,
                     MSG_MSG_ID,
                     MSG_LEN_LO,
                     MSG_LEN_HI,
                     MSG_DATA,
                     MSG_CK_B);

  signal state      : msg_state := MSG_IDLE;
  signal next_state : msg_state := MSG_IDLE;

  -- For identifying characters.
  constant char_0xb5   : char := "10110101"; -- b5
  constant char_0x62   : char := "01100010"; -- 62
  constant char_0x00   : char := "00000000"; -- 00
  constant char_0x01   : char := "00000001"; -- 01
  constant char_0x0d   : char := "00001101"; -- 0d
  constant char_0x10   : char := "00010000"; -- 10
  constant char_0x18   : char := "00011000"; -- 18
  constant char_0x26   : char := "00100110"; -- 26

  -- History of 1 recent digit.
  type char_history_array is array(0 downto 0) of char;
  signal input_history : char_history_array :=
    (others => (others => '0'));

  -- Latch the low and high parts of the length word.
  signal latch_length_lo : std_logic := '0';
  signal latch_length_hi : std_logic := '0';

  -- Count remaining characters.
  signal remain_count      : unsigned(7 downto 0) := (others => '0');
  signal remain_count_next : unsigned(7+1 downto 0) := (others => '0');

  -- Restart checksum calculation.
  signal cksum_init    : std_logic := '0';
  -- Check the checksums.
  signal cksum_a_check : std_logic := '0';
  signal cksum_b_check : std_logic := '0';

  -- Checksum.
  signal cksum_a : char := (others => '0');
  signal cksum_b : char := (others => '0');

  -- Does the checksum match.
  signal cksum_a_ok : std_logic := '0';
  signal cksum_b_ok : std_logic := '0';

  -- Did we have a good checksum a.
  signal cksum_a_good : std_logic := '0';

  -- Good time pulse time data?
  signal good_TIM_TP : std_logic := '0';
  -- Message matched (header) so far?
  signal match_TIM_TP : std_logic := '0';
  -- Individual character matched?
  signal fit_TIM_TP : std_logic := '0';

  -- Good time pulse time data?
  signal good_NAV_TIMELS : std_logic := '0';
  -- Message matched (header) so far?
  signal match_NAV_TIMELS : std_logic := '0';
  -- Individual character matched?
  signal fit_NAV_TIMELS : std_logic := '0';

  -- Quantisation error, i.e. offset of PPS to true top-of-second, in
  -- ps.  In principle field is 32 bits, but never(?) exceeds a much
  -- smaller range.
  signal qerr       : unsigned(15 downto 0) := (others => '0');
  -- From flags register.
  signal qerr_valid : std_logic := '0';

  -- Upcoming leap second
  signal leap_change : unsigned(1 downto 0) := (others => '0');
  -- From flags register.
  signal leap_change_valid : std_logic := '0';

begin

  -- Feed the input history.
  input_history(0) <= unsigned(i_data);

  -- Compare checksums.
  cksum_a_ok <= '1' when (input_history(0) = cksum_a) else '0';
  cksum_b_ok <= '1' when (input_history(0) = cksum_b) else '0';

  -- Prepare downcounting (to look for wrap).
  remain_count_next <= ('0' & remain_count) - 1;
  
  process(state, input_history, remain_count, remain_count_next)
  begin

    -- Default values.
    latch_length_lo <= '0';
    latch_length_hi <= '0';

    cksum_init      <= '0';

    cksum_a_check   <= '0';
    cksum_b_check   <= '0';

    fit_TIM_TP      <= '1';
    fit_NAV_TIMELS  <= '1';
    
    next_state <= state;

    case state is

      when MSG_IDLE =>
        if (input_history(0) = char_0xb5) then
          next_state <= MSG_SYNC2;
        end if;

      when MSG_SYNC2 =>
        if (input_history(0) = char_0x62) then
          next_state <= MSG_MSG_CLASS;
        else
          next_state <= MSG_IDLE;
        end if;
        cksum_init <= '1';

      when MSG_MSG_CLASS =>
        if (input_history(0) /= char_0x0d) then fit_TIM_TP     <= '0'; end if;
        if (input_history(0) /= char_0x01) then fit_NAV_TIMELS <= '0'; end if;
        next_state <= MSG_MSG_ID;

      when MSG_MSG_ID =>
        if (input_history(0) /= char_0x01) then fit_TIM_TP     <= '0'; end if;
        if (input_history(0) /= char_0x26) then fit_NAV_TIMELS <= '0'; end if;
        next_state <= MSG_LEN_LO;

      when MSG_LEN_LO =>
        if (input_history(0) /= char_0x10) then fit_TIM_TP     <= '0'; end if;
        if (input_history(0) /= char_0x18) then fit_NAV_TIMELS <= '0'; end if;
        next_state <= MSG_LEN_HI;
        latch_length_lo <= '1';

      when MSG_LEN_HI =>
        if (input_history(0) /= char_0x00) then fit_TIM_TP     <= '0'; end if;
        if (input_history(0) /= char_0x00) then fit_NAV_TIMELS <= '0'; end if;
        next_state <= MSG_DATA;
        latch_length_hi <= '1';
        
      when MSG_DATA =>
        -- Wrap remain count?
        if (remain_count_next(remain_count_next'high) = '1') then
          next_state <= MSG_CK_B;
          -- We are at the first checksum byte.
          cksum_a_check <= '1';
        end if;

      when MSG_CK_B =>
        next_state <= MSG_IDLE;
        cksum_b_check <= '1';

    end case;
  end process;

  process (clk)
  begin
    if (rising_edge(clk)) then

      good_TIM_TP <= '0';
      good_NAV_TIMELS <= '0';

      -- Only process when new character is available.
      if (i_has_data = '1') then
        state <= next_state;

        -- Data length handling.
        if (latch_length_lo = '1') then
          remain_count <= unsigned(input_history(0));
        elsif (latch_length_hi = '1') then
          -- In principle, the hi length should be latched.  But we
          -- ignore that for now.  In case a garbage value is
          -- encountered, it may take many characters until the state
          -- machine gets back to idle state to search for a new
          -- possible message start.
          null;
        else
          remain_count <= remain_count_next(remain_count'range);
        end if;

        -- Checksum handling.
        if (cksum_init = '1') then
          cksum_a <= (others => '0');
          cksum_b <= (others => '0');
          match_TIM_TP     <= fit_TIM_TP;
          match_NAV_TIMELS <= fit_NAV_TIMELS;
        else
          cksum_a <= cksum_a + input_history(0);
          -- Note that this happens in the following character.
          cksum_b <= cksum_b + cksum_a;
          match_TIM_TP     <= match_TIM_TP     and fit_TIM_TP;
          match_NAV_TIMELS <= match_NAV_TIMELS and fit_NAV_TIMELS;
        end if;

        if (cksum_a_check = '1') then
          cksum_a_good <= cksum_a_ok;
        end if;

        if (cksum_b_check = '1' and
            cksum_a_good = '1' and
            cksum_b_ok = '1') then
          -- We have completed the message successfully.
          good_TIM_TP     <= match_TIM_TP;
          good_NAV_TIMELS <= match_NAV_TIMELS;
        end if;

        -- Data from TIM-TP message.
        if (remain_count = 16-8) then
          qerr(7  downto  0) <= input_history(0);
        end if;
        if (remain_count = 16-9) then
          qerr(15 downto  8) <= input_history(0);
        end if;
        if (remain_count = 16-14) then
          -- Time quantization error is valid.
          qerr_valid         <= not input_history(0)(4);
        end if;

        -- Data from NAV-TIMELS message.
        if (remain_count = 24-11) then
          leap_change        <= input_history(0)(1 downto 0);
        end if;
        if (remain_count = 24-23) then
          leap_change_valid  <= input_history(0)(1);
        end if;

      end if;
    end if;
  end process;

  -- Alias to output variables.
  o_qerr          <= std_logic_vector(qerr);
  o_has_qerr_data <= good_TIM_TP and qerr_valid;

  o_leap_info     <= std_logic_vector(leap_change);
  o_has_leap_info <= good_NAV_TIMELS and leap_change_valid;
end RTL;
