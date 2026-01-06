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

-- The configuration parser handles two inputs:
--
-- - The configuration text.  This is delivered from flash via SPI
--   reads.
--
-- - A configuration memory.  It consist of a tree of lists of
--   accepted characters.  Each node in the tree corresponds to having
--   parsed a certain string of characters of an identifier.  The node
--   has a list of accepted further characters at that point.
--
--   - The first item of the list may accept no further characters,
--     i.e. marks a match when the string ends.  In this case, it
--     contains an index describing where the successfully parsed item
--     shall be written, as well as flags/index describing the format
--     of the item.
--
--     liiiiiiiii11ffff  - l: last item mark (end-of-list)
--                       - i: 9 bits item index
--                       - f: 4 bits of flags
--
--     In case no character matches, the parsing has failed.
--
--   - Each accepted character is associated with a jump offset to the
--     first item of the next node.
--
--     looooooooocccccc  - l: last item mark (end-of-list)
--                       - o: 9 bits offset (of next list)
--                       - c: 6 bits character (26+10+1=37)
--                            (Note that the high two bits of cc
--                             are never '11')
--                            (a-z = 1-26, 0-9 = 32-41, _ = 31)
--
--   - The itemcode '11' of a first entry distinguishes it from accepted
--     characters.
--
--   Parse flags:
--
--   - Integer, i.e. each new digit multiplies the old by 10 and adds
--     the new.  (Multiply by 10 is to shift with one and three and
--     add those.)
--
--     - IP number delimiter acceptance flag: Accept '.', shifts
--       current value by 8 bits.  Also makes multiplication by 10 not
--       carry value into higher bits after first 8.
--
--     - If first two characters are '0x', parse as hexadecimal.
--
--     - If first two characters are '0b', parse as binary.
--       (Not implemented yet.)
--
--   - Hexadecimal, each new value shifts old by 4 bits.
--
--     - Delimiter acceptance flag: Accept and ignore ':'.
--
--   - String.  Characters are written to the given address.
--     The first non-space character gives the termination character.
--     Thus e.g. '"' can be used.
--
--   - '#' is considered an comment until the end-of-line, except in
--     string mode.
--
-- - Option names can be followed by indices in brackets.
--
-- - Between option names and their values, either ':' or '='
--   delimiters must be present.
--
-- - Options can be separated by ';', but not required.
--
-- - Whitespace is generally eaten between all items.
--
-- - Parsing is not case sensitive.
--   (Characters in strings are not modified.)

use work.fnet_util_pkg.all; -- For fnet_or_reduction.
use work.text_config_data.all;

entity efb_text_config_parse is
  port (
    clk           : in  std_logic;
    -- Input data.
    i_reset_parse : in  std_logic;
    i_data        : in  std_logic_vector(7 downto 0);
    i_has_data    : in  std_logic;
    -- Output value (one at a time).
    o_value       : out std_logic_vector(47 downto 0) := (others => '0');
    o_value_index : out std_logic_vector( 8 downto 0) := (others => '0');
    o_has_value   : out std_logic := '0';
    -- Waiting for a new character.
    o_wait_char   : out std_logic := '0';
    -- Overall completion status.
    o_done        : out std_logic := '0';
    o_fail        : out std_logic := '0';
    o_fail_code   : out std_logic_vector( 3 downto 0) := (others => '0');
    -- Debug output.
    o_dbg_has_data_pend : out std_logic := '0';
    o_dbg_state_code    : out std_logic_vector( 4 downto 0) := (others => '0')
    );

end efb_text_config_parse;

architecture RTL of efb_text_config_parse is

  subtype char  is unsigned(7 downto 0);

  type msg_state is (MSG_GROUND,
                     MSG_IDENT,
                     MSG_IDENT_END,

                     MSG_IDENT_FIND_CHAR,
                     MSG_IDENT_FIND_OPTION,

                     MSG_OPTION_BRACKET_L_END,
                     MSG_OPTION_INDEX,
                     MSG_OPTION_INDEX_END,
                     MSG_OPTION_BRACKET_R_END,

                     MSG_OPTION_SWITCH,

                     MSG_STRING_INIT,

                     MSG_HEX,
                     MSG_HEX_COLON,
                     MSG_HEX_END,

                     MSG_DECIMAL,
                     MSG_DECIMAL_LEAD_0,
                     MSG_DECIMAL_DOT,
                     MSG_DECIMAL_END,
                     MSG_DECIMAL_POST_DOT,

                     MSG_COMMENT,

                     MSG_DONE,
                     MSG_FAIL);

  signal state      : msg_state := MSG_GROUND;
  signal next_state : msg_state := MSG_GROUND;
  -- For comment handling:
  signal keep_state : msg_state := MSG_GROUND;
  signal hold_state : msg_state := MSG_GROUND;

  signal state_no   : integer := 0;

  type msg_fail_reason is (MSG_FAIL_UNKNOWN,
                           MSG_FAIL_OPTION_NAME_BAD_START,
                           MSG_FAIL_OPTION_NAME_BAD_CHAR,
                           MSG_FAIL_OPTION_NOT_FOUND,
                           MSG_FAIL_OPTION_BAD_FLAGS,
                           MSG_FAIL_OPTION_NOT_FOUND_PARTIAL,
                           MSG_FAIL_OPTION_INDEX_MALFORMAT,
                           MSG_FAIL_OPTION_BAD_COLON_EQUALS,
                           MSG_FAIL_HEX_MALFORMAT,
                           MSG_FAIL_HEX_OVERFLOW,
                           MSG_FAIL_DECIMAL_MALFORMAT,
                           MSG_FAIL_DECIMAL_OVERFLOW,
                           MSG_FAIL_OPTION_STRING_NOT_HANDLED);

  signal fail_reason      : msg_fail_reason := MSG_FAIL_UNKNOWN;
  signal hold_fail_reason : msg_fail_reason := MSG_FAIL_UNKNOWN;

  signal fail_reason_no   : integer := 0;

  -- For identifying separator characters.
  constant char_tab       : char := "00001001"; -- 09
  constant char_NL        : char := "00001010"; -- 0a
  constant char_CR        : char := "00001101"; -- 0d
  constant char_space     : char := "00100000"; -- 20
  constant char_hash      : char := "00100011"; -- 23
  constant char_dot       : char := "00101110"; -- 2e
  constant char_colon     : char := "00111010"; -- 3a
  constant char_0         : char := "00110000"; -- 30
  constant char_semicolon : char := "00111011"; -- 3b
  constant char_equals    : char := "00111101"; -- 3d
  constant char_uc_X      : char := "01011000"; -- 58
  constant char_lc_x      : char := "01111000"; -- 78
  constant char_bracket_l : char := "01011011"; -- 5b
  constant char_bracket_r : char := "01011101"; -- 5d

  -- Data input.
  signal data_pend       : std_logic_vector(7 downto 0) := (others => '0');
  signal has_data_pend   : std_logic := '0';

  -- Input character accepted.
  signal accept_data     : std_logic := '0';
  -- Had at least one char of current token.
  signal accept_part     : std_logic := '0';
  signal had_part        : std_logic := '0';

  -- Finished parsing option value, report it.
  signal accept_value    : std_logic := '0';
  -- Option index (at destination).
  signal accept_index    : std_logic := '0';
  -- For string, once per character.
  signal got_value       : std_logic := '0';

  -- Parsing of option name.
  signal config_parse_got_char       : std_logic := '0';
  signal config_parse_matched_char   : std_logic := '0';
  signal config_parse_matched_option : std_logic := '0';
  signal config_parse_next_slot      : std_logic := '0';
  signal config_parse_reset          : std_logic := '0';

  -- Address of configuration memory.
  signal config_addr        : unsigned( 8 downto 0) := (others => '1');
  -- Next and actual read address.
  signal config_addr_next   : unsigned( 8 downto 0) := (others => '0');
  -- Value read from configuration memory.
  signal config_slot        : std_logic_vector(15 downto 0) := (others => '0');
  -- Break it down to its parts.
  signal config_slot_offset : std_logic_vector( 8 downto 0) := (others => '0');
  signal config_slot_mark   : std_logic_vector( 1 downto 0) := (others => '0');
  signal config_slot_last   : std_logic                     := '0';
  signal config_slot_id     : std_logic_vector( 5 downto 0) := (others => '0');
  signal config_slot_index  : std_logic_vector( 8 downto 0) := (others => '0');
  signal config_slot_flags  : std_logic_vector( 3 downto 0) := (others => '0');

  -- Latched slot=option index (plus option index, if given).
  signal slot_index : unsigned( 8 downto 0) := (others => '0');

  signal lookfor_id : std_logic_vector(5 downto 0) := (others => '0');

  signal cur_hi : unsigned(3 downto 0) := (others => '0');
  signal cur_lo : unsigned(3 downto 0) := (others => '0');

  signal cur_digit   : unsigned(3 downto 0) := (others => '0');
  signal cur_hex     : unsigned(3 downto 0) := (others => '0');
  signal cur_hex_add : unsigned(3 downto 0) := (others => '0');
  signal cur_is_blank : std_logic := '0';
  signal cur_is_colon_equals : std_logic := '0';
  signal cur_is_0 : std_logic := '0';
  signal cur_is_hash : std_logic := '0';
  signal cur_is_colon : std_logic := '0';
  signal cur_is_semicolon : std_logic := '0';
  signal cur_is_dot : std_logic := '0';
  signal cur_is_x : std_logic := '0';
  signal cur_is_bracket_l : std_logic := '0';
  signal cur_is_bracket_r : std_logic := '0';
  signal cur_is_alpha : std_logic := '0';
  signal cur_is_alpha_hex : std_logic := '0';
  signal cur_is_digit : std_logic := '0';
  signal cur_is_hex : std_logic := '0';
  signal cur_alpha_digit_id : std_logic_vector(5 downto 0) := (others => '0');
  signal cur_alpha_digit_id_hi : std_logic_vector(1 downto 0) := (others=>'0');

  -- Value handling.  Keep track of value, and if it had overflow.
  signal value                 : unsigned(47 downto 0) := (others => '0');
  signal value_overflow        : std_logic := '1';

  -- Actions to do on the value.
  signal value_shift_hex          : std_logic := '0';
  signal value_shift_decimal_byte : std_logic := '0';
  signal value_shift_decimal      : std_logic := '0';
  signal value_reset              : std_logic := '0';

  -- Preliminary new values, for different actions.
  signal vs_decimal            : unsigned(31 downto 0) := (others => '0');
  signal vs_decimal_next       : unsigned(32 downto 0) := (others => '0');
  signal vs_decimal_next_carry : std_logic := '0';
  signal vs_decimal_next_ofl   : std_logic := '0';
  signal vs_hex_next           : unsigned(47 downto 0) := (others => '0');
  signal vs_hex_next_ofl       : std_logic := '0';
  signal vs_binary_next        : unsigned(47 downto 0) := (others => '0');
  signal vs_binary_next_ofl    : std_logic := '0';

  -- Flags to report when parsing finished.
  signal async_done : std_logic := '0';
  signal async_fail : std_logic := '0';
  signal done       : std_logic := '0';
  signal fail       : std_logic := '0';

  -- History of 1 recent character.
  type char_history_array is array(0 downto 0) of char;
  signal cur : char_history_array :=
    (others => (others => '0'));

begin

  -- Feed the input history.
  cur(0) <= unsigned(data_pend);

  cur_is_blank        <= '1' when (cur(0) = char_space or
                            cur(0) = char_tab or
                            cur(0) = char_NL or
                            cur(0) = char_CR) else '0';

  cur_is_colon_equals <= '1' when (cur(0) = char_colon or
                                   cur(0) = char_equals) else '0';

  cur_is_hash         <= '1' when (cur(0) = char_hash) else '0';
  cur_is_dot          <= '1' when (cur(0) = char_dot) else '0';
  cur_is_colon        <= '1' when (cur(0) = char_colon) else '0';
  cur_is_0            <= '1' when (cur(0) = char_0) else '0';
  cur_is_semicolon    <= '1' when (cur(0) = char_semicolon) else '0';

  cur_is_x            <= '1' when (cur(0) = char_uc_X or
                                cur(0) = char_lc_x) else '0';

  cur_is_bracket_l    <= '1' when (cur(0) = char_bracket_l) else '0';
  cur_is_bracket_r    <= '1' when (cur(0) = char_bracket_r) else '0';

  cur_hi <= unsigned(std_logic_vector(cur(0)(7 downto 4)));
  cur_lo <= unsigned(std_logic_vector(cur(0)(3 downto 0)));

  -- A-Z or a-z or _.
  cur_is_alpha <=
    '1' when (((cur_hi = "0100" or                           -- A-O
                cur_hi = "0110") and cur_lo /= "0000") or    -- a-o
              ((cur_hi = "0101" or                           -- P-Z
                cur_hi = "0111") and cur_lo <= 10    ) or    -- p-z
              ( cur_hi = "0101"  and cur_lo =  "1111")) else -- _
    '0';

  -- A-F or a-f.
  cur_is_alpha_hex <=
    '1' when ((cur_hi = "0100" or                            -- A-F
               cur_hi = "0110") and (cur_lo /= "0000" and    -- a-f, >= a
                                     cur_lo <= 6)) else      --      <= f
    '0';

  -- 0-9.
  cur_is_digit <=
    '1' when (( cur_hi = "0011"  and cur_lo < 10)) else      -- 0-9
    '0';

  -- This is only used for digits (cur_hi = "0011"), and letters,
  -- cur_hi = "01xx", so enough to separate on cur_hi(2).
  cur_alpha_digit_id_hi <=
    "10" when (cur_hi(2) = '0') else -- digits  (=> "10dddd")
    ('0' & cur_hi(0));               -- letters (=> "00cccc", "01cccc")

  cur_alpha_digit_id <=
    cur_alpha_digit_id_hi & std_logic_vector(cur_lo);

  lookfor_id <= cur_alpha_digit_id;

  cur_digit <= cur_lo;

  cur_is_hex <= cur_is_digit or cur_is_alpha_hex;

  -- See comemnt above for cur_alpha_digit_id_hi.
  cur_hex_add <= -- Add 0 for digits, add 9 for 'a-f' or A-F'.
    "0000" when (cur_hi(2) = '0') else "1001";

  cur_hex <= cur_lo + cur_hex_add;

  -- Last item in list.
  config_slot_last   <= config_slot(15);
  -- Mark telling if a config slot is an option or character (id).
  config_slot_mark   <= config_slot( 5 downto  4);
  -- When matching characters (mark /= '11').
  config_slot_offset <= config_slot(14 downto  6);
  config_slot_id     <= config_slot( 5 downto  0);
  -- When matching an option (mark = '11').
  config_slot_index  <= config_slot(14 downto  6);
  config_slot_flags  <= config_slot( 3 downto  0);

  -- Prepare upshifted values.
  -- We use this to catch overflows.
  vs_hex_next <=
    value(value'high-4 downto 0) & cur_hex;
  vs_hex_next_ofl <=
    fnet_or_reduction(std_logic_vector(value(value'high downto
                                             value'high-3)));

  vs_binary_next <=
    value(value'high-1 downto 0) & cur_digit(0);
  vs_binary_next_ofl <= value(value'high);

  vs_decimal <= value(vs_decimal'range);
  vs_decimal_next <=
    ("0" & vs_decimal(vs_decimal'high - 3 downto 0) & "000") +
    (      vs_decimal(vs_decimal'high - 1 downto 0) &   "0") +
    cur_digit;
  vs_decimal_next_carry <=
    vs_decimal_next(vs_decimal_next'high);
  vs_decimal_next_ofl <=
    fnet_or_reduction(std_logic_vector(vs_decimal(vs_decimal'high downto
                                                  vs_decimal'high-2)));

  -- Parsing state machine.
  process(state, hold_state, hold_fail_reason,
          cur,
          cur_is_blank,
          cur_is_alpha,
          cur_is_digit,
          cur_is_colon_equals,
          cur_is_colon,
          cur_is_bracket_l,
          cur_is_bracket_r,
          cur_is_colon,
          cur_is_hash,
          cur_is_dot,
          cur_is_semicolon,
          cur_is_hex,
          cur_is_0,
          cur_is_x,
          had_part,
          lookfor_id, config_slot_id,
          config_slot_last, config_slot_flags)
  begin
    -- Default values
    next_state   <= MSG_FAIL;
    fail_reason  <= MSG_FAIL_UNKNOWN;
    keep_state   <= state;  -- Used when going to comment state.

    config_parse_reset          <= '0';
    config_parse_got_char       <= '0';
    config_parse_matched_char   <= '0';
    config_parse_matched_option <= '0';
    config_parse_next_slot      <= '0';

    accept_data  <= '0';
    accept_part  <= '0';

    accept_index <= '0';
    accept_value <= '0';

    value_reset <= '0';
    value_shift_decimal_byte <= '0';
    value_shift_decimal <= '0';
    value_shift_hex <= '0';

    async_done <= '0';
    async_fail <= '0';

    case state is

      when MSG_GROUND =>
        if (cur_is_blank = '1' or
            cur_is_semicolon = '1') then
          -- Just eat spaces.
          accept_data <= '1';
          next_state <= MSG_GROUND;
        elsif (cur_is_hash = '1') then
          accept_data <= '1';
          next_state <= MSG_COMMENT;
        elsif (cur(0) = "00000000" or
               cur(0) = "11111111") then
          accept_data <= '1';
          next_state <= MSG_DONE;
        else
          -- Only thing we consider after this is identifiers.
          next_state <= MSG_IDENT;
        end if;

        -- Reset state of configuration memory address.  Memory from
        -- reset address (+ 1) is read during MSG_IDENT, and available
        -- for use in MSG_IDENT_FIND_CHAR.
        config_parse_reset <= '1';
        -- Reset the current value.  (A bit early, but...)
        value_reset <= '1';

      when MSG_IDENT =>
        -- Accept alpha-numerical characters as part of identifier.
        -- Numerical are only accepted for second and following
        -- characters.  (That is in principle handled by the
        -- configuration memory creation script.)
        if (cur_is_alpha = '1' or
            (had_part = '1' and
             cur_is_digit = '1')) then
          -- We got a character.
          -- Find in config options memory.  Not accepting yet.
          config_parse_got_char <= '1';
          next_state <= MSG_IDENT_FIND_CHAR;
        elsif (had_part = '1') then
          next_state <= MSG_IDENT_END;
        else
          if (had_part = '0') then
            fail_reason <= MSG_FAIL_OPTION_NAME_BAD_START;
          else
            fail_reason <= MSG_FAIL_OPTION_NAME_BAD_CHAR;
          end if;
        end if;

      when MSG_IDENT_END =>
        -- End at ':' or '=', then option name is checked.

        if (cur_is_blank = '1') then
          -- Just eat spaces.
          accept_data <= '1';
          next_state <= MSG_IDENT_END;
        elsif (cur_is_hash = '1') then
          accept_data <= '1';
          next_state <= MSG_COMMENT;
        elsif (cur_is_colon_equals = '1' or
               cur_is_bracket_l = '1') then
          -- Match the identification.  Not accepting yet.
          next_state <= MSG_IDENT_FIND_OPTION;
        else
          fail_reason <= MSG_FAIL_OPTION_BAD_COLON_EQUALS;
        end if;

      when MSG_IDENT_FIND_CHAR =>
        -- Another character of the option name has been seen.
        -- Match with the config memory.

        if (config_slot_id = lookfor_id) then
          -- The current character we want to look up matches the
          -- configuration slot we found.  Use it.
          config_parse_matched_char <= '1';
          accept_data <= '1';
          accept_part <= '1';
          next_state <= MSG_IDENT;
        elsif (config_slot_last = '1') then
          -- End of list.  Mismatch.
          fail_reason <= MSG_FAIL_OPTION_NOT_FOUND;
        else
          config_parse_next_slot <= '1';
          next_state <= MSG_IDENT_FIND_CHAR;
        end if;

      when MSG_IDENT_FIND_OPTION =>
        -- Option name has been fully parsed.
        -- Config memory should now indicate an option.

        if (config_slot_id(5 downto 4) = "11") then
          -- Configuration slot is an option.
          -- Ours, since we only check the first slot.
          config_parse_matched_option <= '1';
          accept_data <= '1';
          if (cur_is_bracket_l = '1') then
            next_state <= MSG_OPTION_BRACKET_L_END;
          else
            next_state <= MSG_OPTION_SWITCH;
          end if;
        else
          fail_reason <= MSG_FAIL_OPTION_NOT_FOUND_PARTIAL;
        end if;

      when MSG_OPTION_BRACKET_L_END =>
        -- Eat spaces until the index.
        if (cur_is_blank = '1') then
          accept_data <= '1';
          next_state <= MSG_OPTION_BRACKET_L_END;
        elsif (cur_is_hash = '1') then
          accept_data <= '1';
          next_state <= MSG_COMMENT;
        else
          next_state <= MSG_OPTION_INDEX;
        end if;

      when MSG_OPTION_INDEX =>
        -- Same handling as decimal number.
        if (cur_is_digit = '1') then
          value_shift_decimal <= '1';
          accept_data <= '1';
          accept_part <= '1';
          next_state <= MSG_OPTION_INDEX;
        elsif (had_part = '1') then
          next_state <= MSG_OPTION_INDEX_END;
        else
          fail_reason <= MSG_FAIL_OPTION_INDEX_MALFORMAT;
        end if;

      when MSG_OPTION_INDEX_END =>
        if (cur_is_blank = '1') then
          accept_data <= '1';
          next_state <= MSG_OPTION_INDEX_END;
        elsif (cur_is_hash = '1') then
          accept_data <= '1';
          next_state <= MSG_COMMENT;
        elsif (cur_is_bracket_r = '1') then
          accept_data <= '1';
          accept_index <= '1';
          next_state <= MSG_OPTION_BRACKET_R_END;
        else
          fail_reason <= MSG_FAIL_OPTION_INDEX_MALFORMAT;
        end if;

      when MSG_OPTION_BRACKET_R_END =>
        -- Eat spaces until the colon/equals.
        if (cur_is_blank = '1') then
          accept_data <= '1';
          next_state <= MSG_OPTION_BRACKET_R_END;
        elsif (cur_is_hash = '1') then
          accept_data <= '1';
          next_state <= MSG_COMMENT;
        elsif (cur_is_colon_equals = '1') then
          -- Option was already matched!
          accept_data <= '1';
          accept_part <= '1'; -- Not really needed.
          next_state <= MSG_OPTION_SWITCH;
        end if;

      when MSG_OPTION_SWITCH =>
        -- Eat spaces until the actual option starts.
        -- This is so that the respective options do not have
        -- to handle whitespace at the start.
        if (cur_is_blank = '1') then
          accept_data <= '1';
          next_state <= MSG_OPTION_SWITCH;
        elsif (cur_is_hash = '1') then
          accept_data <= '1';
          next_state <= MSG_COMMENT;
        else
          -- Note that the address to the config memory did not
          -- change, so we can still use the memory values here.

          -- Find out what kind of data to expect/handle.
          if    (config_slot_flags(2 downto 0) = "001") then
            next_state <= MSG_DECIMAL;
          elsif (config_slot_flags(2 downto 0) = "010") then
            next_state <= MSG_HEX;
          --elsif (config_slot_flags(2 downto 0) = "011") then
          --  next_state <= MSG_BIN_INIT;
          elsif (config_slot_flags(2 downto 0) = "100") then
            next_state <= MSG_STRING_INIT;
          else
            fail_reason <= MSG_FAIL_OPTION_BAD_FLAGS;
          end if;
        end if;

        -- In case the value was used as an index.
        value_reset <= '1';

      when MSG_STRING_INIT =>
        -- We have just seen the ':' or '=' after an string option name.
        -- Skip any whitespace.  Start parsing option.

        if (cur_is_blank = '1') then
          -- Skip space/tab/NL/CR, continue in the current state.
          -- elsif () then
          null; -- TODO: remember quote character.
        end if;

        fail_reason <= MSG_FAIL_OPTION_STRING_NOT_HANDLED;

      when MSG_HEX =>
        if (cur_is_hex = '1') then
          value_shift_hex <= '1';
          accept_data <= '1';
          accept_part <= '1';
          next_state <= MSG_HEX;
        elsif (had_part = '1') then
          next_state <= MSG_HEX_COLON;
        else
          fail_reason <= MSG_FAIL_HEX_MALFORMAT;
        end if;

      when MSG_HEX_COLON =>
        if (cur_is_colon = '1') then
          accept_data <= '1';
          accept_part <= '0'; -- See note in MSG_DECIMAL_END.
          next_state <= MSG_HEX;
        else
          next_state <= MSG_HEX_END;
        end if;

      when MSG_HEX_END =>
        if (cur_is_blank = '1') then
          accept_data <= '1';
          next_state <= MSG_HEX_END;
        elsif (cur_is_hash = '1') then
          accept_data <= '1';
          next_state <= MSG_COMMENT;
        elsif (value_overflow = '0') then
          accept_value <= '1';
          next_state <= MSG_GROUND;
        else
          fail_reason <= MSG_FAIL_HEX_OVERFLOW;
        end if;

      when MSG_DECIMAL =>
        if (cur_is_0 = '1' and
            had_part = '0') then
          -- May be a '0x' or '0b' mark.
          value_shift_decimal <= '1';
          accept_data <= '1';
          accept_part <= '1';
          next_state <= MSG_DECIMAL_LEAD_0;
        elsif (cur_is_digit = '1') then
          value_shift_decimal <= '1';
          accept_data <= '1';
          accept_part <= '1';
          next_state <= MSG_DECIMAL;
        elsif (had_part = '1') then
          next_state <= MSG_DECIMAL_DOT;
        else
          fail_reason <= MSG_FAIL_DECIMAL_MALFORMAT;
        end if;

      when MSG_DECIMAL_LEAD_0 =>
        -- TODO: handle 0b
        if (cur_is_x = '1') then
          -- Continue as hexadecimal parsing.
          -- The leading '0' we had did not affect the value.
          accept_data <= '1';
          -- Unmark it as a token accepted, such that at least another
          -- 0 is reqired by the hex parsing.
          accept_part <= '0';
          next_state <= MSG_HEX;
        else
          -- Go back to normal decimal parsing.
          next_state <= MSG_DECIMAL;
        end if;

      when MSG_DECIMAL_DOT =>
        if (cur_is_blank = '1') then
          accept_data <= '1';
          next_state <= MSG_DECIMAL_DOT;
        elsif ((cur_is_dot = '1') and
               (config_slot_flags(3) = '1')) then
          value_shift_decimal_byte <= '1';
          accept_data <= '1';
          -- Note: this is not considered a data char, such that the
          -- following MSG_DECIMAL requires to see another digit.
          accept_part <= '0';
          -- Want to find another integer
          next_state <= MSG_DECIMAL_POST_DOT;
        else
          next_state <= MSG_DECIMAL_END;
        end if;

      when MSG_DECIMAL_END =>
        if (cur_is_blank = '1') then
          accept_data <= '1';
          next_state <= MSG_DECIMAL_END;
        elsif (cur_is_hash = '1') then
          accept_data <= '1';
          next_state <= MSG_COMMENT;
        elsif (value_overflow = '0') then
          accept_value <= '1';
          next_state <= MSG_GROUND;
        else
          fail_reason <= MSG_FAIL_DECIMAL_OVERFLOW;
        end if;

      when MSG_DECIMAL_POST_DOT =>
        -- The purpose of this state is just to eat blanks after a
        -- decimal dot.  After that must come a digit, i.e. even a
        -- comment is considered wrong at this point.
        if (cur_is_blank = '1') then
          accept_data <= '1';
          next_state <= MSG_DECIMAL_POST_DOT;
        else
          next_state <= MSG_DECIMAL;
        end if;

      when MSG_COMMENT =>
        if (cur(0) = char_NL) then
          -- Comment ends at newline.
          -- Return to the state expected.
          -- Typically comment has same effect as a whitespace.
          next_state <= hold_state;
        else
          -- Eat this character, whatever it is.
          accept_data <= '1';
          keep_state <= hold_state;
          next_state <= MSG_COMMENT;
        end if;

      when MSG_DONE =>
        async_done <= '1';
        next_state <= MSG_DONE;
        null;

      when MSG_FAIL =>
        async_done <= '1';
        async_fail <= '1';
        fail_reason <= hold_fail_reason;
        null;

    end case;
  end process;

  -- Calculate next address of config memory.  Used as read location.
  config_addr_next <= config_addr + 1;

  process (clk)
  begin
    if (rising_edge(clk)) then

      -- Whenever we get an input character, set it as pending.
      -- The state machine may have to go through many states
      -- until it has determined what to do with the input.
      if (i_has_data = '1') then
        has_data_pend <= '1';
        data_pend <= i_data;
      end if;

      -- In the state where accept_value is set to one, another state
      -- is immediately chosen, such that the value acceptance mark to
      -- outside is single-cycle.  Even if the character as such is
      -- not immediately accepted.
      got_value <= accept_value;

      -- While data is pending, update the state machine.
      if (has_data_pend = '1') then

        state <= next_state;
        hold_state <= keep_state;

        hold_fail_reason <= fail_reason;

        -- Once accepted, data is no longer pending.
        if (accept_data = '1') then
          has_data_pend <= '0';

          -- If we accepted the character as a part of a token,
          -- remember that.
          if (accept_part = '1') then
            had_part <= '1';
          else
            had_part <= '0';
          end if;
        end if;

        -- Typical to look at the next slot.
        if (config_parse_next_slot = '1') then
          config_addr <= config_addr_next;
        end if;
        -- Or jump to another slot.
        if (config_parse_matched_char = '1') then
          config_addr <= unsigned(config_slot_offset);
        end if;
        -- Reset the config memory address.
        if (config_parse_reset = '1') then
          config_addr <= (others => '1'); -- Such that config_addr_next is 0.
        end if;

        if (config_parse_matched_option = '1') then
          slot_index <= unsigned(config_slot_index);
        end if;

        -- Value handling
        if (value_shift_hex = '1') then
          -- Shift the value up by 4, and append the new value.
          value <= vs_hex_next;
          value_overflow <=
            value_overflow or vs_hex_next_ofl;
        end if;
        if (value_shift_decimal = '1') then
          if (config_slot_flags(3) = '0') then
            -- Multiply the value by 10, and add the new value.
            -- Multiply by 10 is same as add value multiplied by
            -- 8 and 2, i.e. shifted by 3 and 1.
            value(value'high downto vs_decimal'high+1) <= (others => '0');
            value(vs_decimal'range) <= vs_decimal_next(vs_decimal'range);
            value_overflow <=
              value_overflow or vs_decimal_next_carry or vs_decimal_next_ofl;
          else
            -- We only work with the lowest byte.
            value(7 downto 0) <= vs_decimal_next(7 downto 0);
          end if;
        end if;
        if (value_shift_decimal_byte = '1') then
          -- Shift the value up by one byte.  Fill in zeros.
          value <= value(value'high - 8 downto 0) & "00000000";
          value_overflow <= value_overflow or vs_decimal_next_carry;
        end if;

        if (accept_index = '1') then
          slot_index <= slot_index + value(slot_index'range);
        end if;

        -- Reset value.
        if (value_reset = '1') then
          value <= (others => '0');
          value_overflow <= '0';
        end if;
      end if;

      if (i_reset_parse = '1') then
        state <= MSG_GROUND;
        has_data_pend <= '0';
      end if;

      -- Note, the config memory read takes a cycle of its own, so
      -- therefore reading from 'next' address.
      config_slot <= text_config_array(to_integer(config_addr_next));

      done <= async_done;
      fail <= async_fail;
    end if;
  end process;

  -- For debugging
  process (hold_fail_reason)
  begin
    case hold_fail_reason is
      when MSG_FAIL_UNKNOWN                   => fail_reason_no <=  0;
      when MSG_FAIL_OPTION_NAME_BAD_START     => fail_reason_no <=  1;
      when MSG_FAIL_OPTION_NAME_BAD_CHAR      => fail_reason_no <=  2;
      when MSG_FAIL_OPTION_NOT_FOUND          => fail_reason_no <=  3;
      when MSG_FAIL_OPTION_BAD_FLAGS          => fail_reason_no <=  4;
      when MSG_FAIL_OPTION_NOT_FOUND_PARTIAL  => fail_reason_no <=  5;
      when MSG_FAIL_OPTION_INDEX_MALFORMAT    => fail_reason_no <=  6;
      when MSG_FAIL_OPTION_BAD_COLON_EQUALS   => fail_reason_no <=  7;
      when MSG_FAIL_HEX_MALFORMAT             => fail_reason_no <=  8;
      when MSG_FAIL_HEX_OVERFLOW              => fail_reason_no <=  9;
      when MSG_FAIL_DECIMAL_MALFORMAT         => fail_reason_no <= 10;
      when MSG_FAIL_DECIMAL_OVERFLOW          => fail_reason_no <= 11;
      when MSG_FAIL_OPTION_STRING_NOT_HANDLED => fail_reason_no <= 12;
    end case;
  end process;

  process (state)
  begin
    case state is
      when MSG_GROUND               => state_no <=  0;
      when MSG_IDENT                => state_no <=  1;
      when MSG_IDENT_END            => state_no <=  2;
      when MSG_IDENT_FIND_CHAR      => state_no <=  3;
      when MSG_IDENT_FIND_OPTION    => state_no <=  4;
      when MSG_OPTION_BRACKET_L_END => state_no <=  5;
      when MSG_OPTION_INDEX         => state_no <=  6;
      when MSG_OPTION_INDEX_END     => state_no <=  7;
      when MSG_OPTION_BRACKET_R_END => state_no <=  8;
      when MSG_OPTION_SWITCH        => state_no <=  9;
      when MSG_STRING_INIT          => state_no <= 10;
      when MSG_HEX                  => state_no <= 11;
      when MSG_HEX_COLON            => state_no <= 12;
      when MSG_HEX_END              => state_no <= 13;
      when MSG_DECIMAL              => state_no <= 14;
      when MSG_DECIMAL_LEAD_0       => state_no <= 15;
      when MSG_DECIMAL_DOT          => state_no <= 16;
      when MSG_DECIMAL_END          => state_no <= 17;
      when MSG_DECIMAL_POST_DOT     => state_no <= 18;
      when MSG_COMMENT              => state_no <= 19;
      when MSG_DONE                 => state_no <= 20;
      when MSG_FAIL                 => state_no <= 21;
    end case;
  end process;

  -- Alias to output variables.
  o_wait_char <= (not has_data_pend) and (not done);

  o_done <= done;
  o_fail <= fail;
  o_fail_code   <= std_logic_vector(to_unsigned(fail_reason_no,
                                                o_fail_code'length));

  o_has_value   <= got_value;
  o_value       <= std_logic_vector(value);
  o_value_index <= std_logic_vector(slot_index);

  o_dbg_has_data_pend <= has_data_pend;
  o_dbg_state_code <= std_logic_vector(to_unsigned(state_no,
                                                   o_dbg_state_code'length));
end RTL;
