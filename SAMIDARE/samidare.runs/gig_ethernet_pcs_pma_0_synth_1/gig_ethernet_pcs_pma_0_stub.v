// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (lin64) Build 3671981 Fri Oct 14 04:59:54 MDT 2022
// Date        : Thu Jul  4 14:08:09 2024
// Host        : e16fpga01 running 64-bit Ubuntu 22.04.4 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/nagafusa/work/spadi/Fakernet/SAMIDARE/samidare.runs/gig_ethernet_pcs_pma_0_synth_1/gig_ethernet_pcs_pma_0_stub.v
// Design      : gig_ethernet_pcs_pma_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xcau15p-sbvb484-1-i
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module gig_ethernet_pcs_pma_0(gtwiz_reset_tx_done_in, 
  gtwiz_reset_rx_done_in, gtwiz_userclk_tx_reset_out, gtwiz_userclk_tx_active_out, 
  gtwiz_reset_clk_freerun_out, gtwiz_reset_tx_datapath_out, 
  gtwiz_reset_rx_datapath_out, gtwiz_reset_all_out, gtwiz_userclk_rx_active_out, 
  gtwiz_reset_tx_pll_and_datapath_out, gtwiz_reset_rx_pll_and_datapath_out, 
  rxpmaresetdone_in, txresetdone_in, rxresetdone_in, rxmcommaalignen_out, 
  rxpcommaalignen_out, txelecidle_out, txpd_out, rxpd_out, rxusrclk_out, rxusrclk2_out, 
  txusrclk_out, txusrclk2_out, txctrl0_out, txctrl1_out, txctrl2_out, gtwiz_userdata_tx_out, 
  rxctrl0_in, rxctrl1_in, rxctrl2_in, rxctrl3_in, rxclkcorcnt_in, gtwiz_userdata_rx_in, 
  rxbufstatus_in, txbufstatus_in, cplllock_in, rx8b10ben_out, tx8b10ben_out, 
  rxcommadeten_out, resetdone, mmcm_reset, mmcm_locked, userclk, userclk2, rxuserclk, rxuserclk2, 
  independent_clock_bufg, pma_reset, gmii_txd, gmii_tx_en, gmii_tx_er, gmii_rxd, gmii_rx_dv, 
  gmii_rx_er, gmii_isolate, mdc, mdio_i, mdio_o, mdio_t, phyaddr, configuration_vector, 
  configuration_valid, status_vector, reset, signal_detect)
/* synthesis syn_black_box black_box_pad_pin="gtwiz_reset_tx_done_in,gtwiz_reset_rx_done_in,gtwiz_userclk_tx_reset_out,gtwiz_userclk_tx_active_out,gtwiz_reset_clk_freerun_out,gtwiz_reset_tx_datapath_out,gtwiz_reset_rx_datapath_out,gtwiz_reset_all_out,gtwiz_userclk_rx_active_out,gtwiz_reset_tx_pll_and_datapath_out,gtwiz_reset_rx_pll_and_datapath_out,rxpmaresetdone_in,txresetdone_in,rxresetdone_in,rxmcommaalignen_out,rxpcommaalignen_out,txelecidle_out,txpd_out[1:0],rxpd_out[1:0],rxusrclk_out,rxusrclk2_out,txusrclk_out,txusrclk2_out,txctrl0_out[15:0],txctrl1_out[15:0],txctrl2_out[7:0],gtwiz_userdata_tx_out[15:0],rxctrl0_in[15:0],rxctrl1_in[15:0],rxctrl2_in[7:0],rxctrl3_in[7:0],rxclkcorcnt_in[1:0],gtwiz_userdata_rx_in[15:0],rxbufstatus_in[2:0],txbufstatus_in[1:0],cplllock_in,rx8b10ben_out,tx8b10ben_out,rxcommadeten_out,resetdone,mmcm_reset,mmcm_locked,userclk,userclk2,rxuserclk,rxuserclk2,independent_clock_bufg,pma_reset,gmii_txd[7:0],gmii_tx_en,gmii_tx_er,gmii_rxd[7:0],gmii_rx_dv,gmii_rx_er,gmii_isolate,mdc,mdio_i,mdio_o,mdio_t,phyaddr[4:0],configuration_vector[4:0],configuration_valid,status_vector[15:0],reset,signal_detect" */;
  input gtwiz_reset_tx_done_in;
  input gtwiz_reset_rx_done_in;
  output gtwiz_userclk_tx_reset_out;
  output gtwiz_userclk_tx_active_out;
  output gtwiz_reset_clk_freerun_out;
  output gtwiz_reset_tx_datapath_out;
  output gtwiz_reset_rx_datapath_out;
  output gtwiz_reset_all_out;
  output gtwiz_userclk_rx_active_out;
  output gtwiz_reset_tx_pll_and_datapath_out;
  output gtwiz_reset_rx_pll_and_datapath_out;
  input rxpmaresetdone_in;
  input txresetdone_in;
  input rxresetdone_in;
  output rxmcommaalignen_out;
  output rxpcommaalignen_out;
  output txelecidle_out;
  output [1:0]txpd_out;
  output [1:0]rxpd_out;
  output rxusrclk_out;
  output rxusrclk2_out;
  output txusrclk_out;
  output txusrclk2_out;
  output [15:0]txctrl0_out;
  output [15:0]txctrl1_out;
  output [7:0]txctrl2_out;
  output [15:0]gtwiz_userdata_tx_out;
  input [15:0]rxctrl0_in;
  input [15:0]rxctrl1_in;
  input [7:0]rxctrl2_in;
  input [7:0]rxctrl3_in;
  input [1:0]rxclkcorcnt_in;
  input [15:0]gtwiz_userdata_rx_in;
  input [2:0]rxbufstatus_in;
  input [1:0]txbufstatus_in;
  input cplllock_in;
  output rx8b10ben_out;
  output tx8b10ben_out;
  output rxcommadeten_out;
  output resetdone;
  output mmcm_reset;
  input mmcm_locked;
  input userclk;
  input userclk2;
  input rxuserclk;
  input rxuserclk2;
  input independent_clock_bufg;
  input pma_reset;
  input [7:0]gmii_txd;
  input gmii_tx_en;
  input gmii_tx_er;
  output [7:0]gmii_rxd;
  output gmii_rx_dv;
  output gmii_rx_er;
  output gmii_isolate;
  input mdc;
  input mdio_i;
  output mdio_o;
  output mdio_t;
  input [4:0]phyaddr;
  input [4:0]configuration_vector;
  input configuration_valid;
  output [15:0]status_vector;
  input reset;
  input signal_detect;
endmodule
