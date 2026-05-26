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

    logic am_cmpr_out_RNM;

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
    wire w_in            = in;
    wire w_vdd           = vdd;
    wire w_vss           = vss;
    wire w_inv_bias      = inv_bias;
    
    // Wire for the output
    wire      w_cmpr_out_spice; 
    logic     am_cmpr_out_SPICE = w_cmpr_out_spice;

    // 2. Physical DUT Connections (Nets & UDNs)
    // We declare the UDNs here in the interface
    //cmpr_udn_net vdd_rail;
    
    // Standard nets
    //wire real w_in;
    //wire      w_cmpr_out; // Read by the UVM Monitor

    // 3. The Translation Layer (Variable -> Net)
    // Continuous assignment pushes the UVM driver's variable onto the real wire
    //assign w_in = drv_in_current;
    
    // Push the UVM variable into the UDN structure!
    //assign vdd_rail = '{v_vdd: drv_vdd_voltage, i_idd: 0.0};

endinterface

