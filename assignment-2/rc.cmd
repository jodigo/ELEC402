# Cadence Encounter(R) RTL Compiler
#   version RC14.13 - v14.10-s027_1 (64-bit) built Nov 17 2014
#
# Run with the following arguments:
#   -logfile rc.log
#   -cmdfile rc.cmd

puts "================="
puts "Synthesis Started"
date
puts "================="
include load_etc.tcl
set DESIGN laundrycombo
set SYN_EFF medium
set MAP_EFF medium
set SYN_PATH "."
set PDKDIR $::env(PDKDIR)
set_attribute lib_search_path $PDKDIR/gsclib045_all_v4.4/gsclib045/timing
set_attribute library {slow_vdd1v0_basicCells.lib} 
read_hdl -sv /ubc/ece/home/ugrads/a/a0l0b/Cadence_10980150/synth/in/laundrycombo.sv
elaborate $DESIGN
puts "Runtime & Memory after 'read_hdl'"
timestat Elaboration
check_design -unresolved
read_sdc /ubc/ece/home/ugrads/a/a0l0b/Cadence_10980150/synth/in/laundrycombo.sdc
synthesize -to_generic -eff $SYN_EFF
puts "Runtime & Memory after 'synthesize -to_generic'"
timestat GENERIC
synthesize -to_mapped -eff $MAP_EFF -no_incr
puts "Runtime & Memory after 'synthesize -to_map -no_incr'"
timestat MAPPED
synthesize -to_mapped -eff $MAP_EFF -incr   
insert_tiehilo_cells
puts "Runtime & Memory after incremental synthesis"
timestat INCREMENTAL
report area > ./files_out/${DESIGN}_area.rpt
report gates > ./files_out/${DESIGN}_gates.rpt
report timing > ./files_out/${DESIGN}_timing.rpt
report power > ./files_out/${DESIGN}_power.rpt
write_hdl -mapped > ./files_out/${DESIGN}_map.v
write_sdc > ./files_out/${DESIGN}_map.sdc
write_sdf > ./files_out/${DESIGN}_map.sdf
puts "Final Runtime & Memory."
timestat FINAL
puts "====================="
puts "Synthesis Finished :)"
puts "====================="
