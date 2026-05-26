/*
 * Project: RNM testbench
 * File: comp_sequencer.sv
 * Author: Denis Kucera
 * Created: 2026-05-12
 * Description: Sequencer
 */
class comp_sequencer extends uvm_sequencer#(comp_item);

    comp_item item;

    `uvm_component_utils(comp_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);     // important!!
    endfunction

    // start_of_simulation
    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
    endfunction : start_of_simulation_phase

endclass: comp_sequencer
