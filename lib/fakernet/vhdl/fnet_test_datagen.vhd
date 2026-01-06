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

-- This module can generate data locally.

entity fnet_test_datagen is
  generic (data_bufsize_addrbits : natural);
  port (clk          : in  std_logic;
        tcp_reset    : in  std_logic;
        -- Data to buffer
        lcl_datagen_write      : out std_logic;
        lcl_datagen_word       : out std_logic_vector(31 downto 0);
        lcl_datagen_offset     : out std_logic_vector(7 downto 0);
        lcl_datagen_commit     : out std_logic;
        lcl_datagen_commit_len : out std_logic_vector(5 downto 0);
        lcl_datagen_free       : in  std_logic;
        --
        tc_lcl_datagen_chance   : in  std_logic_vector(31 downto 0);
        tc_lcl_datagen_len_mask : in  std_logic_vector(15 downto 0);
        tc_lcl_datagen_mark     : in  std_logic_vector(3 downto 0)
        );
end fnet_test_datagen;

architecture RTL of fnet_test_datagen is

  signal data_write  : std_logic := '0';
  signal data_word   : std_logic_vector(31 downto 0) := (others => '0');
  signal data_offset : std_logic_vector(7 downto 0) := (others => '0');
  signal data_commit : std_logic := '0';
  signal data_commit_len : std_logic_vector(5 downto 0) := (others => '0');
  -- signal data_free   : std_logic := '0';

  signal data_avail : std_logic_vector(7 downto 0) := (others => '0');
  signal commit_no : std_logic_vector(7 downto 0) := (others => '0');
  signal data_count : std_logic_vector(15 downto 0) := (others => '0');

  signal reset_prev : std_logic := '0';
  signal reset_count : std_logic_vector(3 downto 0) := (others => '0');

  signal commit_len : std_logic_vector(5 downto 0);
  signal commit_len_ok : std_logic;
  signal commit_avail_ok : std_logic;

  signal prev_commit_len : std_logic_vector(5 downto 0);

  signal chance_hi_eq : std_logic;
  signal chance_hi_less : std_logic;
  signal chance_lo_less : std_logic;
  signal chance_ok : std_logic;

  -- The random generator
  signal xor_state  : std_logic_vector(63 downto 0) :=
    (0 => '1', others => '0');
  signal xor_state0 : std_logic_vector(63 downto 0);
  signal xor_state1 : std_logic_vector(63 downto 0);
  signal xor_state2 : std_logic_vector(63 downto 0);
  signal xor_state3 : std_logic_vector(63 downto 0);
  signal xor_shift0 : std_logic_vector(63 downto 0);
  signal xor_shift1 : std_logic_vector(63 downto 0);
  signal xor_shift2 : std_logic_vector(63 downto 0);

  signal rnd_bits : std_logic_vector(63 downto 0);


Component ila_0 is 
port (
clk : in std_logic;
probe0 : in std_logic_vector(199 downto 0)
);
end Component;

begin

  chance_hi_eq <=
    '1' when (rnd_bits(47 downto 32) =
              tc_lcl_datagen_chance(31 downto 16)) else '0';
  chance_hi_less <=
    '1' when (rnd_bits(47 downto 32) <
              tc_lcl_datagen_chance(31 downto 16)) else '0';
  chance_lo_less <=
    '1' when (rnd_bits(31 downto 16) <
              tc_lcl_datagen_chance(15 downto 0)) else '0';

  process(clk)
  begin
    if (rising_edge(clk)) then
      chance_ok <= chance_hi_less or (chance_hi_eq and chance_lo_less);

      commit_len <=
        rnd_bits(5 downto 0) and tc_lcl_datagen_len_mask(13 downto 8);
    end if;
  end process;

  commit_len_ok <=
    '1' when ((commit_len <= tc_lcl_datagen_len_mask(7 downto 0)) and
              (commit_len /= (commit_len'range => '0'))) else '0';

  commit_avail_ok <=
    '1' when commit_len < data_avail else '0';

  process(clk)
  begin
    if (rising_edge(clk)) then

      data_commit <= '0';
      data_write <= '0';

      -- In case we write (such that there are two choices, and not
      -- the useless choice of keeping the old values).
      data_offset <= data_avail;
      data_word <=
        tc_lcl_datagen_mark & reset_count &
        (not data_count(7 downto 0)) & data_count;

      if (lcl_datagen_free = '1' and
          commit_len_ok = '1' and
          chance_ok = '1' and
          commit_avail_ok = '1') then
        -- We commit.
        data_commit <= '1';
        data_commit_len <= commit_len;
        -- This eats data
        data_avail <= data_avail - commit_len;
        -- And we write a header telling that this is commit data.
        data_write <= '1';
        data_offset <= (others => '0');
        data_word <=
          "1010" & "0101" & "00" & commit_len & "00" & prev_commit_len & commit_no;
        commit_no <= commit_no + 1;
        prev_commit_len <= commit_len;
      elsif (lcl_datagen_free = '1' and
             data_avail /= (data_avail'range => '1')) then
        -- When possible, we write more data
        data_write <= '1';
        -- Increment the word count
        data_count <= data_count + '1';
        -- Increment amount of available data.
        data_avail <= data_avail + 1;
      end if;

      -- Pipeline stage.
      lcl_datagen_write      <= data_write;
      lcl_datagen_word       <= data_word;
      lcl_datagen_offset     <= data_offset;
      lcl_datagen_commit     <= data_commit;
      lcl_datagen_commit_len <= data_commit_len;
      --data_free            <= lcl_datagen_free;

      if (tcp_reset = '1') then
        data_avail <= (others => '0');
        data_count <= (others => '0');
        commit_no <= (others => '0');
        prev_commit_len <= (others => '1');
      end if;

      if (tcp_reset = '1' and
          reset_prev = '0') then
        reset_count <= reset_count + 1;
      end if;
      reset_prev <= tcp_reset;
    end if;
  end process;

  -- The random generator
  xor_state0 <= xor_state;

  xor_shift0 <= xor_state0(63-18 downto 0) & (18-1 downto 0 => '0');
  xor_state1 <= xor_state0 xor xor_shift0;

  xor_shift1 <= (31-1 downto 0 => '0') & xor_state1(63 downto 31);
  xor_state2 <= xor_state1 xor xor_shift1;

  xor_shift2 <= xor_state2(63-11 downto 0) & (11-1 downto 0 => '0');
  xor_state3 <= xor_state2 xor xor_shift2;

  process(clk)
  begin
    if (rising_edge(clk)) then
      xor_state <= xor_state3;
    end if;
  end process;

  rnd_bits <= xor_state;


--ila_i : ila_0  
--port map(
--clk => clk,
--probe0(31 downto 0) => data_word,
--probe0(39 downto 32) => data_offset,
--probe0(40)      => '0',
--probe0(41)      => '0',
--probe0(42)      => data_write,
--probe0(48 downto 43) => data_commit_len,
--probe0(54)     => data_commit,
--probe0(55)       => lcl_datagen_free,
--probe0(119 downto 56)       => rnd_bits,
--probe0(120)       =>   chance_hi_eq,
--probe0(121)       =>   chance_hi_less,
--probe0(122)       =>   chance_lo_less,
--probe0(123)       =>  chance_ok, 
--probe0(129 downto 124)       =>       commit_len,
--probe0(130)       =>       commit_len_ok,
--  probe0(131)       =>       commit_avail_ok,
--probe0(139 downto 132)       =>   data_avail,
--probe0(147 downto 140)       =>        commit_no, 
--probe0(179 downto 148)       =>                tc_lcl_datagen_chance,
--probe0(195 downto 180)       =>                tc_lcl_datagen_len_mask,
--probe0(199 downto 196)       =>                tc_lcl_datagen_mark,      
--  probe0(53 downto 49)       => (others => '0')      
----  probe0(499 downto 200)       => (others => '0')
        
--);


end RTL;
