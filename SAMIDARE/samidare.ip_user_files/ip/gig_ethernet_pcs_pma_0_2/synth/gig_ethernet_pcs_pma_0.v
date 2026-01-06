//------------------------------------------------------------------------------
// File       : gig_ethernet_pcs_pma_0.v
// Author     : Xilinx Inc.
//------------------------------------------------------------------------------
// (c) Copyright 2009 Xilinx, Inc. All rights reserved.
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
// 
//------------------------------------------------------------------------------

`timescale 1 ps/1 ps
(* DowngradeIPIdentifiedWarnings="yes" *)

//------------------------------------------------------------------------------
// The module declaration for the Core Block wrapper.
//------------------------------------------------------------------------------

module gig_ethernet_pcs_pma_0   #
   (
    parameter EXAMPLE_SIMULATION                     =  0
   )

   (
      // Transceiver Interface
      //----------------------
      input            gtwiz_reset_tx_done_in,
      input            gtwiz_reset_rx_done_in,
      output           gtwiz_userclk_tx_reset_out,
 
      output           gtwiz_userclk_tx_active_out,
      output           gtwiz_reset_clk_freerun_out,
      output           gtwiz_reset_tx_datapath_out,
      output           gtwiz_reset_rx_datapath_out,
      output           gtwiz_reset_all_out,
      output           gtwiz_userclk_rx_active_out,
      output           gtwiz_reset_tx_pll_and_datapath_out,
      output           gtwiz_reset_rx_pll_and_datapath_out,
     

      input            rxpmaresetdone_in,
      input            txresetdone_in,
      input            rxresetdone_in,
      output           rxmcommaalignen_out,
      output           rxpcommaalignen_out,
      output           txelecidle_out,
      output [1 : 0]   txpd_out,
      output [1 : 0]   rxpd_out,
      output           rxusrclk_out,
      output           rxusrclk2_out,
      output           txusrclk_out,
      output           txusrclk2_out,
      output [15 : 0]  txctrl0_out,
      output [15 : 0]  txctrl1_out,
      output [7 : 0]   txctrl2_out,
      output [15 : 0]  gtwiz_userdata_tx_out, 
      input  [15 : 0]  rxctrl0_in,
      input  [15 : 0]  rxctrl1_in,
      input  [7 : 0]   rxctrl2_in,
      input  [7 : 0]   rxctrl3_in,
      input  [1 : 0]   rxclkcorcnt_in,
      input  [15 : 0]  gtwiz_userdata_rx_in,
      input  [2 : 0]   rxbufstatus_in,
      input  [1 : 0]   txbufstatus_in,
      input            cplllock_in,
      output           rx8b10ben_out,
      output           tx8b10ben_out,
      output           rxcommadeten_out,


      output       resetdone,                 // The GT transceiver has completed its reset cycle
      output       mmcm_reset,
      input        mmcm_locked,               // MMCM Locked
      input        userclk,                 
      input        userclk2,                 
      input        rxuserclk,                
      input        rxuserclk2,               
      input        independent_clock_bufg,
      input        pma_reset,                 // transceiver PMA reset signal
      // GMII Interface
      //---------------
      input [7:0]  gmii_txd,              // Transmit data from client MAC.
      input        gmii_tx_en,            // Transmit control signal from client MAC.
      input        gmii_tx_er,            // Transmit control signal from client MAC.
      output [7:0] gmii_rxd,              // Received Data to client MAC.
      output       gmii_rx_dv,            // Received control signal to client MAC.
      output       gmii_rx_er,            // Received control signal to client MAC.
      output       gmii_isolate,          // Tristate control to electrically isolate GMII.

      // Management: MDIO Interface
      //---------------------------

      input        mdc,                   // Management Data Clock
      input        mdio_i,                // Management Data In
      output       mdio_o,                // Management Data Out
      output       mdio_t,                // Management Data Tristate
      input [4:0]  phyaddr,
      input [4:0]  configuration_vector,  // Alternative to MDIO interface.
      input        configuration_valid,   // Validation signal for Config vector

      // General IO's
      //-------------
      output [15:0] status_vector,         // Core status.
      input        reset,                 // Asynchronous reset for entire core
      input        signal_detect          // Input from PMD to indicate presence of optical input.
   );


(* CORE_GENERATION_INFO = "gig_ethernet_pcs_pma_0,gig_ethernet_pcs_pma_v16_2_9,{x_ipProduct=Vivado 2022.2,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=gig_ethernet_pcs_pma,x_ipVersion=16.2,x_ipCoreRevision=9,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,c_elaboration_transient_dir=.,c_component_name=gig_ethernet_pcs_pma_0,c_family=kintexuplus,c_architecture=kintexuplus,c_is_sgmii=false,c_enable_async_sgmii=false,c_enable_async_lvds=false,c_enable_async_lvds_rx_only=false,c_use_transceiver=true,c_use_tbi=false,c_is_2_5g=false,c_use_lvds=false,c_has_an=false,characterization=false,c_has_mdio=true,c_has_axil=false,c_has_ext_mdio=false,c_sgmii_phy_mode=false,c_dynamic_switching=false,c_sgmii_fabric_buffer=true,c_1588=0,gt_rx_byte_width=1,C_EMAC_IF_TEMAC=true,EXAMPLE_SIMULATION=0,c_support_level=false,c_RxNibbleBitslice0Used=false,c_InstantiateBitslice0=false,c_tx_in_upper_nibble=1,c_TxLane0_Placement=DIFF_PAIR_0,c_TxLane1_Placement=DIFF_PAIR_1,c_RxLane0_Placement=DIFF_PAIR_0,c_RxLane1_Placement=DIFF_PAIR_1,c_sub_core_name=gig_ethernet_pcs_pma_0_gt,c_transceiver_type=GTHE4,c_gt_type=GTH,c_rx_gmii_clk_src=TXOUTCLK,c_transceivercontrol=false,c_gtinex=true,c_xdevicefamily=xcau15p,c_clock_selection=Sync,c_gt_dmonitorout_width=16,c_gt_drpaddr_width=10,c_gt_txdiffctrl_width=5,c_gt_rxmonitorout_width=8,c_num_of_lanes=1,c_refclkrate=156.25,c_drpclkrate=50.0,c_gt_loc=X0Y8,c_refclk_src=clk0,c_enable_tx_userclk_reset_port=true,c_8_or_9_family=true,VERSAL_GT_BOARD_FLOW=0}" *)
(* X_CORE_INFO = "gig_ethernet_pcs_pma_v16_2_9,Vivado 2022.2" *)

gig_ethernet_pcs_pma_0_block # ( .EXAMPLE_SIMULATION             (EXAMPLE_SIMULATION) )  
inst
   (
      // Transceiver Interface
      //----------------------
      .gtwiz_reset_tx_done_in              (gtwiz_reset_tx_done_in),
      .gtwiz_reset_rx_done_in              (gtwiz_reset_rx_done_in),
      .gtwiz_userclk_tx_reset_out          (gtwiz_userclk_tx_reset_out),
      .gtwiz_userclk_tx_active_out         (gtwiz_userclk_tx_active_out),
      .gtwiz_reset_clk_freerun_out         (gtwiz_reset_clk_freerun_out),
      .gtwiz_reset_tx_datapath_out         (gtwiz_reset_tx_datapath_out),
      .gtwiz_reset_rx_datapath_out         (gtwiz_reset_rx_datapath_out),
      .gtwiz_reset_all_out                 (gtwiz_reset_all_out),
      .gtwiz_userclk_rx_active_out         (gtwiz_userclk_rx_active_out),
      .gtwiz_reset_tx_pll_and_datapath_out (gtwiz_reset_tx_pll_and_datapath_out),
      .gtwiz_reset_rx_pll_and_datapath_out (gtwiz_reset_rx_pll_and_datapath_out),

      .rxpmaresetdone_in                   (rxpmaresetdone_in),
      .txresetdone_in                      (txresetdone_in),
      .rxresetdone_in                      (rxresetdone_in),
      .rxmcommaalignen_out                 (rxmcommaalignen_out),
      .rxpcommaalignen_out                 (rxpcommaalignen_out),
      .txelecidle_out                      (txelecidle_out),
      .txpd_out                            (txpd_out),
      .rxpd_out                            (rxpd_out),
      .rxusrclk_out                        (rxusrclk_out),
      .rxusrclk2_out                       (rxusrclk2_out),
      .txusrclk_out                        (txusrclk_out),
      .txusrclk2_out                       (txusrclk2_out),
      .txctrl0_out                         (txctrl0_out),
      .txctrl1_out                         (txctrl1_out),
      .txctrl2_out                         (txctrl2_out),
      .gtwiz_userdata_tx_out               (gtwiz_userdata_tx_out), 
      .rxctrl0_in                          (rxctrl0_in),
      .rxctrl1_in                          (rxctrl1_in),
      .rxctrl2_in                          (rxctrl2_in),
      .rxctrl3_in                          (rxctrl3_in),
      .rxclkcorcnt_in                      (rxclkcorcnt_in),
      .gtwiz_userdata_rx_in                (gtwiz_userdata_rx_in),
      .rxbufstatus_in                      (rxbufstatus_in),
      .txbufstatus_in                      (txbufstatus_in),
      .cplllock_in                         (cplllock_in),
      .rx8b10ben_out                       (rx8b10ben_out),
      .tx8b10ben_out                       (tx8b10ben_out),
      .rxcommadeten_out                    (rxcommadeten_out),
      .resetdone                            (resetdone),
      .mmcm_reset                           (mmcm_reset),
      .mmcm_locked                          (mmcm_locked),
      .userclk                              (userclk),
      .userclk2                             (userclk2),
      .rxuserclk                            (rxuserclk),
      .rxuserclk2                           (rxuserclk2),
      .independent_clock_bufg               (independent_clock_bufg),
      .pma_reset                            (pma_reset),
      // GMII Interface
      //---------------
      .gmii_txd                      (gmii_txd),
      .gmii_tx_en                    (gmii_tx_en),
      .gmii_tx_er                    (gmii_tx_er),
      .gmii_rxd                      (gmii_rxd),
      .gmii_rx_dv                    (gmii_rx_dv),
      .gmii_rx_er                    (gmii_rx_er),
      .gmii_isolate                  (gmii_isolate),

      // Management: MDIO Interface
      //---------------------------

      .mdc                           (mdc),
      .mdio_i                        (mdio_i),
      .mdio_o                        (mdio_o),
      .mdio_t                        (mdio_t),
      .phyaddr                       (phyaddr),
      .configuration_vector          (configuration_vector),
      .configuration_valid           (configuration_valid),

      // General IO's
      //-------------
       
      
      .status_vector                 (status_vector),
      .reset                         (reset),
      .signal_detect                 (signal_detect)
   );


endmodule // gig_ethernet_pcs_pma_0

