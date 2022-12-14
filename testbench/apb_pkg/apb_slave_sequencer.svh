
`ifndef APB_SLAVE_SEQUENCER_SVH
`define APB_SLAVE_SEQUENCER_SVH

class apb_slave_sequencer extends uvm_sequencer #(apb_transfer);

  //////////////////////////////////////////////////////////////////////////////
  //
  //  Public interface (Component users may manipulate these fields/methods)
  //
  //////////////////////////////////////////////////////////////////////////////
  apb_config cfg;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(apb_slave_sequencer)
     // USER: Register fields 
  `uvm_component_utils_end

  // new - constructor
  extern function new (string name, uvm_component parent);

  //////////////////////////////////////////////////////////////////////////////
  //
  //  Implementation (private) interface
  //
  //////////////////////////////////////////////////////////////////////////////

  // The virtual interface used to drive and view HDL signals.
  virtual apb_interface vif;

endclass : apb_slave_sequencer

`endif // APB_SLAVE_SEQUENCER_SVH


