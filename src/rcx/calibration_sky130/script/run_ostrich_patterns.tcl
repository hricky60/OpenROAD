source ./script/user_env.tcl

# read spef PATTERS
 read_spef -setname openrcx -filename $DATA_DIR/rcx_patterns_sky130_customrules.spef
 read_spef -setname invs -filename $innovus_patterns_sky130_spef


# Build TCAP plot
 build_plot -plotname patterns_openrcx_customrules_vs_invs_${TEMP}C -golden invs -target openrcx -datatype tcap
 build_plot -plotname patterns_openrcx_customrules_vs_invs_${TEMP}C -golden invs -target openrcx -datatype xcap 
# export sorted list
 export_sorted_list -plotname patterns_openrcx_customrules_vs_invs_${TEMP}C -datatype tcap -filename sorted_customrules_tcap_${TEMP}C.txt
 export_sorted_list -plotname patterns_openrcx_customrules_vs_invs_${TEMP}C -datatype xcap -filename sorted_customrules_xcap_${TEMP}C.txt

# Get scale factors
 set a [get_scale_factor -plotname patterns_openrcx_customrules_vs_invs_${TEMP}C -datatype tcap -recommended]
 set c [get_scale_factor -plotname patterns_openrcx_customrules_vs_invs_${TEMP}C -datatype xcap -recommended]
 puts "recommended scale factor for tcap: $a "
 puts "recommended scale factor for xcap: $c "
 
# Generate postscript plots
 generate_postscript_plots -plotname patterns_openrcx_customrules_vs_invs_${TEMP}C -prefix sky130hd_patterns_customrules_${TEMP}C

exit
