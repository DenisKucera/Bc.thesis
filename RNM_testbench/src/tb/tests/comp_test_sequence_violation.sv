/*
 * Project: RNM testbench
 * File: comp_test_timming_violation.sv
 * Author: Denis Kucera
 * Created: 2026-05-20
 * Description: timming violation test
 */

 /*
  *  Objective: comparator timming violation resistivity
  *  
  *  Sequence: 
  * 
  *  Test description: send 10 full valid comparator control cycles
  *                    randomized full cycles (50% correct and 50% with wrong timming)
  *                    send 10 cycles with partial wrong timming 
  *                    send 10 full cycles with wrong timming
  *  
  */
 class comp_test_timming_violation extends comp_base_test;

    `uvm_component_utils(comp_test_timming_violation)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

 endclass
