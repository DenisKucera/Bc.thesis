/*
 * Project: RNM testbench
 * File: comp_base_seq.sv
 * Author: Denis Kucera
 * Created: 2026-05-12
 * Description: Base comparator sequence with derived sequences
 */
class comp_sequence extends uvm_sequence#(comp_item);

// Required macro for sequences automation
  `uvm_object_utils(comp_sequence)

  // sequencer pointer macro
  `uvm_declare_p_sequencer(comp_sequencer)

  realtime param_max_acq_time;
  realtime param_max_dec_time; 

  //sequence control fields
  int num_compares;
  comp_item::comp_state_e start_state = comp_item::IDLE;

    // Waveform Configurations
    comp_item::wave_config_s cfg_in;
    comp_item::wave_config_s cfg_bias;
    comp_item::wave_config_s cfg_vdd;
    comp_item::wave_config_s cfg_vss;

    comp_item::comp_control_e cfg_state_transition;
    comp_item::comp_control_e cfg_timing;

    longint seq_timer_ps = 0;

  // Constructor
  function new(string name="comp_sequence");
    super.new(name);

    cfg_in      = '{w_type: comp_item::NOISE, offset: 1.0e-6,  amplitude: 0.5e-6, period_ps: 50, step_ps: 500};
    cfg_bias    = '{w_type: comp_item::STATIC, offset: 0.0,     amplitude: 0.0, period_ps: 50, step_ps: 100};
    cfg_vdd     = '{w_type: comp_item::STATIC, offset: 0.8,     amplitude: 0.0, period_ps: 50, step_ps: 500};
    cfg_vss     = '{w_type: comp_item::STATIC, offset: 0.8,     amplitude: 0.0, period_ps: 50, step_ps: 500};
  endfunction


virtual task body();
        // Create a persistent tracker for the state machine
        comp_item::comp_state_e current_tracker = start_state;

        if(!uvm_config_db#(realtime)::get(null, get_sequencer().get_full_name(), "param_max_dec_time", param_max_dec_time))
            `uvm_fatal("NO_DEC_PARAM_CFG", "Sequence could not find max decision time!")
            
        if(!uvm_config_db#(realtime)::get(null, get_sequencer().get_full_name(), "param_max_acq_time", param_max_acq_time))
            `uvm_fatal("NO_ACQ_PARAM_CFG", "Sequence could not find max sample time!")

        repeat(num_compares) begin
            comp_item req = comp_item::type_id::create("req");

            start_item(req);

            req.param_dec_time_ps = int'(param_max_dec_time / 1ps);
            req.param_acq_time_ps = int'(param_max_acq_time / 1ps);

            // Update the item's state tracker
            req.state = current_tracker;
 
            req.cfg_in        = this.cfg_in;
            req.cfg_bias      = this.cfg_bias;
            req.cfg_vdd       = this.cfg_vdd;

            // --- B. RANDOMIZE DIGITAL PROTOCOL ---
            if (!req.randomize() with {
                req.state_transition == cfg_state_transition;
                req.timing           == cfg_timing;
            }) begin
                `uvm_fatal(get_type_name(), "Failed to randomize comp_item.")
            end

            create_waveform(req.comp_delay_ps, cfg_in, req.in_samples);
            create_waveform(req.comp_delay_ps, cfg_bias,    req.bias_samples);
            create_waveform(req.comp_delay_ps, cfg_vdd,     req.vdd_samples);
            create_waveform(req.comp_delay_ps, cfg_vss,     req.vss_samples);

            `uvm_info("SEQ_ITEM", req.convert2string(), UVM_LOW)
 
            finish_item(req);

            seq_timer_ps += req.comp_delay_ps;
            current_tracker = req.next_state;
        end
    endtask

    function void create_waveform(int delay_ps, comp_item::wave_config_s cfg, ref real analog_samples[]);
        int num_samples;
        
        if (cfg.step_ps > 0) begin
            num_samples = delay_ps / cfg.step_ps;
            analog_samples = new[num_samples]; 
            
            for (int i = 0; i < num_samples; i++) begin
                // Use the Sequence's global time tracker!
                longint time_in_ps = seq_timer_ps + (i * cfg.step_ps);
                analog_samples[i] = calculate_waveform(time_in_ps, cfg); 
            end
        end else begin
            analog_samples = new[0];
        end
    endfunction

    function real calculate_waveform(longint time_ps, comp_item::wave_config_s cfg);
        int  mod_time_ps;
        int  safe_period_ps;
        real phase_fraction;

        safe_period_ps = (cfg.period_ps > 0) ? cfg.period_ps : 1;
        mod_time_ps = time_ps % safe_period_ps;
        phase_fraction = real'(mod_time_ps) / real'(safe_period_ps);

        case (cfg.w_type)
            comp_item::STATIC: begin
                calculate_waveform = cfg.offset;
            end
            
            comp_item::NOISE: begin
                calculate_waveform = cfg.offset + ((real'($urandom_range(0, 200)) - 100.0) / 100.0) * cfg.amplitude;
            end
            
            comp_item::PULSE_POS: begin
                calculate_waveform = (phase_fraction < 0.5) ? (cfg.offset + cfg.amplitude) : cfg.offset;
            end
            
            comp_item::PULSE_NEG: begin
                calculate_waveform = (phase_fraction < 0.5) ? (cfg.offset - cfg.amplitude) : cfg.offset;
            end
            
            comp_item::SLOPE_POS: begin
                calculate_waveform = cfg.offset + (cfg.amplitude * phase_fraction);
            end
            
            comp_item::SLOPE_NEG: begin
                calculate_waveform = cfg.offset - (cfg.amplitude * phase_fraction);
            end
            
            comp_item::SINE: begin
                calculate_waveform = cfg.offset + (cfg.amplitude * $sin(2.0 * 3.14159265 * phase_fraction));
            end
            
            comp_item::DISABLE: begin
                calculate_waveform = 0.0; 
            end
            
            default: calculate_waveform = 0.0;
        endcase
        
    endfunction


endclass: comp_sequence