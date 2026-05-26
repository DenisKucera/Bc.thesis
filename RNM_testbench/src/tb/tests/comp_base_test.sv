/*
 * Project: RNM testbench
 * File: comp_base_test.sv
 * Author: Denis Kucera
 * Created: 2026-05-12
 * Description: Base test class
 */

class comp_base_test extends uvm_test;
    `uvm_component_utils(comp_base_test)
    
    //top layer env instance 
    top_env m_env_top; 

    //sequence
    comp_base_seq m_base_seq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //create top level layer
        m_env_top = top_env::type_id::create("m_env_top", this);
        m_base_seq = comp_base_seq::type_id::create("m_base_seq"); 
        // enable monitor item recording
        set_config_int("*", "recording_detail", 1);
    endfunction

    // end_of_elaboration phase
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();

        // Set a drain time (allow additional time before stopping) for the tests
        //phase.phase_done.set_drain_time(this, 10us);
    endfunction : end_of_elaboration_phase
    
    // set default configuration
    function void set_default_configuration();
    // define default configuration (note: not all fields are set here)
    
    endfunction : set_default_configuration

    task run_phase(uvm_phase phase);
        uvm_objection obj = phase.get_objection();
        phase.raise_objection(this, "Starting Main Sequence");

        obj.set_drain_time(this, 1000); // 1us

        m_base_seq.start(m_env_top.m_comp_env.m_comp_agent.m_comp_sequencer);

        phase.drop_objection(this, "Main Sequence Finished");
    endtask : run_phase

    function void check_phase(uvm_phase phase);
    // configuration checker
        check_config_usage();
    endfunction

endclass
