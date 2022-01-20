source ../script/user_env.tcl

read_lef $TECH_LEF

read_def EXT/patterns.def

define_process_corner -ext_model_index 0 x

puts "TCL: extract_parastics -cc_model 1 -context_depth 10 -coupling_threshold 2"
extract_parasitics -ext_model_file $customRules \
      -cc_model 12 -max_res 0 -context_depth 10 \
      -coupling_threshold 0.01 -debug_net_id "31030"

#puts "TCL: adjust_rc -res_factor 1.968731 -cc_factor 1.22"
#adjust_rc -res_factor 0.968731 -cc_factor 1.22

write_spef $DATA_DIR/rcx_patterns_sky130_customrules.spef

diff_spef -file $innovus_patterns_sky130_spef

#define_process_corner -ext_model_index 0 x
#extract_parasitics -ext_model_file $platformRules \
#      -cc_model 12 -max_res 0 -context_depth 10 \
#      -coupling_threshold 0.01
#
#write_spef $DATA_DIR/rcx_patterns_sky130_platformrules.spef


#diff_spef -file $innovus_patterns_sky130_spef

#read_lef $TECH_LEF
#read_def EXT/patterns.def
#bench_read_spef $DATA_DIR/rcx_patterns_sky130_customrules.spef
#write_rules -file $DATA_DIR/rcx_sky130_double_custom.rules  -db

exit
