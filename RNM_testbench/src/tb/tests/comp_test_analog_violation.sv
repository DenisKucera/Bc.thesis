/*
 * Project: RNM testbench
 * File: comp_test_analog_violation.sv
 * Author: Denis Kucera
 * Created: 2026-05-30
 * Description: Analog parameters violation test
 */

class comp_test_analog_violation extends comp_base_test;

    `uvm_component_utils(comp_test_analog_violation)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    //uvm_objection obj = phase.get_objection();
    phase.raise_objection(this);

    `uvm_info("TEST", "Running Analog violation Test", UVM_LOW)

    // Configure VDD to be noisy
    m_comp_sequence.cfg_in.w_type    = comp_item::SINE;
    m_comp_sequence.cfg_in.offset    = 10.0e-6;    // 1.2V baseline
    m_comp_sequence.cfg_in.amplitude = 2.5e-6;   // 50mV of noise
    m_comp_sequence.cfg_in.step_ps   = 500;     // Update noise very fast (50ps)

    m_comp_sequence.cfg_vdd.w_type   = comp_item::STATIC;
    m_comp_sequence.cfg_vdd.offset   = 0.8;

    m_comp_sequence.start(m_env_top.m_comp_env.m_comp_agent.m_comp_sequencer);

    phase.drop_objection(this);
endtask

endclass