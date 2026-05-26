// ==========================================
// 1. Include directories
// ==========================================

+incdir+../src/tb/uvc
+incdir+../src/tb/tests
+incdir+../src/tb
+incdir+../src/model

//DUT
../src/model/comparator_RNM.sv

// ==========================================
// 2. Interfaces (Always compile first)
// ==========================================
../src/tb/comp_if.sv 

// ==========================================
// 3. Packages (Compile from bottom-up)
// ==========================================
../src/tb/uvc/comp_uvc_pkg.sv
../src/tb/top_pkg.sv
../src/tb/tests/comp_test_pkg.sv

// ==========================================
// 4. Hardware Modules
// ==========================================
../src/tb/test_dut.sv