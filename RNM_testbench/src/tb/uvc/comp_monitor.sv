/*
 * Project: RNM testbench
 * File: comp_monitor.sv
 * Author: Denis Kucera
 * Created: 2026-05-12
 * Description: Monitor
 */

typedef enum bit {COV_ENABLE, COV_DISABLE} cover_e;

class comp_monitor extends uvm_monitor;

  // Collected Data handle
  comp_item m_comp_item;

  // analysis port
  uvm_analysis_port#(comp_item) collected_item;

  cover_e coverage_control = COV_ENABLE;

  virtual interface comp_if m_vif;

  // component macro
  `uvm_component_utils_begin(comp_monitor)
    `uvm_field_enum(cover_e, coverage_control, UVM_ALL_ON)
  `uvm_component_utils_end

  // coverage model
  covergroup collected_items_cg;


  endgroup: collected_items_cg

  // component constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
    collected_item = new("collected_item",this);
    if (coverage_control == COV_ENABLE) begin
      `uvm_info(get_type_name(),"COMPARATOR MONITOR COVERAGE CREATED" , UVM_LOW)
      collected_items_cg = new();
      collected_items_cg.set_inst_name({get_full_name(), ".monitor_item"});
    end
  endfunction : new

  //connect monitor to virtual interface to trace items comming from DUT
  /*function void connect_phase(uvm_phase phase);

   endfunction: connect_phase*/

  // UVM run() phase
  task run_phase(uvm_phase phase);
    forever begin
      // ACQUISITION PHASE
      @(posedge m_vif.am_clk_sample);
      m_comp_item = comp_item::type_id::create("m_comp_item");

      // Capture the value intended to be "stored"
      m_comp_item.comp_stored_curr = m_vif.in;

      // COMPARE PHASE
      wait(m_vif.am_invert == 1);

      // Capture the "live" input value during comparison
      m_comp_item.comp_compare_curr = m_vif.in;
      m_comp_item.comp_vdd          = m_vif.vdd;

      // STABILITY & COLLECTION
      repeat(2) @(posedge m_vif.clk);
      m_comp_item.comp_out = m_vif.am_cmpr_out_RNM;
      m_comp_item.comp_analog_out = m_vif.am_cmpr_out_SPICE;

      collected_item.write(m_comp_item);
    end
  endtask : run_phase

  // UVM report_phase
  function void report_phase(uvm_phase phase);

  endfunction : report_phase

endclass : comp_monitor
