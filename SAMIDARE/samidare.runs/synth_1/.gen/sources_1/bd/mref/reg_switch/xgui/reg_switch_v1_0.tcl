# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_ADDR_I2C_READ" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_ADDR_I2C_WRITE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_ADDR_I2C_WRITE_ALL" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_ADDR_SAMPA_READ" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_ADDR_TRGEN" -parent ${Page_0}


}

proc update_PARAM_VALUE.C_ADDR_I2C_READ { PARAM_VALUE.C_ADDR_I2C_READ } {
	# Procedure called to update C_ADDR_I2C_READ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ADDR_I2C_READ { PARAM_VALUE.C_ADDR_I2C_READ } {
	# Procedure called to validate C_ADDR_I2C_READ
	return true
}

proc update_PARAM_VALUE.C_ADDR_I2C_WRITE { PARAM_VALUE.C_ADDR_I2C_WRITE } {
	# Procedure called to update C_ADDR_I2C_WRITE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ADDR_I2C_WRITE { PARAM_VALUE.C_ADDR_I2C_WRITE } {
	# Procedure called to validate C_ADDR_I2C_WRITE
	return true
}

proc update_PARAM_VALUE.C_ADDR_I2C_WRITE_ALL { PARAM_VALUE.C_ADDR_I2C_WRITE_ALL } {
	# Procedure called to update C_ADDR_I2C_WRITE_ALL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ADDR_I2C_WRITE_ALL { PARAM_VALUE.C_ADDR_I2C_WRITE_ALL } {
	# Procedure called to validate C_ADDR_I2C_WRITE_ALL
	return true
}

proc update_PARAM_VALUE.C_ADDR_SAMPA_READ { PARAM_VALUE.C_ADDR_SAMPA_READ } {
	# Procedure called to update C_ADDR_SAMPA_READ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ADDR_SAMPA_READ { PARAM_VALUE.C_ADDR_SAMPA_READ } {
	# Procedure called to validate C_ADDR_SAMPA_READ
	return true
}

proc update_PARAM_VALUE.C_ADDR_TRGEN { PARAM_VALUE.C_ADDR_TRGEN } {
	# Procedure called to update C_ADDR_TRGEN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ADDR_TRGEN { PARAM_VALUE.C_ADDR_TRGEN } {
	# Procedure called to validate C_ADDR_TRGEN
	return true
}


proc update_MODELPARAM_VALUE.C_ADDR_I2C_WRITE { MODELPARAM_VALUE.C_ADDR_I2C_WRITE PARAM_VALUE.C_ADDR_I2C_WRITE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ADDR_I2C_WRITE}] ${MODELPARAM_VALUE.C_ADDR_I2C_WRITE}
}

proc update_MODELPARAM_VALUE.C_ADDR_I2C_READ { MODELPARAM_VALUE.C_ADDR_I2C_READ PARAM_VALUE.C_ADDR_I2C_READ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ADDR_I2C_READ}] ${MODELPARAM_VALUE.C_ADDR_I2C_READ}
}

proc update_MODELPARAM_VALUE.C_ADDR_SAMPA_READ { MODELPARAM_VALUE.C_ADDR_SAMPA_READ PARAM_VALUE.C_ADDR_SAMPA_READ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ADDR_SAMPA_READ}] ${MODELPARAM_VALUE.C_ADDR_SAMPA_READ}
}

proc update_MODELPARAM_VALUE.C_ADDR_I2C_WRITE_ALL { MODELPARAM_VALUE.C_ADDR_I2C_WRITE_ALL PARAM_VALUE.C_ADDR_I2C_WRITE_ALL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ADDR_I2C_WRITE_ALL}] ${MODELPARAM_VALUE.C_ADDR_I2C_WRITE_ALL}
}

proc update_MODELPARAM_VALUE.C_ADDR_TRGEN { MODELPARAM_VALUE.C_ADDR_TRGEN PARAM_VALUE.C_ADDR_TRGEN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ADDR_TRGEN}] ${MODELPARAM_VALUE.C_ADDR_TRGEN}
}

