################################################################################

# This XDC is used only for OOC mode of synthesis, implementation
# This constraints file contains default clock frequencies to be used during
# out-of-context flows such as OOC Synthesis and Hierarchical Designs.
# This constraints file is not used in normal top-down synthesis (default flow
# of Vivado)
################################################################################
create_clock -name BASECLK -period 25 [get_ports BASECLK]
create_clock -name SFP_CLK_P -period 6.400 [get_ports SFP_CLK_P]
create_clock -name SFP_CLK_N -period 6.400 [get_ports SFP_CLK_N]

################################################################################