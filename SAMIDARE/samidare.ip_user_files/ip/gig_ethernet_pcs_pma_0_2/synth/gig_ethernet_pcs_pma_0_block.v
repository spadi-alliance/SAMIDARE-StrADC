//------------------------------------------------------------------------------
// File       : gig_ethernet_pcs_pma_0_block.v
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
// Description: This Core Block Level wrapper connects the core to a
//              Series-7 Transceiver.
//
//
//   ------------------------------------------------------------
//   |                      Core Block wrapper                  |
//   |                                                          |
//   |        ------------------          -----------------     |
//   |        |      Core      |          | Transceiver   |     |
//   |        |                |          |    Glue       |     |
//   |        |                |          |               |     |
//   |        |                |          |               |     |
// ---------->| GMII           |--------->|               |-------->
//   |        | Tx             |          |               |     |
//   |        |                |          |               |     |
//   |        |                |          |               |     |
//   |        |                |          |               |     |
//   |        |                |          |               |     |
//   |        |                |          |               |     |
//   |        | GMII           |          |               |     |
// <----------| Rx             |<---------|               |<--------
//   |        |                |          |               |     |
//   |        ------------------          -----------------     |
//   |                                                          |
//   ------------------------------------------------------------
//
//


`timescale 1 ps/1 ps
(* DowngradeIPIdentifiedWarnings="yes" *)

//------------------------------------------------------------------------------
// The module declaration for the Core Block wrapper.
//------------------------------------------------------------------------------

module gig_ethernet_pcs_pma_0_block #
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


      output       resetdone,             // The GT transceiver has completed its reset cycle
      output       mmcm_reset, 
      input        mmcm_locked,           // locked indication from MMCM
      input        userclk,               
      input        userclk2,              
      input        rxuserclk,            
      input        rxuserclk2,           
      input        independent_clock_bufg,
      input        pma_reset,             // transceiver PMA reset signal
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
      input        reset,                 // Asynchronous reset for entire core.
      input        signal_detect          // Input from PMD to indicate presence of optical input.
   );


   //---------------------------------------------------------------------------
   // Internal signals used in this block level wrapper.
   //---------------------------------------------------------------------------
   // Core <=> Transceiver interconnect
   wire         plllock;                  // The PLL Locked status of the Transceiver
   wire         mgt_rx_reset;             // Reset for the receiver half of the Transceiver
   wire         mgt_tx_reset;             // Reset for the transmitter half of the Transceiver
   wire [1:0]   rxbufstatus;              // Elastic Buffer Status (bit 1 asserted indicates  overflow or underflow).
   wire         rxchariscomma;            // Comma detected in RXDATA.
   wire         rxcharisk;                // K character received (or extra data bit) in RXDATA.
   wire [2:0]   rxclkcorcnt;              // Indicates clock correction.
   wire [7:0]   rxdata;                   // Data after 8B/10B decoding.
   wire         rxrundisp;                // Running Disparity after current byte, becomes 9th data bit when RXNOTINTABLE='1'.
   wire         rxdisperr;                // Disparity-error in RXDATA.
   wire         rxnotintable;             // Non-existent 8B/10 code indicated.
   wire         txbuferr;                 // TX Buffer error (overflow or underflow).
   wire         powerdown;                // Powerdown the Transceiver
   wire         txchardispmode;           // Set running disparity for current byte.
   wire         txchardispval;            // Set running disparity value.
   wire         txcharisk;                // K character transmitted in TXDATA.
   wire [7:0]   txdata;                   // Data for 8B/10B encoding.
   wire         enablealign;              // Allow the transceivers to serially realign to a comma character.

//
//    parameter gt_rx_byte_width_ver = 1;
//



   wire resetdone_i;
   wire reset_done;
   wire reset_done_i;
   wire [15:0] rx_gt_nominal_latency;

   wire mdio_o_int;



assign mdio_o  =  mdio_o_int;
assign rx_gt_nominal_latency = 'd216;
  


   //---------------------------------------------------------------------------
   // Instantiate the core
   //---------------------------------------------------------------------------
   gig_ethernet_pcs_pma_v16_2_9 #(
       .C_ELABORATION_TRANSIENT_DIR ("BlankString"),
       .C_COMPONENT_NAME            ("gig_ethernet_pcs_pma_0"),
       .C_RX_GMII_CLK               ("TXOUTCLK"),
       .C_FAMILY                    ("artixuplus"),
       .C_IS_SGMII                  (1'b0),
       .C_USE_TRANSCEIVER           (1'b1),
       .C_HAS_TEMAC                 (1'b1),
       .C_USE_TBI                   (1'b0),
       .C_USE_LVDS                  (1'b0),
       .C_HAS_AN                    (1'b0),
       .C_HAS_MDIO                  (1'b1),
       .C_HAS_AXIL                  (1'b0),
       .C_SGMII_PHY_MODE            (1'b0),
       .C_DYNAMIC_SWITCHING         (1'b0),
       .C_SGMII_FABRIC_BUFFER       (1'b1),
       .C_1588                      (0 ),
       .B_SHIFTER_ADDR              (10'b1001010000),
       .C_2_5G                      (1'b0),
       .GT_RX_BYTE_WIDTH            (1 )
     )
   gig_ethernet_pcs_pma_0_core
     (
      .mgt_rx_reset          (mgt_rx_reset),
      .mgt_tx_reset          (mgt_tx_reset),
      .speed_is_10_100       (1'b0),
      .speed_is_100          (1'b0),
      
      .rx_gt_nominal_latency (rx_gt_nominal_latency),
      .userclk               (userclk2),
      .userclk2              (userclk2),
      .dcm_locked            (mmcm_locked),
      .rxbufstatus           (rxbufstatus),
      .rxchariscomma         (rxchariscomma),
      .rxcharisk             (rxcharisk),
      .rxclkcorcnt           (rxclkcorcnt),
      .rxdata                (rxdata),
      .rxdisperr             (rxdisperr),
      .rxnotintable          (rxnotintable),
      .rxrundisp             (rxrundisp),
      .txbuferr              (txbuferr),
      .powerdown             (powerdown),
      .txchardispmode        (txchardispmode),
      .txchardispval         (txchardispval),
      .txcharisk             (txcharisk),
      .txdata                (txdata),
      .enablealign           (enablealign),
      .rxrecclk              (rxuserclk2),
      .gmii_txd              (gmii_txd),
      .gmii_tx_en            (gmii_tx_en),
      .gmii_tx_er            (gmii_tx_er),
      .gmii_rxd              (gmii_rxd),
      .gmii_rx_dv            (gmii_rx_dv),
      .gmii_rx_er            (gmii_rx_er),
      .gmii_isolate          (gmii_isolate),
      .mdc                   (mdc),
      .mdio_in               (mdio_i),
      .mdio_out              (mdio_o_int),
      .mdio_tri              (mdio_t),
      .phyad                 (phyaddr),
      .configuration_vector  (configuration_vector),
      .configuration_valid   (configuration_valid),
      .an_interrupt          (),
      .an_adv_config_vector  (16'b0),
      .an_restart_config     (1'b0),
      .link_timer_value      (10'b0),
      .an_adv_config_val     (1'b0),
      .link_timer_basex      (10'b0),
      .link_timer_sgmii      (10'b0),
      .basex_or_sgmii        (1'b0),
      .status_vector          (status_vector),
      .an_enable              (),
      .speed_selection        (),
      .reset                  (reset),
      .signal_detect          (signal_detect),
      // drp interface used in 1588 mode
      .drp_dclk               (1'b0),
      .drp_gnt                (1'b0),
      .drp_drdy               (1'b0),
      .drp_do                 (16'b0),
      .drp_req                (),
      .drp_den                (),
      .drp_dwe                (),
      .drp_daddr              (),
      .drp_di                 (),
      // 1588 Timer input
      .systemtimer_s_field    (48'b0),
      .systemtimer_ns_field   (32'b0),
      .correction_timer       (64'b0),
      .rxphy_s_field          (),
      .rxphy_ns_field         (),
      .rxphy_correction_timer (),
      
      .gtx_clk                (1'b0),
      .rx_code_group0         (10'b0),
      .rx_code_group1         (10'b0),
      .pma_rx_clk0            (1'b0),
      .pma_rx_clk1            (1'b0),
      .tx_code_group         (),
      .loc_ref               (),
      .ewrap                 (),
      .en_cdet               (),
      .s_axi_aclk    (1'b0),
      .s_axi_resetn  (1'b0),
      .s_axi_awaddr  ('b0),
      .s_axi_awvalid (1'b0),
      .s_axi_awready (),
      .s_axi_wdata   ('b0),
      .s_axi_wvalid  (1'b0),
      .s_axi_wready  (),
      .s_axi_bresp   (),
      .s_axi_bvalid  (),
      .s_axi_bready  (1'b0 ),
      .s_axi_araddr  ('b0 ),
      .s_axi_arvalid (1'b0),
      .s_axi_arready (),
      .s_axi_rdata   (),
      .s_axi_rresp   (),
      .s_axi_rvalid  (),
      .s_axi_rready  (1'b0),  
       
      .reset_done             (reset_done_i)

      );

   //---------------------------------------------------------------------------
   //  Component Instantiation for the Series-7 Transceiver wrapper
   //---------------------------------------------------------------------------

   gig_ethernet_pcs_pma_0_transceiver #
    (
        .EXAMPLE_SIMULATION             (EXAMPLE_SIMULATION)
    )  
transceiver_inst (
      .encommaalign                        (enablealign),
      .powerdown                           (powerdown),
      .usrclk                              (userclk),
      .usrclk2                             (userclk2),
      .rxusrclk                            (rxuserclk),
      .rxusrclk2                           (rxuserclk2),
      .independent_clock                   (independent_clock_bufg),
      .data_valid                          (status_vector[1]),
      .txreset                             (mgt_tx_reset),
      .txchardispmode                      (txchardispmode),
      .txchardispval                       (txchardispval),
      .txcharisk                           (txcharisk),
      .txdata                              (txdata),
      .rxreset                             (mgt_rx_reset),
      .rxchariscomma                       (rxchariscomma),
      .rxcharisk                           (rxcharisk),
      .rxclkcorcnt                         (rxclkcorcnt),
      .rxdata                              (rxdata),
      .rxdisperr                           (rxdisperr),
      .rxnotintable                        (rxnotintable),
      .rxrundisp                           (rxrundisp),
      .rxbuferr                            (rxbufstatus[1]),
      .txbuferr                            (txbuferr),
      .mmcm_reset                          (mmcm_reset),
      .pmareset                            (pma_reset),
      .mmcm_locked                         (mmcm_locked),
      .resetdone                           (resetdone_i),
      .gtwiz_userclk_tx_active_out         (gtwiz_userclk_tx_active_out),
      .gtwiz_userclk_tx_reset_out         (gtwiz_userclk_tx_reset_out),
      .gtwiz_reset_clk_freerun_out         (gtwiz_reset_clk_freerun_out),
      .gtwiz_reset_tx_datapath_out         (gtwiz_reset_tx_datapath_out),
      .gtwiz_reset_rx_datapath_out         (gtwiz_reset_rx_datapath_out),
      .gtwiz_reset_all_out                 (gtwiz_reset_all_out),
      .gtwiz_userclk_rx_active_out         (gtwiz_userclk_rx_active_out),
      .gtwiz_reset_tx_pll_and_datapath_out (gtwiz_reset_tx_pll_and_datapath_out),
      .gtwiz_reset_rx_pll_and_datapath_out (gtwiz_reset_rx_pll_and_datapath_out),
      .gtwiz_reset_tx_done_in              (gtwiz_reset_tx_done_in),
      .gtwiz_reset_rx_done_in              (gtwiz_reset_rx_done_in),
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
      .rxcommadeten_out                    (rxcommadeten_out)
   );


  assign reset_done = resetdone_i;
  gig_ethernet_pcs_pma_0_sync_block sync_block_reset_done
        (
           .clk             (userclk2),
           .data_in         (reset_done),
           .data_out        (reset_done_i)
        );
  assign resetdone  = reset_done_i;



  // Unused
  assign rxbufstatus[0]           = 1'b0;




endmodule // gig_ethernet_pcs_pma_0_block

