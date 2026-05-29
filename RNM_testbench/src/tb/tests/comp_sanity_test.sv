/*
 * Project: RNM testbench
 * File: comp_base_test.sv
 * Author: Denis Kucera
 * Created: 2026-05-12
 * Description: Base test class
 */

class comp_sanity_test extends comp_base_test;

    `uvm_component_utils(comp_sanity_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

virtual task run_phase(uvm_phase phase);
    uvm_objection obj = phase.get_objection();
    phase.raise_objection(this);

    `uvm_info("TEST", "Running VDD Noise Injection Test", UVM_LOW)

    // Configure VDD to be noisy
    m_base_seq.cfg_vdd.w_type    = comp_item::NOISE;
    m_base_seq.cfg_vdd.offset    = 0.8;    // 1.2V baseline
    m_base_seq.cfg_vdd.amplitude = 0.05;   // 50mV of noise
    m_base_seq.cfg_vdd.step_ps   = 50;     // Update noise very fast (50ps)

    //obj.set_drain_time(this, 10000); // 1us

    m_base_seq.start(m_env_top.m_comp_env.m_comp_agent.m_comp_sequencer);

    phase.drop_objection(this);
endtask

endclass