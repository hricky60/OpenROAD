source ./script/user_env.tcl

# read spef DESIGN
 read_spef -setname openrcx -filename /import/okita1/ricardh/OpenROAD/OpenROAD-flow-scripts/tools/OpenROAD/src/rcx/calibration_sky130/data/rcx_design_sky130.spef
 read_spef -setname invs -filename /import/okita1/tdene/osugooglelib/flow/pnrHD_rcx/innovus_riscv_sky130.spef

# Build TCAP plot
 build_plot -plotname openrcx_vs_invs -golden invs -target openrcx -datatype tcap
 build_plot -plotname openrcx_vs_invs -golden invs -target openrcx -datatype res
 build_plot -plotname openrcx_vs_invs -golden invs -target openrcx -datatype xcap 
# export sorted list
 export_sorted_list -plotname openrcx_vs_invs -datatype tcap -filename sorted_tcap.txt
 export_sorted_list -plotname openrcx_vs_invs -datatype res -filename sorted_res.txt
 export_sorted_list -plotname openrcx_vs_invs -datatype xcap -filename sorted_xcap.txt
# Get scale factors
 set a [get_scale_factor -plotname openrcx_vs_invs -datatype tcap -recommended]
 set b [get_scale_factor -plotname openrcx_vs_invs -datatype res -recommended]
 set c [get_scale_factor -plotname openrcx_vs_invs -datatype xcap -recommended]
 puts "recommended scale factor for tcap: $a "
 puts "recommended scale factor for res: $b "
 puts "recommended scale factor for xcap: $c "
#exit
