
`ifndef APB_MASTER_DRIVER_SVH
`define APB_MASTER_DRIVER_SVH

class apb_master_driver extends uvm_driver #(apb_transfer);

  //////////////////////////////////////////////////////////////////////////////
  //
  //  Public interface (Component users may manipulate these fields/methods)
  //
  //////////////////////////////////////////////////////////////////////////////
  apb_config cfg;

  // USER: Add your fields here

  // This macro performs UVM object creation, type control manipulation, and 
  // factory registration
  `uvm_component_utils_begin(apb_master_driver)
     // USER: Register fields here
  `uvm_component_utils_end

  // new - constructor
  extern function new (string name, uvm_component parent);

  // uvm run phase
  extern virtual task run();

  //////////////////////////////////////////////////////////////////////////////
  //
  //  Implementation (private) interface
  //
  //////////////////////////////////////////////////////////////////////////////

  // The virtual interface used to drive and view HDL signals.
  virtual apb_if vif;

  // This is the method that is responsible for getting sequence transactions
  // and driving the transaction into the DUT
  extern virtual protected task get_and_drive();
 
  // This method drives a sequence trasnaction onto the interface
  extern virtual protected task drive_transfer(apb_transfer t);

  // This method reset interface signals
  extern virtual protected task reset_listener();
 
  // This method that is responsible for sending an idle cycle to the DUT
  extern protected task do_idle();
  // This method that is to trigger write transaction
  extern protected task do_write(apb_transfer t);
  // This method that is to trigger read transaction
  extern protected task do_read(apb_transfer t);

endclass : apb_master_driver

`endif // APB_MASTER_DRIVER_SVH
