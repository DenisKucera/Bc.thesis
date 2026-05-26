/*
 * Project: RNM testbench
 * File: comp_driver.sv
 * Author: Denis Kucera
 * Created: 2026-05-12
 * Description:
 */
class comp_driver extends uvm_driver #(comp_item);

  virtual interface comp_if m_vif;

  //REQ m_req

  // component macro
  `uvm_component_utils_begin(comp_driver)

  `uvm_component_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void connect_phase(uvm_phase phase);

  endfunction: connect_phase

  function void init_signals();
    m_vif.clk <= 0;
  endfunction : init_signals

  // start_of_simulation
  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
  endfunction : start_of_simulation_phase

  // UVM run_phase
  task run_phase(uvm_phase phase);

    init_signals();

    //@(negedge m_vif.reset);

    forever begin
      #1ns;
      // Get new item from the sequencer
      seq_item_port.get_next_item(req);

      @(posedge m_vif.clk);
      `uvm_info(get_type_name(), $sformatf("Sending item :\n%s", req.sprint()), UVM_HIGH)

      m_vif.vdd <= req.comp_vdd;

      comparator_control(req);

      // End transaction recording
      end_tr(req);
      // Communicate item done to the sequencer
      seq_item_port.item_done();
    end
  endtask : run_phase


  task drive_idle_signals();
    m_vif.am_invert   <= 0;
    m_vif.in          <= 0.0;
    m_vif.am_complete <= 0;
    m_vif.am_short    <= 0;
  endtask
  task drive_sample_signals(comp_item req);
    m_vif.in          <= req.comp_in_curr;
    m_vif.am_invert   <= 0;
    m_vif.am_short    <= 1;
    @(posedge m_vif.clk);
    m_vif.am_clk_sample <= 1;
  endtask
  task drive_hold_signals();
    m_vif.am_clk_sample <= 0;
    @(posedge m_vif.clk);
    m_vif.am_short      <= 0;
  endtask
  task drive_compare_signals(comp_item req);
    m_vif.in        <= req.comp_in_curr;
    @(posedge m_vif.clk);
    m_vif.am_invert <= 1;
  endtask
  task drive_glitch_signals(comp_item req);
    m_vif.am_clk_sample = req.comp_am_clk_sample;
    m_vif.am_invert     = req.comp_am_invert;
    m_vif.am_short      = req.comp_am_short;
  endtask


  task comparator_control(comp_item req);
    // 1. Drive the signals for the current state
    case(req.state)
      comp_item::SAMPLE:  drive_sample_signals(req);
      comp_item::HOLD:    drive_hold_signals();
      comp_item::COMPARE: drive_compare_signals(req);
      comp_item::IDLE:    drive_idle_signals();
      comp_item::GLITCH:  drive_glitch_signals(req);
    endcase

    // TIMING EXECUTION WITH SAFETY
    //if (req.comp_delay_ps > 0) begin
    //delay shall be greater then 10ps
      #(req.comp_delay_ps * 1ps);
    //end else begin
      // Safety: Force a delta-cycle or a tiny delay
      // so the simulation doesn't hang in a zero-time loop
      //#1ps;
    //end
    // Optional: Sync to clock after delay
    @(posedge m_vif.clk);
  endtask

  // UVM report_phase
  function void report_phase(uvm_phase phase);

  endfunction : report_phase

endclass : comp_driver
