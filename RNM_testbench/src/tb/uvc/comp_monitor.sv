/*
 * Project: RNM testbench
 * File: comp_monitor.sv
 * Author: Denis Kucera
 * Created: 2026-05-12
 * Description: Monitor
 */

class comp_monitor extends uvm_monitor;

  // Collected Data handle
  comp_item m_comp_item;

  // analysis port
  uvm_analysis_port#(comp_item) collected_item;

  virtual interface comp_if m_vif;

  // component macro
  `uvm_component_utils(comp_monitor)
  
  // coverage model

  // component constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
    collected_item = new("collected_item",this);
  endfunction : new

  //connect monitor to virtual interface to trace items comming from DUT
  /*function void connect_phase(uvm_phase phase);

   endfunction: connect_phase*/

  // UVM run() phase
  task run_phase(uvm_phase phase);
    forever begin
      @(posedge m_vif.am_clk_sample);

      // ACQUISITION PHASE (Trapping the Charge)
      @(negedge m_vif.am_invert);
      
      m_comp_item = comp_item::type_id::create("m_comp_item");
      //m_comp_item.state = comp_item::comp_state_e'(m_vif.debug_state);
      m_comp_item.comp_stored_curr = m_vif.in;

      // COMPARE PHASE (Applying the new current)
      @(posedge m_vif.am_invert);

      m_comp_item.comp_compare_curr = m_vif.in;
      m_comp_item.comp_vdd          = m_vif.vdd;
      //m_comp_item.comp_inv_bias     = m_vif.inv_bias; 

      // STABILITY & COLLECTION
      repeat(2) @(posedge m_vif.clk);
      
      m_comp_item.comp_out        = m_vif.am_cmpr_out_rnm;
      m_comp_item.comp_analog_out = m_vif.am_cmpr_out_spice;

      collected_item.write(m_comp_item);
    end
  endtask : run_phase

  // UVM report_phase
  function void report_phase(uvm_phase phase);

  endfunction : report_phase

endclass : comp_monitor
