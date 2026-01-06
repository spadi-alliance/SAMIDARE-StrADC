vlib work
vlib activehdl

vlib activehdl/xpm
vlib activehdl/gig_ethernet_pcs_pma_v16_2_9
vlib activehdl/xil_defaultlib

vmap xpm activehdl/xpm
vmap gig_ethernet_pcs_pma_v16_2_9 activehdl/gig_ethernet_pcs_pma_v16_2_9
vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xpm  -sv2k12 \
"/opt/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/opt/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"/opt/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  \
"/opt/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work gig_ethernet_pcs_pma_v16_2_9 -93  \
"../../../ipstatic/hdl/gig_ethernet_pcs_pma_v16_2_rfs.vhd" \

vlog -work gig_ethernet_pcs_pma_v16_2_9  -v2k5 \
"../../../ipstatic/hdl/gig_ethernet_pcs_pma_v16_2_rfs.v" \

vlog -work xil_defaultlib  -v2k5 \
"../../../ip/gig_ethernet_pcs_pma_0_2/synth/gig_ethernet_pcs_pma_0_transceiver.v" \
"../../../ip/gig_ethernet_pcs_pma_0_2/synth/gig_ethernet_pcs_pma_0_reset_sync.v" \
"../../../ip/gig_ethernet_pcs_pma_0_2/synth/gig_ethernet_pcs_pma_0_sync_block.v" \
"../../../ip/gig_ethernet_pcs_pma_0_2/synth/gig_ethernet_pcs_pma_0_block.v" \
"../../../ip/gig_ethernet_pcs_pma_0_2/synth/gig_ethernet_pcs_pma_0.v" \

vlog -work xil_defaultlib \
"glbl.v"

