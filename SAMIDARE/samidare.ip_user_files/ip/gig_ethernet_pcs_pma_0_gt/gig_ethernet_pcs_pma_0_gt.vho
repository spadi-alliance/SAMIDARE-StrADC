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
-- IP VLNV: xilinx.com:ip:gtwizard_ultrascale:1.7
-- IP Revision: 14

-- The following code must appear in the VHDL architecture header.

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT gig_ethernet_pcs_pma_0_gt
  PORT (
    gtwiz_userclk_tx_reset_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_userclk_tx_active_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_userclk_rx_active_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_clk_freerun_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_all_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_tx_pll_and_datapath_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_tx_datapath_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_rx_pll_and_datapath_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_rx_datapath_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_rx_cdr_stable_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_tx_done_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_rx_done_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_userdata_tx_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    gtwiz_userdata_rx_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    cpllrefclksel_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    drpaddr_in : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    drpclk_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    drpdi_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    drpen_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    drpwe_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    eyescanreset_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    eyescantrigger_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gthrxn_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gthrxp_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtrefclk0_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtrefclk1_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    loopback_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    pcsrsvdin_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    rx8b10ben_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxbufreset_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxcdrhold_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxcommadeten_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxdfelpmreset_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxlpmen_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxmcommaalignen_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxpcommaalignen_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxpcsreset_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxpd_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    rxpmareset_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxpolarity_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxprbscntreset_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxprbssel_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    rxrate_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    rxusrclk_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxusrclk2_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    tx8b10ben_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    txctrl0_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    txctrl1_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    txctrl2_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    txdiffctrl_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    txelecidle_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    txinhibit_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    txpcsreset_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    txpd_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    txpmareset_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    txpolarity_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    txpostcursor_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    txprbsforceerr_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    txprbssel_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    txprecursor_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    txusrclk_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    txusrclk2_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    cplllock_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    dmonitorout_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    drpdo_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    drprdy_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    eyescandataerror_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gthtxn_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gthtxp_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtpowergood_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxbufstatus_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    rxbyteisaligned_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxbyterealign_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxclkcorcnt_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    rxcommadet_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxctrl0_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    rxctrl1_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    rxctrl2_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    rxctrl3_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    rxoutclk_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxpmaresetdone_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxprbserr_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxresetdone_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    txbufstatus_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    txoutclk_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    txpmaresetdone_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    txprgdivresetdone_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    txresetdone_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0) 
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
your_instance_name : gig_ethernet_pcs_pma_0_gt
  PORT MAP (
    gtwiz_userclk_tx_reset_in => gtwiz_userclk_tx_reset_in,
    gtwiz_userclk_tx_active_in => gtwiz_userclk_tx_active_in,
    gtwiz_userclk_rx_active_in => gtwiz_userclk_rx_active_in,
    gtwiz_reset_clk_freerun_in => gtwiz_reset_clk_freerun_in,
    gtwiz_reset_all_in => gtwiz_reset_all_in,
    gtwiz_reset_tx_pll_and_datapath_in => gtwiz_reset_tx_pll_and_datapath_in,
    gtwiz_reset_tx_datapath_in => gtwiz_reset_tx_datapath_in,
    gtwiz_reset_rx_pll_and_datapath_in => gtwiz_reset_rx_pll_and_datapath_in,
    gtwiz_reset_rx_datapath_in => gtwiz_reset_rx_datapath_in,
    gtwiz_reset_rx_cdr_stable_out => gtwiz_reset_rx_cdr_stable_out,
    gtwiz_reset_tx_done_out => gtwiz_reset_tx_done_out,
    gtwiz_reset_rx_done_out => gtwiz_reset_rx_done_out,
    gtwiz_userdata_tx_in => gtwiz_userdata_tx_in,
    gtwiz_userdata_rx_out => gtwiz_userdata_rx_out,
    cpllrefclksel_in => cpllrefclksel_in,
    drpaddr_in => drpaddr_in,
    drpclk_in => drpclk_in,
    drpdi_in => drpdi_in,
    drpen_in => drpen_in,
    drpwe_in => drpwe_in,
    eyescanreset_in => eyescanreset_in,
    eyescantrigger_in => eyescantrigger_in,
    gthrxn_in => gthrxn_in,
    gthrxp_in => gthrxp_in,
    gtrefclk0_in => gtrefclk0_in,
    gtrefclk1_in => gtrefclk1_in,
    loopback_in => loopback_in,
    pcsrsvdin_in => pcsrsvdin_in,
    rx8b10ben_in => rx8b10ben_in,
    rxbufreset_in => rxbufreset_in,
    rxcdrhold_in => rxcdrhold_in,
    rxcommadeten_in => rxcommadeten_in,
    rxdfelpmreset_in => rxdfelpmreset_in,
    rxlpmen_in => rxlpmen_in,
    rxmcommaalignen_in => rxmcommaalignen_in,
    rxpcommaalignen_in => rxpcommaalignen_in,
    rxpcsreset_in => rxpcsreset_in,
    rxpd_in => rxpd_in,
    rxpmareset_in => rxpmareset_in,
    rxpolarity_in => rxpolarity_in,
    rxprbscntreset_in => rxprbscntreset_in,
    rxprbssel_in => rxprbssel_in,
    rxrate_in => rxrate_in,
    rxusrclk_in => rxusrclk_in,
    rxusrclk2_in => rxusrclk2_in,
    tx8b10ben_in => tx8b10ben_in,
    txctrl0_in => txctrl0_in,
    txctrl1_in => txctrl1_in,
    txctrl2_in => txctrl2_in,
    txdiffctrl_in => txdiffctrl_in,
    txelecidle_in => txelecidle_in,
    txinhibit_in => txinhibit_in,
    txpcsreset_in => txpcsreset_in,
    txpd_in => txpd_in,
    txpmareset_in => txpmareset_in,
    txpolarity_in => txpolarity_in,
    txpostcursor_in => txpostcursor_in,
    txprbsforceerr_in => txprbsforceerr_in,
    txprbssel_in => txprbssel_in,
    txprecursor_in => txprecursor_in,
    txusrclk_in => txusrclk_in,
    txusrclk2_in => txusrclk2_in,
    cplllock_out => cplllock_out,
    dmonitorout_out => dmonitorout_out,
    drpdo_out => drpdo_out,
    drprdy_out => drprdy_out,
    eyescandataerror_out => eyescandataerror_out,
    gthtxn_out => gthtxn_out,
    gthtxp_out => gthtxp_out,
    gtpowergood_out => gtpowergood_out,
    rxbufstatus_out => rxbufstatus_out,
    rxbyteisaligned_out => rxbyteisaligned_out,
    rxbyterealign_out => rxbyterealign_out,
    rxclkcorcnt_out => rxclkcorcnt_out,
    rxcommadet_out => rxcommadet_out,
    rxctrl0_out => rxctrl0_out,
    rxctrl1_out => rxctrl1_out,
    rxctrl2_out => rxctrl2_out,
    rxctrl3_out => rxctrl3_out,
    rxoutclk_out => rxoutclk_out,
    rxpmaresetdone_out => rxpmaresetdone_out,
    rxprbserr_out => rxprbserr_out,
    rxresetdone_out => rxresetdone_out,
    txbufstatus_out => txbufstatus_out,
    txoutclk_out => txoutclk_out,
    txpmaresetdone_out => txpmaresetdone_out,
    txprgdivresetdone_out => txprgdivresetdone_out,
    txresetdone_out => txresetdone_out
  );
-- INST_TAG_END ------ End INSTANTIATION Template ---------

-- You must compile the wrapper file gig_ethernet_pcs_pma_0_gt.vhd when simulating
-- the core, gig_ethernet_pcs_pma_0_gt. When compiling the wrapper file, be sure to
-- reference the VHDL simulation library.



