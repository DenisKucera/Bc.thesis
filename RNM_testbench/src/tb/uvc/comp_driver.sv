/*
 * Project: RNM testbench
 * File: comp_driver.sv
 * Author: Denis Kucera
 * Created: 2026-05-12
 * Description:
 */
class comp_driver extends uvm_driver #(comp_item);

  virtual interface comp_if m_vif;

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

    forever begin
      seq_item_port.get_next_item(req);

      fork begin : sample_threads
          fork
            // (Digital) control
            begin
                comparator_control(req);
            end
            
            // Analog threads
            begin drive_in_pin(req.in_samples, req.cfg_in.step_ps/*, req.cfg_in*/); end
            begin drive_vdd_pin(req.vdd_samples, req.cfg_vdd.step_ps/*, req.cfg_vdd*/); end
            begin drive_bias_pin(req.bias_samples, req.cfg_bias.step_ps/*, req.cfg_bias*/); end
          join_any // As soon as ANY thread finishes, move on

          //  kill the remaining threads (the analog ones) 
          //  digital synchronization
          disable fork; 
      end : sample_threads join

      end_tr(req);
      seq_item_port.item_done();
    end
  endtask : run_phase


  task drive_idle_signals();
    m_vif.am_invert   <= 0;
    m_vif.am_complete <= 0;
    m_vif.am_short    <= 0;
  endtask
  task drive_sample_signals(/*comp_item req*/);
    m_vif.am_invert   <= 1;
    m_vif.am_short    <= 1;
    m_vif.am_clk_sample <= 1;
  endtask
  task drive_hold_signals(comp_item req);
    m_vif.am_invert <= 0;
    #(req.invert_to_sample * 1ps);
    m_vif.am_clk_sample <= 0;
  endtask
  task drive_compare_signals(comp_item req);
    m_vif.am_short <= 0;
    #(req.short_to_invert * 1ps);
    m_vif.am_invert <= 1;
  endtask
  task drive_glitch_signals(comp_item req);
    m_vif.am_clk_sample = req.comp_am_clk_sample;
    m_vif.am_invert     = req.comp_am_invert;
    m_vif.am_short      = req.comp_am_short;
    m_vif.am_complete   = req.comp_am_complete;
  endtask

  task comparator_control(comp_item req);

    m_vif.set_debug_state(req.state);
    `uvm_info("DRV_DEBUG", $sformatf("Driver dostal z UVM sekvence stav: %s", req.state.name()), UVM_NONE)
    //if(counter == stored_time) begin
    case(req.state)
      comp_item::SAMPLE:  drive_sample_signals(/*req*/);
      comp_item::HOLD:    drive_hold_signals(req);
      comp_item::COMPARE: drive_compare_signals(req);
      comp_item::IDLE:    drive_idle_signals(/*req*/);
      comp_item::GLITCH:  drive_glitch_signals(req);
    endcase

    //end else begin
        // Safety catch if delay was too short for even one sample
        if (req.comp_delay_ps > 0) #((req.comp_delay_ps - req.invert_to_sample - req.short_to_invert) * 1ps);
        else #1ps; 
    //end
  endtask

  task drive_in_pin(real number_of_samples [], int time_step_ps);
    foreach (number_of_samples[i]) begin
        m_vif.in = number_of_samples[i];
        #(time_step_ps * 1ps);
    end
  endtask

task drive_vdd_pin(real number_of_samples [], int time_step_ps);
    foreach (number_of_samples[i]) begin
        m_vif.vdd = number_of_samples[i];
        #(time_step_ps * 1ps);
    end
  endtask

  task drive_bias_pin(real number_of_samples [], int time_step_ps);
    foreach (number_of_samples[i]) begin
        m_vif.inv_bias = number_of_samples[i];
        #(time_step_ps * 1ps);
    end
  endtask

  // UVM report_phase
  function void report_phase(uvm_phase phase);

  endfunction : report_phase

endclass : comp_driver
