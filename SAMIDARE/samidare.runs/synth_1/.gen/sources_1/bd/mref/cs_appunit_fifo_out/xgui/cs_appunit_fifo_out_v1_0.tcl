# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "COUNTER_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MAX_BIT_SAMPLES" -parent ${Page_0}


}

proc update_PARAM_VALUE.COUNTER_WIDTH { PARAM_VALUE.COUNTER_WIDTH } {
	# Procedure called to update COUNTER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.COUNTER_WIDTH { PARAM_VALUE.COUNTER_WIDTH } {
	# Procedure called to validate COUNTER_WIDTH
	return true
}

proc update_PARAM_VALUE.MAX_BIT_SAMPLES { PARAM_VALUE.MAX_BIT_SAMPLES } {
	# Procedure called to update MAX_BIT_SAMPLES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MAX_BIT_SAMPLES { PARAM_VALUE.MAX_BIT_SAMPLES } {
	# Procedure called to validate MAX_BIT_SAMPLES
	return true
}


proc update_MODELPARAM_VALUE.MAX_BIT_SAMPLES { MODELPARAM_VALUE.MAX_BIT_SAMPLES PARAM_VALUE.MAX_BIT_SAMPLES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MAX_BIT_SAMPLES}] ${MODELPARAM_VALUE.MAX_BIT_SAMPLES}
}

proc update_MODELPARAM_VALUE.COUNTER_WIDTH { MODELPARAM_VALUE.COUNTER_WIDTH PARAM_VALUE.COUNTER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.COUNTER_WIDTH}] ${MODELPARAM_VALUE.COUNTER_WIDTH}
}

