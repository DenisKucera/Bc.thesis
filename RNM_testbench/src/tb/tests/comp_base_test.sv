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
    comp_sequence m_comp_sequence;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //if something goes terribly wrong
        uvm_top.set_report_max_quit_count(100);
        //create top level layer
        m_env_top = top_env::type_id::create("m_env_top", this);
        m_comp_sequence = comp_sequence::type_id::create("m_comp_sequence"); 
        //config
        set_default_configuration();
        // enable monitor item recording
        set_config_int("*", "recording_detail", 1);
    endfunction

    // end_of_elaboration phase
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction : end_of_elaboration_phase
    
    // set default configuration
    virtual function void set_default_configuration();
    // define default configuration (note: not all fields are set here)
        // Digital Defaults
        m_comp_sequence.num_compares         = 100;
        m_comp_sequence.start_state          = comp_item::IDLE;
        m_comp_sequence.cfg_state_transition = comp_item::CORRECT;
        m_comp_sequence.cfg_timing           = comp_item::CORRECT;
        
        // By default all analog stimulus is disabled
        m_comp_sequence.cfg_in.w_type    = comp_item::DISABLE;
        m_comp_sequence.cfg_in.offset    = 0.0;
        m_comp_sequence.cfg_in.amplitude = 0.0;
        m_comp_sequence.cfg_in.period_ps = 50000;
        m_comp_sequence.cfg_in.step_ps   = 100;
        //set to nominal values
        m_comp_sequence.cfg_bias.w_type       = comp_item::DISABLE;
        m_comp_sequence.cfg_bias.offset       = 5.0e-9; // 5nA
        m_comp_sequence.cfg_bias.amplitude    = 0.0;
        m_comp_sequence.cfg_bias.period_ps    = 50000;
        m_comp_sequence.cfg_bias.step_ps      = 1000;
        //set to nominal values
        m_comp_sequence.cfg_vdd.w_type        = comp_item::DISABLE;
        m_comp_sequence.cfg_vdd.offset        = 0.75;
        m_comp_sequence.cfg_vdd.amplitude     = 0.0;
        m_comp_sequence.cfg_vdd.period_ps     = 50000;
        m_comp_sequence.cfg_vdd.step_ps       = 1000;
        //set to nominal values
        m_comp_sequence.cfg_vss.w_type        = comp_item::DISABLE;
        m_comp_sequence.cfg_vss.offset        = 0.0;
        m_comp_sequence.cfg_vss.amplitude     = 0.0;
        m_comp_sequence.cfg_vss.period_ps     = 50000;
        m_comp_sequence.cfg_vss.step_ps       = 1000;

    endfunction : set_default_configuration
        
    virtual task run_phase(uvm_phase phase);
        uvm_objection obj;
        obj = phase.get_objection();
        
        if (obj != null) begin
            obj.set_drain_time(this, 2us);
        end
    endtask : run_phase

    virtual function void check_phase(uvm_phase phase);
        check_config_usage();
    endfunction

endclass
