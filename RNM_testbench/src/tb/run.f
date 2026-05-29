-uvm

// include directories, starting with UVM src directory
-incdir ../uvc
-incdir ../tests

// options
//+UVM_VERBOSITY=UVM_HIGH 
+UVM_TESTNAME=comp_base_test
-defparam tb_top.ENABLE_AMS=0
-defparam tb_top.TEST_DUT=1

// uncomment for gui
//-gui
//+access+rwc

// default timescale
-timescale 1ns/1ps

// interface
comp_if.sv 

// compile files
// UVC package
../uvc/comp_uvc_pkg.sv
top_pkg.sv
../tests/comp_test_pkg.sv

test_dut.sv
// top module for UVM test environment
tb_top.sv
