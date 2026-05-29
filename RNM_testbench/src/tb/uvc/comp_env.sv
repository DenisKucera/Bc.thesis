/*
 * Project: RNM testbench
 * File: comp_env.sv
 * Author: Denis Kucera
 * Created: 2026-05-12
 * Description: UVC level layer
 */
class comp_env extends uvm_env;

  // Components of the environment
  comp_agent m_comp_agent;
  comp_agent_cfg m_agent_cfg;
  comp_scoreboard m_comp_scoreboard;
  //comp_coverage m_comp_coverage;

  // component macro
  `uvm_component_utils(comp_env)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  int cov_enabled;

  // UVM build_phase()
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //create comp UVC agent config
    m_agent_cfg = comp_agent_cfg::type_id::create("m_agent_cfg", this);
    //create comp UVC agent (UVC)
    m_comp_agent = comp_agent::type_id::create("m_comp_agent", this);
    //create scoreboard
    m_comp_scoreboard = comp_scoreboard::type_id::create("m_comp_scoreboard", this);
    //create coverage collector
    /*if(!uvm_config_db#(int)::get(this, "", "DMS CO-SIMULATION ENABLED!", cov_enabled)) begin
      m_comp_coverage = comp_coverage::type_id::create("m_comp_coverage",this);
    end*/
  endfunction : build_phase
  
  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
  endfunction : start_of_simulation_phase

  function void connect_phase(uvm_phase phase);
    m_comp_agent.m_comp_monitor.collected_item.connect(m_comp_scoreboard.m_comp_item_collected);
    /*if(m_comp_coverage != null) begin
      m_comp_agent.m_comp_monitor.collected_item.connect(m_comp_coverage.analysis_export);
    end*/
  endfunction
  
endclass : comp_env
