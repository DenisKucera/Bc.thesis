/*
 * Project: RNM testbench
 * File: comp_scoreboard.sv
 * Author: Denis Kucera
 * Created: 2026-05-12
 * Description: Scoreboard
 */

class comp_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(comp_scoreboard)

    uvm_analysis_imp#(comp_item, comp_scoreboard) m_comp_item_collected;

    // Constructor
    function new(string name="", uvm_component parent=null);
        super.new(name, parent);
        m_comp_item_collected = new("m_comp_item_collected", this);
    endfunction


    task run_phase(uvm_phase phase);

    endtask

    int pass_count = 0;
    int fail_count = 0;

    // PREDICTOR LOGIC
    // !!! TODO !!!
    /*virtual function void write(comp_item item);
        logic out_expected;
        bit rnm_match   = (item.comp_out === out_expected);
        bit spice_match = (item.comp_analog_out === out_expected);


        // Predictor Logic (The "Golden" Reference)
        // We compare the STORED value against the COMPARE value
        if (item.comp_compare_curr > item.comp_stored_curr) begin
            out_expected = 1'b1;
        end else begin
            out_expected = 1'b0;
        end

        // Evaluation Logic

        if (rnm_match && spice_match) begin
            pass_count++;
            `uvm_info("SB_PASS", item.convert2string(), UVM_LOW)
            `uvm_info("SB_PASS", $sformatf("MATCH! Expected: %b | RNM: %b | SPICE: %b", out_expected, item.comp_out, item.comp_analog_out), UVM_LOW)
        end else begin
            fail_count++;
            if (!rnm_match)
                `uvm_error("SB_RNM_FAIL", $sformatf("RNM Error! Expected %b, Got %b", out_expected, item.comp_out))
            if (!spice_match)
                `uvm_error("SB_SPICE_FAIL", $sformatf("SPICE Error! Expected %b, Got %b", out_expected, item.comp_analog_out))
        end

        // 3. Divergence Check
        if (item.comp_out !== item.comp_analog_out) begin
            `uvm_warning("SB_DIVERG", "RNM and SPICE models differ (likely timing/accuracy jitter)")
        end
    endfunction*/

    virtual function void write(comp_item item);
        string msg;
        real delta_current;
        real abs_delta;

        // Calculate the difference for easy debugging
        
        delta_current = (item.comp_compare_curr - item.comp_stored_curr) * 1e6; // in uA
        abs_delta = (delta_current < 0.0) ? -delta_current : delta_current;

        // Create a high-visibility "Data Trace"
        msg = $sformatf("\n+--------------------------------------------------+");
        msg = {msg, $sformatf("\n| RECEIVED ITEM <- COMPARATOR                      |")};
        msg = {msg, $sformatf("\n+--------------------------------------------------+")};
        msg = {msg, $sformatf("\n| ANALOG DATA:                                     |")};
        //msg = {msg, $sformatf("\n| State Path:   %s -> %s (%s)             |", item.state.name(), item.next_state.name(), item.state_transition.name())};
        msg = {msg, $sformatf("\n| Supply:       VDD = %0.3f V                      |", item.comp_vdd)};
        //msg = {msg, $sformatf("\n+--------------------------------------------------+")};
        msg = {msg, $sformatf("\n| [sample]  Stored I:  %10.3f uA               |", item.comp_stored_curr * 1e6)};
        msg = {msg, $sformatf("\n| [compare] Input I:   %10.3f uA               |", item.comp_compare_curr * 1e6)};
        msg = {msg, $sformatf("\n| [Result]    DIFF (I):  %10.3f uA             |", abs_delta)};
        msg = {msg, $sformatf("\n+--------------------------------------------------+")};
        msg = {msg, $sformatf("\n| COMPARATOR RESPONSE:                             |")};
        msg = {msg, $sformatf("\n| RNM OUT:    %b                                    |", item.comp_out)};
        msg = {msg, $sformatf("\n| SPICE OUT:  %b                                    |", item.comp_analog_out)};
        msg = {msg, $sformatf("\n+--------------------------------------------------+")};

        // Quick "Manual Predictor" check for visual confirmation
        /*if (delta_current > 0)
            msg = {msg, "\n  V-OBSERVE:  Input > Stored (Expect '1')"};
        else
            msg = {msg, "\n  V-OBSERVE:  Input < Stored (Expect '0')"};

        msg = {msg, "\n=============================================================="};*/

        `uvm_info("SCB_DEBUG", msg, UVM_LOW)
    endfunction


    function bit predict_output(real stored_i, real compare_i);
      if (compare_i > stored_i) return 1'b1;
      else return 1'b0;
    endfunction


  // The dB Calculator
  function real calculate_db_diff(real stored_i, real compare_i);
      real ratio;
      real db_diff;

      if (stored_i <= 1e-12 || compare_i <= 1e-12) return 0.0; 
      
      ratio = compare_i / stored_i;
      
      db_diff = 10.0 * $log10(ratio);
      //return absolute value
      return (db_diff < 0.0) ? -db_diff : db_diff;
  endfunction

  function void check_sample_time();
    
  endfunction

// UVM check_phase
    function void check_phase(uvm_phase phase);

    endfunction : check_phase

// UVM report() phase
    function void report_phase(uvm_phase phase);
        /*string s;
        s = "\n--------------------------------------------------";
        s = {s, $sformatf("\n SCOREBOARD REPORT")};
        s = {s, $sformatf("\n  PASSED: %0d", pass_count)};
        s = {s, $sformatf("\n  FAILED: %0d", fail_count)};
        s = {s, "\n--------------------------------------------------"};
        `uvm_info("SB_FINAL", s, UVM_LOW)*/
    endfunction : report_phase

endclass : comp_scoreboard
