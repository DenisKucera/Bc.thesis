#!/bin/bash

SIM_DIR="./vcs_dig"
mkdir -p $SIM_DIR

RUN_GUI=0
VCS_ARGS=""

for arg in "$@"; do
    if [ "$arg" == "-gui" ] || [ "$arg" == "-verdi" ]; then
        RUN_GUI=1
    else
        VCS_ARGS="$VCS_ARGS $arg"
    fi
done

vcs -sverilog \
    -ntb_opts uvm \
    -timescale=1ns/1ps \
    -kdb \
    -debug_access+all \
    -f /work/dku/RNM_testbench/scripts/vcs_run.f \
    -pvalue+tb_top.ENABLE_AMS=0 \
    -pvalue+tb_top.TEST_DUT=0 \
    -Mdir=$SIM_DIR/csrc \
    -o $SIM_DIR/simv \
    -l $SIM_DIR/vcs_compile.log \
    "$VCS_ARGS"

# Step 2: Check if compilation succeeded
if [ $? -eq 0 ]; then
    echo "Compilation Successful. Starting Simulation..."
    
    # Základní příkaz pro spuštění
    SIM_CMD="$SIM_DIR/simv +UVM_TESTNAME=comp_test_sanity -l $SIM_DIR/vcs_sim.log"
    
    if [ $RUN_GUI -eq 1 ]; then
        echo "Launching Verdi GUI..."
        $SIM_CMD -verdi
    else
        echo "Running in console mode..."
        $SIM_CMD
    fi
else
    echo "VCS Compilation Failed. Check $SIM_DIR/vcs_compile.log"
    exit 1
fi