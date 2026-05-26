/*
 * Project: RNM testbench
 * File: comp_test_digital_control.sv
 * Author: Denis Kucera
 * Created: 2026-05-20
 * Description: digital control test
 */

 /*
  *  Objective: comparator digital control logic
  *  
  *  Sequence: 
  * 
  *  Test description: send 10 full valid comparator control cycles
  *                    randomized (50% correct and 50% wrong full cycles)
  *                    send 10 partialy correct order cycles
  *                    send 10 wrong order full cycles
  *  
  */
 class comp_test_digital_control extends comp_base_test;

    `uvm_component_utils(comp_test_digital_control)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

 endclass
