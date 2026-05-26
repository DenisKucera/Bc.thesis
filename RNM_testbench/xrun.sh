#!/bin/bash

# Launch Xcelium with Mixed-Signal options
xrun \
  -clean \
  -dms_cosim \
  -sv_ms \
  -spectre_args "+preset=mx" \
  -gui \
  -top comparator_tb \
  amscf.scs \
  src/sv/udn_pkg.sv \
  src/sv/comparator_RNM.sv \
  src/tb/comparator_tb.sv