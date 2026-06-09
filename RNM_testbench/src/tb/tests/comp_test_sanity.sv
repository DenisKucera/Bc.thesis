/*
 * Project: RNM testbench
 * File: comp_test_sanity.sv
 * Author: Denis Kucera
 * Created: 2026-05-30
 * Description: Sanity test
 */

class comp_test_sanity extends comp_base_test;

    `uvm_component_utils(comp_test_sanity)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    //uvm_objection obj = phase.get_objection();
    phase.raise_objection(this);

    `uvm_info("TEST", "Running Sanity Test", UVM_LOW)
    //25 full comparator cycles
    m_comp_sequence.num_compares         = 100;
    m_comp_sequence.start_state          = comp_item::IDLE;
    m_comp_sequence.cfg_state_transition = comp_item::CORRECT;
    m_comp_sequence.cfg_timing           = comp_item::CORRECT;
    // probably different waveform?
    m_comp_sequence.cfg_in.w_type    = comp_item::SINE;
    m_comp_sequence.cfg_in.offset    = 10.0e-6;   
    m_comp_sequence.cfg_in.amplitude = 5e-6;   
    m_comp_sequence.cfg_in.period_ps = 1_000_000_000;
    m_comp_sequence.cfg_in.step_ps   = 10_000; //10ns     
    //correct voltage
    m_comp_sequence.cfg_vdd.w_type   = comp_item::STATIC;
    m_comp_sequence.cfg_vdd.offset   = 1.0;
    //correct bias current
    m_comp_sequence.cfg_bias.w_type = comp_item::STATIC;
    m_comp_sequence.cfg_bias.offset = 5.0e-9;

    m_comp_sequence.start(m_env_top.m_comp_env.m_comp_agent.m_comp_sequencer);

    phase.drop_objection(this);
endtask

endclass