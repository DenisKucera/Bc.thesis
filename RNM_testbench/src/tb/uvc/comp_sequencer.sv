/*
 * Project: RNM testbench
 * File: comp_sequencer.sv
 * Author: Denis Kucera
 * Created: 2026-05-12
 * Description: Sequencer
 */
class comp_sequencer extends uvm_sequencer#(comp_item);

    comp_item item;
    virtual comp_if m_vif;

    `uvm_component_utils(comp_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);     // important!!
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual comp_if)::get(this, "", "m_vif", m_vif))
            `uvm_fatal("NOVIF", "Sequencer could not find vif")
    endfunction

    // start_of_simulation
    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
    endfunction : start_of_simulation_phase

endclass: comp_sequencer
