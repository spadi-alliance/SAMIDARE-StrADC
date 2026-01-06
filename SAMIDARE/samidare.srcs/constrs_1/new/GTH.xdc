
set_property PACKAGE_PIN H5 [get_ports SFP_CLK_N]
set_property PACKAGE_PIN H6 [get_ports SFP_CLK_P]
set_property PACKAGE_PIN F2 [get_ports SFP0RXP]
set_property PACKAGE_PIN F1 [get_ports SFP0RXN]
set_property PACKAGE_PIN E4 [get_ports SFP0TXP]
set_property PACKAGE_PIN E3 [get_ports SFP0TXN]


create_clock -period 6.400 -name SFP_CLK_P [get_ports SFP_CLK_P]

#set_property IOSTANDARD LVDS [get_ports SFP1RXP]
#set_property IOSTANDARD LVDS [get_ports SFP1RXN]
#set_property IOSTANDARD LVDS [get_ports {SFP0RXN SFP0RXP}]
#set_property DIFF_TERM TRUE  [get_ports SFP0RXP]

#set_property IOSTANDARD LVDS [get_ports SFP1TXP]
#set_property IOSTANDARD LVDS [get_ports SFP1TXN]
#set_property IOSTANDARD LVDS [get_ports {SFP0TXN SFP0TXP}]
#set_property DIFF_TERM TRUE  [get_ports SFP0TXP]
#set_property DIFF_TERM TRUE  [get_ports SFP1TX*]




















































