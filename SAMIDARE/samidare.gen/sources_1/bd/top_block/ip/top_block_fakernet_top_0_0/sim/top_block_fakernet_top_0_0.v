// (c) Copyright 1995-2025 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:module_ref:fakernet_top:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module top_block_fakernet_top_0_0 (
  statedebug,
  clk_in,
  clk25_in,
  eth_intb,
  mdio_i_debug,
  mdio_o_debug,
  eth_mdc,
  eth_mdio_in,
  eth_mdio_out,
  eth_rstn,
  eth_txd,
  eth_tx_en,
  eth_tx_clk,
  eth_rxd,
  eth_rx_clk,
  eth_rx_dv,
  eth_rxerr,
  eth_col,
  eth_crs,
  eth_ref_clk,
  spi_sdi,
  spi_csn,
  spi_sdo,
  sw,
  btn,
  led,
  led_r,
  led_g,
  led_b,
  ja0,
  ja1,
  ja2,
  ja3,
  jd0,
  jd1,
  jd2,
  jd3,
  uart_rx,
  uart_tx,
  user_data_word,
  user_data_offset,
  user_data_write,
  user_data_commit_len,
  user_data_commit,
  user_data_free,
  user_data_reset,
  regacc_addr_o,
  regacc_data_rd_i,
  regacc_data_wr_o,
  regacc_write_o,
  regacc_read_o,
  regacc_done_i
);

output wire [19 : 0] statedebug;
input wire clk_in;
input wire clk25_in;
input wire eth_intb;
output wire mdio_i_debug;
output wire mdio_o_debug;
output wire eth_mdc;
input wire eth_mdio_in;
output wire eth_mdio_out;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME eth_rstn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 eth_rstn RST" *)
output wire eth_rstn;
output wire [7 : 0] eth_txd;
output wire eth_tx_en;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME eth_tx_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN top_block_gig_ethernet_pcs_pma_0_0_gmii_rx_clk, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 eth_tx_clk CLK" *)
input wire eth_tx_clk;
input wire [7 : 0] eth_rxd;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME eth_rx_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN top_block_gig_ethernet_pcs_pma_0_0_gmii_rx_clk, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 eth_rx_clk CLK" *)
input wire eth_rx_clk;
input wire eth_rx_dv;
input wire eth_rxerr;
input wire eth_col;
input wire eth_crs;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME eth_ref_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN top_block_fakernet_top_0_0_eth_ref_clk, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 eth_ref_clk CLK" *)
output wire eth_ref_clk;
input wire spi_sdi;
inout wire spi_csn;
inout wire spi_sdo;
input wire [3 : 0] sw;
input wire [3 : 0] btn;
output wire [3 : 0] led;
output wire [3 : 0] led_r;
output wire [3 : 0] led_g;
output wire [3 : 0] led_b;
input wire ja0;
output wire ja1;
input wire ja2;
input wire ja3;
input wire jd0;
output wire jd1;
input wire jd2;
output wire jd3;
input wire uart_rx;
output wire uart_tx;
input wire [31 : 0] user_data_word;
input wire [9 : 0] user_data_offset;
input wire user_data_write;
input wire [10 : 0] user_data_commit_len;
input wire user_data_commit;
output wire user_data_free;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME user_data_reset, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 user_data_reset RST" *)
output wire user_data_reset;
output wire [24 : 0] regacc_addr_o;
input wire [31 : 0] regacc_data_rd_i;
output wire [31 : 0] regacc_data_wr_o;
output wire regacc_write_o;
output wire regacc_read_o;
input wire regacc_done_i;

  fakernet_top #(
    .compiletime(1),
    .dynamic_gen(1),
    .use_pmod_gps(1'B1)
  ) inst (
    .statedebug(statedebug),
    .clk_in(clk_in),
    .clk25_in(clk25_in),
    .eth_intb(eth_intb),
    .mdio_i_debug(mdio_i_debug),
    .mdio_o_debug(mdio_o_debug),
    .eth_mdc(eth_mdc),
    .eth_mdio_in(eth_mdio_in),
    .eth_mdio_out(eth_mdio_out),
    .eth_rstn(eth_rstn),
    .eth_txd(eth_txd),
    .eth_tx_en(eth_tx_en),
    .eth_tx_clk(eth_tx_clk),
    .eth_rxd(eth_rxd),
    .eth_rx_clk(eth_rx_clk),
    .eth_rx_dv(eth_rx_dv),
    .eth_rxerr(eth_rxerr),
    .eth_col(eth_col),
    .eth_crs(eth_crs),
    .eth_ref_clk(eth_ref_clk),
    .spi_sdi(spi_sdi),
    .spi_csn(spi_csn),
    .spi_sdo(spi_sdo),
    .sw(sw),
    .btn(btn),
    .led(led),
    .led_r(led_r),
    .led_g(led_g),
    .led_b(led_b),
    .ja0(ja0),
    .ja1(ja1),
    .ja2(ja2),
    .ja3(ja3),
    .jd0(jd0),
    .jd1(jd1),
    .jd2(jd2),
    .jd3(jd3),
    .uart_rx(uart_rx),
    .uart_tx(uart_tx),
    .user_data_word(user_data_word),
    .user_data_offset(user_data_offset),
    .user_data_write(user_data_write),
    .user_data_commit_len(user_data_commit_len),
    .user_data_commit(user_data_commit),
    .user_data_free(user_data_free),
    .user_data_reset(user_data_reset),
    .regacc_addr_o(regacc_addr_o),
    .regacc_data_rd_i(regacc_data_rd_i),
    .regacc_data_wr_o(regacc_data_wr_o),
    .regacc_write_o(regacc_write_o),
    .regacc_read_o(regacc_read_o),
    .regacc_done_i(regacc_done_i)
  );
endmodule
