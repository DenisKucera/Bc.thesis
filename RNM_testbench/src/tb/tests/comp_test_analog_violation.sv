/*
 * Project: RNM testbench
 * File: comp_test_lib.sv
 * Author: Denis Kucera
 * Created: 2026-05-12
 * Description: Tests library
 */

class comp_test_lib extends comp_base_test;

`uvm_component_utils(comp_test_lib)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
endclass
