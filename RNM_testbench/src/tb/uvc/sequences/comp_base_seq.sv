/*
 * Project: RNM testbench
 * File: comp_base_seq.sv
 * Author: Denis Kucera
 * Created: 2026-05-12
 * Description: Base comparator sequence with derived sequences
 */
class comp_base_seq extends uvm_sequence#(comp_item);

// Required macro for sequences automation
  `uvm_object_utils(comp_base_seq)

  // sequencer pointer macro
  `uvm_declare_p_sequencer(comp_sequencer)

  //fields
  //rand ....
  //rand ...

  //constraints
  //...........

  // Constructor
  function new(string name="comp_base_seq");
    super.new(name);
  endfunction


  virtual task body();
    //create comp item
    //Create a persistent tracker for the state machine
    comp_item::comp_state_e current_tracker = comp_item::IDLE;

    `uvm_info(get_type_name(), "Starting Comparator Base Sequence", UVM_LOW)

    repeat(10) begin
    comp_item req = comp_item::type_id::create("req");

    start_item(req);

    req.state = current_tracker;

    `uvm_info("SEQ", $sformatf("Transition: %s -> %s (Mode: %s)", 
          req.state.name(), req.next_state.name(), req.state_transition.name()), UVM_LOW)

    if (!req.randomize() with {
        req.state_transition == comp_item::CORRECT;
        req.timing == comp_item::CORRECT;
      }) begin
      `uvm_fatal(get_type_name(), "Failed to randomize comp_item.")
    end

    `uvm_info("SEQ", $sformatf("Driving: %s -> %s (Mode: %s, Delay: %0d ps)", 
                  req.state.name(), 
                  req.next_state.name(), 
                  req.state_transition.name(),
                  req.comp_delay_ps), UVM_HIGH)

     finish_item(req);
     `uvm_info("LOG", req.convert2string(), UVM_LOW)

     current_tracker = req.next_state;
    end
   
  endtask


endclass: comp_base_seq

