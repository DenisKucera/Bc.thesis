/*
 * Project: RNM testbench
 * File: comp_agent_cfg.sv
 * Author: Denis Kucera
 * Created: 2026-05-12
 * Description: Configuration layer for UVC agent
 */

class comp_agent_cfg extends uvm_object;

/*typedef enum{
    COV_CMP_INI,
    COV_CMP_ANP
    //...
    //...
    //...
} covergroup_en_e;*/

//covergroup_en_e m_covergroup_en;

//configuration fields
    /*
     *
     *
     *
     */
//registration macro
    `uvm_object_utils_begin(comp_agent_cfg)

    `uvm_object_utils_end
    /*
     *
     *
     *
     *
     */
    extern function new(string name = "comp_agent_cfg");

endclass : comp_agent_cfg

/*function bit is_covergroup_enabled(comp_agent_cfg::covergroup_en_e cg_en);
    if(comp_agent_cfg::m_covergroup_en == cg_en) begin
        return 1;
    end
    else begin
        return 0;
    end
endfunction*/

function comp_agent_cfg::new(string name = "comp_agent_cfg");
    super.new(name);

    // default configuration
    /*
     *
     *
     *
     */


endfunction : new

//methods
