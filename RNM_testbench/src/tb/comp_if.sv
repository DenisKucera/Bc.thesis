/*
 * Project: RNM testbench
 * File: comp_if.sv
 * Author: Denis Kucera
 * Created: 2026-05-12
 * Description: Interface
 */

//import udn_pkg::*;

interface comp_if ();

     `include "uvm_macros.svh"
    import uvm_pkg::*;
  
    
    // 1. UVM Variables (Driven by the UVM Driver)
    logic am_complete;
    logic am_clk_sample;
    logic am_invert;
    logic am_short;

    logic am_cmpr_out_rnm;

    real  in;
    real  inv_bias;
    real  vdd;
    real  vss;
    //main controlling signals
    logic clk;
    logic reset;

    // 1. Create intermediate 'nets' (wires) for the bidirectional SPICE pins
    wire w_am_clk_sample = am_clk_sample;
    wire w_am_short      = am_short;
    wire w_am_invert     = am_invert;
    wire w_am_complete   = am_complete;
    
    // For real numbers, use 'wire real' to satisfy the continuous assignment
    /*if (tb_top.ENABLE_AMS) begin
        wreal w_in = in;
        wreal w_vdd = vdd;
        wreal w_vss = vss;
        wreal w_inv_bias = inv_bias;
    end*/
    typedef enum bit [2:0] {
        IDLE    = 3'b000,
        SAMPLE  = 3'b001,
        HOLD    = 3'b010,
        COMPARE = 3'b011,
        GLITCH  = 3'b100
    } debug_state_e;

    debug_state_e debug_state;

    // 2. Create a string variable to hold the name
    string state_name;

    // 3. Automatically update the string whenever the state changes

    assign state_name = debug_state.name();
    
    // Wire for the output
    wire      w_cmpr_out_spice; 
    logic     am_cmpr_out_spice;
    assign   am_cmpr_out_spice = w_cmpr_out_spice;

    /*module real_wire_bridge (
    input  logic [63:0] wire_in,  // 64-bit wire to carry real bits
    output logic [63:0] wire_out
    );
    real my_real_val;

    // Convert bits from the wire into a real number
    assign my_real_val = $bitsastoreal(wire_in);

    // Convert the real number back to bits to drive a wire
    assign wire_out = $realtobits(my_real_val + 1.5);

    endmodule */

endinterface

