vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xpm
vlib questa_lib/msim/gig_ethernet_pcs_pma_v16_2_9
vlib questa_lib/msim/xil_defaultlib

vmap xpm questa_lib/msim/xpm
vmap gig_ethernet_pcs_pma_v16_2_9 questa_lib/msim/gig_ethernet_pcs_pma_v16_2_9
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xpm -64 -incr -mfcu  -sv \
"/opt/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/opt/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"/opt/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93  \
"/opt/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work gig_ethernet_pcs_pma_v16_2_9 -64 -93  \
"../../../ipstatic/hdl/gig_ethernet_pcs_pma_v16_2_rfs.vhd" \

vlog -work gig_ethernet_pcs_pma_v16_2_9 -64 -incr -mfcu  \
"../../../ipstatic/hdl/gig_ethernet_pcs_pma_v16_2_rfs.v" \

vlog -work xil_defaultlib -64 -incr -mfcu  \
"../../../ip/gig_ethernet_pcs_pma_0_2/synth/gig_ethernet_pcs_pma_0_transceiver.v" \
"../../../ip/gig_ethernet_pcs_pma_0_2/synth/gig_ethernet_pcs_pma_0_reset_sync.v" \
"../../../ip/gig_ethernet_pcs_pma_0_2/synth/gig_ethernet_pcs_pma_0_sync_block.v" \
"../../../ip/gig_ethernet_pcs_pma_0_2/synth/gig_ethernet_pcs_pma_0_block.v" \
"../../../ip/gig_ethernet_pcs_pma_0_2/synth/gig_ethernet_pcs_pma_0.v" \

vlog -work xil_defaultlib \
"glbl.v"

