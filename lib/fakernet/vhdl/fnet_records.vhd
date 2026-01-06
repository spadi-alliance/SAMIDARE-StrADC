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

package fnet_records is

  constant NUM_REG_CH : natural := 2;

  -- OR = OUT_RAM
  constant OR_ICMP    : natural := 0;
  constant OR_PKT_GEN : natural := OR_ICMP    + 1;
  constant OR_UDP_IDP : natural := OR_PKT_GEN + 1;
  constant OR_UDP     : natural := OR_UDP_IDP + 1;
  constant OR_TCP     : natural := OR_UDP     + NUM_REG_CH;
  constant OR_NUM     : natural := OR_TCP     + 2;

  -- TODO: currently the RAM blocks are actually 1024 words long,
  -- but some FPGAs only have 1 kB RAM blocks, so we should perhaps
  -- reduce to adhere to this value?  Optionally?
  -- For USP/ICMP only, and TCP separately?
  constant RAM_BLOCK_WORDS : natural := 512;

  type in_sm_state is (ISM_LL_0,
                       ISM_LL_2,
                       ISM_LL_4,
                       ISM_LL_6,
                       ISM_LL_8,
                       ISM_LL_10,
                       ISM_LL_12,
                       ISM_ARP_14,
                       ISM_ARP_16,
                       ISM_ARP_18,
                       ISM_ARP_20,
                       ISM_ARP_22,
                       ISM_ARP_24,
                       ISM_ARP_26,
                       ISM_ARP_28,
                       ISM_ARP_30,
                       ISM_ARP_32,
                       ISM_ARP_34,
                       ISM_ARP_36,
                       ISM_ARP_38,
                       ISM_ARP_40,
                       ISM_RARP_38,
                       ISM_RARP_40,
                       ISM_ARP_42_60,
                       ISM_ARP_62,
                       ISM_IPV4_14,
                       ISM_IPV4_16,
                       ISM_IPV4_18,
                       ISM_IPV4_20,
                       ISM_IPV4_22,
                       ISM_IPV4_24,
                       ISM_IPV4_26,
                       ISM_IPV4_28,
                       ISM_IPV4_30,
                       ISM_IPV4_32,
                       ISM_ICMP_34,
                       ISM_ICMP_36,
                       ISM_ICMP_DATA1,
                       ISM_ICMP_DATA2,
                       ISM_ICMP_PAD,
                       ISM_ICMP_CK1,
                       ISM_ICMP_CK2,
                       ISM_UDP_34,
                       ISM_UDP_36,
                       ISM_UDP_38,
                       ISM_UDP_40,
                       ISM_UDP_STAT_42,
                       ISM_UDP_STAT_44,
                       ISM_UDP_RA_46,
                       ISM_UDP_RA_48,
                       ISM_UDP_RA_DATA1,
                       ISM_UDP_RA_DATA2,
                       ISM_UDP_RA_PAD,
                       ISM_UDP_RA_CK1,
                       ISM_UDP_RA_CK2,
                       ISM_BOOTP_42,
                       ISM_BOOTP_44,
                       ISM_BOOTP_46,
                       ISM_BOOTP_48,
                       ISM_BOOTP_50,
                       ISM_BOOTP_52,
                       ISM_BOOTP_54,
                       ISM_BOOTP_56,
                       ISM_BOOTP_58,
                       ISM_BOOTP_60,
                       ISM_BOOTP_62,
                       ISM_BOOTP_64,
                       ISM_BOOTP_66,
                       ISM_BOOTP_68,
                       ISM_BOOTP_70,
                       ISM_BOOTP_72,
                       ISM_BOOTP_74,
                       ISM_BOOTP_76_340,
                       ISM_BOOTP_CK1,
                       ISM_BOOTP_CK2,
                       ISM_DHCP_276,
                       ISM_DHCP_278,
                       ISM_NTP_42,
                       ISM_NTP_44,
                       ISM_NTP_46,
                       ISM_NTP_48,
                       ISM_NTP_50,
                       ISM_NTP_52,
                       ISM_NTP_54,
                       ISM_NTP_56,
                       ISM_NTP_58,
                       ISM_NTP_60,
                       ISM_NTP_62,
                       ISM_NTP_64,
                       ISM_NTP_66,
                       ISM_NTP_68,
                       ISM_NTP_70,
                       ISM_NTP_72,
                       ISM_NTP_74,
                       ISM_NTP_76,
                       ISM_NTP_78,
                       ISM_NTP_80,
                       ISM_NTP_82,
                       ISM_NTP_84,
                       ISM_NTP_86,
                       ISM_NTP_88,
                       ISM_NTP_CK1,
                       ISM_NTP_CK2,
                       ISM_TCP_34,
                       ISM_TCP_36,
                       ISM_TCP_38,
                       ISM_TCP_40,
                       ISM_TCP_42,
                       ISM_TCP_44,
                       ISM_TCP_46,
                       ISM_TCP_48,
                       ISM_TCP_50,
                       ISM_TCP_52,
                       ISM_TCP_OPT1,
                       ISM_TCP_OPT2,
                       ISM_TCP_PAD,
                       ISM_TCP_CK1,
                       ISM_TCP_CK2,
                       ISM_GOOD_PACKET,
                       ISM_DONE_PACKET,
                       ISM_BAD_PACKET
                       );

type other_ip_port_rec is record
  ip01                 : std_logic_vector(15 downto 0);
  ip23                 : std_logic_vector(15 downto 0);
  portno               : std_logic_vector(15 downto 0);
end record other_ip_port_rec;

type incoming_udp_reg_state is record
  seq_no               : std_logic_vector(7 downto 0);
  seq_arm_reset_no     : std_logic_vector(7 downto 0);
  seq_reset_armed      : std_logic;
  seq_connected        : std_logic;
  seq_did_access       : std_logic;
  seq_active_marks     : std_logic_vector(1 downto 0);
  other_ip_port        : other_ip_port_rec;
end record incoming_udp_reg_state;

type incoming_udp_reg_state_array is
  array (integer range <>) of incoming_udp_reg_state;

type incoming_state is record
  state                : in_sm_state;
  off                  : std_logic_vector(10 downto 0);
  fill_ram_arp_icmp    : std_logic;
  fill_ram_udp_regacc  : std_logic;
  fill_ram_tcp_template: std_logic;
  ipv4_remain          : std_logic_vector(10 downto 0);
  minsz_remain         : std_logic_vector(10 downto 0);
  ipv4_remain_m2       : std_logic_vector(10 downto 0);
  minsz_remain_m2      : std_logic_vector(10 downto 0);
  ipv4_remain_p6       : std_logic_vector(10 downto 0);
  ipv4_remain_is_0     : std_logic;
  ipv4_remain_m2_is_0  : std_logic;
  ipv4_remain_m8_ge_0  : std_logic;
  ipv4_remain_is_62    : std_logic;
  is_our_mac           : std_logic;
  is_our_ip            : std_logic;
  is_icmp              : std_logic;
  is_tcp               : std_logic;
  is_udp               : std_logic;
  is_bootp             : std_logic;
  is_dhcp              : std_logic;
  is_dhcp_offer        : std_logic;
  is_dhcp_ack          : std_logic;
  is_ntp               : std_logic;
  is_ntp_resp          : std_logic;
  is_tcp_syn           : std_logic;
  is_tcp_ack           : std_logic;
  is_rarp_resp         : std_logic;
  dhcp_option_length_hi : std_logic;
  dhcp_option          : std_logic_vector(7 downto 0);
  dhcp_option_remain   : std_logic_vector(7 downto 0);
  cur_other_ip_port    : other_ip_port_rec;
  dyn_offer_ip_port    : other_ip_port_rec;
  tcp_other_ip_port    : other_ip_port_rec;
  prev_our_a_ip01      : std_logic;
  prev_our_b_ip01      : std_logic;
  prev_bootp_xid_hi    : std_logic;
  prev_dhcp_xid_hi     : std_logic;
  reg_idp              : std_logic;
  reg_ch               : integer range 0 to NUM_REG_CH-1;
  reg                  : incoming_udp_reg_state_array(0 to NUM_REG_CH-1);
  do_reg_seq_failure   : std_logic;
  do_reg_seq_reset_arm : std_logic;
  do_reg_seq_reset     : std_logic;
  do_reg_disconnect    : std_logic;
  do_reg_access        : std_logic;
  do_reg_access_idp    : std_logic;
  repeat_reg_response  : std_logic;
  set_regacc_wcksum    : std_logic;
  ignore_wcksum        : std_logic;
  accum_cksum          : std_logic;
  pseudo_cksum         : std_logic;
  rcksum               : std_logic_vector(16 downto 0);
  wcksum               : std_logic_vector(16 downto 0);
  wcksum_ip            : std_logic_vector(15 downto 0);
  psdcksum             : std_logic_vector(16 downto 0);
  cksum_0              : std_logic;
  -- TODO: These our_ should not be here?
  our_mac01            : std_logic_vector(15 downto 0);
  our_mac23            : std_logic_vector(15 downto 0);
  our_mac45            : std_logic_vector(15 downto 0);
  our_a_ip01           : std_logic_vector(15 downto 0);
  our_a_ip23           : std_logic_vector(15 downto 0);
  seqno_hi_same        : std_logic;
  seqno_hi_next        : std_logic;
  packet_start_count   : std_logic_vector(7 downto 0);
end record incoming_state;

type incoming_async_state is record
  next_state           : in_sm_state;
  wdata                : std_logic_vector(15 downto 0);
  wdata_psd            : std_logic_vector(15 downto 0);
  woff                 : std_logic_vector(10 downto 0);
  ipv4_remain          : std_logic_vector(10 downto 0);
  minsz_remain         : std_logic_vector(10 downto 0);
  is_our_mac           : std_logic;
  is_our_ip            : std_logic;
  is_icmp              : std_logic;
  is_tcp               : std_logic;
  is_udp               : std_logic;
  is_bootp             : std_logic;
  is_dhcp              : std_logic;
  is_dhcp_offer        : std_logic;
  is_dhcp_ack          : std_logic;
  is_ntp               : std_logic;
  is_ntp_resp          : std_logic;
  is_tcp_syn           : std_logic;
  is_tcp_ack           : std_logic;
  is_rarp_resp         : std_logic;

  dhcp_has_new_option  : std_logic;
  dhcp_new_option      : std_logic_vector(7 downto 0);
  dhcp_new_option_length_next : std_logic;
  dhcp_option_remain   : std_logic_vector(7 downto 0);

  -- TODO: Combine into separate structure?
  cur_other_ip_port    : other_ip_port_rec;
  dyn_offer_ip_port    : other_ip_port_rec;
  reg_idp              : std_logic;
  reg_ch               : integer range 0 to NUM_REG_CH-1;
  do_reg_seq_failure   : std_logic;
  do_reg_seq_reset_arm : std_logic;
  do_reg_seq_reset     : std_logic;
  do_reg_disconnect    : std_logic;
  do_reg_access        : std_logic;
  do_reg_access_idp    : std_logic;
  repeat_reg_response  : std_logic;

  set_regacc_end_words : std_logic;
  set_regacc_wcksum    : std_logic;
  ignore_rcksum        : std_logic;
  ignore_wcksum        : std_logic;
  next_accum_cksum     : std_logic;
  next_pseudo_cksum    : std_logic;
  wicmpcksum           : std_logic;
  wudpcksum            : std_logic;
  keepipcksum          : std_logic;
  cksum_0              : std_logic;
  fill_ram_arp_icmp    : std_logic;
  fill_ram_udp_regacc  : std_logic;
  fill_ram_tcp_template: std_logic;
  good_arp             : std_logic;
  any_arp              : std_logic;
  good_rarp            : std_logic;
  good_icmp            : std_logic;
  good_bootp           : std_logic;
  good_dhcp_offer      : std_logic;
  good_dhcp_ack        : std_logic;
  good_udp_regacc      : std_logic;
  good_tcp_packet      : std_logic;
  good_ntp             : std_logic;
  store_tcp_seq_hi     : std_logic;
  store_tcp_seq_lo     : std_logic;
  carry_tcp_seq_hi     : std_logic;
  latch_tcp_ack_hi     : std_logic;
  latch_tcp_ack_lo     : std_logic;
  latch_tcp_window     : std_logic;
  latch_ntp_ts         : std_logic;
  latch_ntp_tx_ts      : std_logic;
  calc_ntp_tx_dly      : std_logic;
  latch_ntp_tx_ref_dly : std_logic;
  latch_ntp_data       : std_logic_vector(0 to 23);
end record incoming_async_state;

type incoming_info_counts is record
  slow_tick         : std_logic;
  timeout_tick      : std_logic;
  words_div_32      : std_logic;
  start_packet      : std_logic;
  mac_for_us        : std_logic;
  start_arp         : std_logic;
  arp_our_ip        : std_logic;
  good_arp          : std_logic;
  good_rarp         : std_logic;
  start_ipv4        : std_logic;
  ip_hdr_ok         : std_logic;
  ip_a_for_us       : std_logic;
  ip_b_for_us       : std_logic;
  start_icmp        : std_logic;
  good_icmp         : std_logic;
  start_udp         : std_logic;
  good_udp          : std_logic;
  start_bootp       : std_logic;
  good_bootp        : std_logic;
  good_dhcp_offer   : std_logic;
  good_dhcp_ack     : std_logic;
  start_ntp         : std_logic;
  good_ntp          : std_logic;
  udp_arm           : std_logic;
  udp_badactivearm  : std_logic;
  udp_reset         : std_logic;
  udp_badreset      : std_logic;
  udp_disconnect    : std_logic;
  udp_baddisconnect : std_logic;
  udp_regaccess     : std_logic;
  udp_regaccess_idp : std_logic;
  udp_ra_is_otherip : std_logic;
  udp_ra_seqplus1   : std_logic;
  udp_ra_repeat     : std_logic;
  udp_ra_busy       : std_logic;
  udp_ra_idp_busy   : std_logic;
  start_tcp         : std_logic;
  good_tcp          : std_logic;
  bad_cksum         : std_logic;
  bad_crc           : std_logic;
  incomplete        : std_logic;
  spurious          : std_logic;
  stop_parse        : std_logic;
  b_ip0123          : std_logic_vector(31 downto 0);
end record incoming_info_counts;

constant iic_zero : incoming_info_counts :=
  (slow_tick => '0',
   timeout_tick => '0',
   words_div_32 => '0',
   start_packet => '0',
   mac_for_us => '0',
   start_arp => '0',
   arp_our_ip => '0',
   good_arp => '0',
   good_rarp => '0',
   start_ipv4 => '0',
   ip_hdr_ok => '0',
   ip_a_for_us => '0',
   ip_b_for_us => '0',
   start_icmp => '0',
   good_icmp => '0',
   start_udp => '0',
   good_udp => '0',
   start_bootp => '0',
   good_bootp => '0',
   good_dhcp_offer => '0',
   good_dhcp_ack => '0',
   start_ntp => '0',
   good_ntp => '0',
   udp_arm => '0',
   udp_badactivearm => '0',
   udp_reset => '0',
   udp_badreset => '0',
   udp_disconnect => '0',
   udp_baddisconnect => '0',
   udp_regaccess => '0',
   udp_regaccess_idp => '0',
   udp_ra_is_otherip => '0',
   udp_ra_seqplus1 => '0',
   udp_ra_repeat => '0',
   udp_ra_busy => '0',
   udp_ra_idp_busy => '0',
   start_tcp => '0',
   -- TODO: counters for TCP packet matching.
   good_tcp => '0',
   bad_cksum => '0',
   bad_crc => '0',
   incomplete => '0',
   spurious => '0',
   stop_parse => '0',
   b_ip0123 => (others => '0')
   );

type out_sm_state is (OSM_IDLE,
                      OSM_PRE_01,
                      OSM_PRE_23,
                      OSM_PRE_45,
                      OSM_PRE_67,
                      OSM_DATA_BCAST_0,
                      OSM_DATA_BCAST_2,
                      OSM_DATA_BCAST_4,
                      OSM_DATA,
                      OSM_CRC1,
                      OSM_CRC2,
                      OSM_GAP
                      );

-- TODO: combine elements in async state that are common?  into new record
type outgoing_state is record
  state                : out_sm_state;
  cnt                  : std_logic_vector(10 downto 0);
  wr_onehot            : std_logic_vector(0 to OR_NUM-1);
  wr_idx               : integer range 0 to OR_NUM-1;
  get_data             : std_logic_vector(15 downto 0);
  wdata                : std_logic_vector(15 downto 0);
  out_ena              : std_logic;
  payload              : std_logic;
end record outgoing_state;

type outgoing_async_state is record
  next_state           : out_sm_state;
  wr_onehot            : std_logic_vector(0 to OR_NUM-1);
  wr_idx               : integer range 0 to OR_NUM-1;
  clear_data           : std_logic;
  check_drop           : std_logic;
  reset_cnt            : std_logic;
  wdata                : std_logic_vector(15 downto 0);
  out_ena              : std_logic;
  payload              : std_logic;
end record outgoing_async_state;

type outgoing_info_counts is record
  arp_icmp      : std_logic;
  drop_ntp      : std_logic;
  pkt_gen       : std_logic;
  udp_idp       : std_logic;
  udp           : std_logic_vector(0 to 8); -- 8 for overflow channels
  tcp           : std_logic;
  packets       : std_logic;
  words_div_32  : std_logic;
  block_bug     : std_logic;
end record outgoing_info_counts;

constant oic_zero : outgoing_info_counts :=
  (arp_icmp => '0',
   drop_ntp => '0',
   pkt_gen => '0',
   udp_idp => '0',
   udp => (others => '0'),
   tcp => '0',
   packets => '0',
   words_div_32 => '0',
   block_bug => '0');

type regacc_state is (RSM_IDLE,
                      RSM_FIRST,
                      RSM_HEADER,
                      RSM_NEXT_ACCESS,
                      RSM_RADDR_1,
                      RSM_RADDR_2,
                      RSM_WRITE_RDATA_1,
                      RSM_WRITE_RDATA_2,
                      RSM_WRITE_WAIT,
                      RSM_WRITE_WADDR_1,
                      RSM_WRITE_WADDR_2,
                      RSM_WRITE_WDATA_1,
                      RSM_WRITE_WDATA_2,
                      RSM_READ_WAIT,
                      RSM_READ_WADDR_1,
                      RSM_READ_WADDR_2,
                      RSM_READ_WDATA_1,
                      RSM_READ_WDATA_2,
                      RSM_PAD,
                      RSM_CK,
                      RSM_DONE
                      );

type regacc_latch is (LATCH_NONE,
                      LATCH_ADDR_1,
                      LATCH_ADDR_2,
                      LATCH_DATA_1,
                      LATCH_DATA_2
                      );

type regaccess_state is record
  state                : regacc_state;
  cnt                  : std_logic_vector(10 downto 0);
  get_data             : std_logic_vector(15 downto 0);
  accum_cksum          : std_logic;
  wcksum               : std_logic_vector(16 downto 0);
end record regaccess_state;

type regacc_off_update is (ROU_RESET,
                           ROU_NONE,
                           ROU_INCREASE,
                           ROU_RESTORE
                           );

type regaccess_async_state is record
  next_state           : regacc_state;
  latch_data           : regacc_latch;
  latch_done           : std_logic;
  reset_read           : std_logic;
  wdata                : std_logic_vector(15 downto 0);
  reset                : std_logic;
  off_update           : regacc_off_update;
  off_store            : std_logic;
  wr                   : std_logic;
  issue_read           : std_logic;
  issue_write          : std_logic;
  done                 : std_logic;
  next_accum_cksum     : std_logic;
  wudpcksum            : std_logic;
end record regaccess_async_state;

type tcp_prep_state is (PSM_IDLE,
                        PSM_FIRST,
                        PSM_HEADER_0,
                        PSM_HEADER_2,
                        PSM_HEADER_4,
                        PSM_HEADER_6,
                        PSM_HEADER_8,
                        PSM_HEADER_10,
                        PSM_HEADER_12,
                        PSM_IPV4_14,
                        PSM_IPV4_16,
                        PSM_IPV4_18,
                        PSM_IPV4_20,
                        PSM_IPV4_22,
                        PSM_IPV4_24,
                        PSM_IPV4_26,
                        PSM_IPV4_28,
                        PSM_IPV4_30,
                        PSM_IPV4_32,
                        PSM_IPV4_CK1,
                        PSM_IPV4_CK2,
                        PSM_IPV4_CK3,
                        PSM_PSTCP_LEN,
                        PSM_PSTCP_26,
                        PSM_PSTCP_28,
                        PSM_PSTCP_30,
                        PSM_PSTCP_32,
                        PSM_TCP_34,
                        PSM_TCP_36,
                        PSM_TCP_38,
                        PSM_TCP_40,
                        PSM_TCP_42,
                        PSM_TCP_44,
                        PSM_TCP_46,
                        PSM_TCP_48,
                        PSM_TCP_50,
                        PSM_TCP_52,
                        PSM_DATA,
                        PSM_PAD,
                        PSM_CK1,
                        PSM_CK2,
                        PSM_CK3,
                        PSM_DONE
                        );

-- TODO: combine elements in async state that are common?  into new record
type tcp_prepare_state is record
  state                : tcp_prep_state;
  get_data             : std_logic_vector(15 downto 0);
  accum_cksum          : std_logic;
  wcksum               : std_logic_vector(16 downto 0);
  payload_len          : std_logic_vector(10 downto 0);
  cur_address          : std_logic_vector(16 downto 0);
  drd                  : std_logic;
  drd_address          : std_logic_vector(31 downto 0);
  drd_rdata            : std_logic_vector(31 downto 0);
  payload_limited      : std_logic;
  repeat               : std_logic;
  keepalive            : std_logic;
  packet_count         : std_logic_vector(7 downto 0);
end record tcp_prepare_state;

type preptcp_off_update is (POU_RESET,
                            POU_NONE,
                            POU_INCREASE,
                            POU_SET_26
                            );

type tcp_prepare_async_state is record
  next_state           : tcp_prep_state;

  wdata                : std_logic_vector(15 downto 0);
  reset                : std_logic;
  off_update           : preptcp_off_update;
  off_store            : std_logic;
  wr                   : std_logic;
  early_done           : std_logic;
  no_discard           : std_logic;
  done                 : std_logic;
  next_accum_cksum     : std_logic;
  cipcksum             : std_logic;
  wipcksum             : std_logic;
  ctcpcksum            : std_logic;
  wtcpcksum            : std_logic;
  payload_len          : std_logic_vector(10 downto 0);
  cur_address          : std_logic_vector(16 downto 0);
  drd                  : std_logic;
  drd_address          : std_logic_vector(31 downto 0);
  payload_limited      : std_logic;
  repeat               : std_logic;
  keepalive            : std_logic;
end record tcp_prepare_async_state;

type ram_block_porti_a11d16 is record
  rdata  : std_logic_vector(15 downto 0);
end record ram_block_porti_a11d16;

type ram_block_porto_a11d16 is record
  addr   : std_logic_vector(10 downto 1);
  rd     : std_logic;
  wr     : std_logic;
  wdata  : std_logic_vector(15 downto 0);
end record ram_block_porto_a11d16;

constant rbpi_zero : ram_block_porti_a11d16 :=
  (rdata => (others => '0'));
constant rbpo_zero : ram_block_porto_a11d16 :=
  (wdata => (others => '0'),
   addr => (others => '0'),
   rd => '0', wr => '0');

type ram_block_port_a11d16 is record
  i : ram_block_porti_a11d16;
  o : ram_block_porto_a11d16;
end record ram_block_port_a11d16;

constant rbp_zero : ram_block_port_a11d16 :=
  (i => rbpi_zero,
   o => rbpo_zero);

type dp_ram_block_a11d16 is record
  port_a     : ram_block_port_a11d16;
  port_b     : ram_block_port_a11d16;
end record dp_ram_block_a11d16;

constant dp_ram_zero : dp_ram_block_a11d16 :=
  (port_a => rbp_zero,
   port_b => rbp_zero);

type ram_stat_block is record
  hasdata   : std_logic;
  broadcast : std_logic;
  drop_dly  : std_logic;
  words     : std_logic_vector(10 downto 0);
end record ram_stat_block;

type ram_prod_block is record
  set_hasdata   : std_logic;
  set_broadcast : std_logic; -- Not used (was used for ARP->RARP gen.).
  set_drop_dly  : std_logic;
  set_words     : std_logic_vector(10 downto 0);
end record ram_prod_block;

type ram_prod2_block is record
  set_again   : std_logic;
end record ram_prod2_block;

type ram_cons_block is record
  clear_hasdata : std_logic;
end record ram_cons_block;

type ram_block is record
  stat  : ram_stat_block;
  prod  : ram_prod_block;
  prod2 : ram_prod2_block;
  cons  : ram_cons_block;
end record ram_block;

type integer_array is array (integer range <>) of integer;

type ram_block_array is
  array (integer range <>) of ram_block;
type dp_ram_block_a11d16_array is
  array (integer range <>) of dp_ram_block_a11d16;

type ram_block_porti_a11d16_array is
  array (integer range <>) of ram_block_porti_a11d16;
type ram_block_porto_a11d16_array is
  array (integer range <>) of ram_block_porto_a11d16;

type ram_stat_block_array is
  array (integer range <>) of ram_stat_block;
type ram_cons_block_array is
  array (integer range <>) of ram_cons_block;
type ram_prod_block_array is
  array (integer range <>) of ram_prod_block;
type ram_prod2_block_array is
  array (integer range <>) of ram_prod2_block;

type regacc_aux_stat is record
  reg_idp       : std_logic;
  reg_ch        : integer range 0 to NUM_REG_CH-1;
  end_words     : std_logic_vector(10 downto 0);
  checksum      : std_logic_vector(16 downto 0);
end record regacc_aux_stat;

type regacc_aux_prod is record
  set_reg_ch    : std_logic;
  set_end_words : std_logic;
  set_checksum  : std_logic;
  v             : regacc_aux_stat;
end record regacc_aux_prod;

type regacc_aux is record
  stat : regacc_aux_stat;
  prod : regacc_aux_prod;
end record regacc_aux;

type tcp_buffer_stat is record
  -- Base of next address to be filled.
  -- Note! Not all bits are used.  Only those as given by the
  -- generic module parameters requested actual buffer size (+1).
  base_fill : std_logic_vector(31 downto 0);

  commit_overrun : std_logic;
  write_overrun  : std_logic;

end record tcp_buffer_stat;

type tcp_conn_state is (CLOSED,       -- Waiting for connection attempt
                        SYN_RECEIVED, -- Got SYN
                        SYN_SENT,     -- Sent ACK/SYN
                        CONNECTED     -- Got ACK
                        );

type tcp_control_stat is record
  -- Current base location (lower bits give actual memory address).
  base_seqno : std_logic_vector(31 downto 0);
  -- How far have we sent data at all (relative to base).
  -- When high bit does not match base, means we are in the next 'page'.
  max_sent   : std_logic_vector(16 downto 0);
  -- How large is current window of the the receiver, reported by peer.
  window_sz  : std_logic_vector(15 downto 0);

  rtt_trip   : std_logic_vector(16 downto 0);

  rtt_est    : std_logic_vector(11 downto 0);

  -- TODO: check these!
  -- We have that: 0 <= cur_sent <= num_sent <= num_avail
  -- And unless the receiving end reduces the window: num_sent <= window_sz

  -- We provide to the filler how much data space is available to be
  -- filled.  This can never decrease more than how much data is
  -- provided by the filler.
  --num_free   : std_logic_vector(23 downto 0);

  -- Counter of ACKs for same position received.
  same_ack   : std_logic_vector(1 downto 0);

  -- Is TCP stream currently connected?
  conn_state : tcp_conn_state;
end record tcp_control_stat;

type tcp_state_async_stat is record
  base_seqno_hi_plus_1 : std_logic_vector(15 downto 0);

  cur_off   : std_logic_vector(15 downto 0);

  filled    : std_logic_vector(31 downto 0);
  unsent    : std_logic_vector(31 downto 0);
  unfilled  : std_logic_vector(31 downto 0);

  some_sent : std_logic;
end record tcp_state_async_stat;

type tcp_control_recv is record
  ack_seqno    : std_logic_vector(16 downto 0);
  window_len   : std_logic_vector(15 downto 0);
  got_ack      : std_logic;
  got_syn      : std_logic;
end record tcp_control_recv;

constant tcp_sr_zero : tcp_control_recv :=
  (ack_seqno => (others => '0'),
   window_len => (others => '0'),
   got_ack => '0', got_syn => '0');

type tcp_packet_req is record
  send_syn       : std_logic;
  send_data      : std_logic;
  send_small     : std_logic;
  send_repeat    : std_logic; -- Note: send_data must also be set.
  send_keepalive : std_logic;
  -- In case the pointers moved, we must discard the ongoing packet.
  -- Otherwise we might deliver wrong data.  (Packet anyhow needs
  -- not be sent.)
  discard_cur_prepare : std_logic;
end record tcp_packet_req;

type tcp_packet_done is record
  done            : std_logic;
  payload_limited : std_logic;
  repeated        : std_logic;
  keepalive       : std_logic;
  cur_address     : std_logic_vector(16 downto 0);
end record tcp_packet_done;

type tcp_control_info_counts is record
  did_repeat      : std_logic;
  did_keepalive   : std_logic;
  got_syn         : std_logic;
  got_ack         : std_logic;
  same_ack        : std_logic;
  twice_same_ack  : std_logic;
  abort_repeat    : std_logic;
  connect         : std_logic;
  start_meas_rtt  : std_logic;
  got_meas_rtt    : std_logic;
  new_rtt_est     : std_logic;
end record tcp_control_info_counts;

constant tsic_zero : tcp_control_info_counts :=
  (did_repeat => '0',
   did_keepalive => '0',
   got_syn => '0',
   got_ack => '0',
   same_ack => '0',
   twice_same_ack => '0',
   abort_repeat => '0',
   connect => '0',
   start_meas_rtt => '0',
   got_meas_rtt => '0',
   new_rtt_est => '0');

type mdio_sm_state is (MSM_IDLE,
                       MSM_CHECK_REQUEST,
                       MSM_PREAMBLE,
                       MSM_PERFORM,
                       MSM_PERFORM_READ,
                       MSM_RESPOND,
                       MSM_WAIT);

type mdio_state is record
  state                : mdio_sm_state;
  active_a             : std_logic;
end record mdio_state;

type mdio_async_state is record
  next_state           : mdio_sm_state;
  active_a             : std_logic;
  do_take_request      : std_logic;
  do_sample            : std_logic;
  do_done              : std_logic;
  do_fail              : std_logic;
  mdc_ena              : std_logic;
  mdc_out              : std_logic;
  mdio_ena             : std_logic;
  mdio_out             : std_logic;
end record mdio_async_state;

type dync_in_stat is record
  any_arp              : std_logic;
  good_rarp            : std_logic;
  good_bootp           : std_logic;
  good_dhcp_offer      : std_logic;
  good_dhcp_ack        : std_logic;
  good_ntpr            : std_logic;

  offer_ip             : std_logic_vector(31 downto 0);
  offer_serv_ip        : std_logic_vector(31 downto 0);
end record dync_in_stat;

type dync_gen_stat is record
  gen_rarp             : std_logic;
  gen_bootp            : std_logic;
  gen_dhcp_disc        : std_logic;
  gen_dhcp_req         : std_logic;
  gen_ntp_query        : std_logic;
  gen_mon              : std_logic;
end record dync_gen_stat;

constant dgs_zero : dync_gen_stat :=
  (gen_rarp => '0',
   gen_bootp => '0',
   gen_dhcp_disc => '0',
   gen_dhcp_req => '0',
   gen_ntp_query => '0',
   gen_mon => '0');

type dync_control_stat is record
  dyn_ip               : std_logic_vector (31 downto 0);
  dyn_ip_set           : std_logic;

  pending_rarp         : std_logic;
  pending_bootp        : std_logic;
  pending_dhcp_disc    : std_logic;
  pending_dhcp_req     : std_logic;

  expect_rarp_resp     : std_logic;
  expect_bootp_resp    : std_logic;
  expect_dhcp_offer    : std_logic;
  expect_dhcp_ack      : std_logic;

  bootp_xid            : std_logic_vector(31 downto 0);
  dhcp_xid             : std_logic_vector(31 downto 0);
  dhcp_offer_ip        : std_logic_vector(31 downto 0);
  dhcp_offer_serv_ip   : std_logic_vector(31 downto 0);
end record dync_control_stat;

type ntpq_control_stat is record
  pending_ntp_query    : std_logic;
  block_non_ntpq       : std_logic;

  ntpq_mac             : std_logic_vector(47 downto 0);
  ntpq_ip              : std_logic_vector(31 downto 0);
  ntpq_tm              : std_logic_vector(63 downto 0);
end record ntpq_control_stat;

type mon_control_stat is record
  pending_mon          : std_logic;

  mon_mac              : std_logic_vector(47 downto 0);
  mon_ip               : std_logic_vector(31 downto 0);
  mon_port             : std_logic_vector(15 downto 0);
end record mon_control_stat;

constant dis_zero : dync_in_stat :=
  (any_arp         => '0',
   good_rarp       => '0',
   good_bootp      => '0',
   good_dhcp_offer => '0',
   good_dhcp_ack   => '0',
   good_ntpr       => '0',
   offer_ip        => (others => '0'),
   offer_serv_ip   => (others => '0'));

type ntp_state is record
  leap                 : std_logic_vector(1 downto 0);
  stratum              : std_logic_vector(7 downto 0);
  precision            : std_logic_vector(7 downto 0);
  root_delay           : std_logic_vector(31 downto 0);
  root_dispersion      : std_logic_vector(31 downto 0);
  reference_id         : std_logic_vector(31 downto 0);
  reference_ts         : std_logic_vector(63 downto 0);
  cur_ts               : std_logic_vector(63 downto 0);
end record ntp_state;

constant ntp_state_zero : ntp_state :=
  (leap => "11",
   stratum => (others => '0'),
   precision => (others => '0'),
   root_delay => (others => '0'),
   root_dispersion => (others => '0'),
   reference_id => (others => '0'),
   reference_ts => (others => '0'),
   cur_ts => (others => '0'));

type word32_array is
  array (integer range <>) of std_logic_vector(31 downto 0);
type word64_array is
  array (integer range <>) of std_logic_vector(63 downto 0);

end fnet_records;
