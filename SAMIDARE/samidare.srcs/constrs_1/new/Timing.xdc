
#set_false_path -rise_from [list [get_pins {top_block_i/reset/ [get_pins {top_block_i/reset/rst_clk_wiz_0_125M/U0/ACTIVE_LOW_PR_OUT_DFF[0].FDRE_PER_N/C}] ]set_false_path -from [get_pins {top_block_i/reset/rst_clk_wiz_1_320M1/U0/ACTIVE_LOW_PR_OUT_DFF[0].FDRE_PER_N/C}] -to [get_pins top_block_i/SO_receiver/idelay_top_v2_0/inst/IDELAYCTRL_inst0/RST]
#set_false_path -from [get_pins {top_block_i/reset/rst_clk_wiz_1_320M1/U0/ACTIVE_LOW_PR_OUT_DFF[0].FDRE_PER_N/C}] -to [get_pins top_block_i/SO_receiver/idelay_top_v2_0/inst/IDELAYCTRL_inst1_2/RST]
#set_false_path -from [get_pins {top_block_i/reset/rst_clk_wiz_1_320M1/U0/ACTIVE_LOW_PR_OUT_DFF[0].FDRE_PER_N/C}] -to [get_pins top_block_i/SO_receiver/idelay_top_v2_0/inst/IDELAYCTRL_inst3/RST]
#set_multicycle_path -from [get_clocks -of_objects [get_pins top_block_i/clock_wrapper/clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT4]] -to [get_clocks -of_objects [get_pins top_block_i/clock_wrapper/clk_wiz_1/inst/mmcme4_adv_inst/CLKOUT0]] 2

#set_multicycle_path -from [get_pins top_block_i/SO_receiver/delay_adjust_init_v1_0/inst/init_adjust_rr_reg/C] -to [get_pins {top_block_i/SO_receiver/idelay_top_v2_0/inst/controller_inst/next_state_reg[0]__0/D}] 2
#set_multicycle_path -from [get_pins {top_block_i/reset/rst_clk_wiz_1_320M1/U0/ACTIVE_LOW_PR_OUT_DFF[0].FDRE_PER_N/C}] -to [get_pins top_block_i/SO_receiver/idelay_top_v2_0/inst/IDELAYCTRL_inst0/RST] 2
#set_multicycle_path -from [get_pins {top_block_i/reset/rst_clk_wiz_1_320M1/U0/ACTIVE_LOW_PR_OUT_DFF[0].FDRE_PER_N/C}] -to [get_pins top_block_i/SO_receiver/idelay_top_v2_0/inst/IDELAYCTRL_inst1_2/RST] 2
#set_multicycle_path -from [get_pins {top_block_i/reset/rst_clk_wiz_1_320M1/U0/ACTIVE_LOW_PR_OUT_DFF[0].FDRE_PER_N/C}] -to [get_pins top_block_i/SO_receiver/idelay_top_v2_0/inst/IDELAYCTRL_inst3/RST] 2

set_false_path -from [get_pins {top_block_i/reset/rst_clk_wiz_0_125M/U0/ACTIVE_LOW_PR_OUT_DFF[0].FDRE_PER_N/C}]








