# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "compiletime" -parent ${Page_0}
  ipgui::add_param $IPINST -name "dynamic_gen" -parent ${Page_0}
  ipgui::add_param $IPINST -name "use_pmod_gps" -parent ${Page_0}


}

proc update_PARAM_VALUE.compiletime { PARAM_VALUE.compiletime } {
	# Procedure called to update compiletime when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.compiletime { PARAM_VALUE.compiletime } {
	# Procedure called to validate compiletime
	return true
}

proc update_PARAM_VALUE.dynamic_gen { PARAM_VALUE.dynamic_gen } {
	# Procedure called to update dynamic_gen when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.dynamic_gen { PARAM_VALUE.dynamic_gen } {
	# Procedure called to validate dynamic_gen
	return true
}

proc update_PARAM_VALUE.use_pmod_gps { PARAM_VALUE.use_pmod_gps } {
	# Procedure called to update use_pmod_gps when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.use_pmod_gps { PARAM_VALUE.use_pmod_gps } {
	# Procedure called to validate use_pmod_gps
	return true
}


proc update_MODELPARAM_VALUE.compiletime { MODELPARAM_VALUE.compiletime PARAM_VALUE.compiletime } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.compiletime}] ${MODELPARAM_VALUE.compiletime}
}

proc update_MODELPARAM_VALUE.dynamic_gen { MODELPARAM_VALUE.dynamic_gen PARAM_VALUE.dynamic_gen } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.dynamic_gen}] ${MODELPARAM_VALUE.dynamic_gen}
}

proc update_MODELPARAM_VALUE.use_pmod_gps { MODELPARAM_VALUE.use_pmod_gps PARAM_VALUE.use_pmod_gps } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.use_pmod_gps}] ${MODELPARAM_VALUE.use_pmod_gps}
}

