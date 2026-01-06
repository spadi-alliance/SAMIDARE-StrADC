-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.2 (lin64) Build 3671981 Fri Oct 14 04:59:54 MDT 2022
-- Date        : Thu Jul  4 14:08:09 2024
-- Host        : e16fpga01 running 64-bit Ubuntu 22.04.4 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/nagafusa/work/spadi/Fakernet/SAMIDARE/samidare.runs/gig_ethernet_pcs_pma_0_synth_1/gig_ethernet_pcs_pma_0_stub.vhdl
-- Design      : gig_ethernet_pcs_pma_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xcau15p-sbvb484-1-i
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gig_ethernet_pcs_pma_0 is
  Port ( 
    gtwiz_reset_tx_done_in : in STD_LOGIC;
    gtwiz_reset_rx_done_in : in STD_LOGIC;
    gtwiz_userclk_tx_reset_out : out STD_LOGIC;
    gtwiz_userclk_tx_active_out : out STD_LOGIC;
    gtwiz_reset_clk_freerun_out : out STD_LOGIC;
    gtwiz_reset_tx_datapath_out : out STD_LOGIC;
    gtwiz_reset_rx_datapath_out : out STD_LOGIC;
    gtwiz_reset_all_out : out STD_LOGIC;
    gtwiz_userclk_rx_active_out : out STD_LOGIC;
    gtwiz_reset_tx_pll_and_datapath_out : out STD_LOGIC;
    gtwiz_reset_rx_pll_and_datapath_out : out STD_LOGIC;
    rxpmaresetdone_in : in STD_LOGIC;
    txresetdone_in : in STD_LOGIC;
    rxresetdone_in : in STD_LOGIC;
    rxmcommaalignen_out : out STD_LOGIC;
    rxpcommaalignen_out : out STD_LOGIC;
    txelecidle_out : out STD_LOGIC;
    txpd_out : out STD_LOGIC_VECTOR ( 1 downto 0 );
    rxpd_out : out STD_LOGIC_VECTOR ( 1 downto 0 );
    rxusrclk_out : out STD_LOGIC;
    rxusrclk2_out : out STD_LOGIC;
    txusrclk_out : out STD_LOGIC;
    txusrclk2_out : out STD_LOGIC;
    txctrl0_out : out STD_LOGIC_VECTOR ( 15 downto 0 );
    txctrl1_out : out STD_LOGIC_VECTOR ( 15 downto 0 );
    txctrl2_out : out STD_LOGIC_VECTOR ( 7 downto 0 );
    gtwiz_userdata_tx_out : out STD_LOGIC_VECTOR ( 15 downto 0 );
    rxctrl0_in : in STD_LOGIC_VECTOR ( 15 downto 0 );
    rxctrl1_in : in STD_LOGIC_VECTOR ( 15 downto 0 );
    rxctrl2_in : in STD_LOGIC_VECTOR ( 7 downto 0 );
    rxctrl3_in : in STD_LOGIC_VECTOR ( 7 downto 0 );
    rxclkcorcnt_in : in STD_LOGIC_VECTOR ( 1 downto 0 );
    gtwiz_userdata_rx_in : in STD_LOGIC_VECTOR ( 15 downto 0 );
    rxbufstatus_in : in STD_LOGIC_VECTOR ( 2 downto 0 );
    txbufstatus_in : in STD_LOGIC_VECTOR ( 1 downto 0 );
    cplllock_in : in STD_LOGIC;
    rx8b10ben_out : out STD_LOGIC;
    tx8b10ben_out : out STD_LOGIC;
    rxcommadeten_out : out STD_LOGIC;
    resetdone : out STD_LOGIC;
    mmcm_reset : out STD_LOGIC;
    mmcm_locked : in STD_LOGIC;
    userclk : in STD_LOGIC;
    userclk2 : in STD_LOGIC;
    rxuserclk : in STD_LOGIC;
    rxuserclk2 : in STD_LOGIC;
    independent_clock_bufg : in STD_LOGIC;
    pma_reset : in STD_LOGIC;
    gmii_txd : in STD_LOGIC_VECTOR ( 7 downto 0 );
    gmii_tx_en : in STD_LOGIC;
    gmii_tx_er : in STD_LOGIC;
    gmii_rxd : out STD_LOGIC_VECTOR ( 7 downto 0 );
    gmii_rx_dv : out STD_LOGIC;
    gmii_rx_er : out STD_LOGIC;
    gmii_isolate : out STD_LOGIC;
    mdc : in STD_LOGIC;
    mdio_i : in STD_LOGIC;
    mdio_o : out STD_LOGIC;
    mdio_t : out STD_LOGIC;
    phyaddr : in STD_LOGIC_VECTOR ( 4 downto 0 );
    configuration_vector : in STD_LOGIC_VECTOR ( 4 downto 0 );
    configuration_valid : in STD_LOGIC;
    status_vector : out STD_LOGIC_VECTOR ( 15 downto 0 );
    reset : in STD_LOGIC;
    signal_detect : in STD_LOGIC
  );

end gig_ethernet_pcs_pma_0;

architecture stub of gig_ethernet_pcs_pma_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "gtwiz_reset_tx_done_in,gtwiz_reset_rx_done_in,gtwiz_userclk_tx_reset_out,gtwiz_userclk_tx_active_out,gtwiz_reset_clk_freerun_out,gtwiz_reset_tx_datapath_out,gtwiz_reset_rx_datapath_out,gtwiz_reset_all_out,gtwiz_userclk_rx_active_out,gtwiz_reset_tx_pll_and_datapath_out,gtwiz_reset_rx_pll_and_datapath_out,rxpmaresetdone_in,txresetdone_in,rxresetdone_in,rxmcommaalignen_out,rxpcommaalignen_out,txelecidle_out,txpd_out[1:0],rxpd_out[1:0],rxusrclk_out,rxusrclk2_out,txusrclk_out,txusrclk2_out,txctrl0_out[15:0],txctrl1_out[15:0],txctrl2_out[7:0],gtwiz_userdata_tx_out[15:0],rxctrl0_in[15:0],rxctrl1_in[15:0],rxctrl2_in[7:0],rxctrl3_in[7:0],rxclkcorcnt_in[1:0],gtwiz_userdata_rx_in[15:0],rxbufstatus_in[2:0],txbufstatus_in[1:0],cplllock_in,rx8b10ben_out,tx8b10ben_out,rxcommadeten_out,resetdone,mmcm_reset,mmcm_locked,userclk,userclk2,rxuserclk,rxuserclk2,independent_clock_bufg,pma_reset,gmii_txd[7:0],gmii_tx_en,gmii_tx_er,gmii_rxd[7:0],gmii_rx_dv,gmii_rx_er,gmii_isolate,mdc,mdio_i,mdio_o,mdio_t,phyaddr[4:0],configuration_vector[4:0],configuration_valid,status_vector[15:0],reset,signal_detect";
begin
end;
