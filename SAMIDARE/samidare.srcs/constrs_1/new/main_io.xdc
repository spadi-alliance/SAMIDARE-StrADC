###############################################
## CONFIG BANK 0
#______________________________________________
# SPI
#set_property PACKAGE_PIN V9 [get_ports SPI_CLK]
#set_property PACKAGE_PIN P8 [get_ports SPI_FCSB]
#set_property PACKAGE_PIN U8 [get_ports SPI_MOSI]
#set_property PACKAGE_PIN T8 [get_ports SPI_D1]
#set_property PACKAGE_PIN R9 [get_ports SPI_D2]
#set_property PACKAGE_PIN R8 [get_ports SPI_D3]
#set_property IOSTANDARD LVCMOS18 [get_ports SPI_*]

#______________________________________________
# JTAG

###############################################
## HP BANK 64, 65, 66
## VCCO: 1.8V
#______________________________________________
# BASE CLK pin
set_property PACKAGE_PIN L17 [get_ports BASECLK]
set_property IOSTANDARD LVCMOS18 [get_ports BASECLK]
create_clock -period 25.000 -name BASECLK [get_ports BASECLK]



#______________________________________________
# SAMPA ELINK
# SAMPA 0 SO
# SO0x 1,8,9,10 are reversed
set_property PACKAGE_PIN Y20 [get_ports {SO0P[0]}]
set_property PACKAGE_PIN Y21 [get_ports {SO0N[0]}]

set_property PACKAGE_PIN V19 [get_ports {SO0P[1]}]
set_property PACKAGE_PIN W19 [get_ports {SO0N[1]}]
set_property PACKAGE_PIN U17 [get_ports {SO0P[2]}]
set_property PACKAGE_PIN V17 [get_ports {SO0N[2]}]
set_property PACKAGE_PIN W17 [get_ports {SO0P[3]}]
set_property PACKAGE_PIN W18 [get_ports {SO0N[3]}]
set_property PACKAGE_PIN Y18 [get_ports {SO0P[4]}]
set_property PACKAGE_PIN Y19 [get_ports {SO0N[4]}]
set_property PACKAGE_PIN Y14 [get_ports {SO0P[5]}]
set_property PACKAGE_PIN Y15 [get_ports {SO0N[5]}]
set_property PACKAGE_PIN W16 [get_ports {SO0P[6]}]
set_property PACKAGE_PIN Y16 [get_ports {SO0N[6]}]
set_property PACKAGE_PIN U18 [get_ports {SO0P[7]}]
set_property PACKAGE_PIN U19 [get_ports {SO0N[7]}]
set_property PACKAGE_PIN V14 [get_ports {SO0P[8]}]
set_property PACKAGE_PIN W14 [get_ports {SO0N[8]}]
set_property PACKAGE_PIN T17 [get_ports {SO0P[9]}]
set_property PACKAGE_PIN T18 [get_ports {SO0N[9]}]
set_property PACKAGE_PIN W13 [get_ports {SO0P[10]}]
set_property PACKAGE_PIN Y13 [get_ports {SO0N[10]}]

# SAMPA 1 SO
#SO1x 1, 3, 4, 8 are reversed
set_property PACKAGE_PIN M19 [get_ports {SO1P[0]}]
set_property PACKAGE_PIN M20 [get_ports {SO1N[0]}]
set_property PACKAGE_PIN N21 [get_ports {SO1P[1]}]
set_property PACKAGE_PIN N22 [get_ports {SO1N[1]}]
set_property PACKAGE_PIN R16 [get_ports {SO1P[2]}]
set_property PACKAGE_PIN P16 [get_ports {SO1N[2]}]
set_property PACKAGE_PIN P21 [get_ports {SO1P[3]}]
set_property PACKAGE_PIN P22 [get_ports {SO1N[3]}]
set_property PACKAGE_PIN N16 [get_ports {SO1P[4]}]
set_property PACKAGE_PIN N17 [get_ports {SO1N[4]}]

set_property PACKAGE_PIN R18 [get_ports {SO1P[5]}]
set_property PACKAGE_PIN P18 [get_ports {SO1N[5]}]
set_property PACKAGE_PIN T21 [get_ports {SO1P[6]}]
set_property PACKAGE_PIN R21 [get_ports {SO1N[6]}]
set_property PACKAGE_PIN K20 [get_ports {SO1P[7]}]
set_property PACKAGE_PIN K21 [get_ports {SO1N[7]}]
set_property PACKAGE_PIN P19 [get_ports {SO1P[8]}]
set_property PACKAGE_PIN N19 [get_ports {SO1N[8]}]

set_property PACKAGE_PIN M17 [get_ports {SO1P[9]}]
set_property PACKAGE_PIN M18 [get_ports {SO1N[9]}]

set_property PACKAGE_PIN R19 [get_ports {SO1P[10]}]
set_property PACKAGE_PIN R20 [get_ports {SO1N[10]}]


# SAMPA 2 SO
#SO2x 0, 5, 9 are reversed
set_property PACKAGE_PIN G19 [get_ports {SO2P[0]}]
set_property PACKAGE_PIN G20 [get_ports {SO2N[0]}]
set_property PACKAGE_PIN G18 [get_ports {SO2P[1]}]
set_property PACKAGE_PIN F18 [get_ports {SO2N[1]}]
set_property PACKAGE_PIN G17 [get_ports {SO2P[2]}]
set_property PACKAGE_PIN F17 [get_ports {SO2N[2]}]
set_property PACKAGE_PIN H16 [get_ports {SO2P[3]}]
set_property PACKAGE_PIN H17 [get_ports {SO2N[3]}]
set_property PACKAGE_PIN H20 [get_ports {SO2P[4]}]
set_property PACKAGE_PIN H21 [get_ports {SO2N[4]}]
set_property PACKAGE_PIN K18 [get_ports {SO2P[5]}]
set_property PACKAGE_PIN K19 [get_ports {SO2N[5]}]
set_property PACKAGE_PIN K16 [get_ports {SO2P[6]}]
set_property PACKAGE_PIN J16 [get_ports {SO2N[6]}]
set_property PACKAGE_PIN M22 [get_ports {SO2P[7]}]
set_property PACKAGE_PIN L22 [get_ports {SO2N[7]}]
set_property PACKAGE_PIN J18 [get_ports {SO2P[8]}]
set_property PACKAGE_PIN J19 [get_ports {SO2N[8]}]
set_property PACKAGE_PIN H22 [get_ports {SO2P[9]}]
set_property PACKAGE_PIN G22 [get_ports {SO2N[9]}]
set_property PACKAGE_PIN L20 [get_ports {SO2P[10]}]
set_property PACKAGE_PIN L21 [get_ports {SO2N[10]}]


# SAMPA 3 SO
#SO3x 0,2, 4, 5, 6, 7, 8, 10 are reversed
set_property PACKAGE_PIN G12 [get_ports {SO3P[0]}]
set_property PACKAGE_PIN F12 [get_ports {SO3N[0]}]
set_property PACKAGE_PIN C15 [get_ports {SO3P[1]}]
set_property PACKAGE_PIN B15 [get_ports {SO3N[1]}]
set_property PACKAGE_PIN D17 [get_ports {SO3P[2]}]
set_property PACKAGE_PIN C17 [get_ports {SO3N[2]}]
set_property PACKAGE_PIN E18 [get_ports {SO3P[3]}]
set_property PACKAGE_PIN D18 [get_ports {SO3N[3]}]
set_property PACKAGE_PIN E13 [get_ports {SO3P[4]}]
set_property PACKAGE_PIN E14 [get_ports {SO3N[4]}]
set_property PACKAGE_PIN F15 [get_ports {SO3P[5]}]
set_property PACKAGE_PIN F16 [get_ports {SO3N[5]}]
set_property PACKAGE_PIN C20 [get_ports {SO3P[6]}]
set_property PACKAGE_PIN C21 [get_ports {SO3N[6]}]
set_property PACKAGE_PIN D13 [get_ports {SO3P[7]}]
set_property PACKAGE_PIN D14 [get_ports {SO3N[7]}]
set_property PACKAGE_PIN F20 [get_ports {SO3P[8]}]
set_property PACKAGE_PIN E20 [get_ports {SO3N[8]}]
set_property PACKAGE_PIN D12 [get_ports {SO3P[9]}]
set_property PACKAGE_PIN C12 [get_ports {SO3N[9]}]
set_property PACKAGE_PIN E19 [get_ports {SO3P[10]}]
set_property PACKAGE_PIN D19 [get_ports {SO3N[10]}]

set_property IOSTANDARD SLVS_400_18 [get_ports {SO0N[*]}]
set_property IOSTANDARD SLVS_400_18 [get_ports {SO0P[*]}]
set_property IOSTANDARD SLVS_400_18 [get_ports {SO1N[*]}]
set_property IOSTANDARD SLVS_400_18 [get_ports {SO1P[*]}]
set_property IOSTANDARD SLVS_400_18 [get_ports {SO2N[*]}]
set_property IOSTANDARD SLVS_400_18 [get_ports {SO2P[*]}]
set_property IOSTANDARD SLVS_400_18 [get_ports {SO3N[*]}]
set_property IOSTANDARD SLVS_400_18 [get_ports {SO3P[*]}]


#set_property DIFF_TERM TRUE [get_ports {SO0N[*]}]
#set_property DIFF_TERM TRUE [get_ports {SO0P[*]}]
#set_property DIFF_TERM TRUE [get_ports {SO1N[*]}]
#set_property DIFF_TERM TRUE [get_ports {SO1P[*]}]
#set_property DIFF_TERM TRUE [get_ports {SO2N[*]}]
#set_property DIFF_TERM TRUE [get_ports {SO2P[*]}]
#set_property DIFF_TERM TRUE [get_ports {SO3N[*]}]
#set_property DIFF_TERM TRUE [get_ports {SO3P[*]}]


#______________________________________________
# HSTL output
set_property PACKAGE_PIN AB17 [get_ports {HBTRG_P[0]}]
set_property PACKAGE_PIN AB18 [get_ports {HBTRG_N[0]}]
set_property PACKAGE_PIN AA18 [get_ports {BX_SYNC_TRG_P[0]}]
set_property PACKAGE_PIN AA16 [get_ports {TRG_P[0]}]
set_property PACKAGE_PIN AA17 [get_ports {TRG_N[0]}]
set_property PACKAGE_PIN T20 [get_ports {TRG_P[1]}]
set_property PACKAGE_PIN T22 [get_ports {TRG_P[2]}]
set_property PACKAGE_PIN C22 [get_ports {TRG_P[3]}]
set_property PACKAGE_PIN B22 [get_ports {TRG_N[3]}]
set_property PACKAGE_PIN AB20 [get_ports {CLKSOIN_P[1]}]
set_property PACKAGE_PIN AB21 [get_ports {CLKSOIN_N[1]}]
set_property PACKAGE_PIN AA21 [get_ports {CLKSOIN_P[2]}]
set_property PACKAGE_PIN AA22 [get_ports {CLKSOIN_N[2]}]


#set_property PACKAGE_PIN V21 [get_ports {HRSTB_P[3]}]
#set_property PACKAGE_PIN T22 [get_ports {HRSTB_P[2]}]
#set_property PACKAGE_PIN V22 [get_ports {HRSTB_P[1]}]
#polarity of HRSTB 1-3 are reversed
set_property PACKAGE_PIN D21 [get_ports {HRSTB_P[3]}]
set_property PACKAGE_PIN D22 [get_ports {HRSTB_N[3]}]
set_property PACKAGE_PIN V22 [get_ports {HRSTB_P[2]}]
set_property PACKAGE_PIN W22 [get_ports {HRSTB_N[2]}]
set_property PACKAGE_PIN V21 [get_ports {HRSTB_P[1]}]
set_property PACKAGE_PIN W21 [get_ports {HRSTB_N[1]}]
set_property PACKAGE_PIN AB14 [get_ports {HRSTB_P[0]}]
set_property PACKAGE_PIN AB15 [get_ports {HRSTB_N[0]}]

set_property PACKAGE_PIN F21 [get_ports {CLKSOIN_P[3]}]
set_property PACKAGE_PIN AA13 [get_ports {CLKSOIN_P[0]}]

set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports {HBTRG_N[0]}]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports {HBTRG_P[0]}]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports {BX_SYNC_TRG_N[0]}]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports {BX_SYNC_TRG_P[0]}]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports {TRG_N[*]}]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports {TRG_P[*]}]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports {HRSTB_N[*]}]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports {HRSTB_P[*]}]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports {CLKSOIN_N[*]}]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports {CLKSOIN_P[*]}]
#______________________________________________
# GPIO
set_property PACKAGE_PIN B12 [get_ports {GPIOP[0]}]
set_property PACKAGE_PIN A13 [get_ports {GPION[0]}]
set_property PACKAGE_PIN C14 [get_ports {GPIOP[1]}]
set_property PACKAGE_PIN B14 [get_ports {GPION[1]}]
set_property PACKAGE_PIN A17 [get_ports {GPION[2]}]
set_property PACKAGE_PIN A18 [get_ports {GPIOP[2]}]
set_property PACKAGE_PIN A20 [get_ports {GPION[3]}]
set_property PACKAGE_PIN A21 [get_ports {GPIOP[3]}]
set_property PACKAGE_PIN A15 [get_ports {GPION[4]}]
set_property PACKAGE_PIN A16 [get_ports {GPIOP[4]}]
set_property PACKAGE_PIN D16 [get_ports {GPIOP[5]}]
set_property PACKAGE_PIN C16 [get_ports {GPION[5]}]
set_property PACKAGE_PIN B17 [get_ports {GPIOP[6]}]
set_property PACKAGE_PIN B18 [get_ports {GPION[6]}]
set_property PACKAGE_PIN C19 [get_ports {GPIOP[7]}]
set_property PACKAGE_PIN B19 [get_ports {GPION[7]}]

set_property IOSTANDARD LVDS [get_ports {GPION[0]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {GPIOP[0]}]
set_property IOSTANDARD LVDS [get_ports {GPIOP[0]}]
set_property IOSTANDARD LVDS [get_ports {GPION[1]}]
set_property IOSTANDARD LVDS [get_ports {GPIOP[1]}]
set_property IOSTANDARD LVDS [get_ports {GPION[2]}]
set_property IOSTANDARD LVDS [get_ports {GPIOP[2]}]
set_property IOSTANDARD LVDS [get_ports {GPION[3]}]
set_property IOSTANDARD LVDS [get_ports {GPIOP[3]}]
set_property IOSTANDARD LVDS [get_ports {GPION[4]}]
set_property IOSTANDARD LVDS [get_ports {GPIOP[4]}]
set_property IOSTANDARD LVDS [get_ports {GPION[5]}]
set_property IOSTANDARD LVDS [get_ports {GPIOP[5]}]
set_property IOSTANDARD LVDS [get_ports {GPION[6]}]
set_property IOSTANDARD LVDS [get_ports {GPIOP[6]}]
set_property IOSTANDARD LVDS [get_ports {GPION[7]}]
set_property IOSTANDARD LVDS [get_ports {GPIOP[7]}]
#set_property IOSTANDARD LVDS [get_ports GPIO[*]]
#set_property IOSTANDARD LVDS [get_ports GPIOP[*]]

#______________________________________________
# MIKUMARI

#set_property IOSTANDARD LVDS [get_ports {SFP1RXP[0]}]
#set_property IOSTANDARD LVDS [get_ports {SFP1RXN[0]}]
#set_property DIFF_TERM TRUE  [get_ports SFP1RXN[0]]


#set_property IOSTANDARD LVDS [get_ports {SFP1TXN[0]}]


###############################################
## HD BANK 84
## VCCO: 1.8V
#______________________________________________
# PUSH SW
set_property PACKAGE_PIN AA10 [get_ports PUSH_SW]
set_property IOSTANDARD LVCMOS18 [get_ports PUSH_SW]
set_property PULLUP true [get_ports PUSH_SW]
#______________________________________________
# PROGBON
#set_property PULLUP TRUE [get_ports PROGBON]
#______________________________________________
# SAMPA_EN
set_property PACKAGE_PIN AA12 [get_ports SAMPA_EN_D]
set_property PACKAGE_PIN AB12 [get_ports SAMPA_EN_A]
set_property IOSTANDARD LVCMOS18 [get_ports SAMPA_EN_*]
set_property PULLDOWN true [get_ports SAMPA_EN_A]
set_property PULLDOWN true [get_ports SAMPA_EN_D]

#______________________________________________
# LED
set_property PACKAGE_PIN V12 [get_ports {LED[0]}]
set_property PACKAGE_PIN U12 [get_ports {LED[1]}]
set_property PACKAGE_PIN V10 [get_ports {LED[2]}]
set_property PACKAGE_PIN V11 [get_ports {LED[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {LED[*]}]
#______________________________________________
# DIP SW
set_property PACKAGE_PIN AB8 [get_ports {DIP_SW[0]}]
set_property PACKAGE_PIN AA8 [get_ports {DIP_SW[1]}]
set_property PACKAGE_PIN AB7 [get_ports {DIP_SW[2]}]
set_property PACKAGE_PIN AB6 [get_ports {DIP_SW[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {DIP_SW[*]}]
set_property PULLUP true [get_ports {DIP_SW[3]}]
set_property PULLUP true [get_ports {DIP_SW[2]}]
set_property PULLUP true [get_ports {DIP_SW[1]}]
set_property PULLUP true [get_ports {DIP_SW[0]}]
#______________________________________________
# EEPROM_0
#______________________________________________
# EEPROM_1


###############################################
## HD BANK 85
## VCCO: 1.2V
#______________________________________________
# SAMPA I2C
set_property PACKAGE_PIN C10 [get_ports S_I2C_SCL]
set_property PACKAGE_PIN A10 [get_ports S_I2C_SDA]
set_property IOSTANDARD LVCMOS12 [get_ports S_I2C_SCL]
set_property IOSTANDARD LVCMOS12 [get_ports S_I2C_SDA]
set_property PULLUP true [get_ports S_I2C_SCL]
set_property PULLUP true [get_ports S_I2C_SDA]


#______________________________________________
# SAMPA CONFIG
set_property PACKAGE_PIN B8 [get_ports {CLK_CFG[0]}]
set_property PACKAGE_PIN A8 [get_ports {CLK_CFG[1]}]
set_property PACKAGE_PIN B9 [get_ports {CLK_CFG[2]}]
set_property PACKAGE_PIN D11 [get_ports {CLK_CFG[3]}]
set_property PACKAGE_PIN A11 [get_ports {CLK_CFG[4]}]
set_property PACKAGE_PIN A12 [get_ports {CLK_CFG[5]}]
set_property PACKAGE_PIN B10 [get_ports {CLK_CFG[6]}]
set_property IOSTANDARD LVCMOS12 [get_ports {CLK_CFG[*]}]

set_property PACKAGE_PIN C9 [get_ports {POL[0]}]
set_property PACKAGE_PIN D8 [get_ports {CTS[0]}]
set_property PACKAGE_PIN C8 [get_ports {CG0[0]}]
set_property PACKAGE_PIN D9 [get_ports {CG1[0]}]
set_property IOSTANDARD LVCMOS12 [get_ports {POL[0]}]
set_property IOSTANDARD LVCMOS12 [get_ports {CTS[0]}]
set_property IOSTANDARD LVCMOS12 [get_ports {CG0[0]}]
set_property IOSTANDARD LVCMOS12 [get_ports {CG1[0]}]






































