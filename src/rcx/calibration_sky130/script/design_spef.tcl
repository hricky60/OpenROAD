source ../script/user_env.tcl

read_lef $TECH_LEF

read_lef $MACRO_LEF

read_def $DESIGN_DEF

read_liberty $LIB

define_process_corner -ext_model_index 0 X
extract_parasitics -ext_model_file $platformRules \
	-cc_model 12 -max_res 0 -context_depth 15 \
	-coupling_threshold 0.01
write_spef $DATA_DIR/rcx_design_sky130_platformrules.spef

define_process_corner -ext_model_index 0 X
extract_parasitics -ext_model_file $customRules \
	-cc_model 12 -max_res 0 -context_depth 15 \
	-coupling_threshold 0.01
write_spef $DATA_DIR/rcx_design_sky130_customrules.spef

exit
