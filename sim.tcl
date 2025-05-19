# simulate.tcl — TCL script to run behavioral simulation
open_project BoriSoC.xpr

add_files -fileset sim_1 ./BoriSoC.sim/testbench.vhd

launch_simulation -mode behavioral
