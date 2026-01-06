-- Copyright (c) 2020, Haakan T. Johansson
-- Copyright (c) 2020, Anders Furufors
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

use work.fnet_util_pkg.all;

entity fnet_out_state is
  port (clk          : in  std_logic;
        --
        out_word     : out std_logic_vector(15 downto 0);
        out_ena      : out std_logic;
        out_payload  : out std_logic;
        out_taken    : in  std_logic;
        --
        timeout_tick   : in  std_logic;
        --
        ram_stat_array : in  ram_stat_block_array(0 to OR_NUM-1);
        ram_cons_array : out ram_cons_block_array(0 to OR_NUM-1);
        dp_ram_array_porti : in  ram_block_porti_a11d16_array(0 to OR_NUM-1);
        dp_ram_array_porto : out ram_block_porto_a11d16_array(0 to OR_NUM-1) :=
          (others => rbpo_zero);
        --
        idx_tcp_prep   : in  integer_array(0 to 1);
        tcp_related    : out std_logic := '0';
        --
        idx_gen        : in  integer;
        block_non_gen  : in  std_logic;
        --
        block_any      : in  std_logic;
        --
        info_counts    : out outgoing_info_counts;
        --
        debug_state    : out std_logic_vector(3 downto 0)
        );
end fnet_out_state;

architecture RTL of fnet_out_state is

  signal      debug_state_r    : std_logic_vector(3 downto 0);
  signal a : outgoing_async_state;

  signal s : outgoing_state :=
        (state => OSM_IDLE,
         cnt => (others => '0'),
         wr_onehot => (others => '0'),
         wr_idx => 0,
         get_data => (others => '0'),
         wdata => (others => '0'),
         out_ena => '0',
         payload => '0');

  signal crc_d16_in : std_logic_vector(15 downto 0);
  signal crc32      : std_logic_vector(31 downto 0) := (others => '0');
  signal crc32_next : std_logic_vector(31 downto 0);

  signal crc32_prev : std_logic_vector(15 downto 0);

  -- Always flip between the TCP prepared memories.
  signal next_tcp_prep : std_logic := '0';

  signal a_get_data    : std_logic_vector(15 downto 0);

  -- Prescaler for word count, see comment in fnet_in_state.
  signal count_words      : std_logic_vector(4 downto 0);
  signal count_words_next : std_logic_vector(5 downto 0);

  -- To detect and prevent logic bugs in other code from hindering
  -- us to send packets completely.
  signal block_any_since_tick : std_logic := '0';
  signal block_any_inhibit    : std_logic := '0';
  signal do_block_any         : std_logic := '0';

  -- To detect and prevent logic bugs in other code from hindering
  -- us to send packets completely.
  signal block_non_gen_since_tick : std_logic := '0';
  signal block_non_gen_inhibit    : std_logic := '0';
  signal do_block_non_gen         : std_logic := '0';

  -- For debugging
  signal state_no : integer := 0;

  procedure first_hasdata(signal ram_block_array : in ram_stat_block_array;
                          signal wr_onehot : out std_logic_vector;
                          signal wr_idx : out integer;
                          variable got_one : out std_logic) is
    variable pickone : std_logic := '1';
  begin
    wr_idx <= 0;
    for i in ram_block_array'range loop
      if (ram_block_array(i).hasdata = '1' and
          do_block_any = '0' and
          (i /= idx_tcp_prep(0) or next_tcp_prep = '0') and
          (i /= idx_tcp_prep(1) or next_tcp_prep = '1') and
          (i  = idx_gen         or do_block_non_gen = '0')) then
        wr_onehot(i) <= pickone; -- Only sets one.
        if (pickone = '1') then
          wr_idx <= i;
        end if;
        pickone := '0';
      end if;
    end loop;
    got_one := not pickone;
  end procedure;


Component ila_0 is 
port (
clk : in std_logic;
probe0 : in std_logic_vector(199 downto 0)
);
end Component;

begin

  process (s,ram_stat_array,
           next_tcp_prep,out_taken,crc32,crc32_prev,
           idx_tcp_prep, idx_gen,
           do_block_any, do_block_non_gen)
    variable got_one : std_logic;
  begin
    a <= (next_state => OSM_IDLE,
          wr_onehot => s.wr_onehot,
          wr_idx => s.wr_idx,
          clear_data => '0',
          check_drop => '0',
          reset_cnt => '0',
          out_ena => '0',
          payload => '0',
          wdata => std_logic_vector(to_unsigned(16#dead#,16))); -- IDLE/GAP
    -- Mark: wdata(0) = '0' for idle (overwritten below), '1' for gap.

    case s.state is
      when OSM_IDLE =>
        a.reset_cnt <= '1';
        a.wr_onehot <= (others => '0');
        a.wr_idx <= 0;

        got_one := '0';
        first_hasdata(ram_stat_array, a.wr_onehot, a.wr_idx, got_one);
        if (got_one = '1') then
          a.next_state <= OSM_PRE_01;
        end if;
        a.wdata(0) <= '0'; -- Not sending IPG.

      when OSM_PRE_01 =>
        a.next_state <= OSM_PRE_23;
        a.wdata <= std_logic_vector(to_unsigned(16#5555#,16));
        a.out_ena <= '1';

      when OSM_PRE_23 =>
        a.reset_cnt <= '1';
        a.next_state <= OSM_PRE_45;
        a.wdata <= std_logic_vector(to_unsigned(16#5555#,16));
        a.out_ena <= '1';

      when OSM_PRE_45 =>
        a.next_state <= OSM_PRE_67;
        a.wdata <= std_logic_vector(to_unsigned(16#5555#,16));
        a.out_ena <= '1';

      when OSM_PRE_67 =>
        a.next_state <= OSM_DATA;
        a.wdata <= std_logic_vector(to_unsigned(16#55d5#,16));
        a.out_ena <= '1';
        if (ram_stat_array(s.wr_idx).broadcast = '1') then
          a.next_state <= OSM_DATA_BCAST_0;
        end if;

        -- Special handling of broadcast, since input state machine
        -- cannot overwrite the broadcast address for RARP generation.
        -- (It knows it wants to generate RARP too late; does not
        -- have spare states to do the overwrite.)
      when OSM_DATA_BCAST_0 =>
        a.next_state <= OSM_DATA_BCAST_2;
        a.wdata <= std_logic_vector(to_unsigned(16#ffff#,16));
        a.out_ena <= '1';
        a.payload <= '1';

      when OSM_DATA_BCAST_2 =>
        a.next_state <= OSM_DATA_BCAST_4;
        a.wdata <= std_logic_vector(to_unsigned(16#ffff#,16));
        a.out_ena <= '1';
        a.payload <= '1';

      when OSM_DATA_BCAST_4 =>
        a.next_state <= OSM_DATA;
        a.wdata <= std_logic_vector(to_unsigned(16#ffff#,16));
        a.out_ena <= '1';
        a.payload <= '1';

      when OSM_DATA =>
        a.next_state <= OSM_DATA;
        if (s.cnt = ram_stat_array(s.wr_idx).words) then
          a.next_state <= OSM_CRC1;
        end if;

        a.out_ena <= '1';
        a.payload <= '1';
        a.wdata <= s.get_data;

      when OSM_CRC1 =>
        a.next_state <= OSM_CRC2;
        a.wdata <= not fnet_bit_reverse(crc32(23 downto 16) &
                                        crc32(31 downto 24));
        a.out_ena <= '1';
        a.payload <= '1';
        -- Clear data two cycles before the drop check, such that
        -- packet itself if sent has been removed.
        a.clear_data <= '1';

      when OSM_CRC2 =>
        a.next_state <= OSM_GAP;
        a.reset_cnt <= '1';
        a.wdata <= not fnet_bit_reverse(crc32_prev(7 downto 0) &
                                        crc32_prev(15 downto 8));
        a.out_ena <= '1';
        a.payload <= '1';

      when OSM_GAP =>
        a.next_state <= OSM_GAP;
        if (s.cnt = 12-2) then -- Started count at 0.  Idle does not
                               -- give a full gap when the
                               -- word-to-nibble/octet converters
                               -- reduce jitter by testing next word
                               -- directly during idle.
          a.next_state <= OSM_IDLE;
        else
          -- We cannot do the drop check (for freshly arrived packet)
          -- in the last GAP cycle, since it will not be gone until
          -- IDLE selection in following cycle.
          a.check_drop <= '1';
        end if;
        -- The 'dead' pattern includes the '1', but be explicit about it.
        a.wdata(0) <= '1'; -- Sending IPG.

    end case;
  end process;

  a_get_data <= dp_ram_array_porti(s.wr_idx).rdata;

  count_words_next <= ('0' & count_words) + s.payload;

  do_block_any     <= block_any     and not block_any_inhibit;

  do_block_non_gen <= block_non_gen and not block_non_gen_inhibit;

  process (clk)
  begin
    if (rising_edge(clk)) then

      for i in ram_cons_array'range loop
        ram_cons_array(i).clear_hasdata <= '0';
      end loop;

      tcp_related <= '0';

      info_counts <= oic_zero;

      if (out_taken = '1') then
        s.state <= a.next_state;

        s.wr_onehot <= a.wr_onehot;
        s.wr_idx <= a.wr_idx;
        s.get_data <= a_get_data;

        s.wdata <= a.wdata;
        s.out_ena <= a.out_ena;
        s.payload <= a.payload;

        if (a.clear_data = '1') then
          for i in ram_cons_array'range loop
            ram_cons_array(i).clear_hasdata <= a.wr_onehot(i);
          end loop;
          if (a.wr_onehot(idx_tcp_prep(0)) = '1') then
            next_tcp_prep <= '1';
          end if;
          if (a.wr_onehot(idx_tcp_prep(1)) = '1') then
            next_tcp_prep <= '0';
          end if;

          info_counts.packets <= '1';

          if (a.wr_onehot(OR_ICMP) = '1') then
            info_counts.arp_icmp <= '1';
            -- Broadcast flag is only used for generated RARP packets.
            --if (ram_stat_array(OR_ICMP).broadcast = '1') then
            --  info_counts.rarp <= '1';
            --end if;
          end if;
          if (a.wr_onehot(OR_PKT_GEN) = '1') then
            info_counts.pkt_gen <= '1';
          end if;
          if (a.wr_onehot(OR_UDP_IDP) = '1') then
            info_counts.udp_idp <= '1';
          end if;
          for j in 0 to NUM_REG_CH-1 loop
            if (a.wr_onehot(OR_UDP+j) = '1') then
              info_counts.udp(j) <= '1';
            end if;
          end loop;
          if (a.wr_onehot(OR_TCP) = '1' or
              a.wr_onehot(OR_TCP+1) = '1') then
            info_counts.tcp <= '1';
          end if;
        end if;

        if (a.check_drop = '1') then
          -- If there is a NTP packet pending, then kill it.
          -- We rather drop NTP packets than send them with a delay,
          -- i.e. prefer to deliver no data than jittery data.

          -- When drop check happens, if the packet was actually sent,
          -- then the clear_data happened two cycles ago, so hasdata
          -- has already been cleared.
          if (ram_stat_array(OR_ICMP).hasdata = '1' and
              ram_stat_array(OR_ICMP).drop_dly = '1') then
            ram_cons_array(OR_ICMP).clear_hasdata <= '1';
            info_counts.drop_ntp <= '1';
          end if;
        end if;

        if (a.reset_cnt = '1') then
          s.cnt <= (others => '0');
        else
          s.cnt <= s.cnt + 2;
        end if;

        if (a.payload = '0') then
          crc32 <= (others => '1');
        else
          crc32 <= crc32_next;
        end if;

        crc32_prev <= crc32(15 downto 0);

        tcp_related <=
          a.wr_onehot(idx_tcp_prep(0)) or a.wr_onehot(idx_tcp_prep(1));

        count_words              <= count_words_next(4 downto 0);
        info_counts.words_div_32 <= count_words_next(5);
      end if;

      -- If the block signal is removed, then things are good.
      if (block_any = '0') then
        block_any_since_tick <= '0';
      end if;

      if (timeout_tick = '1') then
        -- Block active since this tick? (can be zeroed above,
        -- until checked below on next tick).
        block_any_since_tick <= block_any;
        -- Blocking is allowed until next tick if we have not
        -- had the block request continuously since last tick.
        block_any_inhibit <= block_any_since_tick;
        -- There is a bug somewhere (else!) if the block has
        -- been active since the previous clock cycle.
        info_counts.block_bug <= block_any_since_tick;
      end if;

      -- If the block signal is removed, then things are good.
      if (block_non_gen = '0') then
        block_non_gen_since_tick <= '0';
      end if;

      if (timeout_tick = '1') then
        -- Block active since this tick? (can be zeroed above,
        -- until checked below on next tick).
        block_non_gen_since_tick <= block_non_gen;
        -- Blocking is allowed until next tick if we have not
        -- had the block request continuously since last tick.
        block_non_gen_inhibit <= block_non_gen_since_tick;
        -- There is a bug somewhere (else!) if the block has
        -- been active since the previous clock cycle.
        info_counts.block_bug <= block_non_gen_since_tick;
      end if;
    end if;
  end process;

  crc_d16_in <= a.wdata(7 downto 0) & a.wdata(15 downto 8);

  crc32calc : entity work.fnet_crc32
    port map (
      d16 => crc_d16_in,
      crc_in => crc32,
      crc_out => crc32_next
      );

  dprapo_rd: for i in dp_ram_array_porto'range generate
    dp_ram_array_porto(i).rd <= a.wr_onehot(i) and out_taken;
    dp_ram_array_porto(i).addr <= s.cnt(10 downto 1);
  end generate;

  out_word    <= s.wdata;
  out_ena     <= s.out_ena;
  out_payload <= s.payload;

  -- For debugging
  process (clk)
  begin
    if (rising_edge(clk)) then
      case s.state is
        when OSM_IDLE         => state_no <=  1;
        when OSM_PRE_01       => state_no <=  2;
        when OSM_PRE_23       => state_no <=  3;
        when OSM_PRE_45       => state_no <=  4;
        when OSM_PRE_67       => state_no <=  5;
        when OSM_DATA_BCAST_0 => state_no <=  6;
        when OSM_DATA_BCAST_2 => state_no <=  7;
        when OSM_DATA_BCAST_4 => state_no <=  8;
        when OSM_DATA         => state_no <=  9;
        when OSM_CRC1         => state_no <= 10;
        when OSM_CRC2         => state_no <= 11;
        when OSM_GAP          => state_no <= 12;
      end case;
    end if;
  end process;

  debug_state <= std_logic_vector(to_unsigned(state_no,4));
  debug_state_r <= std_logic_vector(to_unsigned(state_no,4));



--ila_inst : ila_0 
--Port map(
--clk  => clk,
--probe0(3 downto 0) => debug_state_r,
--  probe0(4) => '0',
--probe0(20 downto 5) => s.wdata,

--  probe0(21) => s.out_ena,
--  probe0(22) => s.payload,
-- probe0(23) => out_taken,
-- probe0(24) => timeout_tick,
-- probe0(25) => block_non_gen,
-- probe0(26) => block_any,
--probe0(199 downto 27) => (others => '0')
        

--);

end RTL;
