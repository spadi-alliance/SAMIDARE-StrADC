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

use work.fnet_util_pkg.all;

use work.fnet_records.all;

entity fnet_tcp_buffer is
  generic (data_bufsize_addrbits : natural);
  port (clk          : in  std_logic;
        buf_stat     : out tcp_buffer_stat;
        tcp_stat     : in  tcp_state_async_stat;
        tcp_reset    : in std_logic;
        -- User interface (input data)
        data_write      : in  std_logic;
        data_word       : in  std_logic_vector(31 downto 0);
        data_offset     : in  std_logic_vector;
        data_commit     : in  std_logic;
        data_commit_len : in  std_logic_vector;
        data_free       : out std_logic;
        -- Internal data testing interface
        lcl_datagen_write      : in  std_logic;
        lcl_datagen_word       : in  std_logic_vector(31 downto 0);
        lcl_datagen_offset     : in  std_logic_vector;
        lcl_datagen_commit     : in  std_logic;
        lcl_datagen_commit_len : in  std_logic_vector;
        lcl_datagen_free       : out std_logic;
        -- Interface to memory
        data_port_a_addr  : out std_logic_vector;
        data_port_a_rd    : out std_logic;
        data_port_a_wr    : out std_logic;
        data_port_a_wdata : out std_logic_vector;
        -- Use the internal testing interface
        tc_do_lcl_datagen : in std_logic
        );
end fnet_tcp_buffer;

architecture RTL of fnet_tcp_buffer is

  -- Multiply by 4, since all counts are in bytes, but the addresses in 32-bit
  -- words.
  -- >= on a power of 2 is an easy comparison (lower bits disappear)
  constant max_commit_plus_1 : integer :=
    4 * (2**(fnet_max(data_commit_len'length,
                      data_offset'length)));
  constant max_commit_plus_1_lcl : integer :=
    4 * (2**(fnet_max(lcl_datagen_commit_len'length,
                      lcl_datagen_offset'length)));

  constant max_data_offset_len : integer :=
    fnet_max(data_offset'length,
             lcl_datagen_offset'length);

  constant max_data_commit_len : integer :=
    fnet_max(data_commit_len'length,
             lcl_datagen_commit_len'length);

  -- Additional pipeline stage to protect us from timing issues driving
  -- signals all over the chip, if external code uses/provides the values
  -- directly.
  signal data_pre_write  : std_logic := '0';
  signal data_pre_word   : std_logic_vector(31 downto 0) := (others => '0');
  signal data_pre_offset : std_logic_vector(max_data_offset_len-1 downto 0) :=
    (others => '0');
  signal data_pre_commit : std_logic := '0';
  signal data_pre_len    : std_logic_vector(max_data_commit_len-1 downto 0) :=
    (others => '0');
  signal data_pst_free   : std_logic := '0';
  signal data_pst_free3  : std_logic := '0';

  signal base_fill : std_logic_vector(data_bufsize_addrbits+2-1 downto 0) :=
    (data_bufsize_addrbits+2-1 downto 3 => '0') &
    "100"; -- TCP state starts at 4
           -- TODO: Increase to allow wider input.
           -- (Also at reset in code below.)

  signal next_commit : std_logic_vector(base_fill'range);

  signal fill_at : std_logic_vector(data_bufsize_addrbits+2-1 downto 0);

  -- signal used  : std_logic_vector(base_fill'range);
  signal avail : std_logic_vector(data_bufsize_addrbits+2+1-1 downto 0);

  -- Have the user attempted to overrun the buffer?
  signal commit_overrun : std_logic := '0';
  signal write_overrun  : std_logic := '0';

Component ila_0 is 
port (
clk : in std_logic;
probe0 : in std_logic_vector(199 downto 0)
);
end Component;

begin

  next_commit <= base_fill + (data_pre_len & "00");

  fill_at <= base_fill + (data_pre_offset & "00");

  avail <= tcp_stat.unfilled(avail'range);

  process(clk)
  begin
    if (rising_edge(clk)) then

      if (data_pre_commit = '1') then
        if (data_pst_free = '1') then
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

      if (data_pre_write = '1' and
          data_pst_free = '0') then
        -- Attempt was made to write data when free space was
        -- not announced.
        write_overrun <= '1';
      end if;

      data_pst_free  <= '0';
      data_pst_free3 <= '0';
      -- We must be able to hold one more than can be committed.
      -- Thus we can never fully wrap, i.e. avail will always be at
      -- least 1.  (Coming from used being max value.)
      if ((tc_do_lcl_datagen = '1' and avail >= max_commit_plus_1_lcl) or
          (tc_do_lcl_datagen = '0' and avail >= max_commit_plus_1)) then
        data_pst_free <= '1';
      end if;

      -- In worst case: we are currently at full buffer - 3 * max_commit.
      -- In this cycle we commit max, then there are only 2 * max_commit left.
      -- Since we are passing the limit, the free marker will be revoked,
      -- but the user does not notice directly, so starts another packet
      -- (which we have said is ok to complete, if free space was reported
      -- when started).
      -- Thus, some time later that will be committed, and we only have
      -- 1 * max_commit left.  By now, the free marker is since long removed.
      -- But to ensure that not even a buggy code can write into the still
      -- being transmitted memory area, we need this 1 * max_commit spare
      -- space.

      -- We tell outside world (user) that space is available if three times
      -- the space is available.  This handles the delay of a few clock
      -- cycles between user commit a new chunk of data, until we report
      -- no further free space back.
      if ((tc_do_lcl_datagen = '1' and avail >= 3*max_commit_plus_1_lcl) or
          (tc_do_lcl_datagen = '0' and avail >= 3*max_commit_plus_1)) then
        data_pst_free3 <= '1';
      end if;

      if (tcp_reset = '1') then
        base_fill <=
          (data_bufsize_addrbits+2-1 downto 3 => '0') &
          "100"; -- TCP state starts at 4
        write_overrun <= '0';
        commit_overrun <= '0';
        -- No space available during reset.
        data_pst_free3 <= '0';
      end if;

      -- Latch the stuff going to the memory, such that it has maximum
      -- tolerance against timing.
      data_port_a_wdata <= data_pre_word;
      data_port_a_rd <= '0';
      data_port_a_wr <= data_pre_write and data_pst_free;
      data_port_a_addr <= fill_at(fill_at'left downto 2);

      -- To not have to extend with zeros in blocks below.
      data_pre_offset <= (others => '0');
      data_pre_len    <= (others => '0');
      -- Pipeline stage.
      -- Also select if we should use the internal data generator source.
      if (tc_do_lcl_datagen = '1') then
        data_pre_write                             <= lcl_datagen_write;
        data_pre_word                              <= lcl_datagen_word;
        data_pre_offset(lcl_datagen_offset'range)  <= lcl_datagen_offset;
        data_pre_commit                            <= lcl_datagen_commit;
        data_pre_len(lcl_datagen_commit_len'range) <= lcl_datagen_commit_len;
      else
        data_pre_write                      <= data_write;
        data_pre_word                       <= data_word;
        data_pre_offset(data_offset'high downto
                        data_offset'low)    <= data_offset;
        data_pre_commit                     <= data_commit;
        data_pre_len(data_commit_len'high downto
                     data_commit_len'low)   <= data_commit_len;
      end if;
      data_free        <= data_pst_free3;
      lcl_datagen_free <= data_pst_free3;

    end if;
  end process;

  buf_stat.base_fill(31 downto data_bufsize_addrbits+2) <= (others => '0');
  buf_stat.base_fill(data_bufsize_addrbits+2-1 downto 0) <= base_fill;

  buf_stat.commit_overrun <= commit_overrun;
  buf_stat.write_overrun  <= write_overrun;

  --process(clk)
  --begin
  --  report "fnet_tcp_buffer: data_bufsize_addrbits:  " & integer'image(data_bufsize_addrbits);
  --  report "fnet_tcp_buffer: max_commit_plus_1:      " & integer'image(max_commit_plus_1);
  --  report "fnet_tcp_buffer: max_commit_plus_1_lcl:  " & integer'image(max_commit_plus_1_lcl);
  --  report "fnet_tcp_buffer: max_data_offset_len:    " & integer'image(max_data_offset_len);
  --  report "fnet_tcp_buffer: max_data_commit_len:    " & integer'image(max_data_commit_len);
  --  report "fnet_tcp_buffer: 3*max_commit_plus_1:    " & integer'image(3*max_commit_plus_1);
  --  report "fnet_tcp_buffer: 3*max_commit_plus_1_lcl:" & integer'image(3*max_commit_plus_1_lcl);
  --  report "fnet_tcp_buffer: base_fill'length:       " & integer'image(base_fill'length);
  --end process;


--ila_i : ila_0  
--port map(
--clk => clk,
--probe0(0) => tc_do_lcl_datagen,
--probe0(1) => data_write,
--probe0(33 downto 2) => data_word,
--probe0(34) => data_commit,
--probe0(35) => data_pst_free3,
--probe0(36) => lcl_datagen_write,
--probe0(68 downto 37) => lcl_datagen_word,
--probe0(69) => lcl_datagen_commit,
--probe0(70) => data_pre_write,
--probe0(102 downto 71) => data_pre_word,
--probe0(103) => data_pre_commit,

--  probe0(199 downto 104)       => (others => '0')
        
--);


end RTL;
