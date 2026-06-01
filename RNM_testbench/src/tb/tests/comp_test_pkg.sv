package comp_test_pkg;

`include "uvm_macros.svh"
import uvm_pkg::*;

import top_pkg::*;

// import UVC package
import comp_uvc_pkg::*;

// include tests
`include "comp_base_test.sv"
`include "comp_test_sanity.sv"
`include "comp_test_analog_properties.sv"
`include "comp_test_analog_violation.sv"
`include "comp_test_timing_violation.sv"
`include "comp_test_sequence_violation.sv"
`include "comp_test_disable_function.sv"
`include "comp_test_accuracy.sv"
`include "comp_test_power.sv"

endpackage : comp_test_pkg
