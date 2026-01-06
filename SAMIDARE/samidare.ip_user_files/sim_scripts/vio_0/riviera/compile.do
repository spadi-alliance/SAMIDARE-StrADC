vlib work
vlib riviera

vlib riviera/xpm
vlib riviera/xil_defaultlib

vmap xpm riviera/xpm
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xpm  -sv2k12 "+incdir+../../../../samidare_v0_20240515.gen/sources_1/ip/vio_0/hdl/verilog" "+incdir+../../../../samidare_v0_20240515.gen/sources_1/ip/vio_0/hdl" \
"/opt/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -93  \
"/opt/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../samidare_v0_20240515.gen/sources_1/ip/vio_0/hdl/verilog" "+incdir+../../../../samidare_v0_20240515.gen/sources_1/ip/vio_0/hdl" \
"../../../../samidare_v0_20240515.gen/sources_1/ip/vio_0/sim/vio_0.v" \


vlog -work xil_defaultlib \
"glbl.v"

