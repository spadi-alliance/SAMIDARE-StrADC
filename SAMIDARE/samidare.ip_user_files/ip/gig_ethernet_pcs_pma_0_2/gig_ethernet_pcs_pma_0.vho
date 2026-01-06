-- (c) Copyright 1995-2024 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.
-- IP VLNV: xilinx.com:ip:gig_ethernet_pcs_pma:16.2
-- IP Revision: 9

-- The following code must appear in the VHDL architecture header.

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT gig_ethernet_pcs_pma_0
  PORT (
    independent_clock_bufg : IN STD_LOGIC;
    resetdone : OUT STD_LOGIC;
    mmcm_reset : OUT STD_LOGIC;
    userclk : IN STD_LOGIC;
    userclk2 : IN STD_LOGIC;
    pma_reset : IN STD_LOGIC;
    mmcm_locked : IN STD_LOGIC;
    rxuserclk : IN STD_LOGIC;
    rxuserclk2 : IN STD_LOGIC;
    gmii_txd : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    gmii_tx_en : IN STD_LOGIC;
    gmii_tx_er : IN STD_LOGIC;
    gmii_rxd : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    gmii_rx_dv : OUT STD_LOGIC;
    gmii_rx_er : OUT STD_LOGIC;
    gmii_isolate : OUT STD_LOGIC;
    mdc : IN STD_LOGIC;
    mdio_i : IN STD_LOGIC;
    mdio_o : OUT STD_LOGIC;
    mdio_t : OUT STD_LOGIC;
    phyaddr : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    configuration_vector : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    configuration_valid : IN STD_LOGIC;
    status_vector : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    reset : IN STD_LOGIC;
    signal_detect : IN STD_LOGIC;
    gtwiz_userclk_tx_active_out : OUT STD_LOGIC;
    gtwiz_userclk_tx_reset_out : OUT STD_LOGIC;
    gtwiz_reset_clk_freerun_out : OUT STD_LOGIC;
    gtwiz_reset_tx_datapath_out : OUT STD_LOGIC;
    gtwiz_reset_rx_datapath_out : OUT STD_LOGIC;
    gtwiz_reset_all_out : OUT STD_LOGIC;
    gtwiz_userclk_rx_active_out : OUT STD_LOGIC;
    gtwiz_reset_tx_pll_and_datapath_out : OUT STD_LOGIC;
    gtwiz_reset_rx_pll_and_datapath_out : OUT STD_LOGIC;
    gtwiz_reset_tx_done_in : IN STD_LOGIC;
    gtwiz_reset_rx_done_in : IN STD_LOGIC;
    rxpmaresetdone_in : IN STD_LOGIC;
    txresetdone_in : IN STD_LOGIC;
    rxresetdone_in : IN STD_LOGIC;
    rxmcommaalignen_out : OUT STD_LOGIC;
    rxpcommaalignen_out : OUT STD_LOGIC;
    txelecidle_out : OUT STD_LOGIC;
    txpd_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    rxpd_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    rxusrclk_out : OUT STD_LOGIC;
    rxusrclk2_out : OUT STD_LOGIC;
    txusrclk_out : OUT STD_LOGIC;
    txusrclk2_out : OUT STD_LOGIC;
    txctrl0_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    txctrl1_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    txctrl2_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    gtwiz_userdata_tx_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    rxctrl0_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    rxctrl1_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    rxctrl2_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    rxctrl3_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    rxclkcorcnt_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    gtwiz_userdata_rx_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    rxbufstatus_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    txbufstatus_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    cplllock_in : IN STD_LOGIC;
    rx8b10ben_out : OUT STD_LOGIC;
    tx8b10ben_out : OUT STD_LOGIC;
    rxcommadeten_out : OUT STD_LOGIC 
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
your_instance_name : gig_ethernet_pcs_pma_0
  PORT MAP (
    independent_clock_bufg => independent_clock_bufg,
    resetdone => resetdone,
    mmcm_reset => mmcm_reset,
    userclk => userclk,
    userclk2 => userclk2,
    pma_reset => pma_reset,
    mmcm_locked => mmcm_locked,
    rxuserclk => rxuserclk,
    rxuserclk2 => rxuserclk2,
    gmii_txd => gmii_txd,
    gmii_tx_en => gmii_tx_en,
    gmii_tx_er => gmii_tx_er,
    gmii_rxd => gmii_rxd,
    gmii_rx_dv => gmii_rx_dv,
    gmii_rx_er => gmii_rx_er,
    gmii_isolate => gmii_isolate,
    mdc => mdc,
    mdio_i => mdio_i,
    mdio_o => mdio_o,
    mdio_t => mdio_t,
    phyaddr => phyaddr,
    configuration_vector => configuration_vector,
    configuration_valid => configuration_valid,
    status_vector => status_vector,
    reset => reset,
    signal_detect => signal_detect,
    gtwiz_userclk_tx_active_out => gtwiz_userclk_tx_active_out,
    gtwiz_userclk_tx_reset_out => gtwiz_userclk_tx_reset_out,
    gtwiz_reset_clk_freerun_out => gtwiz_reset_clk_freerun_out,
    gtwiz_reset_tx_datapath_out => gtwiz_reset_tx_datapath_out,
    gtwiz_reset_rx_datapath_out => gtwiz_reset_rx_datapath_out,
    gtwiz_reset_all_out => gtwiz_reset_all_out,
    gtwiz_userclk_rx_active_out => gtwiz_userclk_rx_active_out,
    gtwiz_reset_tx_pll_and_datapath_out => gtwiz_reset_tx_pll_and_datapath_out,
    gtwiz_reset_rx_pll_and_datapath_out => gtwiz_reset_rx_pll_and_datapath_out,
    gtwiz_reset_tx_done_in => gtwiz_reset_tx_done_in,
    gtwiz_reset_rx_done_in => gtwiz_reset_rx_done_in,
    rxpmaresetdone_in => rxpmaresetdone_in,
    txresetdone_in => txresetdone_in,
    rxresetdone_in => rxresetdone_in,
    rxmcommaalignen_out => rxmcommaalignen_out,
    rxpcommaalignen_out => rxpcommaalignen_out,
    txelecidle_out => txelecidle_out,
    txpd_out => txpd_out,
    rxpd_out => rxpd_out,
    rxusrclk_out => rxusrclk_out,
    rxusrclk2_out => rxusrclk2_out,
    txusrclk_out => txusrclk_out,
    txusrclk2_out => txusrclk2_out,
    txctrl0_out => txctrl0_out,
    txctrl1_out => txctrl1_out,
    txctrl2_out => txctrl2_out,
    gtwiz_userdata_tx_out => gtwiz_userdata_tx_out,
    rxctrl0_in => rxctrl0_in,
    rxctrl1_in => rxctrl1_in,
    rxctrl2_in => rxctrl2_in,
    rxctrl3_in => rxctrl3_in,
    rxclkcorcnt_in => rxclkcorcnt_in,
    gtwiz_userdata_rx_in => gtwiz_userdata_rx_in,
    rxbufstatus_in => rxbufstatus_in,
    txbufstatus_in => txbufstatus_in,
    cplllock_in => cplllock_in,
    rx8b10ben_out => rx8b10ben_out,
    tx8b10ben_out => tx8b10ben_out,
    rxcommadeten_out => rxcommadeten_out
  );
-- INST_TAG_END ------ End INSTANTIATION Template ---------

-- You must compile the wrapper file gig_ethernet_pcs_pma_0.vhd when simulating
-- the core, gig_ethernet_pcs_pma_0. When compiling the wrapper file, be sure to
-- reference the VHDL simulation library.



