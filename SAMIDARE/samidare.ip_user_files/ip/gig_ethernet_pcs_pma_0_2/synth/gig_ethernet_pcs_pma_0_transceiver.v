//------------------------------------------------------------------------------
// Title      : Top-level Transceiver GT wrapper for Ethernet
// Project    : 1G/2.5G Ethernet PCS/PMA or SGMII LogiCORE
// File       : gig_ethernet_pcs_pma_0_transceiver.v
// Author     : Xilinx
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
// Description:  This is the top-level Transceiver GT wrapper. It
//               instantiates the lower-level wrappers produced by
//               the Series-7 FPGA Transceiver GT Wrapper Wizard.
//------------------------------------------------------------------------------

`timescale 1 ps / 1 ps
(* DowngradeIPIdentifiedWarnings="yes" *)

module gig_ethernet_pcs_pma_0_transceiver #
(
    parameter EXAMPLE_SIMULATION                     =  0         // Set to 1 for simulation
)
(

   output                mmcm_reset,
   input                 encommaalign,
   input                 powerdown,
   input                 usrclk,
   input                 usrclk2,
   input                 rxusrclk,
   input                 rxusrclk2,
   input                 data_valid,
   input                 independent_clock,
   input                 txreset,
   input      [7:0]      txdata,
   input                 txchardispmode,
   input                 txchardispval,
   input                 txcharisk,
   input                 rxreset,
   output reg            rxchariscomma,
   output reg            rxcharisk,
   output reg [2:0]      rxclkcorcnt,
   output reg [7:0]      rxdata,
   output reg            rxdisperr,
   output reg            rxnotintable,
   output reg            rxrundisp,
   output reg            rxbuferr,
   output reg            txbuferr,
   input                 pmareset,
   input                 mmcm_locked,
   output                resetdone,
   output wire           gtwiz_userclk_tx_active_out,
   output wire           gtwiz_userclk_tx_reset_out,
   output wire           gtwiz_reset_clk_freerun_out,
   output wire           gtwiz_reset_tx_datapath_out,
   output wire           gtwiz_reset_rx_datapath_out,
   output wire           gtwiz_reset_all_out,
   output wire           gtwiz_userclk_rx_active_out,
   output wire           gtwiz_reset_tx_pll_and_datapath_out,
   output wire           gtwiz_reset_rx_pll_and_datapath_out,
   input                 gtwiz_reset_tx_done_in,
   input                 gtwiz_reset_rx_done_in,
   input                 rxpmaresetdone_in,
   input                 txresetdone_in,
   input                 rxresetdone_in,
   output                rxmcommaalignen_out,
   output                rxpcommaalignen_out,
   output                txelecidle_out,
   output [1 : 0]        txpd_out,
   output [1 : 0]        rxpd_out,
   output                rxusrclk_out,
   output                rxusrclk2_out,
   output                txusrclk_out,
   output                txusrclk2_out,
   output wire [15 : 0]  txctrl0_out,
   output wire [15 : 0]  txctrl1_out,
   output wire [7 : 0]   txctrl2_out,
   output wire [15 : 0]  gtwiz_userdata_tx_out, 
   input  [15 : 0]       rxctrl0_in,
   input  [15 : 0]       rxctrl1_in,
   input  [7 : 0]        rxctrl2_in,
   input  [7 : 0]        rxctrl3_in,
   input  [1 : 0]        rxclkcorcnt_in,
   input  [15 : 0]       gtwiz_userdata_rx_in,
   input  [2 : 0]        rxbufstatus_in,
   input  [1 : 0]        txbufstatus_in,
   input                 cplllock_in,
   output wire           rx8b10ben_out,
   output wire           tx8b10ben_out,
   output wire           rxcommadeten_out
);

//----------------------------------------------------------------------------
// Signal declarations
//----------------------------------------------------------------------------


wire      [2:0]  rxbufstatus;
wire      [1:0]  txbufstatus;
reg       [2:0]  rxbufstatus_reg;
reg       [1:0]  txbufstatus_reg;
wire      [1:0]  rxclkcorcnt_int;
reg              txpowerdown_reg = 1'b0;
reg              txpowerdown_double = 1'b0;
reg              txpowerdown = 1'b0;
wire      [1:0]  txpowerdown_int;

// signal used to control sampling during bus width conversions
reg              toggle = 1'b0;

// signals reclocked onto the 62.5MHz userclk source of the GT transceiver
wire             encommaalign_int;

// Register transmitter signals from the core
reg        [7:0] txdata_reg;
reg              txchardispmode_reg;
reg              txchardispval_reg;
reg              txcharisk_reg;

// Signals for data bus width doubling on the transmitter path from the core
// to the GT transceiver
reg       [15:0] txdata_double;
reg        [1:0] txchardispmode_double;
reg        [1:0] txchardispval_double;
reg        [1:0] txcharisk_double;

// Double width signals reclocked onto the 62.5MHz userclk source of the GT
// transceiver
reg       [15:0] txdata_int;
reg        [1:0] txchardispmode_int;
reg        [1:0] txchardispval_int;
reg        [1:0] txcharisk_int;

// Double width signals output from the GT transceiver on the 62.5MHz clock
// source
wire       [1:0] rxchariscomma_int;
wire       [1:0] rxcharisk_int;
wire      [15:0] rxdata_int;
wire       [1:0] rxdisperr_int;
wire       [1:0] rxnotintable_int;
wire       [1:0] rxrundisp_int;

// Double width signals reclocked on the GT's 62.5MHz clock source
reg        [1:0] rxchariscomma_reg;
reg        [1:0] rxcharisk_reg;
reg       [15:0] rxdata_reg;
reg        [1:0] rxclkcorcnt_reg;
reg        [1:0] rxdisperr_reg;
reg        [1:0] rxnotintable_reg;
reg        [1:0] rxrundisp_reg;
reg              rxpowerdown_reg = 1'b0;

// Double width signals reclocked onto the 125MHz clock source
reg        [1:0] rxchariscomma_double;
reg        [1:0] rxcharisk_double;
reg       [15:0] rxdata_double;
reg        [1:0] rxclkcorcnt_double;
reg        [1:0] rxdisperr_double;
reg        [1:0] rxnotintable_double;
reg        [1:0] rxrundisp_double;
reg              rxpowerdown_double = 1'b0;

reg              rxpowerdown = 1'b0;
wire       [1:0] rxpowerdown_int;

   assign txpowerdown_int = {2{txpowerdown}};
   assign rxpowerdown_int = {2{rxpowerdown}};

   //---------------------------------------------------------------------------
   // The core works from a 125MHz clock source, the GT transceiver fabric
   // interface works from a 62.5MHz clock source.  The following signals
   // sourced by the core therefore need to be reclocked onto the 62.5MHz
   // clock
   //---------------------------------------------------------------------------

   // Reclock encommaalign
   gig_ethernet_pcs_pma_0_reset_sync reclock_encommaalign
   (
      .clk       (usrclk2),
      .reset_in  (encommaalign),
      .reset_out (encommaalign_int)
   );

   //---------------------------------------------------------------------------
   // toggle signal used to control sampling during bus width conversions
   //---------------------------------------------------------------------------

   always @(posedge usrclk2)
   begin
       toggle <= !toggle;
   end
   
   //---------------------------------------------------------------------------
   // The core works from a 125MHz clock source, the GT transceiver fabric
   // interface works from a 62.5MHz clock source.  The following signals
   // sourced by the core therefore need to be converted to double width, then
   // resampled on the GT's 62.5MHz clock
   //---------------------------------------------------------------------------

   // Reclock the transmitter signals
   always @(posedge usrclk2)
   begin
     if (txreset) begin
       txdata_reg         <= 8'b0;
       txchardispmode_reg <= 1'b0;
       txchardispval_reg  <= 1'b0;
       txcharisk_reg      <= 1'b0;
       txpowerdown_reg    <= 1'b0;
     end
     else begin
       txdata_reg         <= txdata;
       txchardispmode_reg <= txchardispmode;
       txchardispval_reg  <= txchardispval;
       txcharisk_reg      <= txcharisk;
       txpowerdown_reg    <= powerdown;
     end
   end

   // Double the data width
   always @(posedge usrclk2)
   begin
     if (txreset) begin
       txdata_double                <= 16'b0;
       txchardispmode_double        <= 2'b0;
       txchardispval_double         <= 2'b0;
       txcharisk_double             <= 2'b0;
       txpowerdown_double           <= 1'b0;
     end
     else begin
       if (!toggle) begin
         txdata_double[7:0]         <= txdata_reg;
         txchardispmode_double[0]   <= txchardispmode_reg;
         txchardispval_double[0]    <= txchardispval_reg;
         txcharisk_double[0]        <= txcharisk_reg;
         txdata_double[15:8]        <= txdata;
         txchardispmode_double[1]   <= txchardispmode;
         txchardispval_double[1]    <= txchardispval;
         txcharisk_double[1]        <= txcharisk;
       end
       txpowerdown_double         <= txpowerdown_reg;
     end
   end

   // Cross the clock domain
   always @(posedge usrclk)
   begin
     txdata_int         <= txdata_double;
     txchardispmode_int <= txchardispmode_double;
     txchardispval_int  <= txchardispval_double;
     txcharisk_int      <= txcharisk_double;
     txbufstatus_reg    <= txbufstatus;
     txpowerdown        <= txpowerdown_double;
   end

   //---------------------------------------------------------------------------
   // The core works from a 125MHz clock source, the GT transceiver fabric
   // interface works from a 62.5MHz clock source.  The following signals
   // sourced by the GT transceiver therefore need to converted to half width
   //---------------------------------------------------------------------------

  // Sample the double width received data from the GT transsciever on the GT's
  // 62.5MHz clock
  always @(posedge usrclk)
  begin
    rxchariscomma_reg  <= rxchariscomma_int;
    rxcharisk_reg      <= rxcharisk_int;
    rxdata_reg         <= rxdata_int;
    rxclkcorcnt_reg    <= rxclkcorcnt_int;
    rxdisperr_reg      <= rxdisperr_int;
    rxnotintable_reg   <= rxnotintable_int;
    rxrundisp_reg      <= rxrundisp_int;
    rxbufstatus_reg    <= rxbufstatus;
    rxpowerdown        <= rxpowerdown_reg;
  end


  // Reclock the double width received data from the GT transsciever onto the
  // 125MHz clock source.   Both clock domains are frequency related and are
  // derived from the same MMCM: the Xilinx tools will accont for this.

  always @(posedge usrclk2)
  begin
    if (rxreset) begin
      rxchariscomma_double  <= 2'b0;
      rxcharisk_double      <= 2'b0;
      rxdata_double         <= 16'b0;
      rxclkcorcnt_double    <= 2'b0;
      rxdisperr_double      <= 2'b0;
      rxnotintable_double   <= 2'b0;
      rxrundisp_double      <= 2'b0;
      rxpowerdown_double    <= 1'b0;
    end
    else if (toggle) begin
      rxchariscomma_double  <= rxchariscomma_reg;
      rxcharisk_double      <= rxcharisk_reg;
      rxdata_double         <= rxdata_reg;
      rxclkcorcnt_double    <= rxclkcorcnt_reg;
      rxdisperr_double      <= rxdisperr_reg;
      rxnotintable_double   <= rxnotintable_reg;
      rxrundisp_double      <= rxrundisp_reg;
    end
    rxpowerdown_double      <= powerdown;
  end


  // Halve the bus width
  always @(posedge usrclk2)
  begin
    if (rxreset) begin
      rxchariscomma    <= 1'b0;
      rxcharisk        <= 1'b0;
      rxdata           <= 8'b0;
      rxclkcorcnt      <= 3'b0;
      rxdisperr        <= 1'b0;
      rxnotintable     <= 1'b0;
      rxrundisp        <= 1'b0;
      rxpowerdown_reg  <= 1'b0;
    end
    else begin
      if (!toggle) begin
        rxchariscomma  <= rxchariscomma_double[0];
        rxcharisk      <= rxcharisk_double[0];
        rxdata         <= rxdata_double[7:0];
        rxclkcorcnt    <= {1'b0, rxclkcorcnt_double};
        rxdisperr      <= rxdisperr_double[0];
        rxnotintable   <= rxnotintable_double[0];
        rxrundisp      <= rxrundisp_double[0];
      end
      else begin
        rxchariscomma  <= rxchariscomma_double[1];
        rxcharisk      <= rxcharisk_double[1];
        rxdata         <= rxdata_double[15:8];
        rxclkcorcnt    <= {1'b0, rxclkcorcnt_double};
        rxdisperr      <= rxdisperr_double[1];
        rxnotintable   <= rxnotintable_double[1];
        rxrundisp      <= rxrundisp_double[1];
      end
      rxpowerdown_reg  <= rxpowerdown_double;
    end
  end

  assign  mmcm_reset                           = !cplllock_in;
  assign  gtwiz_userclk_tx_active_out          = mmcm_locked;
  assign  gtwiz_userclk_tx_reset_out          = 1'b0;
  assign  gtwiz_userclk_rx_active_out          = rxpmaresetdone_in;
  assign  gtwiz_reset_clk_freerun_out          = independent_clock;
  assign  gtwiz_reset_all_out                  = pmareset;
  assign  gtwiz_reset_tx_pll_and_datapath_out  = 1'b0; 
  assign  gtwiz_reset_tx_datapath_out          = txreset & gtwiz_reset_tx_done_in;
  assign  gtwiz_reset_rx_pll_and_datapath_out  = 1'b0;
  assign  gtwiz_reset_rx_datapath_out          = rxreset & gtwiz_reset_rx_done_in;
  assign  rx8b10ben_out                        = 1'b1;
  assign  rxcommadeten_out                     = 1'b1;
  assign  rxmcommaalignen_out                  = encommaalign_int;
  assign  rxpcommaalignen_out                  = encommaalign_int;
  assign  txelecidle_out                       = txpowerdown_int[0];
  assign  txpd_out                             = txpowerdown_int;
  assign  rxpd_out                             = rxpowerdown_int;
  assign  rxusrclk_out                         = usrclk;
  assign  rxusrclk2_out                        = usrclk;
  assign  txusrclk_out                         = usrclk;
  assign  txusrclk2_out                        = usrclk;
  assign  tx8b10ben_out                        = 1'b1;
  assign  txctrl0_out[1:0]                     = txchardispval_int;
  assign  txctrl1_out[1:0]                     = txchardispmode_int;
  assign  txctrl2_out[1:0]                     = txcharisk_int;
  assign  txctrl0_out[15:2]                    = 14'b0;
  assign  txctrl1_out[15:2]                    = 14'b0;
  assign  txctrl2_out[7:2]                     = 6'b0;
  assign  gtwiz_userdata_tx_out                = txdata_int;
  assign  rxbufstatus                          = rxbufstatus_in;
  assign  txbufstatus                          = txbufstatus_in;
  assign  rxclkcorcnt_int                      = rxclkcorcnt_in;
  assign  rxcharisk_int                        = rxctrl0_in[1:0];
  assign  rxdisperr_int                        = rxctrl1_in[1:0];
  assign  rxchariscomma_int                    = rxctrl2_in[1:0];
  assign  rxnotintable_int                     = rxctrl3_in[1:0];
  assign  rxdata_int                           = gtwiz_userdata_rx_in;
  // Report overall status for both transmitter and receiver reset done signals
  assign resetdone                             = gtwiz_reset_tx_done_in & gtwiz_reset_rx_done_in;


  assign rxrundisp_int = 2'b0;

  // Decode the GT transceiver buffer status signals
always @(posedge usrclk2)
  begin
  rxbuferr    <= rxbufstatus_reg[2];
  txbuferr    <= txbufstatus_reg[1];
end

endmodule
