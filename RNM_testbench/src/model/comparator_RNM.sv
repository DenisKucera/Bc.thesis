// Soubor: sv/comparator_RNM.sv
// Ver. 1.4 added (Functions + Assertions), removed bug
// Denis Kučera

`timescale 1ns/1ps

module comparator_RNM #(
        parameter real    MAX_CURRENT   = 50.0e-6,
        parameter real    MAX_ERR_DB    = 0.25,
        parameter real    MIN_ERR_DB    = 0.10,
        parameter time    ACQ_TIME      = 10us,
        parameter time    DECISION_TIME = 0.01us,
        parameter time    HOLD_TIME     = 300ps,
        parameter real    BIAS_CURRENT  = 10.0e-9,
        parameter real    CURRENT_CONSUMPTION = 35.0e-9,

        // Nové parametry pro check napájení
        parameter real    SUPPLY_MIN    = 0.65,
        parameter real    SUPPLY_MAX    = 1.0
    )(
        input  real  vss,
        input  logic am_clk_sample,
        output logic am_cmpr_out,
        input  logic am_complete,
        input  logic am_invert,
        input  logic am_short,
        input  real  in,
        input  real  inv_bias,
        input  real  vdd,
        //input  real  supply_voltage,
        output real  current_consumption
    );
    real stored_current  = 0.0;
    real residual_offset = 0.0;
    real current_draw;
    logic cmpr_enabled;
    logic cmpr_out;
    time sample_start_time = 0;

    initial cmpr_out = 1'b0;


    // 1. Saturation
    function real apply_saturation(input real in_val);
        real abs_val;
        abs_val = (in_val < 0) ? -in_val : in_val;

        if (abs_val > MAX_CURRENT)
            return (in_val < 0) ? -MAX_CURRENT : MAX_CURRENT;
        else
            return in_val;
    endfunction

    //function for calculating offset
    function real calc_offset(input real in_val);
        real eff_input;
        real mag;
        real dyn_db;
        real rnd_sign;
        real prec_factor;

        eff_input = apply_saturation(in_val);
        mag = (eff_input < 0) ? -eff_input : eff_input;

        // BIAS current
        if (mag < (BIAS_CURRENT * 1.2)) begin
            return 0.0;
        end else begin
            // dyn. error
            dyn_db = MIN_ERR_DB + (MAX_ERR_DB - MIN_ERR_DB) * (BIAS_CURRENT / mag);

            // Clamp
            if (dyn_db > MAX_ERR_DB) dyn_db = MAX_ERR_DB;
            if (dyn_db < MIN_ERR_DB) dyn_db = MIN_ERR_DB;

            // randomize
            rnd_sign = ($urandom_range(0,1)) ? 1.0 : -1.0;
            prec_factor = 10.0**((dyn_db * rnd_sign) / 20.0);

            // Return: offset
            return eff_input * (prec_factor - 1.0);
        end
    endfunction


    // ASSERTIONS (PWR CHECK)

    always @(vdd) begin
        // max
        assert (vdd <= SUPPLY_MAX) else
            $error("[COMPARATOR_RNM] Supply Voltage too HIGH! =%0.3fV (Max: %0.3fV)", vdd, SUPPLY_MAX);
    end

    // enable/disable comparator
    assign cmpr_enabled = (vdd >= SUPPLY_MIN) && (am_complete == 1'b0);
    // comparator output
    assign am_cmpr_out = cmpr_enabled ? cmpr_out : 1'bx;

    // SAMPLE
    always @(posedge am_clk_sample)
    begin
        sample_start_time <= $realtime;
    end

    always @(negedge am_clk_sample) begin
        //if (vdd >= 0.8) begin 
            if (($realtime - sample_start_time) >= ACQ_TIME) begin
                // Použití funkce, blokující přiřazení
                stored_current <= apply_saturation(in);
            end else begin
                $warning("Acquisition time violation. Sample discarded.");
            end
        //end
    end

    // AUTO-ZERO
    always @(posedge am_short)
    begin
        cmpr_out <= 1'b1;
        #HOLD_TIME; // Dummy delay
    end

    /*always @(negedge am_short) begin
     //  offset
     residual_offset <= calc_offset(in);
     end*/

    // COMPARE
    always @(negedge am_short/*posedge am_invert*/) begin

        real curr_input;
        real abs_stored;
        residual_offset <= calc_offset(in);

        #DECISION_TIME;

        curr_input = apply_saturation(in);
        abs_stored = (stored_current < 0) ? -stored_current : stored_current;

        if (abs_stored < BIAS_CURRENT) begin
            cmpr_out <= 1'b0;
        end else begin
            if ((curr_input - stored_current + residual_offset) > 0)
                cmpr_out <= 1'b1;
            else
                cmpr_out <= 1'b0;
        end
    end

    // PWR
    always_comb begin
        if (am_invert)
            current_draw = CURRENT_CONSUMPTION;
        else if (am_clk_sample)
            current_draw = BIAS_CURRENT + 5.0e-9;
        else
            current_draw = BIAS_CURRENT;
    end
    assign current_consumption = cmpr_enabled ? current_draw : 0.0;

endmodule
