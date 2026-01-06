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


// IP VLNV: xilinx.com:module_ref:gig_ethernet_pcs_pma_0_example_design:1.0
// IP Revision: 1

(* X_CORE_INFO = "gig_ethernet_pcs_pma_0_example_design,Vivado 2022.2" *)
(* CHECK_LICENSE_TYPE = "top_block_gig_ethernet_pcs_pma_0_0,gig_ethernet_pcs_pma_0_example_design,{}" *)
(* CORE_GENERATION_INFO = "top_block_gig_ethernet_pcs_pma_0_0,gig_ethernet_pcs_pma_0_example_design,{x_ipProduct=Vivado 2022.2,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=gig_ethernet_pcs_pma_0_example_design,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED}" *)
(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module top_block_gig_ethernet_pcs_pma_0_0 (
  independent_clock,
  io_refclk,
  gtrefclk_p,
  gtrefclk_n,
  rxuserclk2,
  txp,
  txn,
  rxp,
  rxn,
  gmii_tx_clk,
  gmii_rx_clk,
  gmii_txd,
  gmii_tx_en,
  gmii_tx_er,
  gmii_rxd,
  gmii_rx_dv,
  gmii_rx_er,
  mdc,
  mdio_i,
  mdio_o,
  mdio_t,
  phyaddr,
  configuration_vector,
  configuration_valid,
  status_vector,
  reset,
  signal_detect,
  mmcm_locked_out,
  resetdone_out
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME independent_clock, FREQ_HZ 50000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN top_block_clk_wiz_0_0_clk_out1, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 independent_clock CLK" *)
input wire independent_clock;
input wire io_refclk;
input wire gtrefclk_p;
input wire gtrefclk_n;
output wire rxuserclk2;
output wire txp;
output wire txn;
input wire rxp;
input wire rxn;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME gmii_tx_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN top_block_gig_ethernet_pcs_pma_0_0_gmii_rx_clk, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 gmii_tx_clk CLK" *)
input wire gmii_tx_clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME gmii_rx_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN top_block_gig_ethernet_pcs_pma_0_0_gmii_rx_clk, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 gmii_rx_clk CLK" *)
output wire gmii_rx_clk;
input wire [7 : 0] gmii_txd;
input wire gmii_tx_en;
input wire gmii_tx_er;
output wire [7 : 0] gmii_rxd;
output wire gmii_rx_dv;
output wire gmii_rx_er;
input wire mdc;
input wire mdio_i;
output wire mdio_o;
output wire mdio_t;
input wire [4 : 0] phyaddr;
input wire [4 : 0] configuration_vector;
input wire configuration_valid;
output wire [15 : 0] status_vector;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME reset, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset RST" *)
input wire reset;
input wire signal_detect;
output wire mmcm_locked_out;
output wire resetdone_out;

  gig_ethernet_pcs_pma_0_example_design inst (
    .independent_clock(independent_clock),
    .io_refclk(io_refclk),
    .gtrefclk_p(gtrefclk_p),
    .gtrefclk_n(gtrefclk_n),
    .rxuserclk2(rxuserclk2),
    .txp(txp),
    .txn(txn),
    .rxp(rxp),
    .rxn(rxn),
    .gmii_tx_clk(gmii_tx_clk),
    .gmii_rx_clk(gmii_rx_clk),
    .gmii_txd(gmii_txd),
    .gmii_tx_en(gmii_tx_en),
    .gmii_tx_er(gmii_tx_er),
    .gmii_rxd(gmii_rxd),
    .gmii_rx_dv(gmii_rx_dv),
    .gmii_rx_er(gmii_rx_er),
    .mdc(mdc),
    .mdio_i(mdio_i),
    .mdio_o(mdio_o),
    .mdio_t(mdio_t),
    .phyaddr(phyaddr),
    .configuration_vector(configuration_vector),
    .configuration_valid(configuration_valid),
    .status_vector(status_vector),
    .reset(reset),
    .signal_detect(signal_detect),
    .mmcm_locked_out(mmcm_locked_out),
    .resetdone_out(resetdone_out)
  );
endmodule
