/*
 * Project: RNM testbench
 * File: comp_coverage.sv
 * Description: Functional Coverage Collector
 */

class comp_coverage extends uvm_subscriber #(comp_item);

    // Handle to hold the item we receive
    comp_item m_comp_item;

    `uvm_component_utils(comp_coverage)


    function new(string name = "comp_coverage", uvm_component parent = null);
        super.new(name, parent);
        // Instantiate the covergroup
        cg_cmp_ini = new();
        cg_cmp_anp = new();
        cg_cmp_anv = new();
        cg_cmp_seq
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        cg_protocol = new();
        cg_glitch   = new();
        // ...
    endfunction

    covergroup cg_cmp_ini;
        option.per_instance = 1;
        option.name = "Comparator_Functional_Coverage";
        option.weight = 0;

    endgroup
        
    virtual function void write(comp_item t);
        // 1. Copy the incoming item to our local handle
        $cast(m_comp_item, t.clone()); 
        
        // 2. Trigger the covergroup to sample the new values
        cg_cmp_ini.sample();
        //...
        //...
    endfunction

endclass