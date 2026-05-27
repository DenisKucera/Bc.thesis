-uvm
-uvmhome default

// include directories, starting with UVM src directory
-incdir $WORK_ROOT/RNM_testbench/src/tb           // Added for interface/top package access
-incdir $WORK_ROOT/RNM_testbench/src/tb/uvc
-incdir $WORK_ROOT/RNM_testbench/src/tb/tests

// default timescale
-timescale 1ns/1ps

// interface
$WORK_ROOT/RNM_testbench/src/tb/comp_if.sv 

// packages
$WORK_ROOT/RNM_testbench/src/tb/uvc/comp_uvc_pkg.sv
$WORK_ROOT/RNM_testbench/src/tb/top_pkg.sv
$WORK_ROOT/RNM_testbench/src/tb/tests/comp_test_pkg.sv
//dummy DUT 
$WORK_ROOT/RNM_testbench/src/tb/test_dut.sv
//RNM model
$WORK_ROOT/RNM_testbench/src/model/comparator_RNM.sv
//analog comparator netlist
$WORK_ROOT/RNM_testbench/src/ams/amscf.scs
//top module
$WORK_ROOT/RNM_testbench/src/tb/tb_top.sv

+UVM_TESTNAME=comp_base_test
+UVM_VERBOSITY=UVM_LOW      // Start LOW to see your clean Scoreboard tables
-defparam tb_top.ENABLE_MS=1
-defparam tb_top.TEST_DUT=0

// Waveform access (Required for SimVision/shm)
+access+rwc
-gui