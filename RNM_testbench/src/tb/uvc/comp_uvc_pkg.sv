/*
 * Project: RNM testbench
 * File: comp_uvc_pkg.sv
 * Author: Denis Kucera
 * Created: 2026-05-12
 * Description: UVC package
 */

`timescale 1ns/1ps
 
package comp_uvc_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Include the UVC files in the correct compilation order
    `include "comp_item.sv"
    `include "comp_agent_cfg.sv"
    //`include "comp_coverage.sv"
    `include "comp_monitor.sv"
    `include "comp_scoreboard.sv"
    `include "comp_sequencer.sv"
    `include "comp_driver.sv"
    `include "comp_agent.sv"
    `include "comp_env.sv"
    `include "comp_sequence.sv"

endpackage
