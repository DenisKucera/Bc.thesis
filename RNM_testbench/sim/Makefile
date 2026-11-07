# ==========================================
# Verilator + UVM -- Simulation Makefile
# ==========================================
# Denis Kucera, 2026
# ==========================================

# Project variables
TOP_MODULE ?= tb_top
RUN_F      ?= ../scripts/verilator_run.f
TB_TOP_SV  ?= ../src/tb/$(TOP_MODULE).sv

# Simulation runtime arguments (overridable from CLI: make run TEST=my_test VERB=UVM_DEBUG)
TEST       ?= comp_test_sanity
VERB       ?= UVM_MEDIUM
SEED       ?= 1
PLUSARGS   ?=

# UVM Paths (Adjusted for the sim/ folder location)
UVM_HOME   = $(HOME)/uvm/uvm-2020/src
UVM_INC    = +incdir+$(UVM_HOME)
UVM_PKG    = $(UVM_HOME)/uvm_pkg.sv
UVM_DPI   = $(UVM_HOME)/dpi/uvm_dpi.cc -CFLAGS -I$(UVM_HOME)/dpi

# Check if UVM_HOME exists
ifeq ("$(wildcard $(UVM_HOME)/uvm_pkg.sv)","")
  $(error UVM_pkg.sv not found in UVM_HOME=$(UVM_HOME)! Set UVM_HOME properly)
endif

# Verilator Flags
VFLAGS = --binary --timing --trace-fst -Wno-fatal -j 4 \
         --language 1800-2023 \
         --timescale 1ns/1ps \
		 -DVM_TRACE=1 \
         -GENABLE_MS=0 \
         -GTEST_DUT=0 \
         -GCOVERAGE=1 \
         --coverage \
		 +define+UVM_NO_DPI \
		 --top $(TOP_MODULE) \
         $(UVM_INC) $(UVM_PKG)

# Targets
all: build run

lint:
	@echo "--- Running Verilator Elaboration Check ---"
	verilator --lint-only --timing -Wno-fatal $(UVM_INC) $(UVM_PKG) -f $(RUN_F) $(TB_TOP_SV)

build:
	@echo "--- Building Verilator Executable ---"
	verilator $(VFLAGS) -f $(RUN_F) $(TB_TOP_SV)

run:
	@echo "--- Running Simulation (Test: $(TEST), Verbosity: $(VERB)) ---"
	mkdir -p logs
	./obj_dir/V$(TOP_MODULE) \
		+UVM_TESTNAME=$(TEST) \
		+UVM_VERBOSITY=$(VERB) \
		+ntb_random_seed=$(SEED) \
		$(PLUSARGS) | tee logs/$(TEST).log

coverage:
	@echo "--- Processing Coverage Data ---"
	@# Upraveno: Zkusíme načíst soubor z hlavní složky i z logs/
	verilator_coverage --write-info coverage.info logs/coverage.dat coverage.dat 2>/dev/null || verilator_coverage --write-info coverage.info coverage.dat
	@echo "--- Generating HTML Report ---"
	genhtml coverage.info --output-directory coverage_html
	@echo "--- DONE! Open coverage_html/index.html in your browser ---"
	python3 -m http.server 8000
	http://localhost:8000/coverage_html/

waves:
	@echo "--- Opening GTKWave ---"
	gtkwave dump.fst &

clean:
	@echo "--- Cleaning Workspace ---"
	rm -rf obj_dir/
	rm -rf logs/
	rm -rf coverage_html/
	rm -f coverage.info
	rm -f dump.fst
	rm -f *.log
	rm -f coverage.dat  