# ####################################################################

#  Created by Encounter(R) RTL Compiler RC14.13 - v14.10-s027_1 on Mon Sep 30 18:16:44 -0700 2019

# ####################################################################

set sdc_version 1.7

set_units -capacitance 1000.0fF
set_units -time 1000.0ps

# Set the current design
current_design laundrycombo

create_clock -name "clk" -add -period 20.0 -waveform {0.0 10.0} [get_ports clk]
set_clock_gating_check -setup 0.0 
set_wire_load_mode "enclosed"
set_dont_use [get_lib_cells slow_vdd1v0/HOLDX1]
