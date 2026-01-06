-makelib xcelium_lib/xpm -sv \
  "/opt/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "/opt/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
  "/opt/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "/opt/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/gig_ethernet_pcs_pma_v16_2_9 \
  "../../../ipstatic/hdl/gig_ethernet_pcs_pma_v16_2_rfs.vhd" \
-endlib
-makelib xcelium_lib/gig_ethernet_pcs_pma_v16_2_9 \
  "../../../ipstatic/hdl/gig_ethernet_pcs_pma_v16_2_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../ip/gig_ethernet_pcs_pma_0_2/synth/gig_ethernet_pcs_pma_0_transceiver.v" \
  "../../../ip/gig_ethernet_pcs_pma_0_2/synth/gig_ethernet_pcs_pma_0_reset_sync.v" \
  "../../../ip/gig_ethernet_pcs_pma_0_2/synth/gig_ethernet_pcs_pma_0_sync_block.v" \
  "../../../ip/gig_ethernet_pcs_pma_0_2/synth/gig_ethernet_pcs_pma_0_block.v" \
  "../../../ip/gig_ethernet_pcs_pma_0_2/synth/gig_ethernet_pcs_pma_0.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

