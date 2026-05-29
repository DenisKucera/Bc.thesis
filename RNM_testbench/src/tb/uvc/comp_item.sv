/*
 * Project: RNM testbench
 * File: digital_item.sv
 * Author: Denis Kucera
 * Created: 2026-05-12
 * Description: coparator digital item fields and constraints for digital sequencer
 */

class comp_item extends uvm_sequence_item;

    // -------------------------------------------------------
    // 1. DECLARE VARIABLES FIRST
    // -------------------------------------------------------

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

    //real wave_amplitude;
    //real wave_period_ns;
    //fields for sampled analog values
    real in_samples [];
    real bias_samples [];
    real vdd_samples [];
    //sample time for analog signal generation
    //real start_time_ns;

    // timing (realtime)
    rand int unsigned comp_delay_ps;

    rand int unsigned invert_to_sample;
    rand int unsigned short_to_invert;

    rand logic comp_am_short;
    rand logic comp_am_invert;
    rand logic comp_am_clk_sample;
    rand logic comp_am_complete;

    // variables for monitor (Not randomized)
    logic comp_out;
    logic comp_analog_out;
    //types of control sequence stimulus
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
    //types of analog stimulus (including supply voltage)
    typedef enum{
        STATIC,
        NOISE,
        PULSE_NEG,
        PULSE_POS,
        SLOPE_NEG,
        SLOPE_POS,
        SINE,
        DISABLE
    }wave_type_e;

    // The Container! Packages all waveform settings together.
    typedef struct {
        wave_type_e w_type;
        real offset;
        real amplitude;
        //real period_ns;
        int period_ps;
        int  step_ps;
    } wave_config_s;

    //holding current comparator state
    comp_state_e state;

    rand comp_state_e start_state;
    //randomized next state
    rand comp_state_e next_state;
    //control knobs for randomization
    rand comp_control_e timing, state_transition;

    wave_config_s cfg_in_curr;
    wave_config_s cfg_bias;
    wave_config_s cfg_vdd;

 
    `uvm_object_utils_begin(comp_item)
        // Note: realtime variables MUST use uvm_field_real
        // Control Knobs & States
        `uvm_field_enum(comp_state_e, state, UVM_ALL_ON)
        `uvm_field_enum(comp_state_e, start_state, UVM_ALL_ON)
        `uvm_field_enum(comp_state_e, next_state, UVM_ALL_ON)
        `uvm_field_enum(comp_control_e, timing, UVM_ALL_ON)
        `uvm_field_enum(comp_control_e, state_transition, UVM_ALL_ON)

        `uvm_field_int(comp_delay_ps, UVM_ALL_ON)
        `uvm_field_int(comp_am_short, UVM_ALL_ON)
        `uvm_field_int(comp_am_invert, UVM_ALL_ON)
        `uvm_field_int(comp_am_clk_sample, UVM_ALL_ON)
        `uvm_field_int(comp_am_complete, UVM_ALL_ON)

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


    constraint c_default_state_transition { state_transition dist {RANDOM := 1, INCORRECT := 1, CORRECT := 4}; }
    constraint c_default_timings { timing dist {RANDOM := 1, INCORRECT := 1, CORRECT := 4};}

    constraint c_invert_to_sample_delay { invert_to_sample inside {[100 : 1000]};}
    constraint c_short_to_invert_delay { short_to_invert inside {[100 : 1000]};}

    constraint c_state_transition {
        // Knob 1: Follow the spec
        (state_transition == CORRECT) -> {
            state == IDLE  -> next_state == SAMPLE;
            state == SAMPLE -> next_state == HOLD;
            state == HOLD -> next_state == COMPARE;
            state == COMPARE -> next_state == IDLE;
            start_state == IDLE;
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
            start_state dist {SAMPLE := 1, HOLD := 1, COMPARE := 1, IDLE := 1, GLITCH := 1};
        }
        // Knob 3: Dedicated Glitch mode
        (state_transition == RANDOM) -> {
            next_state dist {SAMPLE := 1, HOLD := 1, COMPARE := 1, IDLE := 1, GLITCH := 2};
            next_state != state;
            start_state dist {SAMPLE := 1, HOLD := 1, COMPARE := 1, IDLE := 1, GLITCH := 1};
        }
    }

    constraint c_timings {
        (timing == CORRECT) -> {
            state == SAMPLE  -> comp_delay_ps inside {[0 : 10_000_000]}; // 5-15us
            state == HOLD   -> comp_delay_ps inside {[5_000_000 : 10_000_000]};           // min 300ps
            state == COMPARE -> comp_delay_ps inside {[50_000 : 2_000_000]};         // max 2us
            state == IDLE   -> comp_delay_ps == 50_000_000;                         // 100us
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
    

    function void post_randomize();
    
    endfunction

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
        s = {s, $sformatf("\n+--------------------------------------------------+")};
        s = {s, $sformatf("\n| ANALOG INPUT CONFIGURATIONS:                     |")};
        s = {s, $sformatf("\n|--------------------------------------------------|")};
        s = {s, $sformatf("\n| [VDD]                                            |")};
        s = {s, $sformatf("\n|   Type: %-12s Step: %-7d ps            |", cfg_vdd.w_type.name(), cfg_vdd.step_ps)};
        s = {s, $sformatf("\n|  Offset:  %8.3f V    Amplitude:  %8.3f V   |", cfg_vdd.offset, cfg_vdd.amplitude)};
        s = {s, $sformatf("\n| [INPUT CURRENT]                                  |")};
        s = {s, $sformatf("\n|   Type: %-12s Step: %-7d ps            |", cfg_in_curr.w_type.name(), cfg_in_curr.step_ps)};
        s = {s, $sformatf("\n|  Offset:  %8.3f uA   Amplitude:  %8.3f uA  |", cfg_in_curr.offset * 1e6, cfg_in_curr.amplitude * 1e6)};
        s = {s, $sformatf("\n| [BIAS CURRENT]                                   |")};
        s = {s, $sformatf("\n|   Type: %-12s Step: %-7d ps            |", cfg_bias.w_type.name(), cfg_bias.step_ps)};
        s = {s, $sformatf("\n|  Offset:  %8.3f uA   Amplitude:  %8.3f uA  |", cfg_bias.offset * 1e6, cfg_bias.amplitude * 1e6)};
        s = {s, $sformatf("\n+--------------------------------------------------+")};
        return s;
    endfunction

endclass: comp_item

