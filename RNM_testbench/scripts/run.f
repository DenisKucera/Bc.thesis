-uvm

// include directories, starting with UVM src directory
-incdir ../src/tb/uvc
-incdir ../src/tb/tests

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
../src/tb/comp_if.sv 

// compile files
// UVC package
../src/tb/uvc/comp_uvc_pkg.sv
../src/tb/top_pkg.sv
../src/tb/tests/comp_test_pkg.sv
../src/tb/tb_top.sv
../src/tb/test_dut.sv

test_dut.sv
// top module for UVM test environment
tb_top.sv
