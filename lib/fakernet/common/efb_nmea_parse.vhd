-- Copyright (c) 2022, Haakan T. Johansson
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

-- use work.fnet_util_pkg.all;

-- We just decode enough of the $GPRMC message to figure out
-- how many seconds into the day and how many days after 2000 we are.

-- Strategy:
--
-- We run a few semi-independent operations:
--
-- - NMEA checksum: From any $, until *, keep the XOR of all characters.
--                  After *, wait four characters, check xor1 xor2 CR NL
--                  If successful, declare the packet a success.
--
--                  A new $ will restart the checking.
--                  We count the unfinished $ as a failure.
--
-- - Message identification: Count characters, match message start on
--                           correct count since start and correct name.
--
-- - Comma counter: We find the interesting fields by counting commas.
--
-- Non-handling of foreign sentences, like the binary ublox messages:
--
-- We ignore that complication and just let the parser run.  Every
-- time a $ is encountered, we restart the parsing anyhow, so the
-- amount of spurious $ does not matter.  Then, only if the sentence
-- matches, including the checksum, the actual payload is used.

-- Some hex values:
-- $ 24   * 2a   , 2c   0 30   A 41   a 61
-- GPRMC  47 50 52 4d 43

entity efb_nmea_parse is
  port (
    clk          : in  std_logic; -- Clock from board
    -- Input signals.
    i_data       : in  std_logic_vector(7 downto 0);
    i_has_data   : in  std_logic;
    -- Output signals.
    o_seconds    : out std_logic_vector(16 downto 0);
    o_days       : out std_logic_vector(15 downto 0);
    o_valid_fix  : out std_logic := '0';
    o_has_t_data : out std_logic := '0'
    );

end efb_nmea_parse;

architecture RTL of efb_nmea_parse is

  subtype char  is unsigned(7 downto 0);

  -- For identifying characters.
  constant char_NL     : char := "00001010"; -- 0a
  constant char_CR     : char := "00001101"; -- 0d
  constant char_dollar : char := "00100100"; -- 24
  constant char_star   : char := "00101010"; -- 2a
  constant char_comma  : char := "00101100"; -- 2c
  constant char_dot    : char := "00101110"; -- 2e
  constant char_0      : char := "00110000"; -- 30
  constant char_uc_A   : char := "01000001"; -- 41
  constant char_uc_B   : char := "01000010"; -- 42
  constant char_uc_C   : char := "01000011"; -- 43
  constant char_uc_D   : char := "01000100"; -- 44
  constant char_uc_G   : char := "01000111"; -- 47
  constant char_uc_L   : char := "01001100"; -- 4c
  constant char_uc_M   : char := "01001101"; -- 4d
  constant char_uc_N   : char := "01001110"; -- 4e
  constant char_uc_P   : char := "01010000"; -- 50
  constant char_uc_R   : char := "01010010"; -- 52
  constant char_lc_a   : char := "01100001"; -- 61

  -- Avoid several multiplications by lookup tables of how many
  -- seconds each position contributes.
  type hhmmXs_to_s_array is array(0 to  7) of integer range 0 to 60;
  constant dig_hhmmXs_to_s : hhmmXs_to_s_array  :=
    (0, 10, 20, 30, 40, 50, 60, -- 0..6  (6 only for leap seconds.)
     0);                        -- 7     (Not used for good messages.)
  type hhmXss_to_s_array is array(0 to 15) of integer range 0 to 560;
  constant dig_hhmXss_to_s : hhmXss_to_s_array :=
    (   0,   60, 2*60, 3*60, 4*60, -- 0..4
     5*60, 6*60, 7*60, 8*60, 9*60, -- 5..9
     0, 0, 0, 0, 0, 0);            -- 10..15
  type hhXmss_to_s_array is array(0 to  7) of integer range 0 to 3000;
  constant dig_hhXmss_to_s : hhXmss_to_s_array :=
    (0, 600, 1200, 1800, 2400, 3000, -- 0..5
     0, 0);                          -- 6..7
  type hXmmss_to_s_array is array(0 to 15) of integer range 0 to 36000;
  constant dig_hXmmss_to_s : hXmmss_to_s_array :=
    (     0,   3600, 2*3600, 3*3600, 4*3600, -- 0..4
     5*3600, 6*3600, 7*3600, 8*3600, 9*3600, -- 5..9
     0, 0, 0, 0, 0, 0);                      -- 10..15
  type Xhmmss_to_s_array is array(0 to  3) of integer range 0 to 72000;
  constant dig_Xhmmss_to_s : Xhmmss_to_s_array :=
    (0, 36000, 72000, -- 0..2
     0);              -- 3

  -- Contributions of days.
  type Ddmmyy_to_d_array is array(0 to  3) of integer range 0 to 30;
  constant dig_Xdmmyy_to_d : Ddmmyy_to_d_array :=
    (0, 10, 20, 30); -- 0..3
  type ddXXyy_to_d_array is array(0 to 15) of integer range 0 to 334;
  constant dig_ddXXyy_to_d : ddXXyy_to_d_array :=
    (0,                                                            -- 0
     0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, -- 365 -- 1..12
     0, 0, 0);                                                     -- 13..15
  type ddmmyX_to_d_array is array(0 to 15) of integer range 0 to 3650;
  constant dig_ddmmyX_to_d : ddmmyX_to_d_array :=
    (    0,   365, 2*365, 3*365, 4*365, -- 0..4
     5*365, 6*365, 7*365, 8*365, 9*365, -- 5..9
     0, 0, 0, 0, 0, 0);                 -- 10..15
  type ddmmXy_to_d_array is array(0 to 15) of integer range 0 to 36500;
  constant dig_ddmmXy_to_d : ddmmXy_to_d_array :=
    (     0, 10*365, 20*365, 30*365, 40*365, -- 0..4
     50*365, 60*365, 70*365, 80*365, 90*365, -- 5..9
     0, 0, 0, 0, 0, 0);                      -- 10..15

  -- Latched values of the table lookup (multiplexers).
  signal latch_hhmmXs_to_s : integer range 0 to 60;
  signal latch_hhmXss_to_s : integer range 0 to 560;
  signal latch_hhXmss_to_s : integer range 0 to 3000;
  signal latch_hXmmss_to_s : integer range 0 to 36000;
  signal latch_Xhmmss_to_s : integer range 0 to 72000;

  signal latch_Xdmmyy_to_d : integer range 0 to 30;
  signal latch_ddXXyy_to_d : integer range 0 to 334;
  signal latch_ddmmyX_to_d : integer range 0 to 3650;
  signal latch_ddmmXy_to_d : integer range 0 to 36500;

  signal latch_hhmmsX : integer range 0 to 15;
  signal latch_dXmmyy : integer range 0 to 15;

  -- Summing the seconds and days up (two cycles later).
  signal latch_hhmmss_s    : integer range 0 to 111635; -- maximum result
  signal latch_ddmmyy_d    : integer range 0 to 40593;  -- maximum result

  -- Partial sums for the seconds and days (cycle in-between).
  signal latch_hhmXXX_s    : integer range 0 to 635;    -- maximum result
  signal latch_XXXmss_s    : integer range 0 to 111000; -- maximum result

  signal latch_XXmmyy_d    : integer range 0 to 109;    -- maximum result
  signal latch_ddXXXX_d    : integer range 0 to 40484;  -- maximum result

  -- Count up to 31 commas.
  signal comma_count : unsigned(4 downto 0) := (others => '0');
  -- Count up to 7 start chars.
  signal char_count      : unsigned(2 downto 0) := (others => '0');
  signal char_count_next : unsigned(3 downto 0) := (others => '0');

  -- Checksum accumulation.
  signal xor_sum : char := (others => '0');

  -- Checksum extraction.
  signal checksum_hi_hex_add : unsigned(3 downto 0) := (others => '0');
  signal checksum_lo_hex_add : unsigned(3 downto 0) := (others => '0');

  signal checksum_hi : unsigned(3 downto 0) := (others => '0');
  signal checksum_lo : unsigned(3 downto 0) := (others => '0');

  -- Inside message (after $).
  signal in_message : std_logic := '0';
  -- Checksum to be checked (after *).
  signal in_checksum : std_logic := '0';
  -- Inside GPRMC message.
  signal in_GPRMC : std_logic := '0';
  -- Did we see a good status message (A after comma 2)
  signal status_valid : std_logic := '0';

  -- Did the (good) message contain a valid fix.
  signal fix_valid : std_logic := '0';
  -- Message GPRMC was completed, with good checksum.
  signal good_GPRMC : std_logic := '0';

  -- History of 6 recent digits.
  type char_history_array is array(6 downto 0) of char;
  signal input_history : char_history_array :=
    (others => (others => '0'));

  -- Aliases from the input history
  signal input_hhmmsX : integer range 0 to 15;
  signal input_hhmmXs : integer range 0 to  7;
  signal input_hhmXss : integer range 0 to 15;
  signal input_hhXmss : integer range 0 to  7;
  signal input_hXmmss : integer range 0 to 15;
  signal input_Xhmmss : integer range 0 to  3;

  signal input_ddmmyX : integer range 0 to 15;
  signal input_ddmmXy : integer range 0 to 15;
  signal input_ddmXyy : integer range 0 to 15;
  signal input_ddXmyy : integer range 0 to  1;
  signal input_dXmmyy : integer range 0 to 15;
  signal input_Xdmmyy : integer range 0 to  3;

  -- For the month and year, it helps leap-year handling to have the
  -- full value.
  signal input_ddXXyy : integer range 0 to  15; -- Maximum used result.
  signal input_ddmmXX : integer range 0 to 127; -- Maximum used result.
  -- Variables for multiplication with full (intermediate result) range.
  signal input_ddXXyy_long : integer range 0 to  31; -- Maximum product.
  signal input_ddmmXX_long : integer range 0 to 255; -- Maximum product.

  -- Leap year
  signal leap_year : std_logic := '0';
  signal leap_MM_to_d       : integer range 0 to  1;
  signal latch_leap_MM_to_d : integer range 0 to  1;
  signal leap_YY_to_d       : integer range 0 to 63; -- maximum result
  signal latch_leap_YY_to_d : integer range 0 to 63; -- maximum result

  -- Comma-counting found the hhmmss field.
  signal start_hhmmss : std_logic := '0';

  -- Delayed handling of multiplexed values.
  signal add_hhmmss_to_s    : std_logic := '0';
  signal add_ddmmyy_to_d    : std_logic := '0';

  signal add_hhmmss_to_s_p1 : std_logic := '0';
  signal add_ddmmyy_to_d_p1 : std_logic := '0';

begin

  -- Extraction of date and time digits (when we are at the following
  -- ',' or '.').
  input_hhmmsX <= to_integer(input_history(1)(3 downto 0));
  input_hhmmXs <= to_integer(input_history(2)(2 downto 0));
  input_hhmXss <= to_integer(input_history(3)(3 downto 0));
  input_hhXmss <= to_integer(input_history(4)(2 downto 0));
  input_hXmmss <= to_integer(input_history(5)(3 downto 0));
  input_Xhmmss <= to_integer(input_history(6)(1 downto 0));

  input_ddmmyX <= to_integer(input_history(1)(3 downto 0));
  input_ddmmXy <= to_integer(input_history(2)(3 downto 0));
  input_ddmXyy <= to_integer(input_history(3)(3 downto 0));
  input_ddXmyy <= to_integer(input_history(4)(0 downto 0));
  input_dXmmyy <= to_integer(input_history(5)(3 downto 0));
  input_Xdmmyy <= to_integer(input_history(6)(1 downto 0));

  -- For the month and year, it helps to have the full value.
  input_ddXXyy_long <= input_ddmXyy + (10 * input_ddXmyy); -- small multiply
  input_ddmmXX_long <= input_ddmmyX + (10 * input_ddmmXy); -- mini(4x4->8 bits)
  -- Drop the impossible bits (not used in good messages) from above.
  input_ddXXyy <= input_ddXXyy_long mod 16;
  input_ddmmXX <= input_ddmmXX_long mod 128;

  -- Leap-year if divisible by 4.  (Note 2000 was a leap year, 2100 is not.)
  leap_year    <= '1' when (input_ddmmXX mod 4 = 0
                            -- and input_ddmmXX /= 0  (in case of 2100)
                            ) else '0';
  -- Additional day in year if leap-year and after February.
  leap_MM_to_d <= 1 when (leap_year = '1' and
                          input_ddXXyy > 2) else 0;   -- >= 10th
  -- Additional days accumulated over years.
  -- 2000 => 0, 2001..2004 => 1, 2005..2008 => 2, ...
  leap_YY_to_d <= (input_ddmmXX + 3) / 4; -- 2000 was a leap year, 2100 not.

  -- Extraction of checksum values.
  checksum_hi_hex_add <=
    "0000" when (input_history(3)(5 downto 4) = "11") else "1001";
  checksum_hi <= input_history(3)(3 downto 0) + checksum_hi_hex_add;
  checksum_lo_hex_add <=
    "0000" when (input_history(2)(5 downto 4) = "11") else "1001";
  checksum_lo <= input_history(2)(3 downto 0) + checksum_lo_hex_add;

  -- Feed the input history.
  input_history(0) <= unsigned(i_data);

  -- Value update.
  char_count_next <= ('0' & char_count) + 1;

  process(clk)
  begin
    if (rising_edge(clk)) then

      -- Default values.
      add_hhmmss_to_s <= '0';
      add_ddmmyy_to_d <= '0';

      good_GPRMC <= '0';

      -- Only process when new character is available.
      if (i_has_data = '1') then

        -- Count characters, but do not wrap.
        if (char_count_next(char_count_next'high) /= '1') then
          char_count <= char_count_next(char_count'range);
        end if;

        -- End of message at *.
        if (input_history(0) = char_star) then
          char_count   <= (others => '0');
          in_message   <= '0';
          in_checksum  <= in_message;
        elsif (in_message = '1') then
          -- Only accumulate before the *, to not mess up the check.
          xor_sum <= xor_sum xor input_history(0);
        end if;

        -- This is not really needed, but reduces the likelihood
        -- considerably that a binary message manage to pose as a
        -- valid NMEA message.  Valid NMEA character range is
        -- 0x20-0x7e.  Refuse as NMEA if any 0x00-0x1f or 0x80-0xff
        -- are encountered.
        if ((input_history(0)(7         ) = '1'  ) or
            (input_history(0)(7 downto 5) = "000")) then
          in_message   <= '0';
          -- We cannot kill in_checksum, since the CR and NL
          -- characters are used at the end of the message.
        end if;

        -- Start of message.
        -- After checksum accumulation, to clear in case of new $.
        if (input_history(0) = char_dollar) then
          char_count   <= (others => '0');
          comma_count  <= (others => '0');
          xor_sum      <= (others => '0');
          in_message   <= '1';
          in_GPRMC     <= '0';
          start_hhmmss <= '0';
          status_valid <= '0';
          -- No need to clear in_checksum.
        end if;

        -- Check for particular message (GPRMC).
        if (to_integer(char_count) = 4 and
            in_message = '1' and
            input_history(4) = char_uc_G and
            (input_history(3) = char_uc_P or
             input_history(3) = char_uc_L or
             input_history(3) = char_uc_A or
             input_history(3) = char_uc_B or
             input_history(3) = char_uc_N) and
            input_history(2) = char_uc_R and
            input_history(1) = char_uc_M and
            input_history(0) = char_uc_C) then
          in_GPRMC <= '1';
        end if;

        -- Message completed?
        if (in_checksum = '1' and
            to_integer(char_count) = 3) then
          -- We have ended the checksum,
          in_checksum <= '0';
          if (xor_sum = checksum_hi & checksum_lo and
              input_history(1) = char_CR and
              input_history(0) = char_NL) then
            -- The sentence ended with a good checksum.
            -- Do we have a acceptable message?
            if (in_GPRMC = '1' and
                to_integer(comma_count) = 12) then
              -- We have successfully handled a GPRMC message.
              -- We can ship out the result.
              fix_valid  <= status_valid;
              good_GPRMC <= '1';
            end if;
          end if;
        end if;

        -- Fields end at comma.
        if (input_history(0) = char_comma) then
          -- Update count.
          comma_count <= comma_count + 1;

          -- The time (hhmmss) may end with a comma (next field), or
          -- with a dot (then followed by some fractional seconds that
          -- we do not care about).  So we arm checking for this.
          if (to_integer(comma_count) = 0) then
            start_hhmmss <= '1';
          end if;

          -- Handle ddmmyy, at comma.
          if (to_integer(comma_count) = 9) then
            -- Just found 10th comma.  Is ddmmyy if GPRMC.
            latch_dXmmyy      <=                 input_dXmmyy;
            latch_Xdmmyy_to_d <= dig_Xdmmyy_to_d(input_Xdmmyy);
            latch_ddXXyy_to_d <= dig_ddXXyy_to_d(input_ddXXyy);
            latch_ddmmyX_to_d <= dig_ddmmyX_to_d(input_ddmmyX);
            latch_ddmmXy_to_d <= dig_ddmmXy_to_d(input_ddmmXy);
            latch_leap_MM_to_d <= leap_MM_to_d;
            latch_leap_YY_to_d <= leap_YY_to_d;
            --if (in_GPRMC = '1') then
              add_ddmmyy_to_d <= '1';
            --end if;
          end if;

          -- Handle status, 'A' valid, 'D' differential, or
          -- 'V' invalid, and previous also ','.
          if (to_integer(comma_count) = 2 and
              input_history(2) = char_comma and
              (input_history(1) = char_uc_A or
               input_history(1) = char_uc_D)) then
            status_valid <= '1';
          end if;
        end if;

        -- Handle hhmmss, at comma or dot.  Comma-counting above.
        if (start_hhmmss = '1' and
            (input_history(0) = char_comma or
             input_history(0) = char_dot)) then
          start_hhmmss <= '0';
          -- Found the end of the hhmmss string, if GPRMC.
          latch_hhmmsX      <=                 input_hhmmsX;
          latch_hhmmXs_to_s <= dig_hhmmXs_to_s(input_hhmmXs);
          latch_hhmXss_to_s <= dig_hhmXss_to_s(input_hhmXss);
          latch_hhXmss_to_s <= dig_hhXmss_to_s(input_hhXmss);
          latch_hXmmss_to_s <= dig_hXmmss_to_s(input_hXmmss);
          latch_Xhmmss_to_s <= dig_Xhmmss_to_s(input_Xhmmss);
          --if (in_GPRMC = '1') then
            add_hhmmss_to_s <= '1';
          --end if;
        end if;

        -- Keep six most recent characters.
        -- Needed for both hhmmss and mmddyy.
        input_history(6 downto 1) <= input_history(5 downto 0);
      end if;

      -- Adding the values is delayed two cycles.
      -- Seconds: first cycle - partial sums, can always be performed.
      latch_hhmXXX_s <=
        latch_hhmmsX +
        latch_hhmmXs_to_s +
        latch_hhmXss_to_s;
      latch_XXXmss_s <=
        latch_hhXmss_to_s +
        latch_hXmmss_to_s +
        latch_Xhmmss_to_s;

      add_hhmmss_to_s_p1 <= add_hhmmss_to_s;

      -- Seconds, second cycle: full sum.
      if (add_hhmmss_to_s_p1 = '1') then
        latch_hhmmss_s <=
          latch_hhmXXX_s +
          latch_XXXmss_s;
      end if;

      -- Days, first cycle: partial sums, can always be performed.
      latch_XXmmyy_d <=
        latch_leap_MM_to_d +
        latch_leap_YY_to_d +
        latch_dXmmyy +
        latch_Xdmmyy_to_d;
      latch_ddXXXX_d <=
        latch_ddXXyy_to_d +
        latch_ddmmyX_to_d +
        latch_ddmmXy_to_d;

      add_ddmmyy_to_d_p1 <= add_ddmmyy_to_d;

      -- Days, second cycle: full sum.
      if (add_ddmmyy_to_d_p1 = '1') then
        latch_ddmmyy_d <=
          latch_XXmmyy_d +
          latch_ddXXXX_d - 1; -- First day is not to be counted.
      end if;

    end if;
  end process;

  -- Alias to output variables.
  o_seconds    <= std_logic_vector(to_unsigned(latch_hhmmss_s, 17));
  o_days       <= std_logic_vector(to_unsigned(latch_ddmmyy_d, 16));
  o_valid_fix  <= fix_valid;
  o_has_t_data <= good_GPRMC;
end RTL;
