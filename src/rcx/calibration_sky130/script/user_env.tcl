set TEMP -40
set WORK_DIR /import/okita1/ricardh/OpenROAD/OpenROAD-flow-scripts/tools/OpenROAD/src/rcx/calibration_sky130/work
set SCRIPT_DIR /import/okita1/ricardh/OpenROAD/OpenROAD-flow-scripts/tools/OpenROAD/src/rcx/calibration_sky130/script
set DATA_DIR /import/okita1/ricardh/OpenROAD/OpenROAD-flow-scripts/tools/OpenROAD/src/rcx/calibration_sky130/data
set NETLIST_DIR /import/okita1/ricardh/OpenROAD/OpenROAD-flow-scripts/flow/platforms/sky130hd
set TECH_LEF /import/okita1/ricardh/OpenROAD/OpenROAD-flow-scripts/flow/platforms/sky130hd/lef/sky130_fd_sc_hd.tlef
set MACRO_LEF /import/okita1/ricardh/OpenROAD/OpenROAD-flow-scripts/flow/platforms/sky130hd/lef/sky130_fd_sc_hd_merged.lef
set LIB /import/okita1/ricardh/OpenROAD/OpenROAD-flow-scripts/flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
set DESIGN_DEF /import/okita1/ricardh/OpenROAD/OpenROAD-flow-scripts/flow/results/sky130hd/gcd/base/6_final.def
set innovus_patterns_sky130_spef /import/okita1/ricardh/OpenROAD/pnr/sky130_patterns/innovus_patterns_sky130.spef
set innovus_design_sky130_spef /import/okita1/ricardh/OpenROAD/pnr/sky130_design/innovus_design_sky130.spef

# Technology Node 
set PROCESS_NODE 130
# Process corner
# NEEDS to be changed for different corners.
set CORNER RCmax
#Rule files
set platformRules /import/okita1/ricardh/OpenROAD/OpenROAD-flow-scripts/flow/platforms/sky130hd/rcx_patterns.rules
set customRules ${DATA_DIR}/rcx_sky130_custom.rules
set metalProcess ${DATA_DIR}/rcx_sky130_metals.process
