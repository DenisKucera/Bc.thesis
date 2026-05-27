#!/bin/bash

# --- CONFIGURATION ---
SIM_DIR="./xcelium"
LOG_FILE="$SIM_DIR/xrun.log"
LIB_DIR="$SIM_DIR/xcelium.d"
WAVE_DIR="$SIM_DIR/waves.shm"

# --- ARGUMENT HANDLING ---
if [ "$1" == "clean" ]; then
    echo "Cleaning up Xcelium ballast in $SIM_DIR..."
    rm -rf $SIM_DIR/*
    echo "Done."
    exit 0
fi

# --- PRE-RUN SETUP ---
mkdir -p $SIM_DIR

# "$@" allows you to pass extra UVM arguments like: ./run_sim.sh +UVM_VERBOSITY=UVM_HIGH
xrun -f /work/dku/RNM_testbench/scripts/xcelium_run.f \
     -xmlibdirname $LIB_DIR \
     -l $LOG_FILE \
     "$@"

echo "Simulation Finished. Log available at: $LOG_FILE"