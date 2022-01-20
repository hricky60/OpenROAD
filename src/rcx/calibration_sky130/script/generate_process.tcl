source user_env.tcl

read_lef $TECH_LEF

read_def ../work/EXT/patterns.def

read_process -file "processfile" -name processfile

metal_rules_gen -file "../data/ext_custom.rules" -dir "raphFiles" -name patterns -pattern 6 -write_to_solver -keep_file

exit
