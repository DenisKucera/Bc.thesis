/*
 * Project: RNM testbench
 * File: comp_coverage.sv
 * Description: Functional Coverage Collector
 */

//NOT IMPLEMENTED YET
class comp_coverage extends uvm_subscriber #(comp_item);

    // Handle to hold the item we receive
    comp_item m_comp_item;

    `uvm_component_utils(comp_coverage)

    covergroup cg_cmp_ini;
        option.per_instance = 1;
        option.name = "Comparator_Functional_Coverage";
        option.weight = 0;

    endgroup

    function new(string name = "comp_coverage", uvm_component parent = null);
        super.new(name, parent);
        // Instantiate the covergroup
        cg_cmp_ini = new();
        //cg_cmp_anp = new();
        //cg_cmp_anv = new();
        //cg_cmp_seq
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction
        
    virtual function void write(comp_item t);
        $cast(m_comp_item, t.clone()); 
        
        cg_cmp_ini.sample();
        //...
        //...
    endfunction

endclass