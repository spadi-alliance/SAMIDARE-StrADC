# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DATA_W" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INACT_TIMEOUT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PAGE_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PAGE_SIZE_LOG2" -parent ${Page_0}


}

proc update_PARAM_VALUE.DATA_W { PARAM_VALUE.DATA_W } {
	# Procedure called to update DATA_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_W { PARAM_VALUE.DATA_W } {
	# Procedure called to validate DATA_W
	return true
}

proc update_PARAM_VALUE.INACT_TIMEOUT { PARAM_VALUE.INACT_TIMEOUT } {
	# Procedure called to update INACT_TIMEOUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INACT_TIMEOUT { PARAM_VALUE.INACT_TIMEOUT } {
	# Procedure called to validate INACT_TIMEOUT
	return true
}

proc update_PARAM_VALUE.PAGE_SIZE { PARAM_VALUE.PAGE_SIZE } {
	# Procedure called to update PAGE_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PAGE_SIZE { PARAM_VALUE.PAGE_SIZE } {
	# Procedure called to validate PAGE_SIZE
	return true
}

proc update_PARAM_VALUE.PAGE_SIZE_LOG2 { PARAM_VALUE.PAGE_SIZE_LOG2 } {
	# Procedure called to update PAGE_SIZE_LOG2 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PAGE_SIZE_LOG2 { PARAM_VALUE.PAGE_SIZE_LOG2 } {
	# Procedure called to validate PAGE_SIZE_LOG2
	return true
}


proc update_MODELPARAM_VALUE.DATA_W { MODELPARAM_VALUE.DATA_W PARAM_VALUE.DATA_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_W}] ${MODELPARAM_VALUE.DATA_W}
}

proc update_MODELPARAM_VALUE.PAGE_SIZE { MODELPARAM_VALUE.PAGE_SIZE PARAM_VALUE.PAGE_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PAGE_SIZE}] ${MODELPARAM_VALUE.PAGE_SIZE}
}

proc update_MODELPARAM_VALUE.INACT_TIMEOUT { MODELPARAM_VALUE.INACT_TIMEOUT PARAM_VALUE.INACT_TIMEOUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INACT_TIMEOUT}] ${MODELPARAM_VALUE.INACT_TIMEOUT}
}

proc update_MODELPARAM_VALUE.PAGE_SIZE_LOG2 { MODELPARAM_VALUE.PAGE_SIZE_LOG2 PARAM_VALUE.PAGE_SIZE_LOG2 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PAGE_SIZE_LOG2}] ${MODELPARAM_VALUE.PAGE_SIZE_LOG2}
}

