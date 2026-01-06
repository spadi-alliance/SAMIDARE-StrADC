-- Copyright (C) 2020, Haakan T. Johansson
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


use work.fnet_util_pkg.all;

use work.fnet_records.all;

entity fakernet_module is
  generic (data_bufsize_addrbits : natural;
           test_regs            : boolean := true;
           lcl_data_gen         : boolean := true;
           limit_payload_window : boolean := true;
           debug_regs           : boolean := true;
           debug_counters       : boolean := true;
           compiletime          : integer := 2;
           description          : string  := "");
  port (clk            : in  std_logic;
        clk125            : in  std_logic;
        --countdebug          : out unsigned(7 downto 0);
        statedebug          : out std_logic_vector(19 downto 0) := (others => '0');
        -- Config
        cfg_macaddr    : in  std_logic_vector (47 downto 0);
        cfg_ipaddr     : in  std_logic_vector (31 downto 0);
        cfg_fixed_ip   : in  std_logic := '1';
        cfg_dyn_ip     : in  std_logic := '0';
        cfg_gen_rarp   : in  std_logic := '0';
        cfg_gen_bootp  : in  std_logic := '0';
        cfg_gen_dhcp   : in  std_logic := '0';
        cfg_gen_ntpq   : in  std_logic := '0';
        cfg_gen_mon    : in  std_logic := '0';
        -- Monitor destination.
        mon_macaddr    : in  std_logic_vector (47 downto 0) := (others => '0');
        mon_ipaddr     : in  std_logic_vector (31 downto 0) := (others => '0');
        mon_udp_port   : in  std_logic_vector (15 downto 0) := (others => '0');
        -- Report state
        dyn_ip         : out std_logic_vector (31 downto 0) := (others => '0');
        dyn_ip_set     : out std_logic;
        -- Input network traffic
        in_word        : in  std_logic_vector(15 downto 0);
        in_got_word    : in  std_logic;
        in_new_packet  : in  std_logic;
        -- Output network traffic
        out_word       : out std_logic_vector(15 downto 0);
        out_ena        : out std_logic;
        out_payload    : out std_logic;
        out_taken      : in  std_logic;
        out_block      : in  std_logic := '0';
        -- MIDO interface
        mdc_out        : out std_logic;
        mdc_ena        : out std_logic;
        mdio_in        : in  std_logic;
        mdio_out       : out std_logic;
        mdio_ena       : out std_logic;
        -- Register access interface
        reg_addr       : out std_logic_vector(24 downto 0);
        reg_data_wr    : out std_logic_vector(31 downto 0);
        reg_data_rd    : in  std_logic_vector(31 downto 0);
        reg_write      : out std_logic;
        reg_read       : out std_logic;
        reg_done       : in  std_logic;
        reg_cnt        : out std_logic_vector(3 downto 0);
        -- Data input interface
        data_word      : in  std_logic_vector(31 downto 0);
        data_offset    : in  std_logic_vector;
        data_write     : in  std_logic;
        data_commit_len: in  std_logic_vector;
        data_commit    : in  std_logic;
        data_free      : out std_logic;
        tcp_reset      : out std_logic;
        -- NTP time (to deliver)
        ntp_leap       : in  std_logic_vector(1 downto 0) := "11";
        ntp_prec       : in  std_logic_vector(7 downto 0) := (others => '1');
        ntp_root_delay : in  std_logic_vector(31 downto 0) := (others => '1');
        ntp_root_disp  : in  std_logic_vector(31 downto 0) := (others => '1');
        ntp_cur_ts     : in  std_logic_vector(63 downto 0) := (others => '0');
        ntp_ref_ts     : in  std_logic_vector(63 downto 0) := (others => '0');
        -- NTP query (packet generation)
        ntpq_req       : in  std_logic := '0';
        ntpq_mac       : in  std_logic_vector(47 downto 0) := (others => '0');
        ntpq_ip        : in  std_logic_vector(31 downto 0) := (others => '0');
        ntpq_tm_hi     : in  std_logic_vector(31 downto 0) := (others => '0');
        ntpq_tm_lo     : out std_logic_vector(31 downto 0);
        ntpq_sent      : out std_logic;
        -- NTP response (incoming)
        ntpr_got       : out std_logic;
        ntpr_ip        : out std_logic_vector(31 downto 0);
        ntpr_recv_ts   : out std_logic_vector(63 downto 0);
        ntpr_data      : out word32_array(0 to 11);
        -- Ticker, to be ~2-20 times per max length packet send period.
        -- I.e. ~ 500-5000 ns @ 1 Gbps.  The internal counters are
        -- wide enough to then also handle 10 Mbps, with good margin.
        -- Assuming 100 MHz clock and 5 times per packet, it should
        -- tick every 200 clock cycles.  256 is just as fine!
        slow_clock_tick     : in std_logic;
        -- After two timeout ticks, UDP connections can be reset.
        -- Suggested to be on the order of a second.
        timeout_tick        : in std_logic;
        -- Control (should be a constant, but used in testbench)
        max_packet_payload  : in integer := 1440; -- Do not go above 1440!
        -- Debug
        debug_in_info_counts  : out incoming_info_counts;
        debug_out_info_counts : out outgoing_info_counts;
        debug_state_in      : out std_logic_vector(7 downto 0);
        debug_state_out     : out std_logic_vector(3 downto 0);
        debug_state_regacc  : out std_logic_vector(4 downto 0);
        debug_state_preptcp : out std_logic_vector(5 downto 0)
        );
end;


architecture RTL of fakernet_module is

  signal ram_arp_icmp     : ram_block;
  signal ram_pkt_gen      : ram_block;
  signal ram_udp_regacc   : ram_block;
  signal ram_udp_regidp   : ram_block;
  signal ram_udp_regres   : ram_block_array(0 to NUM_REG_CH-1);
  signal ram_tcp_template : ram_block;
  signal ram_tcp_prep2    : ram_block_array(0 to 1);

  signal ram_udp_regres_stat_tmp : ram_stat_block_array(0 to NUM_REG_CH-1);
  signal ram_udp_regres_cons_tmp : ram_cons_block_array(0 to NUM_REG_CH-1);
  signal ram_udp_regres_prod_tmp : ram_prod_block_array(0 to NUM_REG_CH-1);
  signal ram_udp_regres_prod2_tmp : ram_prod2_block_array(0 to NUM_REG_CH-1);

  signal dp_ram_arp_icmp   : dp_ram_block_a11d16 := dp_ram_zero;
  signal dp_ram_pkt_gen    : dp_ram_block_a11d16 := dp_ram_zero;
  signal dp_ram_udp_regacc : dp_ram_block_a11d16 := dp_ram_zero;
  signal dp_ram_udp_regidp : dp_ram_block_a11d16 := dp_ram_zero;
  signal dp_ram_udp_regres : dp_ram_block_a11d16_array(0 to NUM_REG_CH-1) :=
    (others => dp_ram_zero);
  signal dp_ram_tcp_template : dp_ram_block_a11d16 := dp_ram_zero;
  signal dp_ram_tcp_prep2  : dp_ram_block_a11d16_array(0 to 1) :=
    (others => dp_ram_zero);

  signal dp_ram_udp_regres_port_a_i_tmp : ram_block_porti_a11d16_array(0 to NUM_REG_CH-1);
  signal dp_ram_udp_regres_port_a_o_tmp : ram_block_porto_a11d16_array(0 to NUM_REG_CH-1);
  signal dp_ram_udp_regres_port_b_i_tmp : ram_block_porti_a11d16_array(0 to NUM_REG_CH-1);
  signal dp_ram_udp_regres_port_b_o_tmp : ram_block_porto_a11d16_array(0 to NUM_REG_CH-1);

  signal osm_ram_stat_array   : ram_stat_block_array(0 to OR_NUM-1);
  signal osm_ram_cons_array   : ram_cons_block_array(0 to OR_NUM-1);
  signal osm_dp_ram_array_porti : ram_block_porti_a11d16_array(0 to OR_NUM-1);
  signal osm_dp_ram_array_porto : ram_block_porto_a11d16_array(0 to OR_NUM-1);

  signal in_info_counts  : incoming_info_counts;
  signal out_info_counts : outgoing_info_counts;
  signal ts_info_counts  : tcp_control_info_counts;

  signal regacc_aux_info : regacc_aux;

  signal reg_int_addr    : std_logic_vector(24 downto 0);
  signal reg_int_data_wr : std_logic_vector(31 downto 0);
  signal reg_int_data_rd : std_logic_vector(31 downto 0);
  signal reg_int_write   : std_logic;
  signal reg_int_read    : std_logic;
  signal reg_int_done    : std_logic;
  signal reg_int_cnt     : std_logic_vector(3 downto 0);

  -- MDIO access via local register.
  signal mdio_a_req_data  : std_logic_vector(31 downto 0);
  signal mdio_a_request   : std_logic;
  signal mdio_a_resp_data : std_logic_vector(17 downto 0);
  signal mdio_a_response  : std_logic;

  -- Packet generation requests.
  signal dyn_ctrl_in_stat  : dync_in_stat;
  signal dyn_ctrl_gen_stat : dync_gen_stat;
  signal dyn_ctrl_stat  : dync_control_stat;
  signal ntpq_ctrl_stat : ntpq_control_stat;
  signal mon_ctrl_stat : mon_control_stat;

  signal tcp_ctrl_recv : tcp_control_recv;

  signal tcp_ctrl_stat : tcp_control_stat;
  signal tcp_buf_stat  : tcp_buffer_stat;

  signal tcp_state_stat : tcp_state_async_stat;

  signal packet_req   : tcp_packet_req;
  signal packet_done  : tcp_packet_done;

  signal drive_lfsr   : std_logic;

  -- Note: this is not sent to the tcp prepare or output state machines.
  -- Whatever packets were already prepared are finished.  To not loose
  -- lock between the two buffers.
  signal int_tcp_reset : std_logic;

  constant addrbits : natural := data_bufsize_addrbits;
  constant databits : natural := 32;

  signal data_port_a_addr  : std_logic_vector(addrbits-1 downto 0);
  signal data_port_a_rd    : std_logic;
  signal data_port_a_wr    : std_logic;
  signal data_port_a_wdata : std_logic_vector(databits-1 downto 0);
  signal data_port_a_rdata : std_logic_vector(databits-1 downto 0);

  signal data_port_b_addr  : std_logic_vector(addrbits-1 downto 0);
  signal data_port_b_rd    : std_logic;
  signal data_port_b_rdata : std_logic_vector(databits-1 downto 0);

  -- For decoupling the output.
  signal out_r_word    : std_logic_vector(15 downto 0);
  signal out_r_ena     : std_logic;
  signal out_r_payload : std_logic;
  signal out_r_taken   : std_logic;

  -- Internal testing
  signal tc_limit_tcp_payload : std_logic_vector(10 downto 0);
  signal tc_limit_tcp_window  : std_logic_vector(15 downto 0);

  signal tc_do_lcl_datagen       : std_logic;
  signal tc_lcl_datagen_chance   : std_logic_vector(31 downto 0);
  signal tc_lcl_datagen_len_mask : std_logic_vector(15 downto 0);
  signal tc_lcl_datagen_mark     : std_logic_vector( 3 downto 0);

  signal lcl_datagen_write      : std_logic;
  signal lcl_datagen_word       : std_logic_vector(31 downto 0);
  signal lcl_datagen_offset     : std_logic_vector(7 downto 0);
  signal lcl_datagen_commit     : std_logic;
  signal lcl_datagen_commit_len : std_logic_vector(5 downto 0);
  signal lcl_datagen_free       : std_logic;

  -- NTP system
  signal ntp_stat : ntp_state := ntp_state_zero;


Component ila_0 is 
port (
clk : in std_logic;
probe0 : in std_logic_vector(199 downto 0)
);
end Component;

  signal cc0   : std_logic_vector(49 downto 0) := (others => '0');
  signal cc1   : std_logic_vector(49 downto 0) := (others => '0');

begin

  ram_arp_icmp.prod2.set_again <= '0';
  ram_pkt_gen.prod2.set_again <= '0';
  ram_udp_regacc.prod2.set_again <= '0';

  tmp_NUM_REG_CH : for i in 0 to NUM_REG_CH-1 generate
    ram_udp_regres_stat_tmp(i) <= ram_udp_regres(i).stat;
    ram_udp_regres(i).cons <= ram_udp_regres_cons_tmp(i);
    ram_udp_regres(i).prod  <= ram_udp_regres_prod_tmp(i);
    ram_udp_regres(i).prod2 <= ram_udp_regres_prod2_tmp(i);

    dp_ram_udp_regres_port_a_i_tmp(i) <= dp_ram_udp_regres(i).port_a.i;
    dp_ram_udp_regres(i).port_a.o <= dp_ram_udp_regres_port_a_o_tmp(i);
    dp_ram_udp_regres_port_b_i_tmp(i) <= dp_ram_udp_regres(i).port_b.i;
    dp_ram_udp_regres(i).port_b.o <= dp_ram_udp_regres_port_b_o_tmp(i);
  end generate;

  ntp_stat.stratum         <= std_logic_vector(to_unsigned(1,8));
  ntp_stat.precision       <= ntp_prec;
  ntp_stat.root_delay      <= ntp_root_delay;
  ntp_stat.root_dispersion <= ntp_root_disp;
  ntp_stat.reference_id    <= std_logic_vector(to_unsigned(16#47505300#,
                                                           32)); -- GPS
  ntp_stat.leap            <= ntp_leap;
  ntp_stat.reference_ts    <= ntp_ref_ts;
  ntp_stat.cur_ts          <= ntp_cur_ts;

  in_sm: entity work.fnet_in_state
    port map (
      clk             => clk,
      --
      in_word         => in_word,
      in_got_word     => in_got_word,
      in_new_packet   => in_new_packet,
      --
      cfg_macaddr     => cfg_macaddr,
      cfg_ipaddr      => cfg_ipaddr,
      cfg_fixed_ip    => cfg_fixed_ip,
      cfg_dyn_ip      => cfg_dyn_ip,
      cfg_gen_rarp    => cfg_gen_rarp,
      cfg_gen_bootp   => cfg_gen_bootp,
      cfg_gen_dhcp    => cfg_gen_dhcp,
      cfg_gen_ntpq    => cfg_gen_ntpq,
      --
      slow_clock_tick => slow_clock_tick,
      timeout_tick    => timeout_tick,
      --
      tcp_reset       => int_tcp_reset,
      --
      tcp_stat        => tcp_ctrl_stat,
      tcp_buf_stat    => tcp_buf_stat,
      tcp_astat       => tcp_state_stat,
      tcp_recv        => tcp_ctrl_recv,
      --
      ntp_stat        => ntp_stat,
      --
      ntpr_got        => ntpr_got,
      ntpr_ip         => ntpr_ip,
      ntpr_recv_ts    => ntpr_recv_ts,
      ntpr_data       => ntpr_data,
      --
      dyn_in_stat     => dyn_ctrl_in_stat,
      dyn_ctrl_stat   => dyn_ctrl_stat,
      --
      ram_stat_arp_icmp    => ram_arp_icmp.stat,
      ram_stat_udp_regacc  => ram_udp_regacc.stat,
      ram_stat_udp_regidp  => ram_udp_regidp.stat,
      ram_stat_udp_regres  => ram_udp_regres_stat_tmp,
      ram_stat_tcp_template => ram_tcp_template.stat,
      ram_prod_arp_icmp    => ram_arp_icmp.prod,
      ram_prod_udp_regacc  => ram_udp_regacc.prod,
      ram_prod2_udp_regres => ram_udp_regres_prod2_tmp,
      ram_prod_tcp_template   => ram_tcp_template.prod,
      dp_ram_arp_icmp_porti   => dp_ram_arp_icmp.port_a.i,
      dp_ram_arp_icmp_porto   => dp_ram_arp_icmp.port_a.o,
      dp_ram_udp_regacc_porti => dp_ram_udp_regacc.port_a.i,
      dp_ram_udp_regacc_porto => dp_ram_udp_regacc.port_a.o,
      dp_ram_tcp_template_porti  => dp_ram_tcp_template.port_a.i,
      dp_ram_tcp_template_porto  => dp_ram_tcp_template.port_a.o,
      regacc_prod_aux => regacc_aux_info.prod,
      --
      info_counts     => in_info_counts,
      --
      debug_state     => debug_state_in
      );

  debug_in_info_counts <= in_info_counts;

  osm_ram_stat_array(OR_ICMP)     <= ram_arp_icmp.stat;
  ram_arp_icmp.cons               <= osm_ram_cons_array(OR_ICMP);
  osm_dp_ram_array_porti(OR_ICMP) <= dp_ram_arp_icmp.port_b.i;
  dp_ram_arp_icmp.port_b.o        <= osm_dp_ram_array_porto(OR_ICMP);

  osm_ram_stat_array(OR_UDP_IDP)     <= ram_udp_regidp.stat;
  ram_udp_regidp.cons                  <= osm_ram_cons_array(OR_UDP_IDP);
  osm_dp_ram_array_porti(OR_UDP_IDP) <= dp_ram_udp_regidp.port_b.i;
  dp_ram_udp_regidp.port_b.o           <= osm_dp_ram_array_porto(OR_UDP_IDP);

  osm_NUM_REG_CH : for i in 0 to NUM_REG_CH-1 generate
    osm_ram_stat_array(OR_UDP+i)      <= ram_udp_regres_stat_tmp(i);
    ram_udp_regres_cons_tmp(i)        <= osm_ram_cons_array(OR_UDP+i);
    osm_dp_ram_array_porti(OR_UDP+i)  <= dp_ram_udp_regres_port_b_i_tmp(i);
    dp_ram_udp_regres_port_b_o_tmp(i) <= osm_dp_ram_array_porto(OR_UDP+i);
  end generate;

  -- Order important:
  -- The TCP packets are last, as they are sent with lowest priority.
  -- They could otherwise starve the connectionfor other packet types.
  osm_NUM_TCP : for i in 0 to 1 generate
    osm_ram_stat_array(OR_TCP+i)     <= ram_tcp_prep2(i).stat;
    ram_tcp_prep2(i).cons            <= osm_ram_cons_array(OR_TCP+i);
    osm_dp_ram_array_porti(OR_TCP+i) <= dp_ram_tcp_prep2(i).port_b.i;
    dp_ram_tcp_prep2(i).port_b.o     <= osm_dp_ram_array_porto(OR_TCP+i);
  end generate;

  -- Drive the LFSR by some input data packet input bit.
  drive_lfsr <= in_word(2) and in_got_word;

  dyn_ctrl: entity work.fnet_dyn_control
    port map (
      clk             => clk,
      --
      cfg_gen_rarp    => cfg_gen_rarp,
      cfg_gen_bootp   => cfg_gen_bootp,
      cfg_gen_dhcp    => cfg_gen_dhcp,
      --
      in_stat         => dyn_ctrl_in_stat,
      gen_stat        => dyn_ctrl_gen_stat,
      stat            => dyn_ctrl_stat,
      --
      drive_lfsr      => drive_lfsr,
      timeout_tick    => timeout_tick
      );

  dyn_ip     <= dyn_ctrl_stat.dyn_ip;
  dyn_ip_set <= dyn_ctrl_stat.dyn_ip_set;

  ntpq_ctrl: entity work.fnet_ntp_query_control
    port map (
      clk             => clk,
      --
      cfg_gen_ntpq    => cfg_gen_ntpq,
      --
      ntpq_req        => ntpq_req,
      ntpq_mac        => ntpq_mac,
      ntpq_ip         => ntpq_ip,
      ntpq_tm_hi      => ntpq_tm_hi,
      ntpq_tm_lo      => ntpq_tm_lo,
      ntpq_sent       => ntpq_sent,
      --
      in_stat         => dyn_ctrl_in_stat,
      gen_stat        => dyn_ctrl_gen_stat,
      stat            => ntpq_ctrl_stat,
      --
      timeout_tick    => timeout_tick
      );

  mon_ctrl: entity work.fnet_mon_pkt_control
    port map (
      clk             => clk,
      --
      cfg_gen_mon     => cfg_gen_mon,
      --
      mon_mac         => mon_macaddr,
      mon_ip          => mon_ipaddr,
      mon_port        => mon_udp_port,
      --
      in_stat         => dyn_ctrl_in_stat,
      gen_stat        => dyn_ctrl_gen_stat,
      stat            => mon_ctrl_stat,
      --
      timeout_tick    => timeout_tick
      );

  pkt_gen: entity work.fnet_packet_gen
    port map (
      clk             => clk,
      --
      cfg_macaddr     => cfg_macaddr,
      cfg_ipaddr      => cfg_ipaddr,
      --
      dyn_gen_stat    => dyn_ctrl_gen_stat,
      dyn_ctrl_stat   => dyn_ctrl_stat,
      ntpq_ctrl_stat  => ntpq_ctrl_stat,
      mon_ctrl_stat   => mon_ctrl_stat,
      --
      ram_stat_pkt_gen    => ram_pkt_gen.stat,
      ram_prod_pkt_gen    => ram_pkt_gen.prod,
      ram_cons_pkt_gen    => ram_pkt_gen.cons,
      dp_ram_pkt_gen_porti   => dp_ram_pkt_gen.port_a.i,
      dp_ram_pkt_gen_porto   => dp_ram_pkt_gen.port_a.o
      );

  osm_ram_stat_array(OR_PKT_GEN)     <= ram_pkt_gen.stat;
  ram_pkt_gen.cons                   <= osm_ram_cons_array(OR_PKT_GEN);
  osm_dp_ram_array_porti(OR_PKT_GEN) <= dp_ram_pkt_gen.port_b.i;
  dp_ram_pkt_gen.port_b.o            <= osm_dp_ram_array_porto(OR_PKT_GEN);

  out_sm: entity work.fnet_out_state
    port map (
      clk             => clk,
      --
      out_word        => out_r_word,
      out_ena         => out_r_ena,
      out_payload     => out_r_payload,
      out_taken       => out_r_taken,
      --
      timeout_tick    => timeout_tick,
      --
      ram_stat_array  => osm_ram_stat_array,
      ram_cons_array  => osm_ram_cons_array,
      dp_ram_array_porti => osm_dp_ram_array_porti,
      dp_ram_array_porto => osm_dp_ram_array_porto,
      --
      idx_tcp_prep(0) => OR_TCP,
      idx_tcp_prep(1) => OR_TCP+1,
      tcp_related     => open,
      --
      idx_gen         => OR_PKT_GEN,
      block_non_gen   => ntpq_ctrl_stat.block_non_ntpq,
      --
      block_any       => out_block,
      --
      info_counts     => out_info_counts,
      --
      debug_state     => debug_state_out
      );

  debug_out_info_counts <= out_info_counts;

  out_pl: entity work.fnet_out_pipeline
    port map (
      clk             => clk,
      --
      out_r_word      => out_r_word,
      out_r_ena       => out_r_ena,
      out_r_payload   => out_r_payload,
      out_r_taken     => out_r_taken,
      --
      out_word        => out_word,
      out_ena         => out_ena,
      out_payload     => out_payload,
      out_taken       => out_taken
      );

  -- out_word      <= out_r_word;
  -- out_ena       <= out_r_ena;
  -- out_payload   <= out_r_payload;
  -- out_r_taken   <= out_taken;

  regacc: entity work.fnet_regaccess
    port map (
      clk            => clk,
      --
      regacc_addr    => reg_addr,
      regacc_data_wr => reg_data_wr,
      regacc_data_rd => reg_data_rd,
      regacc_write   => reg_write,
      regacc_read    => reg_read,
      regacc_done    => reg_done,
      regacc_cnt     => reg_cnt,
      --
      regacc_int_addr    => reg_int_addr,
      regacc_int_data_wr => reg_int_data_wr,
      regacc_int_data_rd => reg_int_data_rd,
      regacc_int_write   => reg_int_write,
      regacc_int_read    => reg_int_read,
      regacc_int_done    => reg_int_done,
      regacc_int_cnt     => reg_int_cnt,
      --
      ram_stat_udp_regacc => ram_udp_regacc.stat,
      ram_stat_udp_regidp => ram_udp_regidp.stat,
      ram_stat_udp_regres => ram_udp_regres_stat_tmp,
      ram_cons_udp_regacc => ram_udp_regacc.cons,
      ram_prod_udp_regidp => ram_udp_regidp.prod,
      ram_prod_udp_regres => ram_udp_regres_prod_tmp,
      dp_ram_udp_regacc_porti => dp_ram_udp_regacc.port_b.i,
      dp_ram_udp_regacc_porto => dp_ram_udp_regacc.port_b.o,
      dp_ram_udp_regidp_porti => dp_ram_udp_regidp.port_a.i,
      dp_ram_udp_regidp_porto => dp_ram_udp_regidp.port_a.o,
      dp_ram_udp_regres_porti => dp_ram_udp_regres_port_a_i_tmp,
      dp_ram_udp_regres_porto => dp_ram_udp_regres_port_a_o_tmp,
      --
      regacc_stat_aux => regacc_aux_info.stat,
      --
      debug_state => debug_state_regacc
      );

  lclreg: entity work.fnet_local_reg
    generic map (test_regs            => test_regs,
                 lcl_data_gen         => lcl_data_gen,
                 limit_payload_window => limit_payload_window,
                 debug_regs           => debug_regs,
                 debug_counters       => debug_counters,
                 compiletime          => compiletime,
                 description          => description)
    port map (
      clk            => clk,
      --
      reg_addr       => reg_int_addr,
      reg_data_wr    => reg_int_data_wr,
      reg_data_rd    => reg_int_data_rd,
      reg_write      => reg_int_write,
      reg_read       => reg_int_read,
      reg_done       => reg_int_done,
      reg_cnt        => reg_int_cnt,
      --
      in_info        => in_info_counts,
      out_info       => out_info_counts,
      ts_info        => ts_info_counts,
      --
      tcp_stat       => tcp_ctrl_stat,
      tcp_astat      => tcp_state_stat,
      --
      tcp_reset      => int_tcp_reset,
      --
      mdio_req_data  => mdio_a_req_data,
      mdio_request   => mdio_a_request,
      mdio_resp_data => mdio_a_resp_data,
      mdio_response  => mdio_a_response,
      --
      tc_limit_tcp_payload    => tc_limit_tcp_payload,
      tc_limit_tcp_window     => tc_limit_tcp_window,
      --
      tc_do_lcl_datagen       => tc_do_lcl_datagen,
      tc_lcl_datagen_chance   => tc_lcl_datagen_chance,
      tc_lcl_datagen_len_mask => tc_lcl_datagen_len_mask,
      tc_lcl_datagen_mark     => tc_lcl_datagen_mark
      );

  tcp_reset <= int_tcp_reset;

  tcp_state : entity work.fnet_tcp_state
    generic map (data_bufsize_addrbits => data_bufsize_addrbits)
    port map (
      clk            => clk,
      --
      stat           => tcp_ctrl_stat,
      buf_stat       => tcp_buf_stat,
      --
      astat          => tcp_state_stat
      );

  tcp_ctrl : entity work.fnet_tcp_control
    generic map (data_bufsize_addrbits => data_bufsize_addrbits)
    port map (
      clk            => clk,
      --
      stat           => tcp_ctrl_stat,
      --
      astat          => tcp_state_stat,
      --
      recv           => tcp_ctrl_recv,
      --
      packet_req     => packet_req,
      packet_done    => packet_done,
      --
      tcp_reset      => int_tcp_reset,
      --
      slow_clock_tick => slow_clock_tick,
      timeout_tick   => timeout_tick,
      --
      info_counts    => ts_info_counts,
      --
      tc_limit_tcp_window => tc_limit_tcp_window
      );

  preptcp: entity work.fnet_tcp_prepare
    generic map (data_bufsize_addrbits => data_bufsize_addrbits)
    port map (
      clk            => clk,
      --
      ram_stat_tcp_template => ram_tcp_template.stat,
      ram_stat_tcp_prep0    => ram_tcp_prep2(0).stat,
      ram_stat_tcp_prep1    => ram_tcp_prep2(1).stat,
      ram_cons_tcp_template => ram_tcp_template.cons,
      ram_prod_tcp_prep0    => ram_tcp_prep2(0).prod,
      ram_prod_tcp_prep1    => ram_tcp_prep2(1).prod,
      dp_ram_tcp_template_porti => dp_ram_tcp_template.port_b.i,
      dp_ram_tcp_template_porto => dp_ram_tcp_template.port_b.o,
      dp_ram_tcp_prep0_porti => dp_ram_tcp_prep2(0).port_a.i,
      dp_ram_tcp_prep0_porto => dp_ram_tcp_prep2(0).port_a.o,
      dp_ram_tcp_prep1_porti => dp_ram_tcp_prep2(1).port_a.i,
      dp_ram_tcp_prep1_porto => dp_ram_tcp_prep2(1).port_a.o,
      --
      data_port_b_addr  => data_port_b_addr,
      data_port_b_rd    => data_port_b_rd,
      data_port_b_rdata => data_port_b_rdata,
      --
      stat           => tcp_ctrl_stat,
      astat          => tcp_state_stat,
      --
      packet_req     => packet_req,
      packet_done    => packet_done,
      --prod         => tcp_control.prod,
      --
      max_packet_payload => max_packet_payload,
      --
      tc_limit_tcp_payload => tc_limit_tcp_payload,
      --
      debug_state    => debug_state_preptcp
      );

  tcp_buffer : entity work.fnet_tcp_buffer
    generic map(data_bufsize_addrbits => data_bufsize_addrbits)
    port map (
      clk             => clk,
      --
      buf_stat        => tcp_buf_stat,
      --
      tcp_stat        => tcp_state_stat,  -- astat -> tcp_state
      --
      --tcp_stat     => tcp_control.stat,
      tcp_reset       => int_tcp_reset,
      --
      data_write      => data_write,
      data_word       => data_word,
      data_offset     => data_offset,
      data_commit     => data_commit,
      data_commit_len => data_commit_len,
      data_free       => data_free,
      --
      lcl_datagen_write      => lcl_datagen_write,
      lcl_datagen_word       => lcl_datagen_word,
      lcl_datagen_offset     => lcl_datagen_offset,
      lcl_datagen_commit     => lcl_datagen_commit,
      lcl_datagen_commit_len => lcl_datagen_commit_len,
      lcl_datagen_free       => lcl_datagen_free,
      --
      data_port_a_addr  => data_port_a_addr,
      data_port_a_rd    => data_port_a_rd,
      data_port_a_wr    => data_port_a_wr,
      data_port_a_wdata => data_port_a_wdata,
      --
      tc_do_lcl_datagen => tc_do_lcl_datagen
      );

  data_gen: if (lcl_data_gen) generate
    test_data_gen : entity work.fnet_test_datagen
      generic map(data_bufsize_addrbits => data_bufsize_addrbits)
      port map (
        clk          => clk,
        tcp_reset    => int_tcp_reset,
        --
        lcl_datagen_write      => lcl_datagen_write,
        lcl_datagen_word       => lcl_datagen_word,
        lcl_datagen_offset     => lcl_datagen_offset,
        lcl_datagen_commit     => lcl_datagen_commit,
        lcl_datagen_commit_len => lcl_datagen_commit_len,
        lcl_datagen_free       => lcl_datagen_free,
        --
        tc_lcl_datagen_chance   => tc_lcl_datagen_chance,
        tc_lcl_datagen_len_mask => tc_lcl_datagen_len_mask,
        tc_lcl_datagen_mark     => tc_lcl_datagen_mark
        );
  end generate;

  dpdp_ram_data : entity work.fnet_ram_block_data
    generic map(addrbits => addrbits)
    port map (
      clk          => clk,
      port_a_addr  => data_port_a_addr,
      port_a_rd    => data_port_a_rd,
      port_a_wr    => data_port_a_wr,
      port_a_wdata => data_port_a_wdata,
      port_a_rdata => data_port_a_rdata,

      port_b_addr  => data_port_b_addr,
      port_b_rd    => data_port_b_rd,
      port_b_rdata => data_port_b_rdata
      );

  dpdp_ram_arp_icmp : entity work.ram_block_a11d16
    port map (
      clk       => clk,
      porti_a   => dp_ram_arp_icmp.port_a.i,
      porto_a   => dp_ram_arp_icmp.port_a.o,
      porti_b   => dp_ram_arp_icmp.port_b.i,
      porto_b   => dp_ram_arp_icmp.port_b.o
      );

  dpdp_ram_pkt_gen : entity work.ram_block_a11d16
    port map (
      clk       => clk,
      porti_a   => dp_ram_pkt_gen.port_a.i,
      porto_a   => dp_ram_pkt_gen.port_a.o,
      porti_b   => dp_ram_pkt_gen.port_b.i,
      porto_b   => dp_ram_pkt_gen.port_b.o
      );

  dpdp_ram_udp_regacc : entity work.ram_block_a11d16
    port map (
      clk       => clk,
      porti_a   => dp_ram_udp_regacc.port_a.i,
      porto_a   => dp_ram_udp_regacc.port_a.o,
      porti_b   => dp_ram_udp_regacc.port_b.i,
      porto_b   => dp_ram_udp_regacc.port_b.o
      );

  dpdp_ram_udp_regidp : entity work.ram_block_a11d16
    port map (
      clk       => clk,
      porti_a   => dp_ram_udp_regidp.port_a.i,
      porto_a   => dp_ram_udp_regidp.port_a.o,
      porti_b   => dp_ram_udp_regidp.port_b.i,
      porto_b   => dp_ram_udp_regidp.port_b.o
      );

  dpdp_ram_udp_regres : for i in 0 to NUM_REG_CH-1 generate
    dpdp_ram_udp_regres_i : entity work.ram_block_a11d16
      port map (
        clk       => clk,
        porti_a   => dp_ram_udp_regres(i).port_a.i,
        porto_a   => dp_ram_udp_regres(i).port_a.o,
        porti_b   => dp_ram_udp_regres(i).port_b.i,
        porto_b   => dp_ram_udp_regres(i).port_b.o
        );
  end generate;

  dpdp_ram_tcp_template : entity work.ram_block_a11d16
    port map (
      clk       => clk,
      porti_a   => dp_ram_tcp_template.port_a.i,
      porto_a   => dp_ram_tcp_template.port_a.o,
      porti_b   => dp_ram_tcp_template.port_b.i,
      porto_b   => dp_ram_tcp_template.port_b.o
      );

  dpdp_ram_tcp_prep0 : entity work.ram_block_a11d16
    port map (
      clk       => clk,
      porti_a   => dp_ram_tcp_prep2(0).port_a.i,
      porto_a   => dp_ram_tcp_prep2(0).port_a.o,
      porti_b   => dp_ram_tcp_prep2(0).port_b.i,
      porto_b   => dp_ram_tcp_prep2(0).port_b.o
      );

  dpdp_ram_tcp_prep1 : entity work.ram_block_a11d16
    port map (
      clk       => clk,
      porti_a   => dp_ram_tcp_prep2(1).port_a.i,
      porto_a   => dp_ram_tcp_prep2(1).port_a.o,
      porti_b   => dp_ram_tcp_prep2(1).port_b.i,
      porto_b   => dp_ram_tcp_prep2(1).port_b.o
      );

  ctrl_ram_arp_icmp : entity work.fnet_ram_block_stat
    port map (
      clk       => clk,
      stat      => ram_arp_icmp.stat,
      prod      => ram_arp_icmp.prod,
      prod2     => ram_arp_icmp.prod2,
      cons      => ram_arp_icmp.cons
      );

  ctrl_ram_pkt_gen : entity work.fnet_ram_block_stat
    port map (
      clk       => clk,
      stat      => ram_pkt_gen.stat,
      prod      => ram_pkt_gen.prod,
      prod2     => ram_pkt_gen.prod2,
      cons      => ram_pkt_gen.cons
      );

  ctrl_ram_udp_regacc : entity work.fnet_ram_block_stat
    port map (
      clk       => clk,
      stat      => ram_udp_regacc.stat,
      prod      => ram_udp_regacc.prod,
      prod2     => ram_udp_regacc.prod2,
      cons      => ram_udp_regacc.cons
      );

  ctrl_ram_udp_regaidp : entity work.fnet_ram_block_stat
    port map (
      clk       => clk,
      stat      => ram_udp_regidp.stat,
      prod      => ram_udp_regidp.prod,
      prod2     => ram_udp_regidp.prod2,
      cons      => ram_udp_regidp.cons
      );

  ctrl_ram_udp_regres : for i in 0 to NUM_REG_CH-1 generate
    ctrl_ram_udp_regres_i : entity work.fnet_ram_block_stat
      port map (
        clk       => clk,
        stat      => ram_udp_regres(i).stat,
        prod      => ram_udp_regres(i).prod,
        prod2     => ram_udp_regres(i).prod2,
        cons      => ram_udp_regres(i).cons
        );
  end generate;

  ctrl_ram_tcp_template : entity work.fnet_ram_block_stat
    port map (
      clk       => clk,
      stat      => ram_tcp_template.stat,
      prod      => ram_tcp_template.prod,
      prod2     => ram_tcp_template.prod2,
      cons      => ram_tcp_template.cons
      );

  ctrl_ram_tcp_prep0 : entity work.fnet_ram_block_stat
    port map (
      clk       => clk,
      stat      => ram_tcp_prep2(0).stat,
      prod      => ram_tcp_prep2(0).prod,
      prod2     => ram_tcp_prep2(0).prod2,
      cons      => ram_tcp_prep2(0).cons
      );

  ctrl_ram_tcp_prep1 : entity work.fnet_ram_block_stat
    port map (
      clk       => clk,
      stat      => ram_tcp_prep2(1).stat,
      prod      => ram_tcp_prep2(1).prod,
      prod2     => ram_tcp_prep2(1).prod2,
      cons      => ram_tcp_prep2(1).cons
      );

  ctrl_regacc_aux : entity work.fnet_regacc_aux_stat
    port map (
      clk       => clk,
      stat      => regacc_aux_info.stat,
      prod      => regacc_aux_info.prod
      );

  mdio : entity work.fnet_mdio
    port map (
      clk       => clk125,
        countdebug => open,--countdebug,
        statedebug => statedebug,
      
      mdc_out   => mdc_out,
      mdc_ena   => mdc_ena,
      mdio_in   => mdio_in,
      mdio_out  => mdio_out,
      mdio_ena  => mdio_ena,
      a_req_data  => mdio_a_req_data,
      a_request   => mdio_a_request,
      a_resp_data => mdio_a_resp_data,
      a_response  => mdio_a_response,
      b_req_data  => (others => '0'),
      b_request   => '0'
      );



end RTL;
