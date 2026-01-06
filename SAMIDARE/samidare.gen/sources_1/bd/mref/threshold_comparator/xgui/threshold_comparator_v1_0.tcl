# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "N" -parent ${Page_0}
  ipgui::add_param $IPINST -name "channels" -parent ${Page_0}
  ipgui::add_param $IPINST -name "max_pretrigger" -parent ${Page_0}
  ipgui::add_param $IPINST -name "n_bits" -parent ${Page_0}


}

proc update_PARAM_VALUE.N { PARAM_VALUE.N } {
	# Procedure called to update N when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.N { PARAM_VALUE.N } {
	# Procedure called to validate N
	return true
}

proc update_PARAM_VALUE.channels { PARAM_VALUE.channels } {
	# Procedure called to update channels when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.channels { PARAM_VALUE.channels } {
	# Procedure called to validate channels
	return true
}

proc update_PARAM_VALUE.max_pretrigger { PARAM_VALUE.max_pretrigger } {
	# Procedure called to update max_pretrigger when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.max_pretrigger { PARAM_VALUE.max_pretrigger } {
	# Procedure called to validate max_pretrigger
	return true
}

proc update_PARAM_VALUE.n_bits { PARAM_VALUE.n_bits } {
	# Procedure called to update n_bits when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.n_bits { PARAM_VALUE.n_bits } {
	# Procedure called to validate n_bits
	return true
}


proc update_MODELPARAM_VALUE.N { MODELPARAM_VALUE.N PARAM_VALUE.N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.N}] ${MODELPARAM_VALUE.N}
}

proc update_MODELPARAM_VALUE.n_bits { MODELPARAM_VALUE.n_bits PARAM_VALUE.n_bits } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.n_bits}] ${MODELPARAM_VALUE.n_bits}
}

proc update_MODELPARAM_VALUE.channels { MODELPARAM_VALUE.channels PARAM_VALUE.channels } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.channels}] ${MODELPARAM_VALUE.channels}
}

proc update_MODELPARAM_VALUE.max_pretrigger { MODELPARAM_VALUE.max_pretrigger PARAM_VALUE.max_pretrigger } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.max_pretrigger}] ${MODELPARAM_VALUE.max_pretrigger}
}

