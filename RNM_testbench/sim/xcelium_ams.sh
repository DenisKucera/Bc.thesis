#!/bin/bash

SIM_DIR="./xcelium_ams"
mkdir -p $SIM_DIR

xrun -clean \
     -dms_cosim \
     -sv_ms \
     -spectre_args "+preset=mx" \
      -f /work/dku/RNM_testbench/scripts/xcelium_run.f \
     -top tb_top \
     -xmlibdirname $SIM_DIR/xcelium.d \
     -l $SIM_DIR/xrun.log \
     "$@"