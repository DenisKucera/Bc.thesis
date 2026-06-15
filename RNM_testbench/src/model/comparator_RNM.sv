/* 
 * Project: RNM model
 * File: comparator_RNM.sv
 * Author: Denis Kucera
 * Created: 2025-11-30
 * Ver. 2.4 final version, tested by co-simulation with comparator netlist
 * Description: SystemVerilog Comparator Real Number Model
 */

module comparator_RNM #(
        parameter real        MAX_CURRENT           = 50.0e-6,
        parameter real        MAX_ERR_DB            = 0.25,
        parameter real        MIN_ERR_DB            = 0.10,
        parameter realtime    ACQ_TIME              = 10us,
        parameter realtime    DECISION_TIME         = 2us,
        parameter realtime    HOLD_TIME             = 300ps,
        parameter real        CURRENT_CONSUMPTION   = 35.0e-9,
        parameter real        SUPPLY_MIN            = 0.65,
        parameter real        SUPPLY_MAX            = 1.0,
        parameter real        BIAS_CURRENT          = 5.0e-9
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
        output real  idd
    );
    real stored_current  = 0.0;
    real current_draw;
    real sample_start_time = 0;
    real inv_bias_ok;
    real in_ok;

    logic cmpr_enabled;
    logic cmpr_out;

    initial cmpr_out = 1'b1;


    function real abs(input real val);
        return (val < 0) ? -val : val;
    endfunction

    // Saturation
    function real apply_saturation(input real in_val);
        if (abs(in_val) < inv_bias_ok) begin
            return 0.0;
        end
        else if (abs(in_val) > MAX_CURRENT) begin
            return MAX_CURRENT;
        end
        else begin
            return abs(in_val);
        end
    endfunction

    //function for calculating offset
    function real calc_offset(input real in_val);
        real dyn_db;
        real rnd_sign;
        real prec_factor;
        real eff_input;

        eff_input = apply_saturation(in_val);

        // BIAS current
        if (eff_input < inv_bias_ok) begin
            return 0.0;
        end else begin
            // dyn. error
            dyn_db = MIN_ERR_DB + (MAX_ERR_DB - MIN_ERR_DB) * (real'($urandom_range(0, 1000)) / 1000.0);

            // Clamp
            if (dyn_db > MAX_ERR_DB) dyn_db = MAX_ERR_DB;
            if (dyn_db < MIN_ERR_DB) dyn_db = MIN_ERR_DB;

            // randomize
            rnd_sign = ($urandom_range(0,1)) ? 1.0 : -1.0;
            prec_factor = 10.0**((dyn_db * rnd_sign) / 20.0);

            // offset
            return eff_input * (prec_factor - 1.0);
        end
    endfunction


    // PWR CHECK

    always @(vdd) begin
        // max
        assert ((vdd-vss) <= SUPPLY_MAX) else
            $fatal(0, "[COMPARATOR_RNM] Supply Voltage too HIGH! =%0.3fV (Max: %0.3fV)", vdd, SUPPLY_MAX);
    end

    // enable/disable comparator
    assign cmpr_enabled = ((vdd-vss) >= SUPPLY_MIN) && (am_complete == 1'b0);
    // comparator output
    assign am_cmpr_out = cmpr_enabled ? cmpr_out : 1'bx;
    // valid bias current
    assign inv_bias_ok = (inv_bias >= abs(BIAS_CURRENT)) ? inv_bias : 0.0;
    // input current boundaries
    assign in_ok = apply_saturation(in);

    // SAMPLE
    always @(posedge am_clk_sample)
    begin
        sample_start_time <= $realtime;
        cmpr_out <= 1'b1;
    end

    always @(negedge am_invert iff(am_short)) begin 
        real sampled_current;
        real charge_factor;

            if(in_ok > inv_bias_ok) begin
                sampled_current = in_ok;
            if ($realtime - sample_start_time >= (ACQ_TIME/2.0)) begin
                // 100% fully settled
                stored_current <= sampled_current;
            end else begin
                // Calculate the partial charge 
                charge_factor = 1.0 - $exp(-($realtime - sample_start_time) / (ACQ_TIME/4.0));
                charge_factor = (charge_factor > 1.0) ? 1.0 : charge_factor;
                // Store the partially settled value!
                stored_current <= stored_current + (sampled_current - stored_current) * charge_factor;
                    
                $info("RNM: Sample switch opened early (%0.0f ns). Capacitor reached %0.1f%% charge.", 
                        ($realtime - sample_start_time), charge_factor * 100.0);
            end
        end
        sample_start_time <= 0.0;
    end

    // AUTO-ZERO
    always @(posedge am_short)
    begin
        #HOLD_TIME; // delay
        cmpr_out <= 1'b1; //comparator invalid 
    end

    // COMPARE
    always @(posedge am_invert iff !am_short) begin 
        real curr_input;
        real comp_current;
        real dec_time;

        if(DECISION_TIME > 0) begin
            dec_time = (DECISION_TIME/1000) * real'($urandom_range(500, 1000));
        end
        #dec_time;
        curr_input = in_ok;
        comp_current = curr_input - stored_current;
        //TODO ...
        if((abs(comp_current) < inv_bias_ok) || (curr_input > stored_current)) begin
            cmpr_out <= 1;
        end
        else begin
                //TODO ...
                if ((comp_current + calc_offset(in)) > 0)
                    cmpr_out <= 1'b1;
                else
                    cmpr_out <= 1'b0;
        end
    end

    // Current consumption
    always_comb begin
        if (am_invert && !am_short) //COMPARE phase
            current_draw = CURRENT_CONSUMPTION + inv_bias;
        else
            current_draw = inv_bias;
    end
    assign idd = cmpr_enabled ? current_draw : 0.0;

endmodule