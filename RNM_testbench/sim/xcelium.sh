#!/bin/bash

SIM_DIR="./xcelium"
LOG_FILE="$SIM_DIR/xrun.log"
LIB_DIR="$SIM_DIR/xcelium.d"
WAVE_DIR="$SIM_DIR/waves.shm"

if [ "$1" == "clean" ]; then
    echo "Cleaning up Xcelium ballast in $SIM_DIR..."
    rm -rf $SIM_DIR/*
    echo "Done."
    exit 0
fi

mkdir -p $SIM_DIR

xrun -f /work/dku/RNM_testbench/scripts/xcelium_run.f \
     -xmlibdirname $LIB_DIR \
     -l $LOG_FILE \
     "$@"

echo "Simulation Finished. Log available at: $LOG_FILE"