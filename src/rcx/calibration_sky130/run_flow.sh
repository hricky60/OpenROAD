#!/bin/bash
RUN_DIR=`pwd`
LOGS_DIR=`cd $RUN_DIR/logs; pwd`
PLOTS_DIR=`cd $RUN_DIR/plots; pwd`

QRC=disabled
TEMP=-40
WORK_DIR=$RUN_DIR/work
SCRIPT_DIR=`cd $RUN_DIR/script; pwd`
DATA_DIR=`cd $RUN_DIR/data; pwd`
NETLIST_DIR=/import/okita1/ricardh/OpenROAD/OpenROAD-flow-scripts/flow/platforms/sky130hd
TECH_LEF=${NETLIST_DIR}/lef/sky130_fd_sc_hd.tlef
MACRO_LEF=${NETLIST_DIR}/lef/sky130_fd_sc_hd_merged.lef
LIB=${NETLIST_DIR}/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
DESIGN_DEF=/import/okita1/ricardh/OpenROAD/OpenROAD-flow-scripts/flow/results/sky130hd/gcd/base/6_final.def
INNOVUS_PATTERNS_FLOW_DIR=/import/okita1/ricardh/OpenROAD/pnr/sky130_patterns
INNOVUS_DESIGN_FLOW_DIR=/import/okita1/ricardh/OpenROAD/pnr/sky130_design
innovus_patterns_sky130_spef=$INNOVUS_PATTERNS_FLOW_DIR/innovus_patterns_sky130.spef
innovus_design_sky130_spef=$INNOVUS_DESIGN_FLOW_DIR/innovus_design_sky130.spef

sed -i -e "s|TEMP.*|TEMP $TEMP|g" -e "s|WORK_DIR.*|WORK_DIR $WORK_DIR|g" -e "s|SCRIPT_DIR.*|SCRIPT_DIR $SCRIPT_DIR|g" -e "s|set DATA_DIR.*|set DATA_DIR $DATA_DIR|g" -e "s|NETLIST_DIR.*|NETLIST_DIR ${NETLIST_DIR}|g" -e "s|TECH_LEF.*|TECH_LEF ${TECH_LEF}|g" -e "s|MACRO_LEF.*|MACRO_LEF ${MACRO_LEF}|g" -e "s|LIB.*|LIB ${LIB}|g" -e "s|DESIGN_DEF.*|DESIGN_DEF ${DESIGN_DEF}|g" -e "s|INNOVUS_PATTERNS_FLOW_DIR.*|INNOVUS_PATTERNS_FLOW_DIR ${INNOVUS_PATTERNS_FLOW_DIR}|g" -e "s|INNOVUS_DESIGN_FLOW_DIR.*|INNOVUS_DESIGN_FLOW_DIR ${INNOVUS_DESIGN_FLOW_DIR}|g" -e "s|innovus_patterns_sky130_spef.*|innovus_patterns_sky130_spef ${innovus_patterns_sky130_spef}|g" -e "s|innovus_design_sky130_spef.*|innovus_design_sky130_spef ${innovus_design_sky130_spef}|g" $SCRIPT_DIR/user_env.tcl

sed -i -e "s|set vars(rc_typ,T).*|set vars(rc_typ,T)            ${TEMP}|g" $INNOVUS_PATTERNS_FLOW_DIR/setup.tcl $INNOVUS_DESIGN_FLOW_DIR/setup.tcl
sed -i -e "s|rcOut -rc_corner rc_typ -spef innovus_patterns_sky130_.*|rcOut -rc_corner rc_typ -spef innovus_patterns_sky130_${TEMP}C.spef|g" $INNOVUS_PATTERNS_FLOW_DIR/PLUG/INNOVUS/post_init.tcl $INNOVUS_DESIGN_FLOW_DIR/PLUG/INNOVUS/post_init.tcl

if [ "$QRC" == "enabled" ]; then
	sed -i -e "s|^#set vars(rc_typ,qx_tech_file)|set vars(rc_typ,qx_tech_file)|g" $INNOVUS_PATTERNS_FLOW_DIR/setup.tcl $INNOVUS_DESIGN_FLOW_DIR/setup.tcl
	sed -i -e "s|^#set vars(signoff_extraction_engine) qrc|set vars(signoff_extraction_engine) qrc|g" $INNOVUS_PATTERNS_FLOW_DIR/setup.tcl $INNOVUS_DESIGN_FLOW_DIR/setup.tcl
	sed -i -e "s|^setExtractRCMode -engine postRoute -effortLevel low -coupled true|setExtractRCMode -engine postRoute -effortLevel signoff -coupled true|g" $INNOVUS_PATTERNS_FLOW_DIR/PLUG/INNOVUS/post_init.tcl $INNOVUS_DESIGN_FLOW_DIR/PLUG/INNOVUS/post_init.tcl
else
	sed -i -e "s|^set vars(rc_typ,qx_tech_file)|#set vars(rc_typ,qx_tech_file)|g" $INNOVUS_PATTERNS_FLOW_DIR/setup.tcl $INNOVUS_DESIGN_FLOW_DIR/setup.tcl
	sed -i -e "s|^set vars(signoff_extraction_engine) qrc|#set vars(signoff_extraction_engine) qrc|g" $INNOVUS_PATTERNS_FLOW_DIR/setup.tcl $INNOVUS_DESIGN_FLOW_DIR/setup.tcl
	sed -i -e "s|^setExtractRCMode -engine postRoute -effortLevel signoff -coupled true|setExtractRCMode -engine postRoute -effortLevel low -coupled true|g" $INNOVUS_PATTERNS_FLOW_DIR/PLUG/INNOVUS/post_init.tcl $INNOVUS_DESIGN_FLOW_DIR/PLUG/INNOVUS/post_init.tcl
fi

rm -rf $DATA_DIR
rm -rf $WORK_DIR
rm -rf $LOGS_DIR

mkdir -p $DATA_DIR
mkdir -p $WORK_DIR 
mkdir -p $WORK_DIR/EXT 
mkdir -p $LOGS_DIR 

if [ "$1" = "view" ]; then
	if [ "$3" = "platform" ]; then
		cd $RUN_DIR
		sed -i -e "s|^exit/#exit|g" $SCRIPT_DIR/run_ostrich_design_platform.tcl 
		ostrich $SCRIPT_DIR/run_ostrich_design_platform.tcl
	fi
	sed -i -e "s|^exit/#exit|g" $SCRIPT_DIR/run_ostrich_${2}.tcl 
	ostrich $SCRIPT_DIR/run_ostrich_${2}.tcl | tee $LOGS_DIR/VIEW_${2}_ostrich.log
elif [ "$1" = "all" ]; then

	cd $WORK_DIR
	openroad $SCRIPT_DIR/generate_patterns.tcl | tee $LOGS_DIR/ALL_generate_patterns.log


	cd $INNOVUS_PATTERNS_FLOW_DIR; make reset; make init | tee $LOGS_DIR/ALL_innovus_patterns_flow.log;

	cd $WORK_DIR
	openroad $SCRIPT_DIR/generate_rules.tcl | tee $LOGS_DIR/ALL_generate_rules.log

	openroad $SCRIPT_DIR/ext_patterns.tcl | tee $LOGS_DIR/ALL_ext_patterns.log

	sed -i -e "s|set vars(rc_typ,T).*|set vars(rc_typ,T)            ${TEMP}|g" $INNOVUS_DESIGN_FLOW_DIR/setup.tcl
	sed -i -e "s|rcOut -rc_corner rc_typ -spef innovus_design_sky130_.*|rcOut -rc_corner rc_typ -spef innovus_patterns_sky130_${TEMP}C.spef|g" $INNOVUS_DESIGN_FLOW_DIR/PLUG/INNOVUS/post_init.tcl

	cd $INNOVUS_DESIGN_FLOW_DIR; make reset; make init | tee $LOGS_DIR/ALL_innovus_design_flow.log;

	cd $WORK_DIR
	openroad $SCRIPT_DIR/design_spef.tcl | tee $LOGS_DIR/ALL_design_spef.log

	# Generate Ostrich plots
	cd $RUN_DIR
	sed -i -e "s|^#exit/exit|g" $SCRIPT_DIR/run_ostrich_patterns.tcl 
	sed -i -e "s|^#exit/exit|g" $SCRIPT_DIR/run_ostrich_patterns_platformrules.tcl 
	sed -i -e "s|^#exit/exit|g" $SCRIPT_DIR/run_ostrich_design.tcl 
	sed -i -e "s|^#exit/exit|g" $SCRIPT_DIR/run_ostrich_design_platformrules.tcl 

	ostrich $SCRIPT_DIR/run_ostrich_patterns.tcl | tee $LOGS_DIR/ALL_patterns_generate_plot.log
	ostrich $SCRIPT_DIR/run_ostrich_patterns_platformrules.tcl | tee $LOGS_DIR/ALL_patterns_platformrules_generate_plot.log
	rm *.diff.ps *.ratio.ps
	if [ "$QRC" == "enabled" ]; then
		mv *.ps $PLOTS_DIR/QRC_enabled/patterns/
	else
		mv *.ps $PLOTS_DIR/QRC_disabled/patterns/
	fi

	ostrich $SCRIPT_DIR/run_ostrich_design.tcl | tee $LOGS_DIR/ALL_design_generate_plot.log
	ostrich $SCRIPT_DIR/run_ostrich_design_platformrules.tcl | tee $LOGS_DIR/ALL_design_platformrules_generate_plot.log
	rm *.diff.ps *.ratio.ps
	if [ "$QRC" == "enabled" ]; then
		mv *.ps $PLOTS_DIR/QRC_enabled/design/
	else
		mv *.ps $PLOTS_DIR/QRC_disabled/design/
	fi

elif [ "$1" = "spef" ]; then
	cd $WORK_DIR
    openroad $SCRIPT_DIR/design_spef.tcl | tee $LOGS_DIR/SPEF_design_spef.log
elif [ "$1" = "rules" ]; then
    rm -rf work
    mkdir -p data
    mkdir -p work

    cd $WORK_DIR
    openroad $SCRIPT_DIR/generate_patterns.tcl | tee $LOGS_DIR/RULES_generate_patterns.log

	sed -i -e "s|set vars(rc_typ,T).*|set vars(rc_typ,T)            ${TEMP}|g" $INNOVUS_PATTERNS_FLOW_DIR/setup.tcl
	sed -i -e "s|rcOut -rc_corner rc_typ -spef innovus_patterns_sky130_.*|rcOut -rc_corner rc_typ -spef innovus_patterns_sky130_${TEMP}C.spef|g" $INNOVUS_PATTERNS_FLOW_DIR/PLUG/INNOVUS/post_init.tcl

    cd $INNOVUS_PATTERNS_FLOW_DIR; make reset; make init | tee $LOGS_DIR/RULES_innovus_patterns_flow.log;

    cd $WORK_DIR
    openroad $SCRIPT_DIR/generate_rules.tcl | tee $LOGS_DIR/RULES_generate_rules.log
elif [ "$1" = "inv" ]; then
	sed -i -e "s|set vars(rc_typ,T).*|set vars(rc_typ,T)            ${TEMP}|g" $INNOVUS_DESIGN_FLOW_DIR/setup.tcl

	sed -i -e "s|rcOut -rc_corner rc_typ -spef innovus_design_sky130_.*|rcOut -rc_corner rc_typ -spef innovus_patterns_sky130_${TEMP}C.spef|g" $INNOVUS_DESIGN_FLOW_DIR/PLUG/INNOVUS/post_init.tcl

    cd $INNOVUS_DESIGN_FLOW_DIR; make reset; make init | tee $LOGS_DIR/INV_innovus_design_flow.log;
fi

#mv -f sorted* $LOGS_DIR/
