/*
 * Project: RNM testbench
 * File: top_env.sv
 * Author: Denis Kucera
 * Created: 2026-05-20
 * Description: top level layer
 */

class top_env extends uvm_env;

    // component macro
  `uvm_component_utils(top_env)

    comp_env m_comp_env;

    // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  // UVM build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //create another layer comp UVC env
    m_comp_env = comp_env::type_id::create("m_comp_env", this);
    //in case of other UVC's 
  endfunction : build_phase

endclass
