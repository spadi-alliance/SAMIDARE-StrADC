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

entity fnet_in_state is
  port (clk             : in  std_logic;
        --
        in_word         : in  std_logic_vector(15 downto 0);
        in_got_word     : in  std_logic;
        in_new_packet   : in  std_logic;
        -- Config
        cfg_macaddr     : in  std_logic_vector (47 downto 0);
        cfg_ipaddr      : in  std_logic_vector (31 downto 0);
        cfg_fixed_ip    : in  std_logic;
        cfg_dyn_ip      : in  std_logic;
        cfg_gen_rarp    : in  std_logic;
        cfg_gen_bootp   : in  std_logic;
        cfg_gen_dhcp    : in  std_logic;
        cfg_gen_ntpq    : in  std_logic;
        --
        slow_clock_tick : in  std_logic;
        timeout_tick    : in  std_logic;
        --
        tcp_reset       : in  std_logic;
        --
        tcp_stat        : in  tcp_control_stat;
        tcp_buf_stat    : in  tcp_buffer_stat;
        tcp_astat       : in  tcp_state_async_stat;
        tcp_recv        : out tcp_control_recv := tcp_sr_zero;
        --
        ntp_stat        : in  ntp_state;
        --
        ntpr_got        : out std_logic;
        ntpr_ip         : out std_logic_vector(31 downto 0);
        ntpr_recv_ts    : out std_logic_vector(63 downto 0);
        ntpr_data       : out word32_array(0 to 11);
        --
        dyn_in_stat     : out dync_in_stat := dis_zero;
        dyn_ctrl_stat   : in  dync_control_stat;
        --
        ram_stat_arp_icmp   : in ram_stat_block;
        ram_stat_udp_regacc : in ram_stat_block;
        ram_stat_udp_regidp : in ram_stat_block;
        ram_stat_udp_regres : in ram_stat_block_array(0 to NUM_REG_CH-1);
        ram_stat_tcp_template  : in ram_stat_block;
        ram_prod_arp_icmp   : out ram_prod_block;
        ram_prod_udp_regacc : out ram_prod_block;
        ram_prod2_udp_regres : out ram_prod2_block_array(0 to NUM_REG_CH-1);
        ram_prod_tcp_template  : out ram_prod_block;
        dp_ram_arp_icmp_porti : in  ram_block_porti_a11d16;
        dp_ram_arp_icmp_porto : out ram_block_porto_a11d16 := rbpo_zero;
        dp_ram_udp_regacc_porti : in  ram_block_porti_a11d16;
        dp_ram_udp_regacc_porto : out ram_block_porto_a11d16 := rbpo_zero;
        dp_ram_tcp_template_porti : in  ram_block_porti_a11d16;
        dp_ram_tcp_template_porto : out ram_block_porto_a11d16 := rbpo_zero;
        regacc_prod_aux     : out regacc_aux_prod;
        --
        info_counts    : out incoming_info_counts;
        --
        debug_state    : out std_logic_vector(7 downto 0)
        );
end fnet_in_state;

architecture RTL of fnet_in_state is
  signal a : incoming_async_state;

  signal s : incoming_state :=
        (state => ISM_BAD_PACKET,
         off => (others => '0'),
         fill_ram_arp_icmp => '0',
         fill_ram_udp_regacc => '0',
         fill_ram_tcp_template => '0',
         ipv4_remain => (others => '0'),
         minsz_remain => (others => '0'),
         ipv4_remain_m2 => (others => '0'),
         minsz_remain_m2 => (others => '0'),
         ipv4_remain_p6 => (others => '0'),
         ipv4_remain_is_0 => '0',
         ipv4_remain_m2_is_0 => '0',
         ipv4_remain_m8_ge_0 => '0',
         ipv4_remain_is_62 => '0',
         is_our_mac => '0',
         is_our_ip => '0',
         is_icmp => '0',
         is_tcp => '0',
         is_udp => '0',
         is_bootp => '0',
         is_dhcp => '0',
         is_dhcp_offer => '0',
         is_dhcp_ack => '0',
         is_ntp => '0',
         is_ntp_resp => '0',
         is_tcp_syn => '0',
         is_tcp_ack => '0',
         is_rarp_resp => '0',
         dhcp_option_length_hi => '0',
         dhcp_option => (others => '0'),
         dhcp_option_remain => (others => '0'),
         cur_other_ip_port => (ip01 => (others => '0'),
                               ip23 => (others => '0'),
                               portno => (others => '0')),
         dyn_offer_ip_port => (ip01 => (others => '0'),
                               ip23 => (others => '0'),
                               portno => (others => '0')),
         tcp_other_ip_port => (ip01 => (others => '0'),
                               ip23 => (others => '0'),
                               portno => (others => '0')),
         prev_our_a_ip01 => '0',
         prev_our_b_ip01 => '0',
         prev_bootp_xid_hi => '0',
         prev_dhcp_xid_hi  => '0',
         reg_idp => '0',
         reg_ch => 0,
         reg => (others => (seq_no => (others => '0'),
                            seq_arm_reset_no => (others => '0'),
                            seq_reset_armed => '0',
                            seq_connected => '0',
                            seq_did_access => '0',
                            seq_active_marks => (others => '0'),
                            other_ip_port => (ip01 => (others => '0'),
                                              ip23 => (others => '0'),
                                              portno => (others => '0')))),
         do_reg_seq_failure => '0',
         do_reg_seq_reset_arm => '0',
         do_reg_seq_reset => '0',
         do_reg_disconnect => '0',
         do_reg_access => '0',
         do_reg_access_idp => '0',
         repeat_reg_response => '0',
         set_regacc_wcksum => '0',
         ignore_wcksum => '0',
         accum_cksum => '0',
         pseudo_cksum => '0',
         rcksum => (others => '0'),
         wcksum => (others => '0'),
         wcksum_ip => (others => '0'),
         psdcksum => (others => '0'),
         cksum_0 => '0',
         our_mac01 => (others => '0'),
         our_mac23 => (others => '0'),
         our_mac45 => (others => '0'),
         our_a_ip01 => (others => '0'),
         our_a_ip23 => (others => '0'),
         seqno_hi_same => '0',
         seqno_hi_next => '0',
         packet_start_count => (others => '0'));

  -- Alias from dyncontrol.
  signal our_b_ip01 : std_logic_vector(15 downto 0);
  signal our_b_ip23 : std_logic_vector(15 downto 0);

  signal off   : std_logic_vector(10 downto 0);
  signal offm2 : std_logic_vector(10 downto 0);

  signal word_prev1       : std_logic_vector(15 downto 0);
  signal got_word_prev1   : std_logic;
  signal new_packet_prev1 : std_logic;

  signal w               : std_logic_vector(15 downto 0); -- in_word_prev
  signal got_word_prev   : std_logic;
  signal new_packet_prev : std_logic;

  signal is_our_mac01 : std_logic;
  signal is_our_mac23 : std_logic;
  signal is_our_mac45 : std_logic;

  signal is_our_a_ip01 : std_logic;
  signal is_our_a_ip23 : std_logic;
  signal is_our_b_ip01 : std_logic;
  signal is_our_b_ip23 : std_logic;

  signal is_dyn_offer_ip01 : std_logic;
  signal is_dyn_offer_ip23 : std_logic;

  signal is_bootp_xid_hi : std_logic;
  signal is_bootp_xid_lo : std_logic;
  signal is_dhcp_xid_hi  : std_logic;
  signal is_dhcp_xid_lo  : std_logic;

  signal is_icmp : std_logic;
  signal is_tcp : std_logic;
  signal is_udp : std_logic;

  signal is_udp_ra_reset_arm : std_logic;
  signal is_udp_ra_reset : std_logic;
  signal is_udp_ra_disconnect : std_logic;

  signal is_tcp_dest_port : std_logic;

  signal is_tcp_seq_hi : std_logic;
  signal is_tcp_seq_lo : std_logic;

  signal tcp_seq_hi : std_logic_vector(15 downto 0) := (others => '0');
  signal tcp_seq_lo : std_logic_vector(15 downto 0) := (others => '0');
  signal tcp_seq_lo_carry : std_logic := '0';

  signal w_minus_6 : std_logic_vector(15 downto 0);
  signal w_plus_1 : std_logic_vector(16 downto 0);
  signal w_minus_0x0100 : std_logic_vector(15 downto 0);

  signal is_w_0000 : std_logic;
  signal is_w_0001 : std_logic;
  signal is_w_0004 : std_logic;
  signal is_w_0201 : std_logic;
  signal is_w_0604 : std_logic;
  signal is_w_0800 : std_logic;
  signal is_w_0806 : std_logic;
  signal is_w_4000 : std_logic;
  signal is_w_5363 : std_logic;
  signal is_w_6382 : std_logic;
  signal is_w_8035 : std_logic;
  signal is_whi_00 : std_logic;
  signal is_whi_02 : std_logic;
  signal is_whi_05 : std_logic;
  signal is_whi_06 : std_logic;
  signal is_whi_45 : std_logic;
  signal is_whi_ff : std_logic;
  signal is_wlo_00 : std_logic;
  signal is_wlo_02 : std_logic;
  signal is_wlo_05 : std_logic;
  signal is_wlo_ff : std_logic;

  signal is_prev_wlo_02 : std_logic;
  signal is_prev_wlo_05 : std_logic;

  signal dhcp_option_remain_is_1 : std_logic;
  signal dhcp_option_remain_is_0 : std_logic;

  signal x_is_our_mac01 : std_logic;
  signal x_is_our_mac23 : std_logic;
  signal x_is_our_mac45 : std_logic;

  signal x_is_our_a_ip01 : std_logic;
  signal x_is_our_a_ip23 : std_logic;
  signal x_is_our_b_ip01 : std_logic;
  signal x_is_our_b_ip23 : std_logic;
  signal x_is_our_a_ip : std_logic;
  signal x_is_our_b_ip : std_logic;

  signal x_is_dyn_offer_ip01 : std_logic;
  signal x_is_dyn_offer_ip23 : std_logic;

  signal x_is_bootp_xid_hi : std_logic;
  signal x_is_bootp_xid_lo : std_logic;
  signal x_is_dhcp_xid_hi  : std_logic;
  signal x_is_dhcp_xid_lo  : std_logic;

  signal x_is_bootp_xid    : std_logic;
  signal x_is_dhcp_xid     : std_logic;

  signal x_is_icmp : std_logic;
  signal x_is_tcp : std_logic;
  signal x_is_udp : std_logic;

  signal x_is_udp_ra_reset_arm : std_logic;
  signal x_is_udp_ra_reset : std_logic;
  signal x_is_udp_ra_disconnect : std_logic;

  signal x_is_tcp_dest_port : std_logic;

  signal x_is_tcp_seq_hi : std_logic;
  signal x_is_tcp_seq_lo : std_logic;

  signal x_w_minus_6 : std_logic_vector(15 downto 0);
  signal x_w_plus_1 : std_logic_vector(16 downto 0);
  signal x_w_minus_0x0100 : std_logic_vector(15 downto 0);

  signal x_is_w_0000 : std_logic;
  signal x_is_w_0001 : std_logic;
  signal x_is_w_0004 : std_logic;
  signal x_is_w_0201 : std_logic;
  signal x_is_w_0604 : std_logic;
  signal x_is_w_0800 : std_logic;
  signal x_is_w_0806 : std_logic;
  signal x_is_w_4000 : std_logic;
  signal x_is_w_5363 : std_logic;
  signal x_is_w_6382 : std_logic;
  signal x_is_w_8035 : std_logic;
  signal x_is_whi_00 : std_logic;
  signal x_is_whi_02 : std_logic;
  signal x_is_whi_05 : std_logic;
  signal x_is_whi_06 : std_logic;
  signal x_is_whi_45 : std_logic;
  signal x_is_whi_ff : std_logic;
  signal x_is_wlo_00 : std_logic;
  signal x_is_wlo_02 : std_logic;
  signal x_is_wlo_05 : std_logic;
  signal x_is_wlo_ff : std_logic;

  signal fold_rcksum       : std_logic_vector(16 downto 0);
  signal fold_wcksum       : std_logic_vector(16 downto 0);
  signal accum_rcksum      : std_logic_vector(16 downto 0);
  signal accum_wcksum      : std_logic_vector(16 downto 0);
  signal w_accum_cksum     : std_logic_vector(15 downto 0);
  signal wdata_accum_cksum : std_logic_vector(15 downto 0);

  signal dly_s_accum_cksum  : std_logic;
  signal dly_s_pseudo_cksum : std_logic;

  signal tmp_rcksum : std_logic_vector(16 downto 0);
  signal tmp_wcksum : std_logic_vector(16 downto 0);
  signal tmp_psdcksum : std_logic_vector(16 downto 0);

  signal dly_s_psdcksum : std_logic_vector(16 downto 0);

  signal rcksum_good : std_logic := '0';

  signal actual_woff  : std_logic_vector(10 downto 0) := (others => '0');
  signal actual_wdata : std_logic_vector(15 downto 0) := (others => '0');

  signal dly_actual_woff  : std_logic_vector(10 downto 0) := (others => '0');
  signal dly_actual_wdata : std_logic_vector(15 downto 0) := (others => '0');
  signal dly_wicmpcksum : std_logic := '0';
  signal dly_wudpcksum : std_logic := '0';
  signal dly_actual_dowrite : std_logic := '0';

  signal crc_d16    : std_logic_vector(15 downto 0);
  signal crc32      : std_logic_vector(31 downto 0) := (others => '0');
  signal crc32_next : std_logic_vector(31 downto 0);

  signal is_good_crc32 : std_logic;

  signal reg_seq_no_plus_1 : std_logic_vector(s.reg(0).seq_no'range);

  signal is_req_seq_arm_reset_no : std_logic;
  signal is_reg_seq_no : std_logic;
  signal is_reg_seq_no_plus_1 : std_logic;

  signal x_is_req_seq_arm_reset_no : std_logic;
  signal x_is_reg_seq_no : std_logic;
  signal x_is_reg_seq_no_plus_1 : std_logic;

  signal reg_ch_other_ip_port : other_ip_port_rec;

  signal is_reg_ch_other_ip_port : std_logic;
  signal is_tcp_other_ip_port : std_logic;

  signal x_is_reg_ch_other_ip_port : std_logic;
  signal x_is_tcp_other_ip_port : std_logic;

  signal is_w_ge_tcp_stat_base_seqno_lo : std_logic;
  signal is_tcp_stat_max_sent16_eq_base_seqno16 : std_logic;
  signal is_w_le_tcp_stat_max_sent_lo : std_logic;

  signal x_is_w_ge_tcp_stat_base_seqno_lo : std_logic;
  signal x_is_tcp_stat_max_sent16_eq_base_seqno16 : std_logic;
  signal x_is_w_le_tcp_stat_max_sent_lo : std_logic;

  signal is_ntp_ver_3or4_mode_3or4 : std_logic;
  signal is_ntp_mode_4 : std_logic;

  signal x_is_ntp_ver_3or4_mode_3or4 : std_logic;
  signal x_is_ntp_mode_4 : std_logic;

  signal ntp_pkt_start_ts : std_logic_vector(63 downto 0) := (others => '0');
  signal ntp_tx_future_ts : std_logic_vector(63 downto 0) := (others => '0');
  -- 22 bits = 2^22/2^32 = 2^-10 = 0.97 ms.
  -- At 10 Mbps a 100 byte NTP packet takes 0.1 ms to transmit.
  signal ntp_tx_delay : std_logic_vector(21 downto 0) := (others => '0');
  signal ntp_tx_delay_ref_ts : std_logic_vector(ntp_tx_delay'range) :=
    (others => '0');

  signal ntp_data : word32_array(0 to 11) := (others => (others => '0'));

  signal cnts : incoming_info_counts;

  -- We are a prescaler, since the global scalers cannot count once
  -- per cycle.  They only count once per four cycles, and for all
  -- counts, so we'll use every 32/4 = 8th counting opportunity,
  -- if we get data full speed.
  signal count_words      : std_logic_vector(4 downto 0);
  signal count_words_next : std_logic_vector(5 downto 0);

  -- For debugging
  signal state_no : integer := 0;
  signal      debug_state_r    : std_logic_vector(7 downto 0);

Component ila_0 is 
port (
clk : in std_logic;
probe0 : in std_logic_vector(199 downto 0)
);
end Component;

begin

  our_b_ip01 <= dyn_ctrl_stat.dyn_ip(31 downto 16);
  our_b_ip23 <= dyn_ctrl_stat.dyn_ip(15 downto  0);

  off <= s.off;

  x_is_our_mac01 <= '1' when (word_prev1 = s.our_mac01) else '0';
  x_is_our_mac23 <= '1' when (word_prev1 = s.our_mac23) else '0';
  x_is_our_mac45 <= '1' when (word_prev1 = s.our_mac45) else '0';

  x_is_our_a_ip01 <= '1' when (word_prev1 = s.our_a_ip01) else '0';
  x_is_our_a_ip23 <= '1' when (word_prev1 = s.our_a_ip23) else '0';

  x_is_our_b_ip01 <= '1' when (word_prev1 = our_b_ip01) else '0';
  x_is_our_b_ip23 <= '1' when (word_prev1 = our_b_ip23) else '0';

  x_is_our_a_ip <= s.prev_our_a_ip01 and is_our_a_ip23 and cfg_fixed_ip;
  x_is_our_b_ip <= s.prev_our_b_ip01 and is_our_b_ip23 and cfg_dyn_ip and
                   dyn_ctrl_stat.dyn_ip_set;

  x_is_icmp <= '1' when (word_prev1(7 downto 0) = 16#01#) else '0';
  x_is_tcp  <= '1' when (word_prev1(7 downto 0) = 16#06#) else '0';
  x_is_udp  <= '1' when (word_prev1(7 downto 0) = 16#11#) else '0';

  x_is_udp_ra_reset_arm  <=
    '1' when (word_prev1(15 downto 12) = "1000") else '0';
  x_is_udp_ra_reset      <=
    '1' when (word_prev1(15 downto 12) = "0100") else '0';
  x_is_udp_ra_disconnect <=
    '1' when (word_prev1(15 downto 12) = "0010") else '0';

  x_is_tcp_dest_port <= '1';

  x_is_tcp_seq_hi <= '1' when (word_prev1 = tcp_seq_hi) else '0';
  x_is_tcp_seq_lo <= '1' when (word_prev1 = tcp_seq_lo) else '0';

  x_w_minus_6 <= word_prev1 - 6;
  x_w_plus_1 <= ('0' & word_prev1) + 1;
  x_w_minus_0x0100 <= word_prev1 - 16#0100#;

  x_is_w_0000 <= '1' when (word_prev1 = 16#0000#) else '0';
  x_is_w_0001 <= '1' when (word_prev1 = 16#0001#) else '0';
  x_is_w_0004 <= '1' when (word_prev1 = 16#0004#) else '0';
  x_is_w_0201 <= '1' when (word_prev1 = 16#0201#) else '0';
  x_is_w_0604 <= '1' when (word_prev1 = 16#0604#) else '0';
  x_is_w_0800 <= '1' when (word_prev1 = 16#0800#) else '0';
  x_is_w_0806 <= '1' when (word_prev1 = 16#0806#) else '0';
  x_is_w_4000 <= '1' when (word_prev1 = 16#4000#) else '0';
  x_is_w_5363 <= '1' when (word_prev1 = 16#5363#) else '0';
  x_is_w_6382 <= '1' when (word_prev1 = 16#6382#) else '0';
  x_is_w_8035 <= '1' when (word_prev1 = 16#8035#) else '0';
  x_is_whi_00 <= '1' when (word_prev1(15 downto 8) = 16#00#) else '0';
  x_is_whi_02 <= '1' when (word_prev1(15 downto 8) = 16#02#) else '0';
  x_is_whi_05 <= '1' when (word_prev1(15 downto 8) = 16#05#) else '0';
  x_is_whi_06 <= '1' when (word_prev1(15 downto 8) = 16#06#) else '0';
  x_is_whi_45 <= '1' when (word_prev1(15 downto 8) = 16#45#) else '0';
  x_is_whi_ff <= '1' when (word_prev1(15 downto 8) = 16#ff#) else '0';
  x_is_wlo_00 <= '1' when (word_prev1( 7 downto 0) = 16#00#) else '0';
  x_is_wlo_02 <= '1' when (word_prev1( 7 downto 0) = 16#02#) else '0';
  x_is_wlo_05 <= '1' when (word_prev1( 7 downto 0) = 16#05#) else '0';
  x_is_wlo_ff <= '1' when (word_prev1( 7 downto 0) = 16#ff#) else '0';

  dhcp_option_remain_is_0 <=
    '1' when (conv_integer(s.dhcp_option_remain) = 0) else '0';
  dhcp_option_remain_is_1 <=
    '1' when (conv_integer(s.dhcp_option_remain) = 1) else '0';

  x_is_bootp_xid_hi <=
    '1' when (word_prev1 = dyn_ctrl_stat.bootp_xid(31 downto 16)) else '0';
  x_is_bootp_xid_lo <=
    '1' when (word_prev1 = dyn_ctrl_stat.bootp_xid(15 downto  0)) else '0';
  x_is_dhcp_xid_hi <=
    '1' when (word_prev1 = dyn_ctrl_stat.dhcp_xid(31 downto 16)) else '0';
  x_is_dhcp_xid_lo <=
    '1' when (word_prev1 = dyn_ctrl_stat.dhcp_xid(15 downto  0)) else '0';

  x_is_bootp_xid <= s.prev_bootp_xid_hi and is_bootp_xid_lo;
  x_is_dhcp_xid  <= s.prev_dhcp_xid_hi  and is_dhcp_xid_lo;

  ---- Read cksum
  fold_rcksum <= ('0' & s.rcksum(15 downto 0)) + s.rcksum(16);
  accum_rcksum <=
    fold_rcksum when (s.accum_cksum = '1') else
    s.psdcksum  when (s.pseudo_cksum = '1') else
    (accum_rcksum'range => '0');

  w_accum_cksum <= w when (a.ignore_rcksum = '0') else (w'range => '0');

  tmp_rcksum <= accum_rcksum + w_accum_cksum;

  ---- Write cksum
  fold_wcksum <= ('0' & s.wcksum(15 downto 0)) + s.wcksum(16);
  accum_wcksum <=
    fold_wcksum    when (dly_s_accum_cksum = '1') else
    dly_s_psdcksum when (dly_s_pseudo_cksum = '1') else
    (accum_wcksum'range => '0');

  -- Avoid a.wdata, which is a complicated device.
  -- Instead take latched value.
  -- Means we are one cycle later, so clearing also moved a cycle later.
  wdata_accum_cksum <=
    actual_wdata when (s.ignore_wcksum = '0') else (w'range => '0');

  tmp_wcksum <= accum_wcksum + wdata_accum_cksum;

  ---- Pseudo cksum
  -- TODO: a.wdata_psd is a somewhat complicated device, then in adder.
  tmp_psdcksum <=
    ('0' & s.psdcksum(15 downto 0)) + s.psdcksum(16) + a.wdata_psd;
  ----

  process (clk)
  begin
    if (rising_edge(clk)) then
      --rcksum_good <= '1' when (s.rcksum = "1111111111111111") else '0';
      if (got_word_prev = '1') then
        -- When good, the checksum is 0xffff.  That is what we want to
        -- find.
        --
        -- We however lack one cycle of addition to include the
        -- overflow bit (0x10000) into the checksum, and instead
        -- resort to accept the two cases that can lead to an accepted
        -- checksum, namely 0x0ffff or 0x1fffe.  No other value with
        -- the overflow bit set gives 0xffff after adding.
        if (s.rcksum = "01111111111111111" or
            s.rcksum = "11111111111111110") then
          rcksum_good <= '1';
        else
          rcksum_good <= '0';
        end if;
      end if;
    end if;
  end process;

  is_good_crc32 <= '1' when (crc32 = x"c704dd7b") else '0';

  reg_seq_no_plus_1 <= s.reg(s.reg_ch).seq_no + 1;

  x_is_req_seq_arm_reset_no <=
    '1' when (word_prev1(7 downto 0) = s.reg(s.reg_ch).seq_arm_reset_no) else
    '0';
  x_is_reg_seq_no <=
    '1' when (word_prev1(7 downto 0) = s.reg(s.reg_ch).seq_no) else '0';
  x_is_reg_seq_no_plus_1 <=
    '1' when (word_prev1(7 downto 0) = reg_seq_no_plus_1) else '0';

  reg_ch_other_ip_port <= s.reg(s.reg_ch).other_ip_port;

  x_is_reg_ch_other_ip_port <=
    '1' when (reg_ch_other_ip_port.ip01 = s.cur_other_ip_port.ip01 and
              reg_ch_other_ip_port.ip23 = s.cur_other_ip_port.ip23 and
              reg_ch_other_ip_port.portno = s.cur_other_ip_port.portno) else
    '0';

  x_is_tcp_other_ip_port <=
    '1' when (s.tcp_other_ip_port.ip01 = s.cur_other_ip_port.ip01 and
              s.tcp_other_ip_port.ip23 = s.cur_other_ip_port.ip23 and
              s.tcp_other_ip_port.portno = s.cur_other_ip_port.portno) else
    '0';

  x_is_w_ge_tcp_stat_base_seqno_lo <=
    '1' when (word_prev1 >= tcp_stat.base_seqno(15 downto 0)) else '0';
  x_is_tcp_stat_max_sent16_eq_base_seqno16 <=
    '1' when (tcp_stat.max_sent(16) = tcp_stat.base_seqno(16)) else '0';
  x_is_w_le_tcp_stat_max_sent_lo <=
    '1' when (word_prev1 <= tcp_stat.max_sent(15 downto 0)) else '0';

  x_is_ntp_ver_3or4_mode_3or4 <=
    '1' when ((word_prev1(13 downto 11) = "011" or
               word_prev1(13 downto 11) = "100") and
              (word_prev1(10 downto 8) = "011" or
               word_prev1(10 downto 8) = "100")) else '0';
  x_is_ntp_mode_4 <=
    '1' when (word_prev1(10 downto 8) = "100") else '0';

  x_is_dyn_offer_ip01 <=
    '1' when (word_prev1 = dyn_ctrl_stat.dhcp_offer_ip(31 downto 16)) else '0';
  x_is_dyn_offer_ip23 <=
    '1' when (word_prev1 = dyn_ctrl_stat.dhcp_offer_ip(15 downto  0)) else '0';

  process (s,s.reg,w,
           ram_stat_arp_icmp,ram_stat_udp_regacc,
           ram_stat_udp_regidp,ram_stat_udp_regres,
           tcp_stat, tcp_astat,
           ntp_stat,
           cfg_gen_rarp,
           cfg_gen_bootp,
           cfg_gen_dhcp,
           is_our_mac01, is_our_mac23, is_our_mac45,
           is_dyn_offer_ip01, is_dyn_offer_ip23,
           x_is_our_a_ip,
           x_is_our_b_ip,
           x_is_bootp_xid, x_is_dhcp_xid,
           is_icmp, is_tcp, is_udp,
           w_minus_6,
           w_minus_0x0100,
           is_w_0000, is_w_0001, is_w_0004, is_w_0201, is_w_0604, is_w_0800,
           is_w_0806, is_w_4000, is_w_5363, is_w_6382, is_w_8035,
           is_whi_00, is_whi_02, is_whi_05, is_whi_06, is_whi_45, is_whi_ff,
           is_wlo_00, is_wlo_02, is_wlo_05, is_wlo_ff,
           is_prev_wlo_02, is_prev_wlo_05,
           is_udp_ra_reset_arm, is_udp_ra_reset, is_udp_ra_disconnect,
           is_tcp_seq_hi, is_tcp_seq_lo, tcp_seq_hi, tcp_seq_lo,
           is_req_seq_arm_reset_no,is_reg_seq_no_plus_1, is_reg_seq_no,
           is_ntp_ver_3or4_mode_3or4, is_ntp_mode_4,
           ntp_tx_future_ts, ntp_pkt_start_ts,
           rcksum_good,
           fold_wcksum,
           tcp_buf_stat,
           is_good_crc32,
           is_reg_ch_other_ip_port,
           is_tcp_other_ip_port,
           is_tcp_dest_port,
           is_w_ge_tcp_stat_base_seqno_lo,
           is_tcp_stat_max_sent16_eq_base_seqno16,
           is_w_le_tcp_stat_max_sent_lo,
           dhcp_option_remain_is_0, dhcp_option_remain_is_1)
  begin

    a <= (next_state => ISM_BAD_PACKET,
          wdata => w,
          wdata_psd => (others => '0'),
          woff => (others => '0'),
          ipv4_remain => s.ipv4_remain_m2,
          minsz_remain => s.minsz_remain_m2,
          is_our_mac => s.is_our_mac,
          is_our_ip => s.is_our_ip,
          is_icmp => s.is_icmp,
          is_tcp => s.is_tcp,
          is_udp => s.is_udp,
          is_bootp => s.is_bootp,
          is_dhcp => s.is_dhcp,
          is_dhcp_offer => s.is_dhcp_offer,
          is_dhcp_ack => s.is_dhcp_ack,
          is_ntp => s.is_ntp,
          is_ntp_resp => s.is_ntp_resp,
          is_tcp_syn => s.is_tcp_syn,
          is_tcp_ack => s.is_tcp_ack,
          ignore_rcksum => '0',
          is_rarp_resp => s.is_rarp_resp,
          dhcp_has_new_option => '0',
          dhcp_new_option => (others => '0'),
          dhcp_new_option_length_next => '0',
          dhcp_option_remain => (others => '0'),
          ignore_wcksum => '0',
          next_accum_cksum => '1',
          next_pseudo_cksum => '0',
          wicmpcksum => '0',
          wudpcksum => '0',
          keepipcksum => '0',
          cksum_0 => s.cksum_0,
          fill_ram_arp_icmp => s.fill_ram_arp_icmp,
          fill_ram_udp_regacc => s.fill_ram_udp_regacc,
          fill_ram_tcp_template => s.fill_ram_tcp_template,
          good_arp => '0',
          any_arp => '0',
          good_rarp => '0',
          good_icmp => '0',
          good_bootp => '0',
          good_dhcp_offer => '0',
          good_dhcp_ack => '0',
          good_udp_regacc => '0',
          good_tcp_packet => '0',
          good_ntp => '0',
          store_tcp_seq_hi => '0',
          store_tcp_seq_lo => '0',
          carry_tcp_seq_hi => '0',
          cur_other_ip_port => s.cur_other_ip_port,
          dyn_offer_ip_port => s.dyn_offer_ip_port,
          reg_idp => s.reg_idp,
          reg_ch => s.reg_ch,
          do_reg_seq_failure => s.do_reg_seq_failure,
          do_reg_seq_reset_arm => s.do_reg_seq_reset_arm,
          do_reg_seq_reset => s.do_reg_seq_reset,
          do_reg_disconnect => s.do_reg_disconnect,
          do_reg_access => s.do_reg_access,
          do_reg_access_idp => s.do_reg_access_idp,
          repeat_reg_response => s.repeat_reg_response,
          set_regacc_end_words => '0',
          set_regacc_wcksum => '0',
          latch_tcp_ack_hi => '0',
          latch_tcp_ack_lo => '0',
          latch_tcp_window => '0',
          latch_ntp_ts => '0',
          latch_ntp_tx_ts => '0',
          calc_ntp_tx_dly => '0',
          latch_ntp_tx_ref_dly => '0',
          latch_ntp_data => (others => '0')
          );

    a.dhcp_option_remain <= s.dhcp_option_remain - 2;

    cnts <= iic_zero;

    case s.state is

        -------------------------------------------------------------
        --
        -- Ethernet
        --
        -------------------------------------------------------------

      when ISM_LL_0 =>
        a.next_state <= ISM_LL_2;
        a.is_our_mac <= is_our_mac01;
        a.woff <= std_logic_vector(to_unsigned(6,11));
        a.wdata <= s.our_mac01;
        -- TODO: correct?  Perform tests around min packet length.
        a.minsz_remain <= std_logic_vector(to_unsigned(64-4-4,11));
        a.fill_ram_arp_icmp <= not ram_stat_arp_icmp.hasdata;
        a.fill_ram_udp_regacc <= not ram_stat_udp_regacc.hasdata;
        a.fill_ram_tcp_template <= '0';
        if (tcp_stat.conn_state = CLOSED) then
          -- s.fill_ram_tcp_template is used in other states to check if
          -- we are in closed state, trying to set up a new connection.
          a.fill_ram_tcp_template <= '1';
        end if;
        a.is_rarp_resp <= '0';
        a.do_reg_seq_failure <= '0';
        a.do_reg_seq_reset_arm <= '0';
        a.do_reg_seq_reset <= '0';
        a.do_reg_disconnect <= '0';
        a.do_reg_access <= '0';
        a.do_reg_access_idp <= '0';
        a.repeat_reg_response <= '0';
        a.latch_ntp_ts <= '1';
        cnts.start_packet <= '1';
      when ISM_LL_2 =>
        a.next_state <= ISM_LL_4;
        a.is_our_mac <= s.is_our_mac and is_our_mac23;
        a.woff <= std_logic_vector(to_unsigned(6,11));
        a.wdata <= s.our_mac23;
      when ISM_LL_4 =>
        a.next_state <= ISM_LL_6;
        a.is_our_mac <= s.is_our_mac and is_our_mac45;
        a.woff <= std_logic_vector(to_unsigned(6,11));
        a.wdata <= s.our_mac45;
      when ISM_LL_6 =>
        -- Source MAC must not have the 'group' bit set.
        -- This also prevents us from responding with broadcast MAC
        -- as destination.
        if (w(8) = '0') then
          a.next_state <= ISM_LL_8;
        end if;
        a.woff <= std_logic_vector(to_unsigned(2048-6,11));
        cnts.mac_for_us <= s.is_our_mac;
      when ISM_LL_8 =>
        a.next_state <= ISM_LL_10;
        a.woff <= std_logic_vector(to_unsigned(2048-6,11));
      when ISM_LL_10 =>
        a.next_state <= ISM_LL_12;
        a.woff <= std_logic_vector(to_unsigned(2048-6,11));
        a.latch_ntp_tx_ref_dly <= '1';
      when ISM_LL_12 =>
        if (is_w_0806 = '1' or    -- ARP
            is_w_8035 = '1') then -- RARP
          a.next_state <= ISM_ARP_14;
          cnts.start_arp <= '1';
        elsif (is_w_0800 = '1') then
          a.next_state <= ISM_IPV4_14;
          cnts.start_ipv4 <= '1';
        end if;
        a.next_accum_cksum <= '0';

        -------------------------------------------------------------
        --
        -- ARP
        --
        -------------------------------------------------------------

      when ISM_ARP_14 =>
        if (is_w_0001 = '1') then  -- Hardware type: ethernet (1).
          a.next_state <= ISM_ARP_16;
        end if;
      when ISM_ARP_16 =>
        if (is_w_0800 = '1') then  -- Protocol type: IPv4 (0x0800).
          a.next_state <= ISM_ARP_18;
        end if;
      when ISM_ARP_18 =>
        if (is_w_0604 = '1') then  -- Hardware size: 6, protocol size: 4.
          a.next_state <= ISM_ARP_20;
        end if;
      when ISM_ARP_20 =>
        if (is_w_0001 = '1') then  -- 1 = ARP request.
          a.next_state <= ISM_ARP_22;
          -- Make ARP response.
          a.wdata <= std_logic_vector(to_unsigned(16#0002#,16));
        end if;
        if (is_w_0004 = '1' and    -- 4 = RARP response.
            cfg_gen_rarp = '1') then -- Can make RARPs, so handle response.
          a.next_state <= ISM_ARP_22;
          a.is_rarp_resp <= '1';
        end if;

      -- This and following five states are too few to be better by counter.
      -- RARP reception will not generate packet, so writes do not matter.
      -- Sender MAC:
      when ISM_ARP_22 =>
        a.next_state <= ISM_ARP_24;
        a.woff <= std_logic_vector(to_unsigned(10,11));
      when ISM_ARP_24 =>
        a.next_state <= ISM_ARP_26;
        a.woff <= std_logic_vector(to_unsigned(10,11));
      when ISM_ARP_26 =>
        a.next_state <= ISM_ARP_28;
        a.woff <= std_logic_vector(to_unsigned(10,11));

      -- Sender IP:
      when ISM_ARP_28 =>
        a.next_state <= ISM_ARP_30;
        a.woff <= std_logic_vector(to_unsigned(10,11));
      when ISM_ARP_30 =>
        a.next_state <= ISM_ARP_32;
        a.woff <= std_logic_vector(to_unsigned(10,11));

      -- Common for both incoming ARP (request),
      -- and incoming RARP (response).
      -- Target MAC:
      when ISM_ARP_32 =>
        a.next_state <= ISM_ARP_34;
        a.is_our_mac <= is_our_mac01; -- For RARP reception.
        a.woff <= std_logic_vector(to_unsigned(2048-10,11));
        a.wdata <= s.our_mac01;
      when ISM_ARP_34 =>
        a.next_state <= ISM_ARP_36;
        a.is_our_mac <= s.is_our_mac and is_our_mac23;
        a.woff <= std_logic_vector(to_unsigned(2048-10,11));
        a.wdata <= s.our_mac23;
      when ISM_ARP_36 =>
        a.next_state <= ISM_ARP_38;
        a.is_our_mac <= s.is_our_mac and is_our_mac45;
        a.woff <= std_logic_vector(to_unsigned(2048-10,11));
        a.wdata <= s.our_mac45;
        if (s.is_rarp_resp = '1') then
          a.next_state <= ISM_RARP_38;
        end if;

      -- Note how a.is_our_mac is completely reset here for ARP request!
      -- Also, it is actually (as an exception) actually checking the IP
      -- address, and not the MAC!
      -- Target IP:
      when ISM_ARP_38 => -- IP (high (01))
        a.next_state <= ISM_ARP_40;
        a.woff <= std_logic_vector(to_unsigned(2048-10,11));
      when ISM_ARP_40 => -- IP (low (23))
        a.next_state <= ISM_ARP_42_60;
        a.is_our_mac <= x_is_our_a_ip or
                        x_is_our_b_ip;
        cnts.arp_our_ip <= x_is_our_a_ip or
                           x_is_our_b_ip;
        a.woff <= std_logic_vector(to_unsigned(2048-10,11));
        -- Abuse as counter.  The following state is performed 2*10 times.
        -- Saves some LUTs compared to explicit states.
        a.ipv4_remain <= std_logic_vector(to_unsigned(20-2,11));

      when ISM_RARP_38 =>
        a.next_state <= ISM_RARP_40;
        a.dyn_offer_ip_port.ip01 <= w; -- For RARP reception.
      when ISM_RARP_40 =>
        a.next_state <= ISM_ARP_42_60;
        a.dyn_offer_ip_port.ip23 <= w; -- For RARP reception.
        -- Abuse as counter.  The following state is performed 2*10 times.
        -- Saves some LUTs compared to explicit states.
        a.ipv4_remain <= std_logic_vector(to_unsigned(20-2,11));

      -- Checksum.
      when ISM_ARP_42_60 =>
        if (s.ipv4_remain_is_0 = '0') then
          a.next_state <= ISM_ARP_42_60;
        else
          a.next_state <= ISM_ARP_62;
        end if;
        -- For ISM_ARP_60, the following not used, as we will not use,
        -- packet length is smaller.
        a.wdata <= std_logic_vector(to_unsigned(16#0000#,16));
      when ISM_ARP_62 =>
        if (is_good_crc32 = '1') then
          a.next_state <= ISM_GOOD_PACKET;
          if (s.is_rarp_resp = '0') then
            a.good_arp <= s.is_our_mac;
            cnts.good_arp <= s.is_our_mac;
            a.any_arp <= '1';
          else
            a.good_rarp <= s.is_our_mac;
            cnts.good_rarp <= s.is_our_mac;
          end if;
        end if;
        cnts.bad_crc <= not is_good_crc32;

        -------------------------------------------------------------
        --
        -- IPv4
        --
        -------------------------------------------------------------

      when ISM_IPV4_14 => -- Version | IHL | DSCP | ECN
        -- Ignore the DSCP | ECN fields.
        -- (DSCP bit was set in a BOOTP response).
        if (is_whi_45 = '1') then -- Version = 4: IPv4,
                                  -- IHL = 5: 5x32 bits header
          a.next_state <= ISM_IPV4_16;
        end if;
        -- Respond with 0 in DSCP | ECN.
        a.wdata(7 downto 0) <= "00000000";
      when ISM_IPV4_16 => -- Total length
        -- Only accept lengths multiple of 2.
        if (w(0 downto 0) = "0" and
            w >= std_logic_vector(to_unsigned(20,16))  and
            w <= std_logic_vector(to_unsigned(2*(RAM_BLOCK_WORDS
                                                 - 7  - 2),16)) ) then
          a.next_state <= ISM_IPV4_18;
        end if;
        a.ipv4_remain <= w_minus_6(a.ipv4_remain'range);
        a.wdata_psd <= w;-- - 16#0014#; -- Subtract IP header length

      when ISM_IPV4_18 => -- Identification (sequence no.)
        a.next_state <= ISM_IPV4_20;
        -- The high identification octet is echoed.  The low octet
        -- gets a packet count.  That way, it can be seen if packet
        -- duplication happened on the way to or from us.
        a.wdata(7 downto 0) <= s.packet_start_count;

      when ISM_IPV4_20 => -- Flags | fragment offset
        -- Flag: do not fragments bit ok, fragments not
        if (is_w_4000 = '1' or is_w_0000 = '1') then
          a.next_state <= ISM_IPV4_22;
        end if;

      when ISM_IPV4_22 => -- TTL | Protocol
        if (is_whi_00 = '0') then -- TTL 0 not accepted
          a.next_state <= ISM_IPV4_24;
        end if;
        -- TODO: check that remaining number of bytes can take at least
        -- full header of respective format.
        -- Or easier perhaps: a generic abort if packet runs out of length
        -- before reaching the end.  E.g. setting a flag that from this
        -- on, ip4v_remain rules.
        a.is_icmp <= is_icmp;
        a.is_tcp <= is_tcp;
        a.is_udp <= is_udp;
        a.wdata <= w_minus_0x0100;
        a.wdata_psd <= "00000000" & w(7 downto 0); -- TODO: into restart value

      when ISM_IPV4_24 => -- Checksum
        a.next_state <= ISM_IPV4_26;
        a.ignore_wcksum <= '1';

      when ISM_IPV4_26 => -- Source IP (high)
        a.next_state <= ISM_IPV4_28;
        a.woff <= std_logic_vector(to_unsigned(4,11));
        a.wdata_psd <= w;
        a.cur_other_ip_port.ip01 <= w;
      when ISM_IPV4_28 => -- Source IP (low)
        a.next_state <= ISM_IPV4_30;
        a.woff <= std_logic_vector(to_unsigned(4,11));
        a.wdata_psd <= w;
        a.cur_other_ip_port.ip23 <= w;
      when ISM_IPV4_30 => -- Destination IP (high)
        a.next_state <= ISM_IPV4_32;
        a.woff <= std_logic_vector(to_unsigned(2048-4,11));
        a.wdata_psd <= w;
      when ISM_IPV4_32 => -- Destination IP (low)
        a.is_our_ip <= '0';
        cnts.ip_hdr_ok <= '1';
        cnts.ip_a_for_us <= x_is_our_a_ip;
        cnts.ip_b_for_us <= x_is_our_b_ip;
        if (x_is_our_a_ip = '1' or
            x_is_our_b_ip = '1') then
          if (s.is_icmp = '1') then
            a.next_state <= ISM_ICMP_34;
            cnts.start_icmp <= '1';
          end if;
          if (s.is_tcp = '1') then
            a.next_state <= ISM_TCP_34;
            a.next_pseudo_cksum <= '1';
            cnts.start_tcp <= '1';
          end if;
          a.is_our_ip <= '1';
        end if;
        -- Since UDP may be BOOTP, we cannot check the IP number here,
        -- must be deferred until selecting protocol.
        if (s.is_udp = '1') then
          a.next_state <= ISM_UDP_34;
          a.next_pseudo_cksum <= '1';
          cnts.start_udp <= '1';
        end if;
        a.woff <= std_logic_vector(to_unsigned(2048-4,11));
        a.next_accum_cksum <= '0';
        a.wdata_psd <= w;

        -------------------------------------------------------------
        --
        -- ICMP
        --
        -------------------------------------------------------------

      when ISM_ICMP_34 => -- Type | code
        -- Type = 8: request
        if (is_w_0800 = '1') then
          a.next_state <= ISM_ICMP_36;
        end if;
        -- Type = 0: reply
        a.wdata <= std_logic_vector(to_unsigned(16#0000#,16));

        -- This needs to be a cycle later (and then the write
        -- (use of s.wcksum_ip) would need to move further down
        -- as well)
        -- Get the IP checksum
        -- a.keepipcksum <= '1';

      when ISM_ICMP_36 => --  Checksum
        if (rcksum_good = '1') then -- Check the IP checksum
          a.next_state <= ISM_ICMP_DATA1;
        end if;
        cnts.bad_cksum <= not rcksum_good;

        -- We are writing the IP checksum!
        -- a.wdata <= s.wcksum_ip;
        a.wdata <= not fold_wcksum(15 downto 0);
        -- TODO: this depends on having no IP options?
        a.woff <= std_logic_vector(to_unsigned(2048-12,11));
        -- So ignoring the value
        a.ignore_wcksum <= '1';

      when ISM_ICMP_DATA1 =>
        if (s.ipv4_remain_is_0 = '0') then
	  if (s.minsz_remain /= std_logic_vector(to_unsigned(0,11))) then
	    a.next_state <= ISM_ICMP_DATA1;
	  else
	    a.next_state <= ISM_ICMP_DATA2;
	  end if;
	else
          -- TODO: Needs to move in case of garbage in the pad field?
	  -- a.next_accum_cksum <= '0';
	  if (s.minsz_remain /= std_logic_vector(to_unsigned(0,11))) then
	    a.next_state <= ISM_ICMP_PAD;
	  else
	    a.next_state <= ISM_ICMP_CK1;
	  end if;
	end if;

      when ISM_ICMP_DATA2 =>
        if (s.ipv4_remain_is_0 = '0') then
	  a.next_state <= ISM_ICMP_DATA2;
	else
	  a.next_state <= ISM_ICMP_CK1;
	end if;

      when ISM_ICMP_PAD =>
        a.ignore_rcksum <= '1';
        if (s.minsz_remain /= std_logic_vector(to_unsigned(0,11))) then
          a.next_state <= ISM_ICMP_PAD;
        else
          a.next_state <= ISM_ICMP_CK1;
        end if;

      when ISM_ICMP_CK1 =>
        a.next_state <= ISM_ICMP_CK2;

      when ISM_ICMP_CK2 =>
        if (rcksum_good = '1' and
            is_good_crc32 = '1') then
	  a.next_state <= ISM_GOOD_PACKET;
	  a.good_icmp <= '1';
          cnts.good_icmp <= '1';
	end if;
        cnts.bad_cksum <= not rcksum_good;
        cnts.bad_crc   <= not is_good_crc32;

        a.wdata <= not fold_wcksum(15 downto 0); -- s.s.wcksum16;
        a.wicmpcksum <= '1';

        -------------------------------------------------------------
        --
        -- UDP
        --
        -------------------------------------------------------------

      when ISM_UDP_34 => -- Source port
        a.next_state <= ISM_UDP_36;
        a.woff <= std_logic_vector(to_unsigned(2,11));
        a.cur_other_ip_port.portno <= w;

      when ISM_UDP_36 => -- Destination port
        a.is_bootp <= '0';
        a.is_dhcp_offer <= '0';
        a.is_dhcp_ack <= '0';
        a.is_ntp <= '0';
        if (rcksum_good = '1') then -- Check the IP checksum
          -- IP match check here, since not applicable to BOOTP.
          if (s.is_our_ip = '1') then
            if (w(15 downto 4) = 16#001# and -- Port 16..31
                w(3 downto 0) < NUM_REG_CH) then
              a.next_state <= ISM_UDP_38;
              a.reg_idp <= '0';
              a.reg_ch <= conv_integer( w(3 downto 0) );
            end if;
            if (w(15 downto 0) = 16#000f#) then -- Port 15
              a.next_state <= ISM_UDP_38;
              a.reg_idp <= '1';
            end if;
            if (w(15 downto 0) = 16#007b#) then -- Port 123 (NTP)
              a.next_state <= ISM_UDP_38;
              a.is_ntp <= '1';
              cnts.start_ntp <= '1';
            end if;
          end if;
          -- BOOTP gets an IP, so cannot not check it (unknown).
          if (w(15 downto 0) = 16#0044# and -- Port 68 (BOOTP)
              (cfg_gen_bootp = '1' or
               cfg_gen_dhcp = '1')) then -- Can make BOOTP,
                                         -- so handle responses.
            a.next_state <= ISM_UDP_38;
            a.is_bootp <= '1';
            cnts.start_bootp <= '1';
          end if;
        end if;
        cnts.bad_cksum <= not rcksum_good;

        a.woff <= std_logic_vector(to_unsigned(2048-2,11));

        -- Get the IP checksum
        a.keepipcksum <= '1';

      when ISM_UDP_38 => -- Length
        if (w = s.ipv4_remain_p6) then
          a.next_state <= ISM_UDP_40;
        end if;

      when ISM_UDP_40 => -- Checksum
        if (--a.ipv4_remain >= std_logic_vector(to_unsigned(4-2,11))) then
            s.ipv4_remain_m8_ge_0 = '1') then -- FIXME: always one (unsigned compare)
          a.next_state <= ISM_UDP_STAT_42;
        end if;
        if (s.is_bootp = '1') then
          a.next_state <= ISM_BOOTP_42;
        end if;
        if (s.is_ntp = '1') then
          a.next_state <= ISM_NTP_42;
        end if;

        -- Remember if the checksum field was 0 = unused.
        a.cksum_0 <= is_w_0000;
        -- We are writing the IP checksum!
        a.wdata <= s.wcksum_ip;
        -- TODO: this depends on having no IP options?
        a.woff <= std_logic_vector(to_unsigned(2048-16,11));
        -- So ignoring the value
        a.ignore_wcksum <= '1';

      when ISM_UDP_STAT_42 => -- First status word
        if (is_w_0000 = '1') then
          a.next_state <= ISM_UDP_STAT_44;
	end if;
        stat_connected: for i in 0 to NUM_REG_CH-1 loop
          a.wdata(i) <= s.reg(i).seq_connected;
        end loop;
        stat_active: for i in 0 to NUM_REG_CH-1 loop
          if (s.reg(i).seq_active_marks /=
              (s.reg(i).seq_active_marks'range => '0')) then
            a.wdata(8+i) <= '1';
          else
            a.wdata(8+i) <= '0';
          end if;
        end loop;
        a.wdata( 7 downto   NUM_REG_CH) <=
          std_logic_vector(to_unsigned(0,8-NUM_REG_CH));
        a.wdata(15 downto 8+NUM_REG_CH) <=
          std_logic_vector(to_unsigned(0,8-NUM_REG_CH));

      when ISM_UDP_STAT_44 => -- Second status word
        if (is_w_0000 = '1') then
          a.next_state <= ISM_UDP_RA_46;
	end if;

        case tcp_stat.conn_state is
          when CLOSED       => a.wdata(2 downto 0) <= "001";
          when SYN_RECEIVED => a.wdata(2 downto 0) <= "010";
          when SYN_SENT     => a.wdata(2 downto 0) <= "010";
          when CONNECTED    => a.wdata(2 downto 0) <= "011";
        end case;
        a.wdata(3) <= '0';
        a.wdata(4) <= tcp_buf_stat.commit_overrun;
        a.wdata(5) <= tcp_buf_stat.write_overrun;
        a.wdata(6) <= '0'; -- TCP_RAM_BITFLIP
        a.wdata(7) <= '0'; -- ANY_RAM_BITFLIP
        a.wdata(15 downto 8) <= "00000000";

      when ISM_UDP_RA_46 =>
        -- If we do not like the request, we will simply go to
        -- the bad packet state, as usual.
        if (s.reg_idp = '0') then
        if (is_udp_ra_reset_arm = '1' and
            s.ipv4_remain_m2_is_0 = '1') then
          -- Request to arm the reset
	  a.next_state <= ISM_UDP_RA_48;
          if (s.reg(s.reg_ch).seq_active_marks =
              (s.reg(s.reg_ch).seq_active_marks'range => '0')) then
            a.do_reg_seq_reset_arm <= '1';
            a.wdata <=
              "100" & s.reg(s.reg_ch).seq_connected &
              w(11 downto 8) & (s.reg(s.reg_ch).seq_arm_reset_no + 1);
            cnts.udp_arm <= '1';
          else
            -- Report the failure
            a.do_reg_seq_failure <= '1';
            -- This channel is active, not allowing reset (arm) yet.
            a.wdata <=
              "100" & s.reg(s.reg_ch).seq_connected &
              not w(11 downto 8) & (7 downto 0 => '0');
            cnts.udp_badactivearm <= '1';
          end if;
        elsif (is_udp_ra_reset = '1' and
               s.ipv4_remain_m2_is_0 = '1') then
          -- Request to reset (if armed).
          -- Request is valid, so respond to that.
          a.next_state <= ISM_UDP_RA_48;
          -- Are we armed?
          if (s.reg(s.reg_ch).seq_reset_armed = '1' and
              is_req_seq_arm_reset_no = '1') then
            -- Do the reset
            a.do_reg_seq_reset <= '1';
            -- The value given is written to the response field.
            cnts.udp_reset <= '1';
          else
            -- Report the failure
            a.do_reg_seq_failure <= '1';
             -- We are not armed, or armed with the wrong number.
            a.wdata <= std_logic_vector(to_unsigned(16#4400#,16));
            a.wdata(1 downto 0) <= not w(1 downto 0);
            cnts.udp_badreset <= '1';
          end if;
        elsif (is_udp_ra_disconnect = '1' and
               s.ipv4_remain_m2_is_0 = '1') then
          -- Request to disconnect (if connected).
          -- Request is valid, so respond to that.
          a.next_state <= ISM_UDP_RA_48;
          if (s.reg(s.reg_ch).seq_connected = '1' and
              is_reg_ch_other_ip_port = '1') then
            -- Do the reset
            a.do_reg_disconnect <= '1';
            -- The value given is written to the response field.
            cnts.udp_disconnect <= '1';
          else
            -- Report the failure
            a.do_reg_seq_failure <= '1';
            -- We are not connected, or connected to someone else.
            a.wdata <= std_logic_vector(to_unsigned(16#2200#,16));
            cnts.udp_baddisconnect <= '1';
          end if;
        elsif (is_udp_ra_reset_arm = '0' and
               is_udp_ra_reset = '0' and
               is_udp_ra_disconnect = '0') then
          cnts.udp_regaccess <= '1';
          if (s.reg(s.reg_ch).seq_connected = '1' and
              is_reg_ch_other_ip_port = '1') then
            cnts.udp_ra_is_otherip <= '1';
            -- We can only perform a new access if the register
            -- access system can write the data somewhere.
            if (ram_stat_udp_regres(s.reg_ch).hasdata = '0') then
              if (is_reg_seq_no_plus_1 = '1') then
                a.next_state <= ISM_UDP_RA_48;
                a.do_reg_access <= '1';
                cnts.udp_ra_seqplus1 <= '1';
              elsif (is_reg_seq_no = '1' and
                     s.reg(s.reg_ch).seq_did_access = '1') then
                a.next_state <= ISM_UDP_RA_48;
                if (ram_stat_udp_regres(s.reg_ch).hasdata = '0') then
                  -- This will retransmit old response.
                  a.repeat_reg_response <= s.fill_ram_udp_regacc;
                end if;
                cnts.udp_ra_repeat <= '1';
              end if;
            else
              cnts.udp_ra_busy <= '1';
            end if;
          end if;
          a.wdata <= w;
        end if;
        end if;
        -- reg_idp is the multi-client, non-sequence, unreliable port
        if (s.reg_idp = '1') then
          if (is_udp_ra_reset_arm = '0' and
              is_udp_ra_reset = '0' and
              is_udp_ra_disconnect = '0') then
            cnts.udp_regaccess_idp <= '1';
            -- We can only perform a new access if the register
            -- access system can write the data somewhere.
            if (ram_stat_udp_regidp.hasdata = '0') then
              a.next_state <= ISM_UDP_RA_48;
              a.do_reg_access_idp <= '1';
            else
              cnts.udp_ra_idp_busy <= '1';
            end if;
          end if;
        end if;
          -- Write answer in the response field.
        a.woff <= std_logic_vector(to_unsigned(2,11));

      when ISM_UDP_RA_48 =>
        -- Response field is to be all zeros
        -- We are to be followed by a multiple of 2x32 bits,
        -- i.e. n*8 bytes left
        if (is_w_0000 = '1' and
            s.ipv4_remain(2 downto 0) = "000") then
	  if (s.ipv4_remain_is_0 = '0') then
	    a.next_state <= ISM_UDP_RA_DATA1;
	  else
	    a.next_state <= ISM_UDP_RA_PAD;
	  end if;
	end if;
        -- Write the zero into the request field.
        a.woff <= std_logic_vector(to_unsigned(2048-2,11));
        a.set_regacc_end_words <= '1';
        a.set_regacc_wcksum <= '1';

      when ISM_UDP_RA_DATA1 =>
        if (s.ipv4_remain_is_0 = '0') then
	  if (s.minsz_remain /= std_logic_vector(to_unsigned(0,11))) then
	    a.next_state <= ISM_UDP_RA_DATA1;
	  else
	    a.next_state <= ISM_UDP_RA_DATA2;
	  end if;
        else
	  -- a.next_accum_cksum <= '0';  -- TODO needed for crappy pad?
	  if (s.minsz_remain /= std_logic_vector(to_unsigned(0,11))) then
	    a.next_state <= ISM_UDP_RA_PAD;
	  else
	    a.next_state <= ISM_UDP_RA_CK1;
	  end if;
	end if;
        a.set_regacc_end_words <= '1';

      when ISM_UDP_RA_DATA2 =>
        if (s.ipv4_remain_is_0 = '0') then
          a.next_state <= ISM_UDP_RA_DATA2;
        else
	  -- a.next_accum_cksum <= '0';  -- TODO needed for crappy pad?
	  a.next_state <= ISM_UDP_RA_CK1;
	end if;
        a.set_regacc_end_words <= '1';

      when ISM_UDP_RA_PAD =>
        a.ignore_rcksum <= '1';
        if (s.minsz_remain /= std_logic_vector(to_unsigned(0,11))) then
          a.next_state <= ISM_UDP_RA_PAD;
        else
          a.next_state <= ISM_UDP_RA_CK1;
        end if;

      when ISM_UDP_RA_CK1 =>
        a.next_state <= ISM_UDP_RA_CK2;

      when ISM_UDP_RA_CK2 =>
        if (rcksum_good = '1' and
            is_good_crc32 = '1') then
          a.next_state <= ISM_GOOD_PACKET;
          a.good_udp_regacc <= '1';
          cnts.good_udp <= '1';
        end if;
        cnts.bad_cksum <= not rcksum_good;
        cnts.bad_crc   <= not is_good_crc32;

        a.wdata <= not fold_wcksum(15 downto 0);
        a.wudpcksum <= '1';

        -------------------------------------------------------------
        --
        -- BOOTP
        --
        -------------------------------------------------------------

        -- Handle incoming BOOTP replies.
        -- We do not respond to these packets.

      when ISM_BOOTP_42 => -- Opcode: 2 | hardware type: ethernet (1).
        if (is_w_0201 = '1') then
          a.next_state <= ISM_BOOTP_44;
        end if;
      when ISM_BOOTP_44 => -- HW addr length: 6 | Hops.
        if (is_whi_06 = '1') then
          a.next_state <= ISM_BOOTP_46;
        end if;
      when ISM_BOOTP_46 => -- Transaction ID hi.
        a.next_state <= ISM_BOOTP_48;
      when ISM_BOOTP_48 => -- Transaction ID lo.
        a.is_bootp <= '0';
        a.is_dhcp <= '0';
        if (x_is_bootp_xid = '1' and
            cfg_gen_bootp = '1') then
          a.next_state <= ISM_BOOTP_50;
          a.is_bootp <= '1';
        end if;
        if (x_is_dhcp_xid = '1' and
            cfg_gen_dhcp = '1') then
          a.next_state <= ISM_BOOTP_50;
          a.is_dhcp <= '1';
        end if;

      when ISM_BOOTP_50 => -- Seconds.
        a.next_state <= ISM_BOOTP_52;
      when ISM_BOOTP_52 => -- Flags.
        a.next_state <= ISM_BOOTP_54;
      when ISM_BOOTP_54 => -- Client IP.
        a.next_state <= ISM_BOOTP_56;
      when ISM_BOOTP_56 => -- Client IP.
        a.next_state <= ISM_BOOTP_58;
      when ISM_BOOTP_58 => -- Our (given/offered) IP.
        a.next_state <= ISM_BOOTP_60;
        a.dyn_offer_ip_port.ip01 <= w; -- Latch IP.
        a.is_our_ip <= is_dyn_offer_ip01; -- Check for ack packet.
      when ISM_BOOTP_60 => -- Our (given/offered) IP.
        a.next_state <= ISM_BOOTP_62;
        a.dyn_offer_ip_port.ip23 <= w; -- Latch IP.
        a.is_our_ip <= s.is_our_ip and is_dyn_offer_ip23; -- For ack packet.
      when ISM_BOOTP_62 => -- Next server IP.
        a.next_state <= ISM_BOOTP_64;
      when ISM_BOOTP_64 => -- Next server IP.
        a.next_state <= ISM_BOOTP_66;
      when ISM_BOOTP_66 => -- Gateway (relay agent) IP.
        a.next_state <= ISM_BOOTP_68;
      when ISM_BOOTP_68 => -- Gateway (relay agent) IP.
        a.next_state <= ISM_BOOTP_70;
      when ISM_BOOTP_70 => -- Client HW address (check).
        a.next_state <= ISM_BOOTP_72;
        -- Note: BOOTP may be sent to broadcast MAC in ethernet
        -- header, so ignore previous s.is_our_mac and only check value
        -- here in payload.
        a.is_our_mac <= is_our_mac01;
      when ISM_BOOTP_72 => -- Client HW address (check).
        a.next_state <= ISM_BOOTP_74;
        a.is_our_mac <= s.is_our_mac and is_our_mac23;
      when ISM_BOOTP_74 => -- Client HW address (check).
        a.next_state <= ISM_BOOTP_76_340;
        a.is_our_mac <= s.is_our_mac and is_our_mac45;

        -- And then skip the remaining (HW addr padding 10) +
        -- (server name) 64, (boot filename) 128, (vendor options) 64 = 266.

      -- Checksum.
      when ISM_BOOTP_76_340 =>
        if (s.ipv4_remain_is_62 = '1' and
            is_w_6382 = '1') then -- 1st DHCP magic.
          a.next_state <= ISM_DHCP_276;
        elsif (s.ipv4_remain_is_0 = '0') then
          a.next_state <= ISM_BOOTP_76_340;
        else
          a.next_state <= ISM_BOOTP_CK1;
        end if;

      when ISM_BOOTP_CK1 =>
        a.next_state <= ISM_BOOTP_CK2;

      when ISM_BOOTP_CK2 =>
        if (rcksum_good = '1' and
            is_good_crc32 = '1') then
          a.next_state <= ISM_GOOD_PACKET;
          if (s.is_bootp = '1') then
            a.good_bootp <= s.is_our_mac;
            cnts.good_bootp <= s.is_our_mac;
          end if;
          if (s.is_dhcp_offer = '1') then
            a.good_dhcp_offer <= s.is_our_mac;
            cnts.good_dhcp_offer <= s.is_our_mac;
          end if;
          if (s.is_dhcp_ack = '1') then
            a.good_dhcp_ack <= s.is_our_mac and s.is_our_ip;
            cnts.good_dhcp_ack <= s.is_our_mac and s.is_our_ip;
          end if;
        end if;
        cnts.bad_crc <= not is_good_crc32;

        -------------------------------------------------------------
        --
        -- DHCP
        --
        -------------------------------------------------------------

        -- A bootp packet will be treated as DHCP if it contains the
        -- magic, and the DHCP option (53).  Otherwise, it will revert
        -- to BOOTP handling.

      when ISM_DHCP_276 =>
        if (is_w_5363 = '1') then -- 2nd DHCP magic.
          a.next_state <= ISM_DHCP_278;
        else
          a.next_state <= ISM_BOOTP_76_340;
        end if;
        -- Fake option which was fully contained in this word.
        a.dhcp_has_new_option       <= '1';
        a.dhcp_new_option           <= (others => '0');
        a.dhcp_option_remain        <= (others => '0');

        -- DHCP options.  This decoding is somewhat messy, in that
        -- options can make the processing unaligned.  So we have
        -- to try everything vs. both the first and second word.

      when ISM_DHCP_278 =>
        -- First needed thing is to keep track of where options start,
        -- such that only the actual option identifier octets are
        -- checked.

        -- DHCP option handling:
        --
        -- remain = 0 : hi = ff                      -> end
        --              hi = OPT                     -> new OPT + len
        --              hi = 0  : lo = 0             -> pad
        --                        lo = ff            -> end
        --                        lo = OPT           -> new OPT, len in next
        -- remain = 1           : lo = 0             -> pad
        --                      : lo = ff            -> end
        --                      : lo = OPT           -> new OPT, len in next

        -- By default, we continue to parse DHCP options.
        a.next_state <= ISM_DHCP_278;

        -- Option was started in previous word, length in this one.
        if (s.dhcp_option_length_hi = '1') then
          -- The case of the option length being 0 is handled below.
          a.dhcp_option_remain      <= w(15 downto 8) - 1;
        end if;

        -- New option, option in the hi word.
        if ((dhcp_option_remain_is_0 = '1' and
             is_whi_00 = '0')) then -- Not pad (then option in low word).
          if (is_whi_ff = '1') then -- End option.
            a.next_state <= ISM_BOOTP_76_340;
          end if;
          -- Harmless in case of end:
          -- We have a new option in hi word.
          a.dhcp_has_new_option         <= '1';
          a.dhcp_new_option             <= w(15 downto 8);
          a.dhcp_option_remain          <= w(7 downto 0);
        end if;

        -- New option, option in the lo word.
        if ((dhcp_option_remain_is_1 = '1') or -- New option start at low word.
            (dhcp_option_remain_is_0 = '1' and -- New option start at high,
             is_whi_00 = '1') or               -- but high word is pad.
            (s.dhcp_option_length_hi = '1' and -- Option in prev lo word has
             is_whi_00 = '1')) then            -- length 0 in this hi word,
                                               -- so lo word is new option.
          if (is_wlo_ff = '1') then -- END option in lo word
            a.next_state <= ISM_BOOTP_76_340;
            -- Assignments below are harmless.
          end if;
          -- We have a new option in lo word.
          -- It is unaligned, with length in next word.
          a.dhcp_has_new_option         <= '1';
          a.dhcp_new_option             <= w(7 downto 0);
          a.dhcp_new_option_length_next <= '1';
          -- Give a dummy length, large enough to not trigger option
          -- handling or new option check next round.  Will next round
          -- be overwritten with correct value.
          a.dhcp_option_remain      <= "00000100"; -- 4, to not trigger

          -- Check for pad option at lo word!
          if (is_wlo_00 = '1') then
            -- To look again in next word, fake it as option which was
            -- fully contained in this word.
            a.dhcp_has_new_option       <= '1';
            a.dhcp_new_option           <= (others => '0');
            a.dhcp_new_option_length_next <= '0';
            a.dhcp_option_remain        <= (others => '0');
          end if;
        end if;

        -- Ran out of option space, go to final check.
        if (s.ipv4_remain_is_0 = '1') then
          a.next_state <= ISM_BOOTP_CK1;
        end if;

        -- Consider the data if we just completed an option.

        -- Option 53 - DHCP.
        if (conv_integer(s.dhcp_option) = 53) then
          -- An option 53 means it is not a plain BOOTP response.
          a.is_bootp <= '0';
          -- Is it an offer (2) or ack (5)?
          if ((dhcp_option_remain_is_1 = '1' and
               is_whi_02 = '1') or
              (dhcp_option_remain_is_0 = '1' and
               is_prev_wlo_02 = '1')) then
            a.is_dhcp_offer <= s.is_dhcp;
          end if;
          if ((dhcp_option_remain_is_1 = '1' and
               is_whi_05 = '1') or
              (dhcp_option_remain_is_0 = '1' and
               is_prev_wlo_05 = '1')) then
            a.is_dhcp_ack <= s.is_dhcp;
          end if;
        end if;

        -------------------------------------------------------------
        --
        -- NTP
        --
        -------------------------------------------------------------

        -- We respond to almost whatever (NTP) packet.

      when ISM_NTP_42 => -- leap-version-mode, stratum
        -- Only respond to NTP version 3 or 4.
        -- Only respond to mode 3 (client) (since we respond with mode
        -- 4, this means we cannot make a loop).
        -- For mode 4, it is a response to a query from us.  We do not respond.
        if (is_ntp_ver_3or4_mode_3or4 = '1') then
          a.next_state <= ISM_NTP_44;
        end if;
        a.is_ntp_resp <= is_ntp_mode_4;
        -- .. (leap), ... (version of request), 100 (4 = server), stratum
        a.wdata <= ntp_stat.leap & w(13 downto 11) & "100" & ntp_stat.stratum;
        a.latch_ntp_data(0) <= '1';

      when ISM_NTP_44 => -- poll, precision
        a.next_state <= ISM_NTP_46;
        -- poll, precision
        a.wdata <= "00000100" & ntp_stat.precision;
        a.latch_ntp_data(1) <= '1';

      when ISM_NTP_46 => -- root_delay
        a.next_state <= ISM_NTP_48;
        a.wdata <= ntp_stat.root_delay(31 downto 16);
        a.latch_ntp_data(2) <= '1';

      when ISM_NTP_48 =>
        a.next_state <= ISM_NTP_50;
        a.wdata <= ntp_stat.root_delay(15 downto 0);
        a.latch_ntp_data(3) <= '1';

      when ISM_NTP_50 => -- root_dispersion
        a.next_state <= ISM_NTP_52;
        a.wdata <= ntp_stat.root_dispersion(31 downto 16);
        a.latch_ntp_data(4) <= '1';

      when ISM_NTP_52 =>
        a.next_state <= ISM_NTP_54;
        a.wdata <= ntp_stat.root_dispersion(15 downto 0);
        a.latch_ntp_data(5) <= '1';

      when ISM_NTP_54 => -- reference_id
        a.next_state <= ISM_NTP_56;
        a.wdata <= ntp_stat.reference_id(31 downto 16);
        a.latch_ntp_data(6) <= '1';

      when ISM_NTP_56 =>
        a.next_state <= ISM_NTP_58;
        a.wdata <= ntp_stat.reference_id(15 downto 0);
        a.latch_ntp_data(7) <= '1';

      when ISM_NTP_58 => -- reference_ts (our latest time fix)
        a.next_state <= ISM_NTP_60;
        a.wdata <= ntp_stat.reference_ts(63 downto 48);
        a.latch_ntp_data(8) <= '1';

      when ISM_NTP_60 =>
        a.next_state <= ISM_NTP_62;
        a.wdata <= ntp_stat.reference_ts(47 downto 32);
        a.latch_ntp_data(9) <= '1';

      when ISM_NTP_62 =>
        a.next_state <= ISM_NTP_64;
        a.wdata <= ntp_stat.reference_ts(31 downto 16);
        a.latch_ntp_data(10) <= '1';
        a.calc_ntp_tx_dly <= '1';

      when ISM_NTP_64 =>
        a.next_state <= ISM_NTP_66;
        a.wdata <= ntp_stat.reference_ts(15 downto 0);
        a.latch_ntp_data(11) <= '1';
        -- Prepare the transmit timestamp.
        a.latch_ntp_tx_ts <= '1';

        -- Timestamp handling:
        --
        -- Normally, we should as our receive timestamp write the time
        -- when we _started_ to receive the packet, i.e. the time at
        -- the packet preamble start.  As transmit timestamp we should
        -- write the time at our end of the packet transmission
        -- (before the IPG).  While the first is rather easy, the
        -- second is more involved.
        --
        -- What is important is however the symmetry between the two
        -- times.  Since we know that reception and transmission
        -- operate at the same speed, it would be equally suitable to
        -- report the time e.g. the end of reception and start of
        -- transmission, respectively.  Or something in-between, as
        -- long as the two times shift by the same amount in opposite
        -- directions.
        --
        -- An NTP packet (without extensions) is 104 bytes long
        -- (including the preamble).
        --
        -- For the time being, we adjust the transmission time by
        -- taking the local time when that data has to be written
        -- (next cycle below, at byte (preamble 8)+66), and shift it
        -- to be (64-10)=54 bytes later.  I.e. at 8+66+54-104 = 24
        -- bytes into the transmitted packets.
        --
        -- The reception time is taken and written as the time when it
        -- is needed, at byte 72 (i.e. 104-72 = 32 bytes before the
        -- end.
        --
        -- TODO: These two values are bug-compatible with the NTP
        -- query reception time taken at the packet start after the
        -- preamble.  When that has been fixed, the transmit shift
        -- should be made 32 as well.

      when ISM_NTP_66 => -- originate_ts (just send back what we got)
        -- We ignore what we get here, but write the transmit timestamp!
        -- (Write our current time at transmission, e.g. time plus usual
        -- delay until actual transmit.)
        a.next_state <= ISM_NTP_68;
        a.wdata <= ntp_tx_future_ts(63 downto 48);
        a.woff <= std_logic_vector(to_unsigned(16,11));
        a.latch_ntp_data(12) <= '1';

      when ISM_NTP_68 =>
        a.next_state <= ISM_NTP_70;
        a.wdata <= ntp_tx_future_ts(47 downto 32);
        a.woff <= std_logic_vector(to_unsigned(16,11));
        a.latch_ntp_data(13) <= '1';

      when ISM_NTP_70 =>
        a.next_state <= ISM_NTP_72;
        a.wdata <= ntp_tx_future_ts(31 downto 16);
        a.woff <= std_logic_vector(to_unsigned(16,11));
        a.latch_ntp_data(14) <= '1';

      when ISM_NTP_72 =>
        a.next_state <= ISM_NTP_74;
        a.wdata <= ntp_tx_future_ts(15 downto  0);
        a.woff <= std_logic_vector(to_unsigned(16,11));
        a.latch_ntp_data(15) <= '1';
        -- If we are generating a response (incoming is query),
        -- then re-latch the rx timestamp.
        a.latch_ntp_ts <= not s.is_ntp_resp;

      when ISM_NTP_74 => -- receive_ts (our current time at reception,
                         -- e.g. time when we started reception.)
        a.next_state <= ISM_NTP_76;
        a.wdata <= ntp_pkt_start_ts(63 downto 48);
        a.latch_ntp_data(16) <= '1';

      when ISM_NTP_76 =>
        a.next_state <= ISM_NTP_78;
        a.wdata <= ntp_pkt_start_ts(47 downto 32);
        a.latch_ntp_data(17) <= '1';

      when ISM_NTP_78 =>
        a.next_state <= ISM_NTP_80;
        a.wdata <= ntp_pkt_start_ts(31 downto 16);
        a.latch_ntp_data(18) <= '1';

      when ISM_NTP_80 =>
        a.next_state <= ISM_NTP_82;
        a.wdata <= ntp_pkt_start_ts(15 downto  0);
        a.latch_ntp_data(19) <= '1';

      when ISM_NTP_82 => -- transmit_ts.  This is written to the originate_ts.
        a.next_state <= ISM_NTP_84;
        a.woff <= std_logic_vector(to_unsigned(2048-16,11));
        a.latch_ntp_data(20) <= '1';

      when ISM_NTP_84 =>
        a.next_state <= ISM_NTP_86;
        a.woff <= std_logic_vector(to_unsigned(2048-16,11));
        a.latch_ntp_data(21) <= '1';

      when ISM_NTP_86 =>
        a.next_state <= ISM_NTP_88;
        a.woff <= std_logic_vector(to_unsigned(2048-16,11));
        a.latch_ntp_data(22) <= '1';

      when ISM_NTP_88 =>
        -- This checks that the IP and UDP packet length fields were
        -- correct (for a non-options, i.e. fixed size NTP packet).
        if (s.ipv4_remain_is_0 = '1') then
          a.next_state <= ISM_NTP_CK1;
        end if;
        a.woff <= std_logic_vector(to_unsigned(2048-16,11));
        a.latch_ntp_data(23) <= '1';

      when ISM_NTP_CK1 =>
        a.next_state <= ISM_NTP_CK2;

      when ISM_NTP_CK2 =>
        if ((rcksum_good = '1' or s.cksum_0 = '1') and
            is_good_crc32 = '1') then
          a.next_state <= ISM_GOOD_PACKET;
          a.good_ntp <= '1';
          cnts.good_ntp <= '1';
        end if;
        cnts.bad_cksum <= not rcksum_good;
        cnts.bad_crc   <= not is_good_crc32;

        a.wdata <= not fold_wcksum(15 downto 0);
        a.wudpcksum <= '1';

        -------------------------------------------------------------
        --
        -- TCP
        --
        -------------------------------------------------------------

        -- For TCP we only care about the write data or offset,
        -- up to including the source and destinations ports, and
        -- the ack number, as we might be constructing the template
        -- header.

      when ISM_TCP_34 => -- Source port
        a.next_state <= ISM_TCP_36;
        a.woff <= std_logic_vector(to_unsigned(2,11));
        a.cur_other_ip_port.portno <= w;

      when ISM_TCP_36 => -- Destination port
        -- The IP/port comparison is done in this cycle (port was set
        -- in previous cycle), check in next.
        if (is_tcp_dest_port = '1' and
            rcksum_good = '1') then -- Check the IP checksum
          a.next_state <= ISM_TCP_38;
        end if;
        cnts.bad_cksum <= not rcksum_good;

        a.woff <= std_logic_vector(to_unsigned(2048-2,11));

        -- Get the IP checksum
        -- a.keepipcksum <= '1';   -- Not used.

      when ISM_TCP_38 => -- Sequence number (hi)
        -- Either we are not connected, or
        -- it must be the conn. IP/port, and the sequence number
        -- shall match what the other end sent at connection time.
        if (s.fill_ram_tcp_template = '1' or
            (is_tcp_other_ip_port = '1' and
             is_tcp_seq_hi = '1')) then
          a.next_state <= ISM_TCP_40;
        end if;
        if (s.fill_ram_tcp_template = '1') then
          -- Keep the hi seq number
          a.store_tcp_seq_hi <= '1';
        end if;
        -- What we write in this location does not matter,
        -- since packet preparer will provide the value.

      when ISM_TCP_40 => -- Sequence number (lo)
        if (s.fill_ram_tcp_template = '1' or
            is_tcp_seq_lo = '1') then
          a.next_state <= ISM_TCP_42;
        end if;
        if (s.fill_ram_tcp_template = '1') then
          -- Keep the lo seq number (+1)
          a.store_tcp_seq_lo <= '1';
        end if;
        -- What we write in this location does not matter,
        -- since packet preparer will provide the value.

      when ISM_TCP_42 => -- Ack number (hi)
        a.next_state <= ISM_TCP_44;
        a.latch_tcp_ack_hi <= '1';
        -- Write the lo seq number (was added last cycle),
        -- (hi value not ready yet)
        a.woff <= std_logic_vector(to_unsigned(2,11));
        a.wdata <= tcp_seq_lo;
        if (s.fill_ram_tcp_template = '1') then
          -- Carry into the hi seq number if needed.
          a.carry_tcp_seq_hi <= '1';
        end if;

      when ISM_TCP_44 => -- Ack number (lo)
        -- If we are not connected, we are not checking.
        -- TODO: if we have sent SYN, we should check.
        -- If hi part was same, then low part must be larger or equal.
        -- If hi part was next, then low part must be lower.
        -- If hi part did not match any of those two, we are a failure.
        if (tcp_stat.conn_state /= CONNECTED or
            (s.seqno_hi_same = '1' and
             (is_w_ge_tcp_stat_base_seqno_lo = '1') and
             ((is_tcp_stat_max_sent16_eq_base_seqno16 = '0') or
              (is_w_le_tcp_stat_max_sent_lo = '1'))) or
            (s.seqno_hi_next = '1' and
             ((is_tcp_stat_max_sent16_eq_base_seqno16 = '0') and
              (is_w_le_tcp_stat_max_sent_lo = '1')))) then
          a.next_state <= ISM_TCP_46;
        end if;
        a.latch_tcp_ack_lo <= '1';
        -- Write the hi seq number.
        a.woff <= std_logic_vector(to_unsigned(2048-2,11));
        a.wdata <= tcp_seq_hi;

      when ISM_TCP_46 => -- Data off, 000, flags
        -- TODO: Check that length matches remaining size with no payload data.
        a.next_state <= ISM_TCP_48;
        -- Prepare template with zero value.  Since packet generator
        -- will write the flags, it also has to write the length
        -- (4x5=20), as it updates the checksum.
        -- No need: it calculates fresh checksums
        -- a.wdata <= std_logic_vector(to_unsigned(16#5000#,16));

        a.is_tcp_syn <= '0';
        a.is_tcp_ack <= '0';

        if (w(4 downto 0) = "00010" and
            s.fill_ram_tcp_template = '1') then
          a.is_tcp_syn <= '1';
        end if;
        if (w(4 downto 0) = "10000" and
            (tcp_stat.conn_state = SYN_SENT or
             tcp_stat.conn_state = CONNECTED)) then
          a.is_tcp_ack <= '1';
        end if;

      when ISM_TCP_48 => -- Window size
        a.next_state <= ISM_TCP_50;
        a.latch_tcp_window <= '1';
        -- Wireshark does not like window size 0, so announce 1.
        -- We never acknowledge data however.
        -- 1-byte payload packets will also be ignored due to odd length
        -- check already in IP header.
        a.wdata <= (0 => '1', others => '0');

      when ISM_TCP_50 => -- Checksum
        a.next_state <= ISM_TCP_52;
        a.wdata <= (others => '0');

      when ISM_TCP_52 => -- Urgent pointer
        if (s.ipv4_remain_is_0 = '0') then
          a.next_state <= ISM_TCP_OPT1;
        else
          a.next_state <= ISM_TCP_PAD;
        end if;
        a.wdata <= (others => '0');

      when ISM_TCP_OPT1 =>
        if (s.ipv4_remain_is_0 = '0') then
	  if (s.minsz_remain /= std_logic_vector(to_unsigned(0,11))) then
	    a.next_state <= ISM_TCP_OPT1;
	  else
	    a.next_state <= ISM_TCP_OPT2;
	  end if;
        else
	  if (s.minsz_remain /= std_logic_vector(to_unsigned(0,11))) then
	    a.next_state <= ISM_TCP_PAD;
	  else
	    a.next_state <= ISM_TCP_OPT1;
	  end if;
	end if;
        -- Output data does not matter, we'll not use this far in the template.

      when ISM_TCP_OPT2 =>
        if (s.ipv4_remain_is_0 = '0') then
          a.next_state <= ISM_TCP_OPT2;
        else
	  a.next_state <= ISM_TCP_CK1;
	end if;
        -- Output data does not matter.

      when ISM_TCP_PAD =>
        a.ignore_rcksum <= '1';
        if (s.minsz_remain /= std_logic_vector(to_unsigned(0,11))) then
          a.next_state <= ISM_TCP_PAD;
        else
          a.next_state <= ISM_TCP_CK1;
        end if;

      when ISM_TCP_CK1 =>
        a.next_state <= ISM_TCP_CK2;
        -- Output data does not matter.

      when ISM_TCP_CK2 =>
        if (rcksum_good = '1' and
            is_good_crc32 = '1') then
          a.next_state <= ISM_GOOD_PACKET;
          a.good_tcp_packet <= '1';
          cnts.good_tcp <= '1';
        end if;
        cnts.bad_cksum <= not rcksum_good;
        cnts.bad_crc   <= not is_good_crc32;

        -- Output data does not matter.

        -------------------------------------------------------------
        --
        -- Common
        --
        -------------------------------------------------------------

      when ISM_GOOD_PACKET =>
        a.next_state <= ISM_DONE_PACKET;

      when ISM_DONE_PACKET =>
        -- This state marks that a packet was successfully parsed.
        a.next_state <= ISM_DONE_PACKET;

      when ISM_BAD_PACKET =>
        -- This state marks that a packet failed parsing.

    end case;
  end process;

  -- Count latched value for better pipeline.
  count_words_next <= ('0' & count_words) + got_word_prev;

  process (clk)
  begin
    if (rising_edge(clk)) then

      ram_prod_arp_icmp.set_hasdata <= '0';
      ram_prod_udp_regacc.set_hasdata <= '0';
      rpur_NUM_REG_CH : for i in 0 to NUM_REG_CH-1 loop
        ram_prod2_udp_regres(i).set_again <= '0';
      end loop;
      ram_prod_tcp_template.set_hasdata <= '0';

      ram_prod_arp_icmp.set_broadcast <= '0';
      ram_prod_udp_regacc.set_broadcast <= '0';
      ram_prod_tcp_template.set_broadcast <= '0';
      ram_prod_arp_icmp.set_drop_dly <= '0';
      ram_prod_udp_regacc.set_drop_dly <= '0';
      ram_prod_tcp_template.set_drop_dly <= '0';

      tcp_recv.got_syn <= '0';
      tcp_recv.got_ack <= '0';

      dyn_in_stat.any_arp         <= '0';
      dyn_in_stat.good_rarp       <= '0';
      dyn_in_stat.good_bootp      <= '0';
      dyn_in_stat.good_dhcp_offer <= '0';
      dyn_in_stat.good_dhcp_ack   <= '0';
      dyn_in_stat.good_ntpr       <= '0';

      info_counts <= iic_zero;

      info_counts.b_ip0123 <= our_b_ip01 & our_b_ip23;

      dly_actual_dowrite <= '0';

      ntpr_got <= '0';

      if (timeout_tick = '1') then
        age_active: for i in 0 to NUM_REG_CH-1 loop
          s.reg(i).seq_active_marks <=
            '0' & s.reg(i).seq_active_marks(s.reg(i).seq_active_marks'left
                                            downto 1);
        end loop;
      end if;

      if (got_word_prev = '1') then
        s.state <= a.next_state;
        s.is_our_mac <= a.is_our_mac;
        s.is_our_ip <= a.is_our_ip;
        s.is_icmp <= a.is_icmp;
        s.is_tcp <= a.is_tcp;
        s.is_udp <= a.is_udp;
        s.is_bootp <= a.is_bootp;
        s.is_dhcp <= a.is_dhcp;
        s.is_dhcp_offer <= a.is_dhcp_offer;
        s.is_dhcp_ack <= a.is_dhcp_ack;
        s.is_ntp <= a.is_ntp;
        s.is_ntp_resp <= a.is_ntp_resp;
        s.is_tcp_syn <= a.is_tcp_syn;
        s.is_tcp_ack <= a.is_tcp_ack;
        s.is_rarp_resp <= a.is_rarp_resp;
        s.cur_other_ip_port <= a.cur_other_ip_port;
        s.dyn_offer_ip_port <= a.dyn_offer_ip_port;
        s.reg_idp <= a.reg_idp;
        s.reg_ch <= a.reg_ch;
        s.do_reg_seq_failure <= a.do_reg_seq_failure;
        s.do_reg_seq_reset_arm <= a.do_reg_seq_reset_arm;
        s.do_reg_seq_reset <= a.do_reg_seq_reset;
        s.do_reg_disconnect <= a.do_reg_disconnect;
        s.do_reg_access <= a.do_reg_access;
        s.do_reg_access_idp <= a.do_reg_access_idp;
        s.repeat_reg_response <= a.repeat_reg_response;
        s.fill_ram_arp_icmp <= a.fill_ram_arp_icmp;
        s.fill_ram_udp_regacc <= a.fill_ram_udp_regacc;
        s.fill_ram_tcp_template <= a.fill_ram_tcp_template;
        s.cksum_0 <= a.cksum_0;
        s.packet_start_count <= s.packet_start_count + cnts.start_packet;

        info_counts <= cnts;

        s.ipv4_remain <= a.ipv4_remain;
        s.minsz_remain <= a.minsz_remain;
        s.ipv4_remain_m2 <= a.ipv4_remain - 2;
        s.minsz_remain_m2 <= a.minsz_remain - 2;
        s.ipv4_remain_p6 <= a.ipv4_remain - 2 + 8;

        if ((a.ipv4_remain) = std_logic_vector(to_unsigned(0,11))) then
          s.ipv4_remain_is_0 <= '1';
        else
          s.ipv4_remain_is_0 <= '0';
        end if;
        if ((a.ipv4_remain - 2) = std_logic_vector(to_unsigned(0,11))) then
          s.ipv4_remain_m2_is_0 <= '1';
        else
          s.ipv4_remain_m2_is_0 <= '0';
        end if;
        if ((a.ipv4_remain - 8) >= std_logic_vector(to_unsigned(0,11))) then
          s.ipv4_remain_m8_ge_0 <= '1';
        else
          s.ipv4_remain_m8_ge_0 <= '0';
        end if;
        if ((a.ipv4_remain) = std_logic_vector(to_unsigned(62,11))) then
          s.ipv4_remain_is_62 <= '1';
        else
          s.ipv4_remain_is_62 <= '0';
        end if;

        s.rcksum <= tmp_rcksum;
        s.wcksum <= tmp_wcksum;

        s.prev_our_a_ip01 <= is_our_a_ip01;
        s.prev_our_b_ip01 <= is_our_b_ip01;

        s.prev_bootp_xid_hi <= is_bootp_xid_hi;
        s.prev_dhcp_xid_hi  <= is_dhcp_xid_hi;

        if (a.next_accum_cksum = '1' or
            a.next_pseudo_cksum = '1') then
          s.psdcksum <= tmp_psdcksum;
        else
          --s.psdcksum <= (others => '0');
          -- Instead of subtracting the IP header length from
          -- a.wdata_psd in ISM_IPV4_16, we apply the correction
          -- as the init value here.
          s.psdcksum <= "11111111111101010";
        end if;

        dly_s_psdcksum <= s.psdcksum;

        if (a.keepipcksum = '1') then
          -- Do the not here, as other users of fold_wcksum do that as well.
          s.wcksum_ip <= not fold_wcksum(15 downto 0);
        end if;

        s.accum_cksum <= a.next_accum_cksum;
        s.pseudo_cksum <= a.next_pseudo_cksum;

        dly_s_accum_cksum <= s.accum_cksum;
        dly_s_pseudo_cksum <= s.pseudo_cksum;

        s.ignore_wcksum <= a.ignore_wcksum or a.ignore_rcksum;
        s.set_regacc_wcksum <= a.set_regacc_wcksum;

        if (a.latch_tcp_ack_hi = '1') then
          tcp_recv.ack_seqno(16) <= w(0);

          s.seqno_hi_same <= '0';
          s.seqno_hi_next <= '0';

          if (w = tcp_stat.base_seqno(31 downto 16)) then
            s.seqno_hi_same <= '1';
          end if;
          if (w = tcp_astat.base_seqno_hi_plus_1) then
            s.seqno_hi_next <= '1';
          end if;
        end if;
        if (a.latch_tcp_ack_lo = '1') then
          tcp_recv.ack_seqno(15 downto 0) <= w;
        end if;
        if (a.latch_tcp_window = '1') then
          tcp_recv.window_len <= w;
        end if;

        if (a.store_tcp_seq_hi = '1') then
          tcp_seq_hi <= w;
        end if;
        if (a.store_tcp_seq_lo = '1') then
          tcp_seq_lo <= w_plus_1(15 downto 0);
          tcp_seq_lo_carry <= w_plus_1(16);
        end if;
        if (a.carry_tcp_seq_hi = '1') then
          tcp_seq_hi <= tcp_seq_hi + tcp_seq_lo_carry;
        end if;

        -- We can calculate where and what to update even if not writing
        actual_woff <= off + a.woff;

        dly_wicmpcksum <= a.wicmpcksum;
        dly_wudpcksum <= a.wudpcksum;

        actual_wdata <= a.wdata;

        -- Only do the updates if we are live.  (Is this needed?)
        if (a.next_state /= ISM_DONE_PACKET and
            a.next_state /= ISM_BAD_PACKET) then
          dly_actual_dowrite <= '1';
        end if;

        -- Any good (checksum valid) ARP packet.
        -- Provoke dynamic requests.
        dyn_in_stat.any_arp <= a.any_arp;

        if (a.dhcp_has_new_option = '1') then
          s.dhcp_option        <= a.dhcp_new_option;
        end if;

        -- Should we get the option length next cycle?
        s.dhcp_option_length_hi <= a.dhcp_new_option_length_next;
        -- Always update how much remains of the option payload.
        s.dhcp_option_remain <= a.dhcp_option_remain;

        if (s.is_our_mac = '1') then
          if ((a.good_arp = '1' or
               a.good_icmp = '1' or
               (a.good_ntp = '1' and
                s.is_ntp_resp = '0')) and
              s.fill_ram_arp_icmp = '1') then
            ram_prod_arp_icmp.set_hasdata <= '1';
            ram_prod_arp_icmp.set_broadcast <= '0';
            ram_prod_arp_icmp.set_drop_dly <= a.good_ntp;
          end if;

          dyn_in_stat.good_rarp       <= a.good_rarp;
          dyn_in_stat.good_bootp      <= a.good_bootp;
          dyn_in_stat.good_dhcp_offer <= a.good_dhcp_offer;
          dyn_in_stat.good_dhcp_ack   <= a.good_dhcp_ack;

          if (a.good_udp_regacc = '1') then
            -- We cannot send the reset requests via the register
            -- access machinery, since that would overwrite the response,
            -- which can then not be sent again (if the response is for
            -- a failed connect access request).
            -- Perform the actions,
            -- either we could write the response or not.
            if (s.do_reg_access = '1') then
              -- Access attempt enough to unarm the reset.
              s.reg(s.reg_ch).seq_reset_armed <= '0';
              s.reg(s.reg_ch).seq_active_marks <= "11";
              -- We can only update the sequence counter if we filled
              -- the memory such that the access actually gets performed.
              if (s.fill_ram_udp_regacc = '1') then
                s.reg(s.reg_ch).seq_did_access <= '1';
                s.reg(s.reg_ch).seq_no <= reg_seq_no_plus_1;
                ram_prod_udp_regacc.set_hasdata <= '1';
              end if;
            end if;
            if (s.do_reg_access_idp = '1') then
              -- We can only update the sequence counter if we filled
              -- the memory such that the access actually gets performed.
              if (s.fill_ram_udp_regacc = '1') then
                ram_prod_udp_regacc.set_hasdata <= '1';
              end if;
            end if;
            if (s.do_reg_seq_reset_arm = '1') then
              -- Attempt enough to change sequence number.
              s.reg(s.reg_ch).seq_arm_reset_no <=
                s.reg(s.reg_ch).seq_arm_reset_no + 1;
              -- But only arm if reported.
              if (s.fill_ram_arp_icmp = '1') then
                s.reg(s.reg_ch).seq_reset_armed <= '1';
                ram_prod_arp_icmp.set_hasdata <= '1';
              end if;
            end if;
            if (s.do_reg_seq_reset = '1') then
              -- Attempt enough to unarm
              s.reg(s.reg_ch).seq_reset_armed <= '0';
              s.reg(s.reg_ch).seq_did_access <= '0';
              -- But only connect if reported.
              if (s.fill_ram_arp_icmp = '1') then
                -- Needs a reset somewhere ?
                s.reg(s.reg_ch).seq_connected <= '1';
                s.reg(s.reg_ch).seq_active_marks <= "11";
                s.reg(s.reg_ch).seq_no <=
                  (not s.reg(s.reg_ch).seq_arm_reset_no(
                    s.reg(s.reg_ch).seq_arm_reset_no'left downto 4)) &
                  (    s.reg(s.reg_ch).seq_arm_reset_no(3 downto 0));
                s.reg(s.reg_ch).other_ip_port <= s.cur_other_ip_port;
                ram_prod_arp_icmp.set_hasdata <= '1';
              else
                s.reg(s.reg_ch).seq_connected <= '0';
              end if;
            end if;
            if (s.do_reg_disconnect = '1') then
              -- Attempt enough to unarm
              s.reg(s.reg_ch).seq_reset_armed <= '0';
              s.reg(s.reg_ch).seq_did_access <= '0';
              -- Disconnect
              s.reg(s.reg_ch).seq_connected <= '0';
              s.reg(s.reg_ch).seq_active_marks <= "00";
              if (s.fill_ram_arp_icmp = '1') then
                ram_prod_arp_icmp.set_hasdata <= '1';
              end if;
            end if;
            if (s.do_reg_seq_failure = '1') then
              -- Deliver the failure packet, if prepared.
              if (s.fill_ram_arp_icmp = '1') then
                ram_prod_arp_icmp.set_hasdata <= '1';
              end if;
            end if;
            if (s.repeat_reg_response = '1') then
              ram_prod2_udp_regres(s.reg_ch).set_again <= '1';
            end if;
          end if;

          if (a.good_tcp_packet = '1') then
            if (s.fill_ram_tcp_template = '1') then
              ram_prod_tcp_template.set_hasdata <= '1';
            end if;
            if (s.is_tcp_syn = '1') then
              s.tcp_other_ip_port <= s.cur_other_ip_port;
            end if;

            -- Take from latched state, are from many cycles ago.
            tcp_recv.got_syn <= s.is_tcp_syn;
            tcp_recv.got_ack <= s.is_tcp_ack;

          end if;

          if (a.good_ntp = '1' and
              s.is_ntp_resp = '1') then
            -- We just got a NTP response, which parsed well.
            -- Report to whoever will deal with that.
            ntpr_got <= '1';
            dyn_in_stat.good_ntpr  <= '1';
          end if;
        end if;

        s.off <= s.off + 2;
      end if; -- got_word_prev

      if (new_packet_prev = '1') then
        if (s.state /= ISM_GOOD_PACKET) then
          -- Previous packet was exactly not fully parsed.
          -- We cought things either during parsing, or in BAD_PACKET
          -- state.
          if (s.state = ISM_BAD_PACKET) then
            -- Note that failure to parse does not mean the packet
            -- is broken.  It may just not have been for us.
            info_counts.stop_parse <= '1';
          elsif (s.state = ISM_DONE_PACKET) then
            -- The packet passed parsing and was ok.
            -- But something delivered a word beyond the end, before
            -- a new SFD was detected.
            info_counts.spurious <= '1';
          else
            -- The packets has passed all checks so far, but a new
            -- packet has been started before it was completed.
            -- Thus the previous packet was incomplete (= broken).
            info_counts.incomplete <= '1';
          end if;
        end if;

        s.state <= ISM_LL_0;
        s.off <= (others => '0');
      end if;

      if (got_word_prev1 = '1') then
        crc32 <= crc32_next;
      end if;

      if (new_packet_prev1 = '1') then
        crc32 <= (others => '1');
      end if;

      w                <= word_prev1;
      got_word_prev    <= got_word_prev1;
      new_packet_prev  <= new_packet_prev1;

      word_prev1       <= in_word;
      got_word_prev1   <= in_got_word;
      new_packet_prev1 <= in_new_packet;

      -- Do the input-word comparisons and checks using the previous
      -- stage, such that the results can be latched.
      is_our_mac01 <= x_is_our_mac01;
      is_our_mac23 <= x_is_our_mac23;
      is_our_mac45 <= x_is_our_mac45;

      is_our_a_ip01 <= x_is_our_a_ip01;
      is_our_a_ip23 <= x_is_our_a_ip23;

      is_our_b_ip01 <= x_is_our_b_ip01;
      is_our_b_ip23 <= x_is_our_b_ip23;

      is_dyn_offer_ip01 <= x_is_dyn_offer_ip01;
      is_dyn_offer_ip23 <= x_is_dyn_offer_ip23;

      is_bootp_xid_hi <= x_is_bootp_xid_hi;
      is_bootp_xid_lo <= x_is_bootp_xid_lo;
      is_dhcp_xid_hi <= x_is_dhcp_xid_hi;
      is_dhcp_xid_lo <= x_is_dhcp_xid_lo;

      is_icmp <= x_is_icmp;
      is_tcp <= x_is_tcp;
      is_udp <= x_is_udp;

      is_udp_ra_reset_arm <= x_is_udp_ra_reset_arm;
      is_udp_ra_reset <= x_is_udp_ra_reset;
      is_udp_ra_disconnect <= x_is_udp_ra_disconnect;

      is_tcp_dest_port <= x_is_tcp_dest_port;

      is_tcp_seq_hi <= x_is_tcp_seq_hi;
      is_tcp_seq_lo <= x_is_tcp_seq_lo;

      w_minus_6 <= x_w_minus_6;
      w_plus_1 <= x_w_plus_1;
      w_minus_0x0100 <= x_w_minus_0x0100;

      is_w_0000 <= x_is_w_0000;
      is_w_0001 <= x_is_w_0001;
      is_w_0004 <= x_is_w_0004;
      is_w_0201 <= x_is_w_0201;
      is_w_0604 <= x_is_w_0604;
      is_w_0800 <= x_is_w_0800;
      is_w_0806 <= x_is_w_0806;
      is_w_4000 <= x_is_w_4000;
      is_w_5363 <= x_is_w_5363;
      is_w_6382 <= x_is_w_6382;
      is_w_8035 <= x_is_w_8035;
      is_whi_00 <= x_is_whi_00;
      is_whi_02 <= x_is_whi_02;
      is_whi_05 <= x_is_whi_05;
      is_whi_06 <= x_is_whi_06;
      is_whi_45 <= x_is_whi_45;
      is_whi_ff <= x_is_whi_ff;
      is_wlo_00 <= x_is_wlo_00;
      is_wlo_02 <= x_is_wlo_02;
      is_wlo_05 <= x_is_wlo_05;
      is_wlo_ff <= x_is_wlo_ff;

      is_prev_wlo_02 <= is_wlo_02;
      is_prev_wlo_05 <= is_wlo_05;

      is_req_seq_arm_reset_no <= x_is_req_seq_arm_reset_no;
      is_reg_seq_no <= x_is_reg_seq_no;
      is_reg_seq_no_plus_1 <= x_is_reg_seq_no_plus_1;

      is_reg_ch_other_ip_port <= x_is_reg_ch_other_ip_port;
      is_tcp_other_ip_port <= x_is_tcp_other_ip_port;

      is_w_ge_tcp_stat_base_seqno_lo <= x_is_w_ge_tcp_stat_base_seqno_lo;
      is_tcp_stat_max_sent16_eq_base_seqno16 <=
        x_is_tcp_stat_max_sent16_eq_base_seqno16;
      is_w_le_tcp_stat_max_sent_lo <= x_is_w_le_tcp_stat_max_sent_lo;

      is_ntp_ver_3or4_mode_3or4 <= x_is_ntp_ver_3or4_mode_3or4;
      is_ntp_mode_4 <= x_is_ntp_mode_4;

      -- Pipeline writing of data.
      -- Needed to decouple the actual_woff.
      dly_actual_woff <= actual_woff;

      if (dly_wicmpcksum = '1') then
        dly_actual_woff <= std_logic_vector(to_unsigned(36,11));
      end if;
      if (dly_wudpcksum = '1') then
        dly_actual_woff <= std_logic_vector(to_unsigned(40,11));
      end if;

      dly_actual_wdata <= actual_wdata;

      dp_ram_arp_icmp_porto.wr   <= '0';
      dp_ram_udp_regacc_porto.wr <= '0';
      dp_ram_tcp_template_porto.wr  <= '0';

      if (dly_actual_dowrite = '1') then
        dp_ram_arp_icmp_porto.wr   <= s.fill_ram_arp_icmp;
        dp_ram_udp_regacc_porto.wr <= s.fill_ram_udp_regacc;
        dp_ram_tcp_template_porto.wr  <= s.fill_ram_tcp_template;
      end if;

      -- This is counted regardless of if we got a word.
      -- (Should not be here, but elsewhere.
      -- Is not associated with this state machine.)
      info_counts.slow_tick <= slow_clock_tick;
      info_counts.timeout_tick <= timeout_tick;

      count_words              <= count_words_next(4 downto 0);
      info_counts.words_div_32 <= count_words_next(5);

      if (a.latch_ntp_ts = '1') then
        ntp_pkt_start_ts <= ntp_stat.cur_ts;
      end if;
      if (a.latch_ntp_tx_ref_dly = '1') then
        ntp_tx_delay_ref_ts <= ntp_stat.cur_ts(ntp_tx_delay_ref_ts'range);
      end if;
      if (a.calc_ntp_tx_dly = '1') then
        ntp_tx_delay <=
          ntp_stat.cur_ts(ntp_tx_delay'range) -
          ntp_tx_delay_ref_ts;
      end if;
      if (a.latch_ntp_tx_ts = '1') then
        ntp_tx_future_ts <=
          ntp_stat.cur_ts + ntp_tx_delay;
      end if;

      for i in 0 to 11 loop
        if (a.latch_ntp_data(2*i  ) = '1') then
          ntp_data(i)(31 downto 16) <= w;
        end if;
        if (a.latch_ntp_data(2*i+1) = '1') then
          ntp_data(i)(15 downto  0) <= w;
        end if;
      end loop;
    end if;
  end process;

  crc_d16 <= word_prev1(7 downto 0) & word_prev1(15 downto 8);

  crc32calc : entity work.fnet_crc32
    port map (
      d16 => crc_d16,
      crc_in => crc32,
      crc_out => crc32_next
      );

  offm2 <= off + std_logic_vector(to_unsigned(2048-2,11));

  -- When we set that we have data, this is what is set
  ram_prod_arp_icmp.set_words   <= offm2(10 downto 0);
  ram_prod_udp_regacc.set_words <= offm2(10 downto 0);
  ram_prod_tcp_template.set_words  <= offm2(10 downto 0);

  dp_ram_arp_icmp_porto.addr    <= dly_actual_woff(10 downto 1);
  dp_ram_udp_regacc_porto.addr  <= dly_actual_woff(10 downto 1);
  dp_ram_tcp_template_porto.addr   <= dly_actual_woff(10 downto 1);
  dp_ram_arp_icmp_porto.wdata   <= dly_actual_wdata;
  dp_ram_udp_regacc_porto.wdata <= dly_actual_wdata;
  dp_ram_tcp_template_porto.wdata  <= dly_actual_wdata;

  regacc_prod_aux.set_end_words <=
    a.fill_ram_udp_regacc and a.set_regacc_end_words;
  regacc_prod_aux.v.end_words <= s.off + 2;
  regacc_prod_aux.set_checksum <=
    a.fill_ram_udp_regacc and s.set_regacc_wcksum; -- delay one cycle
  regacc_prod_aux.v.checksum <= s.wcksum;
  regacc_prod_aux.set_reg_ch <=
    a.fill_ram_udp_regacc and a.set_regacc_wcksum;
  regacc_prod_aux.v.reg_idp <= s.reg_idp;
  -- If we only have one access channel, reg_ch need no bits, and got double drivers
  assign_reg_ch: if (NUM_REG_CH > 1) generate
    regacc_prod_aux.v.reg_ch <= s.reg_ch;
  end generate;

  -- TODO: Latch?
  s.our_a_ip01 <= cfg_ipaddr(31 downto 16);
  s.our_a_ip23 <= cfg_ipaddr(15 downto  0);

  s.our_mac01 <= cfg_macaddr(47 downto 32);
  s.our_mac23 <= cfg_macaddr(31 downto 16);
  s.our_mac45 <= cfg_macaddr(15 downto  0);

  -- These can aliased, they are only used when
  -- dyn_in_stat.good_dhcp_offer is set.
  dyn_in_stat.offer_ip      <=
    s.dyn_offer_ip_port.ip01 & s.dyn_offer_ip_port.ip23;
  dyn_in_stat.offer_serv_ip <=
    s.cur_other_ip_port.ip01 & s.cur_other_ip_port.ip23;

  -- For debugging
  process (clk)
  begin
    if (rising_edge(clk)) then
      case s.state is
        when ISM_LL_0         => state_no <=     1;
        when ISM_LL_2         => state_no <=     2;
        when ISM_LL_4         => state_no <=     3;
        when ISM_LL_6         => state_no <=     4;
        when ISM_LL_8         => state_no <=     5;
        when ISM_LL_10        => state_no <=     6;
        when ISM_LL_12        => state_no <=     7;

        when ISM_ARP_14       => state_no <= 64+ 1;
        when ISM_ARP_16       => state_no <= 64+ 2;
        when ISM_ARP_18       => state_no <= 64+ 3;
        when ISM_ARP_20       => state_no <= 64+ 4;
        when ISM_ARP_22       => state_no <= 64+ 5;
        when ISM_ARP_24       => state_no <= 64+ 6;
        when ISM_ARP_26       => state_no <= 64+ 7;
        when ISM_ARP_28       => state_no <= 64+ 8;
        when ISM_ARP_30       => state_no <= 64+ 9;
        when ISM_ARP_32       => state_no <= 64+10;
        when ISM_ARP_34       => state_no <= 64+11;
        when ISM_ARP_36       => state_no <= 64+12;
        when ISM_ARP_38       => state_no <= 64+13;
        when ISM_ARP_40       => state_no <= 64+14;
        when ISM_ARP_42_60    => state_no <= 64+15;
        when ISM_ARP_62       => state_no <= 64+16;

        when ISM_RARP_38      => state_no <= 64+22;
        when ISM_RARP_40      => state_no <= 64+23;

        when ISM_IPV4_14      => state_no <= 16+ 1;
        when ISM_IPV4_16      => state_no <= 16+ 2;
        when ISM_IPV4_18      => state_no <= 16+ 3;
        when ISM_IPV4_20      => state_no <= 16+ 4;
        when ISM_IPV4_22      => state_no <= 16+ 5;
        when ISM_IPV4_24      => state_no <= 16+ 6;
        when ISM_IPV4_26      => state_no <= 16+ 7;
        when ISM_IPV4_28      => state_no <= 16+ 8;
        when ISM_IPV4_30      => state_no <= 16+ 9;
        when ISM_IPV4_32      => state_no <= 16+10;

        when ISM_ICMP_34      => state_no <= 32+ 1;
        when ISM_ICMP_36      => state_no <= 32+ 2;
        when ISM_ICMP_DATA1   => state_no <= 32+ 3;
        when ISM_ICMP_DATA2   => state_no <= 32+ 4;
        when ISM_ICMP_PAD     => state_no <= 32+ 5;
        when ISM_ICMP_CK1     => state_no <= 32+ 6;
        when ISM_ICMP_CK2     => state_no <= 32+ 7;

        when ISM_UDP_34       => state_no <= 48+ 1;
        when ISM_UDP_36       => state_no <= 48+ 2;
        when ISM_UDP_38       => state_no <= 48+ 3;
        when ISM_UDP_40       => state_no <= 48+ 4;
        when ISM_UDP_STAT_42  => state_no <= 48+ 5;
        when ISM_UDP_STAT_44  => state_no <= 48+ 6;
        when ISM_UDP_RA_46    => state_no <= 48+ 7;
        when ISM_UDP_RA_48    => state_no <= 48+ 8;
        when ISM_UDP_RA_DATA1 => state_no <= 48+ 9;
        when ISM_UDP_RA_DATA2 => state_no <= 48+10;
        when ISM_UDP_RA_PAD   => state_no <= 48+11;
        when ISM_UDP_RA_CK1   => state_no <= 48+12;
        when ISM_UDP_RA_CK2   => state_no <= 48+13;

        when ISM_BOOTP_42     => state_no <= 160+ 1;
        when ISM_BOOTP_44     => state_no <= 160+ 2;
        when ISM_BOOTP_46     => state_no <= 160+ 3;
        when ISM_BOOTP_48     => state_no <= 160+ 4;
        when ISM_BOOTP_50     => state_no <= 160+ 5;
        when ISM_BOOTP_52     => state_no <= 160+ 6;
        when ISM_BOOTP_54     => state_no <= 160+ 7;
        when ISM_BOOTP_56     => state_no <= 160+ 8;
        when ISM_BOOTP_58     => state_no <= 160+ 9;
        when ISM_BOOTP_60     => state_no <= 160+10;
        when ISM_BOOTP_62     => state_no <= 160+11;
        when ISM_BOOTP_64     => state_no <= 160+12;
        when ISM_BOOTP_66     => state_no <= 160+13;
        when ISM_BOOTP_68     => state_no <= 160+14;
        when ISM_BOOTP_70     => state_no <= 160+15;
        when ISM_BOOTP_72     => state_no <= 160+16;
        when ISM_BOOTP_74     => state_no <= 160+17;
        when ISM_BOOTP_76_340 => state_no <= 160+18;
        when ISM_BOOTP_CK1    => state_no <= 160+19;
        when ISM_BOOTP_CK2    => state_no <= 160+20;

        when ISM_DHCP_276     => state_no <= 160+22;
        when ISM_DHCP_278     => state_no <= 160+23;

        when ISM_NTP_42       => state_no <= 128+ 1;
        when ISM_NTP_44       => state_no <= 128+ 2;
        when ISM_NTP_46       => state_no <= 128+ 3;
        when ISM_NTP_48       => state_no <= 128+ 4;
        when ISM_NTP_50       => state_no <= 128+ 5;
        when ISM_NTP_52       => state_no <= 128+ 6;
        when ISM_NTP_54       => state_no <= 128+ 7;
        when ISM_NTP_56       => state_no <= 128+ 8;
        when ISM_NTP_58       => state_no <= 128+ 9;
        when ISM_NTP_60       => state_no <= 128+10;
        when ISM_NTP_62       => state_no <= 128+11;
        when ISM_NTP_64       => state_no <= 128+12;
        when ISM_NTP_66       => state_no <= 128+13;
        when ISM_NTP_68       => state_no <= 128+14;
        when ISM_NTP_70       => state_no <= 128+15;
        when ISM_NTP_72       => state_no <= 128+16;
        when ISM_NTP_74       => state_no <= 128+17;
        when ISM_NTP_76       => state_no <= 128+18;
        when ISM_NTP_78       => state_no <= 128+19;
        when ISM_NTP_80       => state_no <= 128+20;
        when ISM_NTP_82       => state_no <= 128+21;
        when ISM_NTP_84       => state_no <= 128+22;
        when ISM_NTP_86       => state_no <= 128+23;
        when ISM_NTP_88       => state_no <= 128+24;
        when ISM_NTP_CK1      => state_no <= 128+25;
        when ISM_NTP_CK2      => state_no <= 128+26;

        when ISM_TCP_34       => state_no <= 96+ 1;
        when ISM_TCP_36       => state_no <= 96+ 2;
        when ISM_TCP_38       => state_no <= 96+ 3;
        when ISM_TCP_40       => state_no <= 96+ 4;
        when ISM_TCP_42       => state_no <= 96+ 5;
        when ISM_TCP_44       => state_no <= 96+ 6;
        when ISM_TCP_46       => state_no <= 96+ 7;
        when ISM_TCP_48       => state_no <= 96+ 8;
        when ISM_TCP_50       => state_no <= 96+ 9;
        when ISM_TCP_52       => state_no <= 96+10;
        when ISM_TCP_OPT1     => state_no <= 96+11;
        when ISM_TCP_OPT2     => state_no <= 96+12;
        when ISM_TCP_PAD      => state_no <= 96+13;
        when ISM_TCP_CK1      => state_no <= 96+14;
        when ISM_TCP_CK2      => state_no <= 96+15;

        when ISM_GOOD_PACKET  => state_no <=    13;
        when ISM_DONE_PACKET  => state_no <=    14;
        when ISM_BAD_PACKET   => state_no <=    15;
      end case;
    end if;
  end process;

  debug_state <= std_logic_vector(to_unsigned(state_no,8));
  debug_state_r <= std_logic_vector(to_unsigned(state_no,8));

  -- We can report the NTP response info from the internal state.
  -- Will be latched by the outside at the ntpr_got signal.

  ntpr_ip <= s.cur_other_ip_port.ip01 & s.cur_other_ip_port.ip23;
  ntpr_recv_ts <= ntp_pkt_start_ts;
  ntpr_data <= ntp_data;


--ila_inst : ila_0 
--Port map(
--clk  => clk,
--probe0(0) => in_got_word,
--probe0(1) => in_new_packet,
--probe0(2) => cfg_fixed_ip,
--probe0(3) => cfg_dyn_ip,
--probe0(4) => cfg_gen_rarp,
--probe0(5) => cfg_gen_bootp,
--probe0(6) => cfg_gen_dhcp,
--probe0(7) => cfg_gen_ntpq,
--probe0(55 downto 8) => cfg_macaddr,
--probe0(87 downto 56) => cfg_ipaddr,
--probe0(95 downto 88) => debug_state_r,

--probe0(96) => is_our_mac01, 
--probe0(97) => is_our_mac23, 
--probe0(98) => is_our_mac45,

--probe0(99) => is_our_a_ip01,
--probe0(100) => is_our_a_ip23,
--probe0(101) => is_our_b_ip01,
--probe0(102) => is_our_b_ip23,

--probe0(103) => is_dyn_offer_ip01,
--probe0(104) => is_dyn_offer_ip23,

--probe0(105) => is_bootp_xid_hi,
--probe0(106) => is_bootp_xid_lo,
--probe0(107) => is_dhcp_xid_hi,
--probe0(108) => is_dhcp_xid_lo,

--probe0(109) => is_icmp,
--probe0(110) => is_tcp,
--probe0(111) => is_udp,

--probe0(112) => is_udp_ra_reset_arm,
--probe0(113) => is_udp_ra_reset,
--probe0(114) => is_udp_ra_disconnect,

--probe0(115) => is_tcp_dest_port,

--probe0(116) => is_tcp_seq_hi,
--probe0(117) => is_tcp_seq_lo,
--probe0(199 downto 118) => (others => '0')

--);

end RTL;
