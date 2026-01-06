

#################################################################################################################################
# Transceiver Placement
# Full details of available transceiver locations can be found in the UltraScale documentation.
# These are sample constraints, please use correct locations for your chosen device using the same constraint format.
#################################################################################################################################
#set_property LOC GTHE3_CHANNEL_X0Y20 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[*].*gen_gthe3_channel_inst[*].GTHE3_CHANNEL_PRIM_INST}]

#-----------------------------------------------------------
# Clock source used for the IDELAY Controller (if present) -
#-----------------------------------------------------------


create_clock -name io_refclk -period 3.333 [get_ports io_refclk]

#-----------------------------------------------------------
# Clock source used for the GT free running and DRP clock
#-----------------------------------------------------------

create_clock -name independent_clock -period 20.00 [get_ports independent_clock]



create_clock -add -name gtrefclk -period 6.40 [get_ports gtrefclk_p]

create_clock -name gmii_tx_clk -period 8.000 [get_ports gmii_tx_clk]
#-----------------------------------------------------------
# GMII Tx Elastic Buffer Constraints                       -
#-----------------------------------------------------------

# Control Gray Code delay and skew across clock boundary
set_false_path -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *tx_elastic_buffer_inst/reclock_rd_addrgray*/data_sync*}] -filter {REF_PIN_NAME =~ D}]
set_false_path -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *tx_elastic_buffer_inst/reclock_wr_addrgray*/data_sync*}] -filter {REF_PIN_NAME =~ D}]

# Constrain between Distributed Memory (output data) and the 1st set of flip-flops
set_false_path -from [get_clocks gmii_tx_clk] -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *tx_elastic_buffer_inst/tx_en_fifo_reg1*}] -filter {REF_PIN_NAME =~ D}]
set_false_path -from [get_clocks gmii_tx_clk] -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *tx_elastic_buffer_inst/tx_er_fifo_reg1*}] -filter {REF_PIN_NAME =~ D}]
set_false_path -from [get_clocks gmii_tx_clk] -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *tx_elastic_buffer_inst/txd_fifo_reg1*}] -filter {REF_PIN_NAME =~ D}]

set_false_path -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *reset_sync*}] -filter {REF_PIN_NAME =~ PRE}]

set_false_path -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *core_resets_i/pma_reset_pipe_reg*}] -filter {REF_PIN_NAME =~ PRE}]
set_false_path -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *core_resets_i/pma_reset_pipe*[0]}] -filter {REF_PIN_NAME =~ D}]

create_waiver -quiet -type CDC -id {CDC-10} -user "gig_ethernet_pcs_pma" -tags "11999" -desc "The CDC-10 warning is waived as this is within the GT Wizard reset syncer"\
 -to [get_pins -of [get_cells -hier -filter {name =~ */reset_synchronizer_gtwiz_reset_*x_*_inst/rst_in_meta_reg*}] -filter {name =~ *PRE}] 

create_waiver -quiet -type CDC -id {CDC-12} -user "gig_ethernet_pcs_pma" -tags "11999" -desc "The CDC-12 warning is waived as this is within the GT Wizard reset syncer"\
-to [get_pins -of [get_cells -hier -filter {name =~ */reset_synchronizer_gtwiz_reset_*x_*_inst/rst_in_meta_reg*}] -filter {name =~ *PRE}]

create_waiver -quiet -type CDC -id {CDC-10} -user "gig_ethernet_pcs_pma" -tags "11999" -desc "The CDC-10 warning is waived as this is within the GT Wizard"\
 -from [get_pins -of [get_cells -hier -filter {name =~ */reset_synchronizer_*x_done_inst/rst_in_out_reg*}] -filter {name =~ *C}]\
 -to [get_pins -of [get_cells -hier -filter {name =~ */sync_block_reset_done/data_sync_reg1*}] -filter {name =~ *D}] 

create_waiver -quiet -type CDC -id {CDC-10} -user "gig_ethernet_pcs_pma" -tags "11999" -desc "The CDC-10 warning is waived as this is within the GT Wizard"\
 -from [get_pins -of [get_cells -hier -filter {name =~ */gen_gtwiz_buffbypass_rx_main.gen_auto_mode.gtwiz_buffbypass_*x_done_out_reg*}] -filter {name =~ *C}]\ 
 -to [get_pins -of [get_cells -hier -filter {name =~ */sync_block_reset_done/data_sync_reg1*}] -filter {name =~ *D}]

#create_waiver -quiet -type CDC -id {CDC-10} -user "gig_ethernet_pcs_pma" -tags "11999" -desc "The CDC-10 warning is waived as this is within the GT Wizard"\
# -from [get_pins -of [get_cells -hier -filter {name =~ */transceiver_inst/gtwiz_reset_*x_done_*_int_reg_reg*}] -filter {name =~ *C}]\
# -to [get_pins -of [get_cells -hier -filter {name =~ */reset_synchronizer_gtwiz_reset_*x_*_inst/rst_in_meta_reg*}] -filter {name =~ *PRE}]
#
create_waiver -quiet -type CDC -id {CDC-13} -user "gig_ethernet_pcs_pma" -tags "11999" -desc "The CDC-13 warning is waived as this is within the GT Wizard" -from [get_pins -of [get_cells -hier -filter {name =~ */reclock_encommaalign/reset_sync6*}] -filter {name =~ *C}] -to [get_pins -of [get_cells -hier -filter {name =~ */gt*_channel_gen.gen_gt*_channel_inst[0].GT*_CHANNEL_PRIM_INST*}] -filter {name =~ *RX*COMMAALIGNEN}]

create_waiver -quiet -type CDC -id {CDC-11} -user "gig_ethernet_pcs_pma" -tags "11999" -desc "The CDC-11 warning is waived as this is within the GT Wizard"\
 -from [get_pins -of [get_cells -hier -filter {name =~ */U_TXOUTCLK_FREQ_COUNTER/state_reg[0]*}] -filter {name =~ *C}]\
 -to [list [get_pins -of [get_cells -hier -filter {name =~ */U_TXOUTCLK_FREQ_COUNTER/reset_synchronizer_testclk_rst_inst/rst_in_meta_reg*}] -filter {name =~ *PRE}] [get_pins -of [get_cells -hier -filter {name =~ */U_TXOUTCLK_FREQ_COUNTER/tstclk_rst_dly1_reg*}] -filter {name =~ *D}] ]

create_waiver -quiet -type CDC -id {CDC-10} -user "gig_ethernet_pcs_pma" -tags "11999" -desc "The CDC-10 warning is waived as this is within the GT Wizard" -from [get_pins -of [get_cells -hier -filter {name =~ */gen_gtwizard_*.gen_rx_buffer_bypass_internal.gen_single_instance.gtwiz_buffbypass_rx_inst/gen_gtwiz_buffbypass_rx_main.gen_auto_mode.gtwiz_buffbypass_rx_done_out_reg*}] -filter {name =~ *C}] -to [get_pins -of [get_cells -hier -filter {name =~ */sync_block_reset_done/data_sync_reg1*}] -filter {name =~ *D}]



  ## Prevent Placer from placing Tri-Stated OBUF in HDIO Banks for ZynqUPlus and KintexUPlus Devices
  set_property PROHIBIT TRUE [get_sites -of_objects [get_tiles -filter { NAME =~ "HDIO_*"}]]
