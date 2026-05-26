/*
 * Project: RNM testbench
 * File: comp_test_power.sv
 * Author: Denis Kucera
 * Created: 2026-05-20
 * Description: comparator supply test
 */

 /*
  *  Objective: test the correct comparator power behaviour
  *  
  *  Sequence: 
  * 
  *  Test description: send 10 full valid comparator cycles (with nominal voltage level) OPTIONAL: observe current
  *                    send 10 full valid comparator cycles and sweep voltage from 0.65V to 1V 
  *                    power fail scenario: 50% undervoltage or 50% overvoltage    
  *  
  */
 class comp_test_power extends comp_base_test;

    `uvm_component_utils(comp_test_power)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

 endclass
