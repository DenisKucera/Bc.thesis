package comp_test_pkg;

`include "uvm_macros.svh"
import uvm_pkg::*;

import top_pkg::*;

// import UVC package
import comp_uvc_pkg::*;

// include tests
`include "comp_base_test.sv"
`include "comp_test_digital_control.sv"
`include "comp_test_timming_violation.sv"
`include "comp_test_power.sv"

endpackage : comp_test_pkg
