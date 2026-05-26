/*
 * Project: RNM testbench
 * File: comp_agent_cfg.sv
 * Author: Denis Kucera
 * Created: 2026-05-12
 * Description: Configuration layer for UVC agent
 */

class comp_agent_cfg extends uvm_object;

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
