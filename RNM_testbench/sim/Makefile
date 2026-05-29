# ==========================================
# Verilator UVM Simulation Makefile
# ==========================================

# Project variables
TOP_MODULE = tb_top
RUN_F      = ../scripts/verilator_run.f

# UVM Paths (Adjusted for the sim/ folder location)
UVM_HOME   = ../uvm/uvm-2020/src
UVM_INC    = +incdir+$(UVM_HOME)
UVM_PKG    = $(UVM_HOME)/uvm_pkg.sv
#UVM_DPI    = $(UVM_HOME)/dpi/uvm_dpi.cc -CFLAGS -I$(UVM_HOME)/dpi

# Verilator Flags
VFLAGS = --binary --timing --trace-fst -Wno-fatal -j 4 \
         --language 1800-2023 \
         --timescale 1ns/1ps \
		 -DVM_TRACE=1 \
         -GENABLE_MS=0 \
         -GTEST_DUT=0 \
		 +define+UVM_NO_DPI \
		 --top $(TOP_MODULE) \
         $(UVM_INC) $(UVM_PKG)

# ==========================================
# Targets
# ==========================================

all: build run

lint:
	@echo "--- Running Verilator Elaboration Check ---"
	verilator --lint-only --timing -f $(RUN_F) ../src/tb/$(TOP_MODULE).sv $(UVM_INC) $(UVM_PKG)

build:
	@echo "--- Building Verilator Executable ---"
	verilator $(VFLAGS) -f $(RUN_F) ../src/tb/$(TOP_MODULE).sv

run:
	@echo "--- Running Simulation ---"
	./obj_dir/V$(TOP_MODULE) +UVM_TESTNAME=comp_sanity_test

waves:
	@echo "--- Opening GTKWave ---"
	gtkwave dump.fst &

clean:
	@echo "--- Cleaning Workspace ---"
	rm -rf obj_dir/
	rm -f dump.fst
	rm -f *.log