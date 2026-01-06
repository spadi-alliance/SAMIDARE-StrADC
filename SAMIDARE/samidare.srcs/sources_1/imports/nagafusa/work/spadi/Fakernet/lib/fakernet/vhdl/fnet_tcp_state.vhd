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

entity fnet_tcp_state is
  generic (data_bufsize_addrbits : natural);
  port (clk          : in  std_logic;
        --
        stat         : in  tcp_control_stat;
        buf_stat     : in  tcp_buffer_stat;
        --
        astat        : out tcp_state_async_stat
        );
end fnet_tcp_state;

-- The TCP state is kept track of by three location markers:
--
-- * base_seqno,
-- * max_fill, and
-- * base_fill.
--
-- The first two are updated (moved forward) by the tcp_control,
-- while the third is updated (moved forward) by the tcp_buffer.
--
-- What actions (data sending, and data filling) are allowed by
-- each is however given by the differences of these three values.
--
-- This module calculates those differences.
--
-- Note that since the values are latched in the respective routines,
-- we here do not latch them, just take them as granted.

architecture RTL of fnet_tcp_state is

  constant buffer_size : integer := 2**(data_bufsize_addrbits+2); -- In bytes.

  signal a_stat_initval : tcp_state_async_stat :=
    (cur_off   => (others => '0'),
     base_seqno_hi_plus_1 => (20-16 => '1', 16-16 => '1', others => '0'),
     filled    => (others => '0'),
     unsent    => (others => '0'),
     unfilled  => (others => '0'),
     some_sent => '0');

  signal a_stat : tcp_state_async_stat := a_stat_initval;

  signal ext_cur : std_logic_vector(16 downto 0);
  signal cur_off : std_logic_vector(16 downto 0);

  -- TODO: Only as many bits as needed by arithmetic?
  signal tmp_filled   : std_logic_vector(31 downto 0);
  signal tmp_unsent   : std_logic_vector(31 downto 0);
  signal tmp_unfilled : std_logic_vector(31 downto 0);

  -- For debug;
  signal x_cur_off : std_logic_vector(15 downto 0);

  signal x_filled  : std_logic_vector(31 downto 0);
  signal x_unsent  : std_logic_vector(31 downto 0);

begin

  ext_cur(16) <= '0' when (stat.max_sent(16) =
                           stat.base_seqno(16)) else '1';
  ext_cur(15 downto 0) <= stat.max_sent(15 downto 0);

  cur_off <= ext_cur - ('0' & stat.base_seqno(15 downto 0));

  a_stat.some_sent <=
    '1' when (stat.max_sent /= stat.base_seqno(16 downto 0)) else '0';

  a_stat.cur_off <= cur_off(15 downto 0);

  -- Should we make this part of the ctrl_stat?  (even though not latched)
  a_stat.base_seqno_hi_plus_1 <= stat.base_seqno(31 downto 16) + 1;

  tmp_filled <= buf_stat.base_fill - stat.base_seqno;
  -- Below we use the clamped value (a_stat.filled), since base_fill
  -- is a clamped value, and the subtraction above therefore give
  -- arbitrary high bits.
  tmp_unsent <= a_stat.filled - cur_off;
  tmp_unfilled <=
    std_logic_vector(to_unsigned(buffer_size, tmp_unfilled'length)) -
    a_stat.filled;

  -- Filled and unsent can never be the entire buffer, since free space
  -- is left for new data.  Since the buffer can be completely empty,
  -- unfilled need to use an extra bit.
  a_stat.filled(data_bufsize_addrbits+2-1 downto 0) <=
    tmp_filled(data_bufsize_addrbits+2-1 downto 0);
  a_stat.unsent(data_bufsize_addrbits+2-1 downto 0) <=
    tmp_unsent(data_bufsize_addrbits+2-1 downto 0);
  a_stat.unfilled(data_bufsize_addrbits+2 downto 0) <=
    tmp_unfilled(data_bufsize_addrbits+2 downto 0);

  a_stat.filled(31 downto data_bufsize_addrbits+2) <= (others => '0');
  a_stat.unsent(31 downto data_bufsize_addrbits+2) <= (others => '0');
  a_stat.unfilled(31 downto data_bufsize_addrbits+2+1) <= (others => '0');

  -- Not needed since the TCP control will discard an ongoing repeat
  -- packet preparation if the master catches up meanwhile:
  -- We leave free space of one packet payload (+ small to not make
  -- the adder larger than necessary).  This allows the packet preparation
  -- procedure to continue prepare an old packet, even in case we meanwhile
  -- receive an ACK message making it unnecessary.  (It is easier to not
  -- detect the unnecessary condition, and just go ahead and transmit it).
  -- stat.num_free <= memory_size - stat.num_avail - (1536); -- 1024+512

  astat <= a_stat;

  -- For debug

  x_cur_off <= a_stat.cur_off;
  x_filled  <= a_stat.filled;
  x_unsent  <= a_stat.unsent;

  --process(clk)
  --begin
  --  report "fnet_tcp_state: buffer_size:" & integer'image(buffer_size);
  --end process;

end RTL;
