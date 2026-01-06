









































set_property PACKAGE_PIN A15 [get_ports {GPIOP[4]}]
set_property PACKAGE_PIN C14 [get_ports {GPION[1]}]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 4 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER true [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list top_block_i/clock_wrapper/clk_wiz_1/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 48 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[0]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[1]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[2]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[3]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[4]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[5]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[6]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[7]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[8]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[9]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[10]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[11]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[12]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[13]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[14]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[15]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[16]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[17]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[18]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[19]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[20]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[21]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[22]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[23]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[24]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[25]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[26]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[27]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[28]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[29]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[30]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[31]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[32]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[33]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[34]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[35]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[36]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[37]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[38]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[39]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[40]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[41]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[42]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[43]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[44]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[45]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[46]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/count[47]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 48 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[0]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[1]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[2]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[3]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[4]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[5]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[6]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[7]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[8]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[9]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[10]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[11]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[12]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[13]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[14]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[15]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[16]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[17]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[18]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[19]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[20]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[21]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[22]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[23]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[24]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[25]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[26]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[27]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[28]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[29]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[30]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[31]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[32]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[33]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[34]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[35]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[36]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[37]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[38]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[39]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[40]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[41]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[42]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[43]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[44]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[45]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[46]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/int_cnt[47]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 48 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[0]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[1]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[2]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[3]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[4]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[5]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[6]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[7]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[8]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[9]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[10]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[11]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[12]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[13]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[14]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[15]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[16]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[17]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[18]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[19]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[20]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[21]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[22]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[23]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[24]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[25]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[26]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[27]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[28]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[29]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[30]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[31]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[32]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[33]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[34]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[35]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[36]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[37]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[38]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[39]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[40]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[41]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[42]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[43]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[44]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[45]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[46]} {top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/ext_cnt[47]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 1 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list top_block_i/clock_wrapper/locked]]
create_debug_core u_ila_1 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_1]
set_property ALL_PROBE_SAME_MU_CNT 4 [get_debug_cores u_ila_1]
set_property C_ADV_TRIGGER true [get_debug_cores u_ila_1]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_1]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_1]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_1]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_1]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_1]
set_property port_width 1 [get_debug_ports u_ila_1/clk]
connect_debug_port u_ila_1/clk [get_nets [list top_block_i/clock_wrapper/clk_wiz_0/inst/clk_out4]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe0]
set_property port_width 1 [get_debug_ports u_ila_1/probe0]
connect_debug_port u_ila_1/probe0 [get_nets [list top_block_i/appUnit/FIFO_logic/cs_clk_sel_0/select_ext]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
