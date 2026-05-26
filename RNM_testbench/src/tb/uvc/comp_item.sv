/*
 * Project: RNM testbench
 * File: comp_item.sv
 * Author: Denis Kucera
 * Created: 2026-05-12
 * Description: Comparator item fields and methods for sequencer
 */

class comp_item extends uvm_sequence_item;

    // -------------------------------------------------------
    // 1. DECLARE VARIABLES FIRST
    // -------------------------------------------------------

    // timing (realtime)
    rand int unsigned comp_delay_ps;

    rand logic comp_am_short;
    rand logic comp_am_invert;
    rand logic comp_am_clk_sample;

    // accuracy
    real comp_acc;

    // analog input
    real comp_in_curr;
    // for monitor obsevation of sampled and compared currents
    real comp_stored_curr;
    real comp_compare_curr;
    // analog input bias current
    real comp_bias_curr;

    // supply
    real comp_vdd;
    real comp_idd;

    // variables for monitor (Not randomized)
    logic comp_out;
    logic comp_analog_out;

    typedef enum{
        IDLE,
        SAMPLE,
        HOLD,
        COMPARE,
        GLITCH
    }comp_state_e;

    typedef enum{
        CORRECT,
        INCORRECT,
        RANDOM
    }comp_control_e;

    //holding current comparator state
    comp_state_e state;
    //randomized next state
    rand comp_state_e next_state;
    //control knobs for randomization
    rand comp_control_e timing, state_transition;

    // -------------------------------------------------------
    // 2. UVM MACROS SECOND
    // -------------------------------------------------------
    `uvm_object_utils_begin(comp_item)
        // Note: realtime variables MUST use uvm_field_real
        // Control Knobs & States
        `uvm_field_enum(comp_state_e, state, UVM_ALL_ON)
        `uvm_field_enum(comp_state_e, next_state, UVM_ALL_ON)
        `uvm_field_enum(comp_control_e, timing, UVM_ALL_ON)
        `uvm_field_enum(comp_control_e, state_transition, UVM_ALL_ON)

        // Timing & Glitch Signals
        `uvm_field_int(comp_delay_ps, UVM_ALL_ON)
        `uvm_field_int(comp_am_short, UVM_ALL_ON)
        `uvm_field_int(comp_am_invert, UVM_ALL_ON)
        `uvm_field_int(comp_am_clk_sample, UVM_ALL_ON)

        // Analog Values
        `uvm_field_real(comp_acc, UVM_ALL_ON)
        `uvm_field_real(comp_in_curr, UVM_ALL_ON)
        `uvm_field_real(comp_bias_curr, UVM_ALL_ON)
        `uvm_field_real(comp_vdd, UVM_ALL_ON)
        `uvm_field_real(comp_idd, UVM_ALL_ON)

        // Monitor outputs
        `uvm_field_int(comp_out, UVM_ALL_ON)
        `uvm_field_int(comp_analog_out, UVM_ALL_ON)
    `uvm_object_utils_end

    // Constructor
    function new (string name = "comp_item");
        super.new(name);
    endfunction : new


    constraint default_state_transition { state_transition dist {RANDOM := 1, INCORRECT := 1, CORRECT := 4}; }

    constraint default_timings { timing dist {RANDOM := 1, INCORRECT := 1, CORRECT := 4};}

    constraint c_state_transition {
        // Knob 1: Follow the spec
        (state_transition == CORRECT) -> {
            state == IDLE  -> next_state == SAMPLE;
            state == SAMPLE -> next_state == HOLD;
            state == HOLD -> next_state == COMPARE;
            state == COMPARE -> next_state == IDLE;
            next_state != GLITCH;
        }
        // Knob 2: Spin the wheel (The "Chaos" button)
        (state_transition == INCORRECT) -> {
            // Rule: It MUST NOT be the correct next state
            state == IDLE     -> next_state != SAMPLE;
            state == SAMPLE   -> next_state != HOLD;
            state == HOLD     -> next_state != COMPARE;
            state == COMPARE  -> next_state != IDLE;
            // Rule: Don't jump to GLITCH here (keep GLITCH as a separate knob)
            next_state != GLITCH;
        }
        // Knob 3: Dedicated Glitch mode
        (state_transition == RANDOM) -> {
            next_state dist {SAMPLE := 1, HOLD := 1, COMPARE := 1, IDLE := 1, GLITCH := 2};
            next_state != state;
        }
    }

    constraint c_timings {
        (timing == CORRECT) -> {
            state == SAMPLE  -> comp_delay_ps inside {[5_000_000 : 15_000_000]}; // 5-15us
            state == HOLD   -> comp_delay_ps == 300;                            // 300ps
            state == COMPARE -> comp_delay_ps inside {[5_000 : 20_000]};         // 5-20ns
            state == IDLE   -> comp_delay_ps == 10_000;                         // 10ns
            state == GLITCH -> comp_delay_ps == 1_000;                          // 1ns
        }

        // Knob 2: Violation (Too short)
        (timing == INCORRECT) -> {
            state == SAMPLE -> comp_delay_ps inside {[10 : 1_000]};              // Violates ACQ_TIME
            state == COMPARE -> comp_delay_ps inside {[10 : 1_000]};              // Violates DECISION_TIME
            state == HOLD -> comp_delay_ps == 10;                              // Violates HOLD_TIME
        }

        // Knob 3: Pure Chaos
        (timing == RANDOM) -> {
            comp_delay_ps inside {[10 : 20_000_000]};                      // Up to 20ms
        }
    }

    // post_randomize() - for variations of constraints based on selected mode
    function void post_randomize();

        // Randomize between 6 and 50000, multiply by 1e-9 -> [6.0e-9 : 50.0e-6]
        comp_in_curr = $urandom_range(6, 50000) * 1.0e-9;

        // Randomize between 4 and 6, multiply by 1e-9 -> [4.0e-9 : 6.0e-9]
        comp_bias_curr = $urandom_range(4, 6) * 1.0e-9;

        // Randomize between 10 and 25, divide by 100 -> [0.1 : 0.25]
        comp_acc = $urandom_range(10, 25) / 100.0;

        // Randomize between 65 and 100, divide by 100 -> [0.65 : 1.0]
        comp_vdd = $urandom_range(65, 100) / 100.0;
    endfunction : post_randomize

    virtual function string convert2string();
        string s;
        s = $sformatf("\n+--------------------------------------------------+");
        s = {s, $sformatf("\n| SENT ITEM -> COMPARATOR                          |")};
        s = {s, $sformatf("\n+--------------------------------------------------+")};
        s = {s, $sformatf("\n| CONTROL LOGIC STATUS:                            |")};
        s = {s, $sformatf("\n| COMPARATOR STATE: %-15s                |", state.name())};
        s = {s, $sformatf("\n| NEXT STATE:       %-15s                |", next_state.name())};
        s = {s, $sformatf("\n| STATE ORDER:      %-15s                |", state_transition.name())};
        s = {s, $sformatf("\n| TIMING:           %-15s                |", timing.name())};
        s = {s, $sformatf("\n|                                                  |")};
        s = {s, $sformatf("\n| ANALOG INPUT VALUES:                             |")};
        s = {s, $sformatf("\n| VDD:              %10.3f V                   |", comp_vdd)};
        s = {s, $sformatf("\n| INPUT CURRENT:    %10.3f uA                  |", comp_in_curr * 1e6)};
        s = {s, $sformatf("\n| BIAS CURRENT:     %10.3f uA                  |", comp_bias_curr * 1e6)};
        s = {s, $sformatf("\n+--------------------------------------------------+")};
        return s;
    endfunction

endclass: comp_item
