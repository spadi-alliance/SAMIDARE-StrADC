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
use work.fnet_util_pkg.all;

entity fnet_local_reg is
  generic (test_regs            : boolean;
           lcl_data_gen         : boolean;
           limit_payload_window : boolean;
           debug_regs           : boolean;
           debug_counters       : boolean;
           compiletime          : integer;
           description          : string);
  port (clk            : in  std_logic;
        --
        reg_addr    : in  std_logic_vector(24 downto 0);
        reg_data_wr : in  std_logic_vector(31 downto 0);
        reg_data_rd : out std_logic_vector(31 downto 0) := (others=>'0');
        reg_write   : in  std_logic;
        reg_read    : in  std_logic;
        reg_done    : out std_logic;
        reg_cnt     : in  std_logic_vector(3 downto 0);
        --
        in_info        : in  incoming_info_counts;
        out_info       : in  outgoing_info_counts;
        ts_info        : in  tcp_control_info_counts;
        --
        tcp_stat       : in  tcp_control_stat;
        tcp_astat      : in  tcp_state_async_stat;
        --
        tcp_reset      : out std_logic;
        --
        mdio_req_data  : out std_logic_vector(31 downto 0);
        mdio_request   : out std_logic;
        mdio_resp_data : in  std_logic_vector(17 downto 0);
        mdio_response  : in  std_logic;
        --
        tc_limit_tcp_payload    : out std_logic_vector(10 downto 0) := (others=>'0');
        tc_limit_tcp_window     : out std_logic_vector(15 downto 0) := (others=>'0');
        --
        tc_do_lcl_datagen       : out std_logic := '0';
        tc_lcl_datagen_chance   : out std_logic_vector(31 downto 0) := (others=>'0');
        tc_lcl_datagen_len_mask : out std_logic_vector(15 downto 0) := (others=>'0');
        tc_lcl_datagen_mark     : out std_logic_vector( 3 downto 0) := (others=>'0')
        );
end fnet_local_reg;

architecture RTL of fnet_local_reg is
  signal dp_ram_counts : dp_ram_block_a11d16 := dp_ram_zero;

  constant num_counters : integer := 128;
  signal to_count : std_logic_vector(num_counters-1 downto 0) :=
    (others => '0');

  constant num_rawregs : integer := 32;
  type rawregs_type is
    array(0 to num_rawregs) of std_logic_vector(31 downto 0);

  signal rawregs : rawregs_type := (others => (others => '0'));

  constant num_verregs : integer := 4+12;
  type verregs_type is
    array(0 to num_verregs) of std_logic_vector(31 downto 0);

  signal verregs : verregs_type := (others => (others => '0'));

  signal description_string : std_logic_vector(12*4*8-1 downto 0) :=
    fnet_string_to_slv(description, 48);

  constant num_testctrl_regs : integer := 8;
  type testctrl_regs_type is
    array(0 to num_testctrl_regs) of std_logic_vector(31 downto 0);

  signal testctrl_reg : testctrl_regs_type := (others => (others => '0'));

  constant num_testctrl_pulses : integer := 8;
  signal testctrl_pulse : std_logic_vector(num_testctrl_pulses-1 downto 0) :=
    (others => '0');

  signal mdio_req     : std_logic := '0';
  signal mdio_req_d   : std_logic_vector(31 downto 0) := (others => '0');
  signal mdio_latched : std_logic_vector(17 downto 0) := (others => '0');

  signal cnt : std_logic_vector(1 downto 0) := "00";

  signal cnt_idx : std_logic_vector(6 downto 0) := (others => '0');
  signal high_idx : std_logic_vector(6 downto 0) := (others => '0');

  signal high_idx0 : std_logic_vector(5 downto 0) := (others => '0');
  signal high_idx1 : std_logic_vector(5 downto 0) := (others => '0');
  signal some_idx1 : std_logic := '1';

  signal wdata_incr : std_logic := '0';
  signal wdata_next : std_logic_vector(16 downto 0) := (others => '0');

  signal reg_read_prev  : std_logic := '0';
  signal reg_read_prev2 : std_logic := '0';

  signal access_done : std_logic := '0';

begin

  -- Our counter adding operates in four phases:

  -- 0: address to low value: read
  -- 1: address to high value: read ; increment low value
  -- 2: address to low value: write ; increment high value
  -- 3: address to high value: write

  -- dp_ram_counts.port_b.i.rdata
  -- dp_ram_counts.port_b.o.rd / wr / addr / wdata

  dp_ram_counts.port_a.o.addr <= "00" & cnt_idx & cnt(0);
  dp_ram_counts.port_a.o.rd   <= not cnt(1);
  dp_ram_counts.port_a.o.wr   <=     cnt(1);

  wdata_next <= ('0' & dp_ram_counts.port_a.i.rdata) + wdata_incr;

  -- We send address on cnt 0 and 1, one higher on 1.
  -- The data is then consumed on cnt 1 and 2.
  dp_ram_counts.port_b.o.addr <= reg_addr(8 downto 0) & reg_cnt(0);
  dp_ram_counts.port_b.o.rd   <= reg_read or reg_read_prev;

  process (clk)
  begin
    if (rising_edge(clk)) then

      access_done <= '0';
      tcp_reset <= '0';

      if (reg_write = '1' and
          reg_addr(11 downto 0) = "1000" & "00000000") then -- 0x0800
        tcp_reset <= '1';
        access_done <= '1';
      end if;

      if (test_regs) then
        if (reg_write = '1' and
            reg_addr(11 downto 4) = "0100" & "0000") then -- 0x0400
          testctrl_reg(conv_integer(reg_addr(2 downto 0))) <= reg_data_wr;
          access_done <= '1';
        end if;

        if (reg_read = '1' and
            reg_addr(11 downto 4) = "0100" & "0000") then -- 0x0400
          reg_data_rd <= testctrl_reg(conv_integer(reg_addr(2 downto 0)));
          access_done <= '1';
        end if;

        testctrl_pulse <= (others => '0');

        if (reg_write = '1' and
            reg_addr(11 downto 4) = "0101" & "0000") then -- 0x0500
          testctrl_pulse(conv_integer(reg_addr(2 downto 0))) <= '1';
          access_done <= '1';
        end if;
      end if;

      -- Debug counter readout
      if (debug_counters) then
        if (reg_read_prev = '1') then
          if (reg_addr(11 downto 9) = "001") then -- 0x0200 (0x1ff)
            -- The counting updates the high word one cycle after the low word.
            -- Since we also read the high word one cycle after the low word,
            -- we'll be in sync between low and high words.
            if (reg_cnt(1 downto 0) = "01") then
              reg_data_rd(15 downto  0) <= dp_ram_counts.port_b.i.rdata;
            end if;
          end if;
        end if;
        if (reg_read_prev2 = '1') then
          if (reg_addr(11 downto 9) = "001") then -- 0x0200
            if (reg_cnt(1 downto 0) = "10") then
              reg_data_rd(31 downto 16) <= dp_ram_counts.port_b.i.rdata;
              access_done <= '1';
            end if;
          end if;
        end if;
      end if;

      -- Counter readout is pipelined.
      reg_read_prev  <= reg_read;
      reg_read_prev2 <= reg_read_prev;

      -- Debug register readout
      if (debug_regs) then
        if (reg_read = '1') then
          if (reg_addr(11 downto 5) = "0000001") then-- 0x0020 (0x1f)
            reg_data_rd <= rawregs(conv_integer(reg_addr(4 downto 0)));
            access_done <= '1';
          end if;
        end if;
      end if;

      -- Version register readout
      if (reg_read = '1') then
        if (reg_addr(11 downto 4) = "00000001") then-- 0x0010 (0x0f)
          reg_data_rd <= verregs(conv_integer(reg_addr(3 downto 0)));
          access_done <= '1';
        end if;
      end if;

      -- MDIO access (write)
      if (reg_write = '1' and
          reg_addr(11 downto 0) = "0001" & "00000000") then -- 0x0100
        if (mdio_req = '0') then
          mdio_req  <= '1';
          mdio_req_d <= reg_data_wr;
          mdio_latched(17 downto 16) <= "00";
          access_done <= '1';
        end if;
      end if;

      -- Response from MDIO interface
      if (mdio_response = '1') then
        mdio_req <= '0';
        mdio_latched <= mdio_resp_data;
      end if;

      -- MDIO access (read)
      if (reg_read = '1' and
          reg_addr(11 downto 0) = "0001" & "00000000") then -- 0x0100
        -- We report what access was performed to give the currently
        -- latched MDIO response.
        reg_data_rd <= mdio_req_d(31 downto 18) & mdio_latched;
        access_done <= '1';
      end if;

      -- Is is not necessary to choose the next address to deal with
      -- in one cycle, since a new index is chosen only every 4
      -- cycles, and then immediately reset.  Important is just to
      -- find some non-zero item (or 0).

      -- Split in two steps, in order to not have a too large priority
      -- encoder.  Step 1: Find items in the two halves of the array.
      high_idx0 <= std_logic_vector(to_unsigned(
        find_highest(to_count(num_counters/2-1 downto 0)),
        high_idx0'length));
      high_idx1 <= std_logic_vector(to_unsigned(
        find_highest(to_count(num_counters-1 downto num_counters/2)),
        high_idx1'length));
      some_idx1 <=
        fnet_or_reduction(to_count(num_counters-1 downto num_counters/2));
      -- Step 2: Choose item in second half if available, else first half.
      if (some_idx1 = '1') then
        high_idx <= "1" & high_idx1;
      else
        high_idx <= "0" & high_idx0;
      end if;

      if (cnt = "11") then
        -- Choose next address to deal with.
        cnt_idx <= high_idx;
        for i in to_count'range loop
          if (high_idx = std_logic_vector(to_unsigned(i,cnt_idx'length))) then
            to_count(i) <= '0';
          end if;
        end loop;
      end if;

      wdata_incr <= '1'; -- Default (low word) add 1
      if (cnt = "01") then -- But for high word, do the carry.
        wdata_incr <= wdata_next(16);
      end if;

      dp_ram_counts.port_a.o.wdata <= wdata_next(15 downto 0);

      -- Which items shall be counted?
      if (in_info.start_packet = '1')      then to_count( 1) <= '1'; end if;
      if (in_info.mac_for_us = '1')        then to_count( 2) <= '1'; end if;
      if (in_info.start_arp = '1')         then to_count( 3) <= '1'; end if;
      if (in_info.arp_our_ip = '1')        then to_count( 4) <= '1'; end if;
      if (in_info.start_ipv4 = '1')        then to_count( 6) <= '1'; end if;
      if (in_info.ip_hdr_ok = '1')         then to_count( 5) <= '1'; end if;
      if (in_info.ip_a_for_us = '1')       then to_count( 7) <= '1'; end if;
      if (in_info.ip_b_for_us = '1')       then to_count(69) <= '1'; end if;
      if (in_info.good_arp = '1')          then to_count( 8) <= '1'; end if;
      if (in_info.good_rarp = '1')         then to_count(68) <= '1'; end if;
      if (in_info.start_icmp = '1')        then to_count( 9) <= '1'; end if;
      if (in_info.start_udp = '1')         then to_count(10) <= '1'; end if;
      if (in_info.start_tcp = '1')         then to_count(11) <= '1'; end if;
      if (in_info.good_icmp = '1')         then to_count(12) <= '1'; end if;
      if (in_info.good_udp = '1')          then to_count(13) <= '1'; end if;
      if (in_info.start_bootp = '1')       then to_count(73) <= '1'; end if;
      if (in_info.good_bootp = '1')        then to_count(74) <= '1'; end if;
      if (in_info.good_dhcp_offer = '1')   then to_count(77) <= '1'; end if;
      if (in_info.good_dhcp_ack = '1')     then to_count(78) <= '1'; end if;
      if (in_info.start_ntp = '1')         then to_count(71) <= '1'; end if;
      if (in_info.good_ntp = '1')          then to_count(72) <= '1'; end if;
      if (in_info.good_tcp = '1')          then to_count(14) <= '1'; end if;
      if (in_info.bad_cksum = '1')         then to_count(63) <= '1'; end if;
      if (in_info.bad_crc = '1')           then to_count(64) <= '1'; end if;
      if (in_info.incomplete = '1')        then to_count(65) <= '1'; end if;
      if (in_info.spurious = '1')          then to_count(66) <= '1'; end if;
      if (in_info.stop_parse = '1')        then to_count(67) <= '1'; end if;
      if (in_info.udp_arm  = '1')          then to_count(15) <= '1'; end if;
      if (in_info.udp_badactivearm  = '1') then to_count(16) <= '1'; end if;
      if (in_info.udp_reset = '1')         then to_count(17) <= '1'; end if;
      if (in_info.udp_badreset = '1')      then to_count(18) <= '1'; end if;
      if (in_info.udp_disconnect = '1')    then to_count(19) <= '1'; end if;
      if (in_info.udp_baddisconnect = '1') then to_count(20) <= '1'; end if;
      if (in_info.udp_regaccess = '1')     then to_count(21) <= '1'; end if;
      if (in_info.udp_regaccess_idp = '1') then to_count(60) <= '1'; end if;
      if (in_info.udp_ra_is_otherip = '1') then to_count(22) <= '1'; end if;
      if (in_info.udp_ra_seqplus1 = '1')   then to_count(23) <= '1'; end if;
      if (in_info.udp_ra_repeat = '1')     then to_count(24) <= '1'; end if;
      if (in_info.udp_ra_busy = '1')       then to_count(25) <= '1'; end if;
      if (in_info.udp_ra_idp_busy = '1')   then to_count(61) <= '1'; end if;
      if (in_info.slow_tick = '1')         then to_count(26) <= '1'; end if;
      if (in_info.timeout_tick = '1')      then to_count(27) <= '1'; end if;
      if (in_info.words_div_32 = '1')      then to_count(58) <= '1'; end if;

      if (out_info.arp_icmp = '1')         then to_count(33) <= '1'; end if;
      if (out_info.drop_ntp = '1')         then to_count(76) <= '1'; end if;
      if (out_info.pkt_gen = '1')          then to_count(70) <= '1'; end if;
      if (out_info.udp_idp = '1')          then to_count(62) <= '1'; end if;
      for i in out_info.udp'range loop
        if (out_info.udp(i) = '1')         then to_count(34+i) <= '1'; end if;
      end loop;                            --      last: 34+8 = 42
      if (out_info.tcp = '1')              then to_count(43) <= '1'; end if;
      if (out_info.packets = '1')          then to_count(44) <= '1'; end if;
      if (out_info.words_div_32 = '1')     then to_count(59) <= '1'; end if;
      if (out_info.block_bug = '1')        then to_count(75) <= '1'; end if;

      if (ts_info.start_meas_rtt = '1')    then to_count(47) <= '1'; end if;
      if (ts_info.did_repeat = '1')        then to_count(48) <= '1'; end if;
      if (ts_info.did_keepalive = '1')     then to_count(57) <= '1'; end if;
      if (ts_info.got_ack = '1')           then to_count(49) <= '1'; end if;
      if (ts_info.got_meas_rtt = '1')      then to_count(50) <= '1'; end if;
      if (ts_info.same_ack = '1')          then to_count(51) <= '1'; end if;
      if (ts_info.twice_same_ack = '1')    then to_count(52) <= '1'; end if;
      if (ts_info.abort_repeat = '1')      then to_count(53) <= '1'; end if;
      if (ts_info.connect = '1')           then to_count(54) <= '1'; end if;
      if (ts_info.got_syn = '1')           then to_count(55) <= '1'; end if;
      if (ts_info.new_rtt_est = '1')       then to_count(56) <= '1'; end if;
      -- Next to use:                                    79

      cnt <= cnt + 1;
    end if;
  end process;

  reg_done <= access_done;

  mdio_request  <= mdio_req;
  mdio_req_data <= mdio_req_d;

  verregs(0) <= std_logic_vector(to_unsigned(compiletime, verregs(0)'length));

  descr_to_ver: for i in 0 to 11 generate
    verregs(4+i) <= description_string(4*8*(i+1)-1 downto 4*8*i);
  end generate;

  rawregs(1)                               <= tcp_stat.base_seqno;
  rawregs(2)(tcp_stat.max_sent'range)      <= tcp_stat.max_sent;
  --      3  latched below, due to timing
  --      4  latched below, due to timing
  --      5  latched below, due to timing
  rawregs(6)(tcp_stat.window_sz'range)     <= tcp_stat.window_sz;
  rawregs(7)(tcp_stat.rtt_trip'range)      <= tcp_stat.rtt_trip;
  --      8  latched below, due to timing
  rawregs(9)(tcp_stat.same_ack'range)      <= tcp_stat.same_ack;
  rawregs(10)(tcp_stat.rtt_est'range)      <= tcp_stat.rtt_est;
  rawregs(11)                              <= in_info.b_ip0123;

  process (clk)
  begin
    if (rising_edge(clk)) then
      rawregs(3)(tcp_astat.filled'range)       <= tcp_astat.filled;
      rawregs(4)(tcp_astat.unsent'range)       <= tcp_astat.unsent;
      rawregs(5)(tcp_astat.unfilled'range)     <= tcp_astat.unfilled;
      rawregs(8)(tcp_astat.cur_off'range)      <= tcp_astat.cur_off;
    end if;
  end process;

  if_dpdp_ram_info_counts: if (debug_counters) generate
    dpdp_ram_info_counts : entity work.ram_block_a11d16
      port map (
        clk       => clk,
        porti_a   => dp_ram_counts.port_a.i,
        porto_a   => dp_ram_counts.port_a.o,
        porti_b   => dp_ram_counts.port_b.i,
        porto_b   => dp_ram_counts.port_b.o
        );
  end generate;

  limit_payl_wind: if (limit_payload_window) generate
    -- Registers to perform internal testing.
    tc_limit_tcp_payload    <= testctrl_reg(0)(tc_limit_tcp_payload'range);
    tc_limit_tcp_window     <= testctrl_reg(1)(tc_limit_tcp_window'range);
  end generate;

  data_gen: if (lcl_data_gen) generate
    tc_do_lcl_datagen       <= testctrl_reg(2)(0);
    tc_lcl_datagen_chance   <= testctrl_reg(3)(tc_lcl_datagen_chance'range);
    tc_lcl_datagen_len_mask <= testctrl_reg(4)(tc_lcl_datagen_len_mask'range);
    tc_lcl_datagen_mark     <= testctrl_reg(5)(tc_lcl_datagen_mark'range);
  end generate;

end RTL;

-- Internal (local) register map:
--
-- All internal access has bit 0x08000000 set.
-- All reads are 0x20000000 and writes are 0x80000000.
--
-- We so far only care about bits 0 to 11, i.e. bits 12-26 are ignored.
--
--    0x03fff000 ignored
--
-- R: 0x28000020 - 0x2800003f (0x28000020, mask 0x0000001f) internal status
-- R: 0x28000200 - 0x280003ff (0x28000200, mask 0x000001ff) counters
--
-- W: 0x88000800   TCP reset
--
-- R: 0x28000400 - 0x28000407 (0x28000400, mask 0x00000007) test reg
-- W: 0x88000400 - 0x28000407 (0x28000400, mask 0x00000007) test reg
--
-- testreg(0): payload constraint (0 = no constraint)
-- testreg(1): window constraint (0 = no constraint)
-- testreg(2): local data generator, bit 0: enable
-- testreg(3): local data generator, chance to generate data word
-- testreg(4): local data generator, mask for commit length
--
-- W: 0x88000500 - 0x28000507 (0x28000400, mask 0x00000007) test pulse (unused)
