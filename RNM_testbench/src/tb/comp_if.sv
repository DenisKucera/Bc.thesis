/*
 * Project: RNM testbench
 * File: comp_if.sv
 * Author: Denis Kucera
 * Created: 2026-05-12
 * Description: Interface
 */

interface comp_if (/*parameter bit ENABLE_MS = 1*/);

     `include "uvm_macros.svh"
    import uvm_pkg::*;
  
    // UVM Variables (Driven by the UVM Driver)
    logic am_complete;
    logic am_clk_sample;
    logic am_invert;
    logic am_short;

    logic am_cmpr_out_rnm;

    real  in;
    real  inv_bias;
    real  vdd;
    real  vss;
    real  idd;
    //main controlling signals
    logic clk;
    logic reset;

    typedef enum bit [2:0] {
        IDLE    = 3'b000,
        SAMPLE  = 3'b001,
        HOLD    = 3'b010,
        COMPARE = 3'b011,
        GLITCH  = 3'b100
    } debug_state_e;

    //bit [2:0] debug_state;
    debug_state_e debug_state;

    // 2. Create a string variable to hold the name
    string state_name;

    function void set_debug_state(bit [2:0] val);
        $cast(debug_state, val);
    endfunction

    // 3. Automatically update the string whenever the state changes

    assign state_name = debug_state.name();
    
    // Wire for the output
    wire      w_cmpr_out_spice; 
    logic     am_cmpr_out_spice;
    assign   am_cmpr_out_spice = w_cmpr_out_spice;

endinterface

