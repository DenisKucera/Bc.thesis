#!/bin/bash

SIM_DIR="./xcelium_ams"
mkdir -p $SIM_DIR

xrun -clean \
     +define+XCELIUM_MS \
     -dms_cosim \
     -sv_ms \
     -wreal wreal1driver \
     -dms_trace_coercion \
     -spectre_args "+preset=mx" \
      -f /work/dku/RNM_testbench/scripts/xcelium_run.f \
     -top tb_top \
     -xmlibdirname $SIM_DIR/xcelium.d \
     -l $SIM_DIR/xrun.log \
     "$@"