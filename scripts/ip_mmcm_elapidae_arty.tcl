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
#
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 5.3 -module_name $ipname -dir $ipDir
set_property -dict [list CONFIG.CLKOUT2_USED {true} CONFIG.CLKOUT3_USED {true} CONFIG.CLKOUT4_USED {true} CONFIG.PRIMARY_PORT {clk_in} CONFIG.CLK_OUT1_PORT {adc_clk} CONFIG.CLK_OUT2_PORT {dac_clk} CONFIG.CLK_OUT3_PORT {dac_nclk} CONFIG.CLK_OUT4_PORT {sys_clk} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {15.000} CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {30.000} CONFIG.CLKOUT2_REQUESTED_PHASE {-15.000} CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {30.000} CONFIG.CLKOUT3_REQUESTED_PHASE {-195.000} CONFIG.RESET_TYPE {ACTIVE_LOW} CONFIG.MMCM_DIVCLK_DIVIDE {1} CONFIG.MMCM_CLKFBOUT_MULT_F {9.000} CONFIG.MMCM_CLKOUT0_DIVIDE_F {36.000} CONFIG.MMCM_CLKOUT1_DIVIDE {18} CONFIG.MMCM_CLKOUT1_PHASE {-15.000} CONFIG.MMCM_CLKOUT2_DIVIDE {18} CONFIG.MMCM_CLKOUT2_PHASE {-15.000} CONFIG.MMCM_CLKOUT3_DIVIDE {9} CONFIG.NUM_OUT_CLKS {4} CONFIG.RESET_PORT {resetn} CONFIG.CLKOUT1_JITTER {183.467} CONFIG.CLKOUT1_PHASE_ERROR {105.461} CONFIG.CLKOUT2_JITTER {159.475} CONFIG.CLKOUT2_PHASE_ERROR {105.461} CONFIG.CLKOUT3_JITTER {159.475} CONFIG.CLKOUT3_PHASE_ERROR {105.461} CONFIG.CLKOUT4_JITTER {137.681} CONFIG.CLKOUT4_PHASE_ERROR {105.461}] [get_ips $ipname]
# 
# PASTE XILINX TCL ABOVE

# DO NOT EDIT BELOW
# -----------------------------------------
generate_target all [get_files  $ipname.xci]
export_ip_user_files -of_objects [get_files $ipname.xci] -no_script -ip_user_files_dir $ipDir -force -quiet
export_simulation -of_objects [get_files $ipname.xci] -force -quiet

set marker [open $done_marker w+]
close $marker
