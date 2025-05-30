# should clean the uselss files
puts "Cleaning Vivado backup and simulation files..."

foreach f [glob -nocomplain \
    *.str \
    *.wdb \
    *.backup.jou \
    *.backup.log \
    *.xpr.backup \
    xsim.ini \
    xsim.dir \
] {
    puts "Deleting $f"
    file delete -force $f
}


# simulate.tcl — TCL script to run behavioral simulation
open_project BoriSoC.xpr

add_files -fileset sim_1 ./BoriSoC.sim/testbench.vhd
add_files -fileset sources_1 ./BoriSoC.srcs/sources_1/new/IO_pack.vhd
add_files -fileset sources_1 ./BoriSoC.srcs/sources_1/new/mnemonic_pack.vhd

#set_property top testbench [get_filesets sim_1]

launch_simulation -mode behavioral

#extend simulation time
run 10 us
