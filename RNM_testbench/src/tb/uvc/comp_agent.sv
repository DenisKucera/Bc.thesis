/*
 * Project: RNM testbench
 * File: comp_agent.sv
 * Author: Denis Kucera
 * Created: 2026-05-12
 * Description: Comparator testbench UVC agent
 */

class comp_agent extends uvm_agent;

  // predeclared field inherited from uvm_agent determines whether an agent is active or passive.
  // uvm_active_passive_enum is_active = UVM_ACTIVE;  //  This field determines whether an agent is active or passive.

  // virtual interface reference
  virtual interface comp_if m_vif;
  
  comp_monitor   m_comp_monitor;
  comp_sequencer m_comp_sequencer;
  comp_driver    m_comp_driver;

  //for scoreboard
  int ams_enabled;
  
  // component macro
  `uvm_component_utils_begin(comp_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_component_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // UVM build_phase() method
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get interface
    if(!uvm_config_db#(virtual comp_if)::get(this, "", "m_vif", m_vif)) begin
      `uvm_fatal(get_type_name(), "Failed to get virtual interface from config DB!")
    end
    if (!uvm_config_db#(int)::get(this, "", "AMS CO-SIMULATION ENABLED!", ams_enabled)) begin
      `uvm_info(get_type_name(), "AMS setting not found, defaulting to 0", UVM_LOW)
      ams_enabled = 0; // Default to RNM only if not found
    end

    m_comp_monitor = comp_monitor::type_id::create("m_comp_monitor", this);
    if (is_active == UVM_ACTIVE) begin
      m_comp_sequencer = comp_sequencer::type_id::create("m_comp_sequencer", this);
      m_comp_driver = comp_driver::type_id::create("m_comp_driver", this);
    end
  endfunction : build_phase

  // UVM connect_phase() method
  function void connect_phase(uvm_phase phase);
    if (is_active == UVM_ACTIVE) begin
        //passing vif
        m_comp_monitor.m_vif = m_vif;
        m_comp_driver.m_vif = m_vif;
      end 
      // Connect the driver and the sequencer 
      m_comp_driver.seq_item_port.connect(m_comp_sequencer.seq_item_export);
  endfunction : connect_phase

  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
  endfunction : start_of_simulation_phase

endclass : comp_agent
