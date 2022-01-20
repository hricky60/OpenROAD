source ./script/user_env.tcl

# Innovus on the X axis
# RCX on the Y axis

# read spef DESIGN
 read_spef -setname openrcx -filename $DATA_DIR/rcx_design_sky130_platformrules.spef
 read_spef -setname invs -filename $innovus_design_sky130_spef

# Build TCAP plot
 build_plot -plotname design_openrcx_platformrules_vs_invs_${TEMP}C -golden invs -target openrcx -datatype tcap
 build_plot -plotname design_openrcx_platformrules_vs_invs_${TEMP}C -golden invs -target openrcx -datatype xcap 
# export sorted list
 export_sorted_list -plotname design_openrcx_platformrules_vs_invs_${TEMP}C -datatype tcap -filename sorted_tcap_platformrules_${TEMP}.txt
 export_sorted_list -plotname design_openrcx_platformrules_vs_invs_${TEMP}C -datatype xcap -filename sorted_xcap_platformrules_${TEMP}.txt
# Get scale factors
 set a [get_scale_factor -plotname design_openrcx_platformrules_vs_invs_${TEMP}C -datatype tcap -recommended]
 set c [get_scale_factor -plotname design_openrcx_platformrules_vs_invs_${TEMP}C -datatype xcap -recommended]
 puts "recommended scale factor for tcap: $a "
 puts "recommended scale factor for xcap: $c "

 generate_postscript_plots -plotname design_openrcx_platformrules_vs_invs_${TEMP}C -prefix sky130hd_design_platformrules_${TEMP}C

exit
