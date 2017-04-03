# DO NOT EDIT BELOW
# -----------------------------------------

set filename [file tail [info script]]
set name [file rootname $filename]
set ipname [lindex [split $name _] 1]

set rm_prefix_and_name [join [lreplace $name 0 1] _]
set project            [lreplace [lreverse [split $rm_prefix_and_name .]] 0 0]

set thisDir [file dirname [info script]]
set rootDir     "../../.."
set workDir     "$rootDir/vivado/workdir"
set hdlDir      "$rootDir/hdl"
set tbDir       "$rootDir/tb"
set xdcDir      "$rootDir/vivado/xdc"
set ipDir       "$workDir/ip"
set done_marker "$workDir/$filename.ip.done"

create_project -force $ipname\_$project $ipDir -part xc7a35ticsg324-1L -ip
set obj [get_projects]
set_property "simulator_language" "Mixed" $obj
set_property "target_language" "Verilog"  $obj

set_property target_simulator XSim [current_project]
# -----------------------------------------
# DO NOT EDIT ABOVE

# PASTE XILINX TCL BELOW
# Change ip name mentions to $ipname and specify "-dir $ipDir" after "-module_name $ipname" at the end of "create_ip" command

create_ip -name xbip_dsp48_macro -vendor xilinx.com -library ip -version 3.0 -module_name $ipname -dir $ipDir
set_property -dict [list CONFIG.instruction1 {A*B+PCIN>>17} CONFIG.pipeline_options {Expert} CONFIG.areg_3 {false} CONFIG.breg_3 {false} CONFIG.preg_6 {true} CONFIG.a_width {25} CONFIG.has_a_ce {true} CONFIG.has_b_ce {true} CONFIG.areg_4 {true} CONFIG.breg_4 {true} CONFIG.creg_3 {false} CONFIG.creg_4 {false} CONFIG.creg_5 {false} CONFIG.mreg_5 {true} CONFIG.has_m_ce {true} CONFIG.d_width {18} CONFIG.a_binarywidth {0} CONFIG.b_width {18} CONFIG.b_binarywidth {0} CONFIG.concat_width {48} CONFIG.concat_binarywidth {0} CONFIG.c_binarywidth {0} CONFIG.pcin_binarywidth {0} CONFIG.has_p_ce {true}] [get_ips $ipname]

#
# PASTE XILINX TCL ABOVE

# DO NOT EDIT BELOW
# -----------------------------------------
generate_target all [get_files  $ipname.xci]
export_ip_user_files -of_objects [get_files $ipname.xci] -no_script -ip_user_files_dir $ipDir -force -quiet
export_simulation -of_objects [get_files $ipname.xci] -force -quiet

set marker [open $done_marker w+]
close $marker
