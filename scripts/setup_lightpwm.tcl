set project lightpwm
set tmpDir      "./tmp"
set rtlDir      "./rtl"
set xdcDir      "./xdc"
set tbDir       "./tb"
set ipDir       "./ip"
set scriptsDir  "./scripts"
set done_marker "$tmpDir/$project.setup.done"

# Create project
create_project -force $project $tmpDir -part xc7a35ticsg324-1L

# Set project properties
set obj [get_projects $project]
set_property "simulator_language" "Mixed" $obj
set_property "target_language" "Verilog"  $obj

# add RTL descriptions
set rtls [glob -directory $rtlDir *.v]
foreach f $rtls {
  add_files -norecurse -fileset sources_1 $f
}

# add testbenches
set sims [glob -directory $tbDir *.v]
foreach f $sims {
  add_files -norecurse -fileset sim_1 $f
}

# add memory initialization files
set data [glob -nocomplain -directory $tbDir *.dat*]
foreach f $data {
  add_files -norecurse -fileset sources_1 $f
}

# https://raw.githubusercontent.com/Digilent/Arty/master/Resources/XDC/Arty_Master.xdc
add_files -norecurse -fileset constrs_1 $xdcDir/arty.xdc

# Get IP list
set ip_list [glob -nocomplain -directory $scriptsDir ip_*.tcl]
foreach ip $ip_list {
  set splitname [split $ip _]
  set basename [lindex $splitname 1]
  add_files -norecurse -fileset sources_1 $ipDir/$basename/$basename.xci
}

set_property top $project [get_filesets sources_1]
set_property top $project\_tb [get_filesets sim_1]

set marker [open $done_marker w]
close $marker
