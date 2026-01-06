// (c) Copyright 1995-2024 Xilinx, Inc. All rights reserved.
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

// IP VLNV: xilinx.com:ip:gig_ethernet_pcs_pma:16.2
// IP Revision: 9

// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
gig_ethernet_pcs_pma_0 your_instance_name (
  .independent_clock_bufg(independent_clock_bufg),                            // input wire independent_clock_bufg
  .resetdone(resetdone),                                                      // output wire resetdone
  .mmcm_reset(mmcm_reset),                                                    // output wire mmcm_reset
  .userclk(userclk),                                                          // input wire userclk
  .userclk2(userclk2),                                                        // input wire userclk2
  .pma_reset(pma_reset),                                                      // input wire pma_reset
  .mmcm_locked(mmcm_locked),                                                  // input wire mmcm_locked
  .rxuserclk(rxuserclk),                                                      // input wire rxuserclk
  .rxuserclk2(rxuserclk2),                                                    // input wire rxuserclk2
  .gmii_txd(gmii_txd),                                                        // input wire [7 : 0] gmii_txd
  .gmii_tx_en(gmii_tx_en),                                                    // input wire gmii_tx_en
  .gmii_tx_er(gmii_tx_er),                                                    // input wire gmii_tx_er
  .gmii_rxd(gmii_rxd),                                                        // output wire [7 : 0] gmii_rxd
  .gmii_rx_dv(gmii_rx_dv),                                                    // output wire gmii_rx_dv
  .gmii_rx_er(gmii_rx_er),                                                    // output wire gmii_rx_er
  .gmii_isolate(gmii_isolate),                                                // output wire gmii_isolate
  .mdc(mdc),                                                                  // input wire mdc
  .mdio_i(mdio_i),                                                            // input wire mdio_i
  .mdio_o(mdio_o),                                                            // output wire mdio_o
  .mdio_t(mdio_t),                                                            // output wire mdio_t
  .phyaddr(phyaddr),                                                          // input wire [4 : 0] phyaddr
  .configuration_vector(configuration_vector),                                // input wire [4 : 0] configuration_vector
  .configuration_valid(configuration_valid),                                  // input wire configuration_valid
  .status_vector(status_vector),                                              // output wire [15 : 0] status_vector
  .reset(reset),                                                              // input wire reset
  .signal_detect(signal_detect),                                              // input wire signal_detect
  .gtwiz_userclk_tx_active_out(gtwiz_userclk_tx_active_out),                  // output wire gtwiz_userclk_tx_active_out
  .gtwiz_userclk_tx_reset_out(gtwiz_userclk_tx_reset_out),                    // output wire gtwiz_userclk_tx_reset_out
  .gtwiz_reset_clk_freerun_out(gtwiz_reset_clk_freerun_out),                  // output wire gtwiz_reset_clk_freerun_out
  .gtwiz_reset_tx_datapath_out(gtwiz_reset_tx_datapath_out),                  // output wire gtwiz_reset_tx_datapath_out
  .gtwiz_reset_rx_datapath_out(gtwiz_reset_rx_datapath_out),                  // output wire gtwiz_reset_rx_datapath_out
  .gtwiz_reset_all_out(gtwiz_reset_all_out),                                  // output wire gtwiz_reset_all_out
  .gtwiz_userclk_rx_active_out(gtwiz_userclk_rx_active_out),                  // output wire gtwiz_userclk_rx_active_out
  .gtwiz_reset_tx_pll_and_datapath_out(gtwiz_reset_tx_pll_and_datapath_out),  // output wire gtwiz_reset_tx_pll_and_datapath_out
  .gtwiz_reset_rx_pll_and_datapath_out(gtwiz_reset_rx_pll_and_datapath_out),  // output wire gtwiz_reset_rx_pll_and_datapath_out
  .gtwiz_reset_tx_done_in(gtwiz_reset_tx_done_in),                            // input wire gtwiz_reset_tx_done_in
  .gtwiz_reset_rx_done_in(gtwiz_reset_rx_done_in),                            // input wire gtwiz_reset_rx_done_in
  .rxpmaresetdone_in(rxpmaresetdone_in),                                      // input wire rxpmaresetdone_in
  .txresetdone_in(txresetdone_in),                                            // input wire txresetdone_in
  .rxresetdone_in(rxresetdone_in),                                            // input wire rxresetdone_in
  .rxmcommaalignen_out(rxmcommaalignen_out),                                  // output wire rxmcommaalignen_out
  .rxpcommaalignen_out(rxpcommaalignen_out),                                  // output wire rxpcommaalignen_out
  .txelecidle_out(txelecidle_out),                                            // output wire txelecidle_out
  .txpd_out(txpd_out),                                                        // output wire [1 : 0] txpd_out
  .rxpd_out(rxpd_out),                                                        // output wire [1 : 0] rxpd_out
  .rxusrclk_out(rxusrclk_out),                                                // output wire rxusrclk_out
  .rxusrclk2_out(rxusrclk2_out),                                              // output wire rxusrclk2_out
  .txusrclk_out(txusrclk_out),                                                // output wire txusrclk_out
  .txusrclk2_out(txusrclk2_out),                                              // output wire txusrclk2_out
  .txctrl0_out(txctrl0_out),                                                  // output wire [15 : 0] txctrl0_out
  .txctrl1_out(txctrl1_out),                                                  // output wire [15 : 0] txctrl1_out
  .txctrl2_out(txctrl2_out),                                                  // output wire [7 : 0] txctrl2_out
  .gtwiz_userdata_tx_out(gtwiz_userdata_tx_out),                              // output wire [15 : 0] gtwiz_userdata_tx_out
  .rxctrl0_in(rxctrl0_in),                                                    // input wire [15 : 0] rxctrl0_in
  .rxctrl1_in(rxctrl1_in),                                                    // input wire [15 : 0] rxctrl1_in
  .rxctrl2_in(rxctrl2_in),                                                    // input wire [7 : 0] rxctrl2_in
  .rxctrl3_in(rxctrl3_in),                                                    // input wire [7 : 0] rxctrl3_in
  .rxclkcorcnt_in(rxclkcorcnt_in),                                            // input wire [1 : 0] rxclkcorcnt_in
  .gtwiz_userdata_rx_in(gtwiz_userdata_rx_in),                                // input wire [15 : 0] gtwiz_userdata_rx_in
  .rxbufstatus_in(rxbufstatus_in),                                            // input wire [2 : 0] rxbufstatus_in
  .txbufstatus_in(txbufstatus_in),                                            // input wire [1 : 0] txbufstatus_in
  .cplllock_in(cplllock_in),                                                  // input wire cplllock_in
  .rx8b10ben_out(rx8b10ben_out),                                              // output wire rx8b10ben_out
  .tx8b10ben_out(tx8b10ben_out),                                              // output wire tx8b10ben_out
  .rxcommadeten_out(rxcommadeten_out)                                        // output wire rxcommadeten_out
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

// You must compile the wrapper file gig_ethernet_pcs_pma_0.v when simulating
// the core, gig_ethernet_pcs_pma_0. When compiling the wrapper file, be sure to
// reference the Verilog simulation library.

