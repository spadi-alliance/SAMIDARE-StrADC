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

// IP VLNV: xilinx.com:ip:gtwizard_ultrascale:1.7
// IP Revision: 14

// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
gig_ethernet_pcs_pma_0_gt your_instance_name (
  .gtwiz_userclk_tx_reset_in(gtwiz_userclk_tx_reset_in),                    // input wire [0 : 0] gtwiz_userclk_tx_reset_in
  .gtwiz_userclk_tx_active_in(gtwiz_userclk_tx_active_in),                  // input wire [0 : 0] gtwiz_userclk_tx_active_in
  .gtwiz_userclk_rx_active_in(gtwiz_userclk_rx_active_in),                  // input wire [0 : 0] gtwiz_userclk_rx_active_in
  .gtwiz_reset_clk_freerun_in(gtwiz_reset_clk_freerun_in),                  // input wire [0 : 0] gtwiz_reset_clk_freerun_in
  .gtwiz_reset_all_in(gtwiz_reset_all_in),                                  // input wire [0 : 0] gtwiz_reset_all_in
  .gtwiz_reset_tx_pll_and_datapath_in(gtwiz_reset_tx_pll_and_datapath_in),  // input wire [0 : 0] gtwiz_reset_tx_pll_and_datapath_in
  .gtwiz_reset_tx_datapath_in(gtwiz_reset_tx_datapath_in),                  // input wire [0 : 0] gtwiz_reset_tx_datapath_in
  .gtwiz_reset_rx_pll_and_datapath_in(gtwiz_reset_rx_pll_and_datapath_in),  // input wire [0 : 0] gtwiz_reset_rx_pll_and_datapath_in
  .gtwiz_reset_rx_datapath_in(gtwiz_reset_rx_datapath_in),                  // input wire [0 : 0] gtwiz_reset_rx_datapath_in
  .gtwiz_reset_rx_cdr_stable_out(gtwiz_reset_rx_cdr_stable_out),            // output wire [0 : 0] gtwiz_reset_rx_cdr_stable_out
  .gtwiz_reset_tx_done_out(gtwiz_reset_tx_done_out),                        // output wire [0 : 0] gtwiz_reset_tx_done_out
  .gtwiz_reset_rx_done_out(gtwiz_reset_rx_done_out),                        // output wire [0 : 0] gtwiz_reset_rx_done_out
  .gtwiz_userdata_tx_in(gtwiz_userdata_tx_in),                              // input wire [15 : 0] gtwiz_userdata_tx_in
  .gtwiz_userdata_rx_out(gtwiz_userdata_rx_out),                            // output wire [15 : 0] gtwiz_userdata_rx_out
  .cpllrefclksel_in(cpllrefclksel_in),                                      // input wire [2 : 0] cpllrefclksel_in
  .drpaddr_in(drpaddr_in),                                                  // input wire [9 : 0] drpaddr_in
  .drpclk_in(drpclk_in),                                                    // input wire [0 : 0] drpclk_in
  .drpdi_in(drpdi_in),                                                      // input wire [15 : 0] drpdi_in
  .drpen_in(drpen_in),                                                      // input wire [0 : 0] drpen_in
  .drpwe_in(drpwe_in),                                                      // input wire [0 : 0] drpwe_in
  .eyescanreset_in(eyescanreset_in),                                        // input wire [0 : 0] eyescanreset_in
  .eyescantrigger_in(eyescantrigger_in),                                    // input wire [0 : 0] eyescantrigger_in
  .gthrxn_in(gthrxn_in),                                                    // input wire [0 : 0] gthrxn_in
  .gthrxp_in(gthrxp_in),                                                    // input wire [0 : 0] gthrxp_in
  .gtrefclk0_in(gtrefclk0_in),                                              // input wire [0 : 0] gtrefclk0_in
  .gtrefclk1_in(gtrefclk1_in),                                              // input wire [0 : 0] gtrefclk1_in
  .loopback_in(loopback_in),                                                // input wire [2 : 0] loopback_in
  .pcsrsvdin_in(pcsrsvdin_in),                                              // input wire [15 : 0] pcsrsvdin_in
  .rx8b10ben_in(rx8b10ben_in),                                              // input wire [0 : 0] rx8b10ben_in
  .rxbufreset_in(rxbufreset_in),                                            // input wire [0 : 0] rxbufreset_in
  .rxcdrhold_in(rxcdrhold_in),                                              // input wire [0 : 0] rxcdrhold_in
  .rxcommadeten_in(rxcommadeten_in),                                        // input wire [0 : 0] rxcommadeten_in
  .rxdfelpmreset_in(rxdfelpmreset_in),                                      // input wire [0 : 0] rxdfelpmreset_in
  .rxlpmen_in(rxlpmen_in),                                                  // input wire [0 : 0] rxlpmen_in
  .rxmcommaalignen_in(rxmcommaalignen_in),                                  // input wire [0 : 0] rxmcommaalignen_in
  .rxpcommaalignen_in(rxpcommaalignen_in),                                  // input wire [0 : 0] rxpcommaalignen_in
  .rxpcsreset_in(rxpcsreset_in),                                            // input wire [0 : 0] rxpcsreset_in
  .rxpd_in(rxpd_in),                                                        // input wire [1 : 0] rxpd_in
  .rxpmareset_in(rxpmareset_in),                                            // input wire [0 : 0] rxpmareset_in
  .rxpolarity_in(rxpolarity_in),                                            // input wire [0 : 0] rxpolarity_in
  .rxprbscntreset_in(rxprbscntreset_in),                                    // input wire [0 : 0] rxprbscntreset_in
  .rxprbssel_in(rxprbssel_in),                                              // input wire [3 : 0] rxprbssel_in
  .rxrate_in(rxrate_in),                                                    // input wire [2 : 0] rxrate_in
  .rxusrclk_in(rxusrclk_in),                                                // input wire [0 : 0] rxusrclk_in
  .rxusrclk2_in(rxusrclk2_in),                                              // input wire [0 : 0] rxusrclk2_in
  .tx8b10ben_in(tx8b10ben_in),                                              // input wire [0 : 0] tx8b10ben_in
  .txctrl0_in(txctrl0_in),                                                  // input wire [15 : 0] txctrl0_in
  .txctrl1_in(txctrl1_in),                                                  // input wire [15 : 0] txctrl1_in
  .txctrl2_in(txctrl2_in),                                                  // input wire [7 : 0] txctrl2_in
  .txdiffctrl_in(txdiffctrl_in),                                            // input wire [4 : 0] txdiffctrl_in
  .txelecidle_in(txelecidle_in),                                            // input wire [0 : 0] txelecidle_in
  .txinhibit_in(txinhibit_in),                                              // input wire [0 : 0] txinhibit_in
  .txpcsreset_in(txpcsreset_in),                                            // input wire [0 : 0] txpcsreset_in
  .txpd_in(txpd_in),                                                        // input wire [1 : 0] txpd_in
  .txpmareset_in(txpmareset_in),                                            // input wire [0 : 0] txpmareset_in
  .txpolarity_in(txpolarity_in),                                            // input wire [0 : 0] txpolarity_in
  .txpostcursor_in(txpostcursor_in),                                        // input wire [4 : 0] txpostcursor_in
  .txprbsforceerr_in(txprbsforceerr_in),                                    // input wire [0 : 0] txprbsforceerr_in
  .txprbssel_in(txprbssel_in),                                              // input wire [3 : 0] txprbssel_in
  .txprecursor_in(txprecursor_in),                                          // input wire [4 : 0] txprecursor_in
  .txusrclk_in(txusrclk_in),                                                // input wire [0 : 0] txusrclk_in
  .txusrclk2_in(txusrclk2_in),                                              // input wire [0 : 0] txusrclk2_in
  .cplllock_out(cplllock_out),                                              // output wire [0 : 0] cplllock_out
  .dmonitorout_out(dmonitorout_out),                                        // output wire [15 : 0] dmonitorout_out
  .drpdo_out(drpdo_out),                                                    // output wire [15 : 0] drpdo_out
  .drprdy_out(drprdy_out),                                                  // output wire [0 : 0] drprdy_out
  .eyescandataerror_out(eyescandataerror_out),                              // output wire [0 : 0] eyescandataerror_out
  .gthtxn_out(gthtxn_out),                                                  // output wire [0 : 0] gthtxn_out
  .gthtxp_out(gthtxp_out),                                                  // output wire [0 : 0] gthtxp_out
  .gtpowergood_out(gtpowergood_out),                                        // output wire [0 : 0] gtpowergood_out
  .rxbufstatus_out(rxbufstatus_out),                                        // output wire [2 : 0] rxbufstatus_out
  .rxbyteisaligned_out(rxbyteisaligned_out),                                // output wire [0 : 0] rxbyteisaligned_out
  .rxbyterealign_out(rxbyterealign_out),                                    // output wire [0 : 0] rxbyterealign_out
  .rxclkcorcnt_out(rxclkcorcnt_out),                                        // output wire [1 : 0] rxclkcorcnt_out
  .rxcommadet_out(rxcommadet_out),                                          // output wire [0 : 0] rxcommadet_out
  .rxctrl0_out(rxctrl0_out),                                                // output wire [15 : 0] rxctrl0_out
  .rxctrl1_out(rxctrl1_out),                                                // output wire [15 : 0] rxctrl1_out
  .rxctrl2_out(rxctrl2_out),                                                // output wire [7 : 0] rxctrl2_out
  .rxctrl3_out(rxctrl3_out),                                                // output wire [7 : 0] rxctrl3_out
  .rxoutclk_out(rxoutclk_out),                                              // output wire [0 : 0] rxoutclk_out
  .rxpmaresetdone_out(rxpmaresetdone_out),                                  // output wire [0 : 0] rxpmaresetdone_out
  .rxprbserr_out(rxprbserr_out),                                            // output wire [0 : 0] rxprbserr_out
  .rxresetdone_out(rxresetdone_out),                                        // output wire [0 : 0] rxresetdone_out
  .txbufstatus_out(txbufstatus_out),                                        // output wire [1 : 0] txbufstatus_out
  .txoutclk_out(txoutclk_out),                                              // output wire [0 : 0] txoutclk_out
  .txpmaresetdone_out(txpmaresetdone_out),                                  // output wire [0 : 0] txpmaresetdone_out
  .txprgdivresetdone_out(txprgdivresetdone_out),                            // output wire [0 : 0] txprgdivresetdone_out
  .txresetdone_out(txresetdone_out)                                        // output wire [0 : 0] txresetdone_out
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

// You must compile the wrapper file gig_ethernet_pcs_pma_0_gt.v when simulating
// the core, gig_ethernet_pcs_pma_0_gt. When compiling the wrapper file, be sure to
// reference the Verilog simulation library.

