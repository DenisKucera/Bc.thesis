/*
 * Project: RNM testbench
 * File: tb_top.sv
 * Author: Denis Kucera
 * Created: 2026-05-12
 * Description: UVM testbench
 */

module tb_top;
    //RNM and TB parametrization (values can be overwritten, RNM params overide)
    parameter real        MAX_CURRENT           = 50.0e-6;
    parameter real        MAX_ERR_DB            = 0.25;
    parameter real        MIN_ERR_DB            = 0.10;
    parameter realtime    ACQ_TIME              = 10us;
    parameter realtime    DECISION_TIME         = 2us;
    parameter realtime    HOLD_TIME             = 300ps;
    parameter real        CURRENT_CONSUMPTION   = 35.0e-9;
    parameter real        SUPPLY_MIN            = 0.65;
    parameter real        SUPPLY_MAX            = 1.0;
    parameter real        BIAS_CURRENT          = 5.0e-9;
    //DMS co-simulation is turned-off by default
    parameter bit ENABLE_MS=0;
    //Enables to run environment only for UVM architecture check
    parameter bit TEST_DUT=0;
    //coverage control enable/disable
    //parameter bit COVERAGE=0;

    `include "uvm_macros.svh"
    import uvm_pkg::*;

    // import test package
    // here are located all the tests
    import comp_test_pkg::*;

    // signals
    reg reset;
    reg clock;

    // UVC interface instance
    comp_if vif();

    if (TEST_DUT) begin
        test_dut dut(
            .clock(clock),
            .reset(reset)
        );
    end
    else begin
    //RNM model instance
    comparator_RNM #(
        .MAX_ERR_DB             (MAX_ERR_DB),
        .MIN_ERR_DB             (MIN_ERR_DB),
        .MAX_CURRENT            (MAX_CURRENT),
        .ACQ_TIME               (ACQ_TIME),
        .DECISION_TIME          (DECISION_TIME),
        .HOLD_TIME              (HOLD_TIME),
        .SUPPLY_MIN             (SUPPLY_MIN),
        .SUPPLY_MAX             (SUPPLY_MAX),
        .CURRENT_CONSUMPTION    (CURRENT_CONSUMPTION),
        .BIAS_CURRENT           (BIAS_CURRENT)
    )dut_rnm(
        .vss           (vif.vss),
        .am_clk_sample (vif.am_clk_sample),
        .am_cmpr_out   (vif.am_cmpr_out_rnm), // Changed from am_cmpr_out to match common naming
        .am_complete   (vif.am_complete),
        .am_invert     (vif.am_invert),
        .am_short      (vif.am_short),
        .in            (vif.in),
        .inv_bias      (vif.inv_bias),
        .vdd           (vif.vdd),
        .idd           (vif.idd)
    );
    

    if (ENABLE_MS) begin: dut_spice_inst
        //analog model instance
        comparator dut_spice(
            .vss           (vif.w_vss),
            .am_clk_sample (vif.w_am_clk_sample),
            .am_cmpr_out   (vif.w_cmpr_out_spice),
            .am_complete   (vif.w_am_complete),
            .am_invert     (vif.w_am_invert),
            .am_short      (vif.w_am_short),
            .in            (vif.w_in),
            .inv_bias      (vif.w_inv_bias),
            .vdd           (vif.w_vdd)
        );
        end: dut_spice_inst
    end

    // ADD THIS BLOCK TO ENABLE WAVEFORM DUMPING
    initial begin
        // Only trigger the dump if Verilator is running
        `ifdef VM_TRACE
            $dumpfile("dump.fst");
            $dumpvars(0, tb_top); // '0' dumps all signals in the hierarchy
        `endif
    end

    // configure UVC's virtual interface in DB
    initial begin : config_if_block
        //set vif globally for all components
        uvm_config_db#(virtual comp_if)::set(null, "uvm_test_top.m_env_top.m_comp_env.m_comp_agent*", "m_vif", vif);
        //pass config bit to UVM
        uvm_config_db#(int)::set(null, "uvm_test_top.m_env_top.m_comp_env.m_comp_agent*", "DMS CO-SIMULATION ENABLED!", ENABLE_MS);
        //pass coverage control bit to comp UVC env
        //uvm_config_db#(int)::set(null, "uvm_test_top.m_env_top.m_comp_env*", "COVERAGE TRACKING ENABLED!", COVERAGE);

        // Set individual variables directly to the sequencer path
        uvm_config_db#(realtime)::set(null, 
            "uvm_test_top.m_env_top.m_comp_env.m_comp_agent.m_comp_sequencer", 
            "param_max_dec_time", 
            DECISION_TIME);
        uvm_config_db#(realtime)::set(null, 
            "uvm_test_top.m_env_top.m_comp_env.m_comp_agent.m_comp_sequencer", 
            "param_max_acq_time", 
            ACQ_TIME);
    end

    

    // define initial clock value and generate reset
    initial begin : clock_and_rst_init_block
        reset <= 1'b0;
        clock <= 1'b0;
        #501 reset <= 1'b1;
    end

    // generate clock
    always begin : clock_gen_block
        #(36873.153ps) clock <= ~clock; // 13.56 MHz RFID clock
    end
    assign vif.clk = clock;
    assign vif.reset = reset;

    // run test
    initial begin : run_test_block
        run_test();
    end

endmodule : tb_top

