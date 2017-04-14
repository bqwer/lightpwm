# DO NOT EDIT BELOW
# -----------------------------------------

set filename [file tail [info script]]
set ipname [file rootname $filename]

set rootDir     "."
set workDir     "$rootDir/tmp"
set ipDir       "$workDir/ip"
set done_marker "$workDir/$filename.ip.done"

create_project -force $ipname $ipDir -part xc7a35ticsg324-1L -ip
set obj [get_projects]
set_property "simulator_language" "Mixed" $obj
set_property "target_language" "Verilog"  $obj

set_property target_simulator XSim [current_project]
# -----------------------------------------
# DO NOT EDIT ABOVE

# PASTE XILINX TCL BELOW
# Change ip name mentions to $ipname and specify "-dir $ipDir" after "-module_name $ipname" at the end of "create_ip" command

create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.1 -module_name $ipname -dir $ipDir
set_property -dict [list CONFIG.Fifo_Implementation {Independent_Clocks_Distributed_RAM} CONFIG.Input_Data_Width {12} CONFIG.Input_Depth {64} CONFIG.Full_Flags_Reset_Value {0} CONFIG.Output_Data_Width {12} CONFIG.Output_Depth {64} CONFIG.Reset_Type {Asynchronous_Reset} CONFIG.Data_Count_Width {6} CONFIG.Write_Data_Count_Width {6} CONFIG.Read_Data_Count_Width {6} CONFIG.Full_Threshold_Assert_Value {61} CONFIG.Full_Threshold_Negate_Value {60}] [get_ips $ipname]

# 
# PASTE XILINX TCL ABOVE

# DO NOT EDIT BELOW
# -----------------------------------------
generate_target all [get_files  $ipname.xci]
export_ip_user_files -of_objects [get_files $ipname.xci] -no_script -ip_user_files_dir $ipDir -force -quiet
export_simulation -of_objects [get_files $ipname.xci] -force -quiet

set marker [open $done_marker w+]
close $marker
