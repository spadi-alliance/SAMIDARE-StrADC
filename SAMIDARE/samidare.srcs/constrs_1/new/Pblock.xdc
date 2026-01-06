#set_property UNAVAILABLE_DURING_CALIBRATION TRUE [get_ports SO0P[2]]
#set_property UNAVAILABLE_DURING_CALIBRATION TRUE [get_ports SO0P[8]]

#set_property PRESERVE true [get_nets top_block_i/SO_receiver/idelay_top_v2_0/inst/gen_SO1[*].signal_inst.u_idelay_impl_SO1/buf_data]
#set_property PRESERVE true [get_nets top_block_i/SO_receiver/idelay_top_v2_0/inst/gen_SO2[*].signal_inst.u_idelay_impl_SO2/buf_data]
#set_property PRESERVE true [get_nets top_block_i/SO_receiver/idelay_top_v2_0/inst/gen_SO3[*].signal_inst.u_idelay_impl_SO3/buf_data]


set_property IODELAY_GROUP SO0 [get_cells -hier *IDELAYCTRL_inst0*]
set_property IODELAY_GROUP SO1_2 [get_cells -hier *IDELAYCTRL_inst1*]
set_property IODELAY_GROUP SO3 [get_cells -hier *IDELAYCTRL_inst3*]
set_property IODELAY_GROUP SO0 [get_cells -hier *idelay*SO0*]
set_property IODELAY_GROUP SO1_2 [get_cells -hier *idelay*SO1*]
set_property IODELAY_GROUP SO1_2 [get_cells -hier *idelay*SO2*]
set_property IODELAY_GROUP SO3 [get_cells -hier *idelay*SO3*]













