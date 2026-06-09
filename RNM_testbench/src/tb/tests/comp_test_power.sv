/*
 * Project: RNM testbench
 * File: comp_test_power.sv
 * Author: Denis Kucera
 * Created: 2026-05-30
 * Description: Base test class
 */

class comp_test_power extends comp_base_test;

    `uvm_component_utils(comp_test_power)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    //uvm_objection obj = phase.get_objection();
    phase.raise_objection(this);

    `uvm_info("TEST", "Running Supply-Power Test", UVM_LOW)

    // Correct sequence setup 
    m_comp_sequence.num_compares         = 100;
    m_comp_sequence.start_state          = comp_item::IDLE;
    m_comp_sequence.cfg_state_transition = comp_item::CORRECT;
    m_comp_sequence.cfg_timing           = comp_item::CORRECT;

    // Set changing current (input stimulus for comparator)
    m_comp_sequence.cfg_in.w_type    = comp_item::SINE;
    m_comp_sequence.cfg_in.offset    = 10.0e-6;    // 
    m_comp_sequence.cfg_in.amplitude = 2.5e-6;   // 
    m_comp_sequence.cfg_in.period_ps = 1_000_000;
    m_comp_sequence.cfg_in.step_ps   = 1_000;     // 
    //correct bias current
    m_comp_sequence.cfg_bias.w_type = comp_item::STATIC;
    m_comp_sequence.cfg_bias.offset = 6.0e-9;

    //PWR VIOLATION high-voltage
    m_comp_sequence.cfg_vdd.w_type     = comp_item::PULSE_POS;
    m_comp_sequence.cfg_vdd.offset     = 1.0;
    m_comp_sequence.cfg_vdd.amplitude  = 0.2;
    m_comp_sequence.cfg_vdd.period_ps = 1_000_000;
    m_comp_sequence.cfg_vdd.step_ps   = 1_000;     // 

    m_comp_sequence.start(m_env_top.m_comp_env.m_comp_agent.m_comp_sequencer);

    //PWR VIOLATION low-voltage
    m_comp_sequence.cfg_vdd.w_type     = comp_item::PULSE_NEG;
    m_comp_sequence.cfg_vdd.offset     = 0.65;
    m_comp_sequence.cfg_vdd.amplitude  = 0.2;
    m_comp_sequence.cfg_vdd.period_ps   = 1_000_000;
    m_comp_sequence.cfg_vdd.step_ps     = 1_000;     // 

    m_comp_sequence.start(m_env_top.m_comp_env.m_comp_agent.m_comp_sequencer);

    //AM_COMPLETE test
    m_comp_sequence.cfg_vdd.w_type     = comp_item::STATIC;
    m_comp_sequence.cfg_vdd.offset     = 0.85;
    m_comp_sequence.cfg_vdd.step_ps     = 1_000;  

    m_comp_sequence.am_complete_en = 1;

    m_comp_sequence.start(m_env_top.m_comp_env.m_comp_agent.m_comp_sequencer);

    phase.drop_objection(this);
endtask

endclass