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
  uvm_analysis_port#(comp_item) m_collected_item;

  virtual interface comp_if m_vif;

  // component macro
  `uvm_component_utils(comp_monitor)
  
  real sample_start_time;
  real decision_start_time;

  // component constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
    m_collected_item = new("m_collected_item",this);
  endfunction : new

  
  function void connect_phase(uvm_phase phase);

   endfunction: connect_phase

  // UVM run() phase
  task run_phase(uvm_phase phase);
    forever begin
      @(posedge m_vif.am_clk_sample);
      sample_start_time = $realtime;

      // ACQUISITION PHASE 
      @(negedge m_vif.am_invert);
      if (m_vif.am_short !== 1'b1) begin
         continue; 
      end
      
      m_comp_item = comp_item::type_id::create("m_comp_item");
      //m_comp_item.state = comp_item::get_debug_state(m_vif.debug_state);
      m_comp_item.comp_stored_curr = m_vif.in;
      m_comp_item.comp_sample_time_ns = real'($realtime - sample_start_time);

      // Applying the new current)
      @(posedge m_vif.am_invert);
      decision_start_time = $realtime;
      m_comp_item.comp_compare_curr = m_vif.in;
      m_comp_item.comp_vdd          = m_vif.vdd;
      //m_comp_item.comp_inv_bias     = m_vif.inv_bias; 
     
      fork
          // Track the RNM Output
          begin : rnm_watchdog
              fork
                  begin
                      @(m_vif.am_cmpr_out_rnm);
                      m_comp_item.comp_rnm_decision_time_ns = real'($realtime - decision_start_time);
                  end
                  begin
                      @(negedge m_vif.am_invert); // Timeout!
                      m_comp_item.comp_rnm_decision_time_ns = 0.0; // It held its state
                  end
              join_any
              disable fork; // Kills ONLY the rnm_watchdog threads
          end : rnm_watchdog

          // Track the SPICE Output
          begin : spice_watchdog
              fork
                  begin
                      @(m_vif.am_cmpr_out_spice);
                      m_comp_item.comp_spice_decision_time_ns = real'($realtime - decision_start_time);
                  end
                  begin
                      @(negedge m_vif.am_invert); // Timeout!
                      m_comp_item.comp_spice_decision_time_ns = 0.0; // It held its state
                  end
              join_any
              disable fork; // Kills ONLY the spice_watchdog threads
          end : spice_watchdog
      join
   
      m_comp_item.comp_out        = m_vif.am_cmpr_out_rnm;
      m_comp_item.comp_analog_out = m_vif.am_cmpr_out_spice;

      m_collected_item.write(m_comp_item);
    end
  endtask : run_phase

  // UVM report_phase
  function void report_phase(uvm_phase phase);

  endfunction : report_phase

endclass : comp_monitor
