/*
 * Project: RNM testbench
 * File: comp_coverage.sv
 * Description: Functional Coverage Collector
 */

class comp_coverage extends uvm_subscriber #(comp_item);

    int cov_vdd; 
    real cov_in;
    int cov_delay_ps;
    comp_item::comp_state_e cov_state; 
    bit cov_out;

    `uvm_component_utils(comp_coverage)

    covergroup cg_cmp_ini;
        option.per_instance = 1;
        option.name = "Comparator_Functional_Coverage";

        cp_state: coverpoint cov_state {
            bins st_idle      = {comp_item::IDLE};
            bins st_compare   = {comp_item::COMPARE}; 
            bins st_acquiring = {comp_item::HOLD};
        }
        
        cp_vdd_offset: coverpoint cov_vdd {
            bins low_vdd  = {[650 : 750]};
            bins nom_vdd  = {[760 : 900]};
            bins high_vdd = {[910 : 1000]};
        }
        
        cx_state_vdd: cross cp_state, cp_vdd_offset;

        cp_comp_delay_ps: coverpoint cov_delay_ps {
            bins hit = {[1_000_000 : 50_000_000]};
        }

        cp_output: coverpoint cov_out {
            bins out_zero = {0}; 
            bins out_one  = {1}; 
        }
    endgroup

    function new(string name = "comp_coverage", uvm_component parent = null);
        super.new(name, parent);
        cg_cmp_ini = new();
    endfunction
        
    virtual function void write(comp_item t);
        cov_state = t.monitor_state;
        cov_out   = t.comp_out;
        cov_in = t.comp_stored_curr;
        cov_delay_ps = int'(t.comp_delay_ps); 
        cov_vdd = int'(t.comp_vdd * 1000);
        
        `uvm_info("COV_DEBUG", $sformatf(" state=%s, vdd=%d mV, delay_ps=%d CURRENT=%f", cov_state.name(), cov_vdd, cov_delay_ps, cov_in), UVM_LOW)
        
        cg_cmp_ini.sample();
    endfunction

endclass