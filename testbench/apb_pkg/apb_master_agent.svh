
`ifndef APB_MASTER_AGENT_SVH
`define APB_MASTER_AGENT_SVH

class apb_master_agent extends uvm_agent;

  //////////////////////////////////////////////////////////////////////////////
  //
  //  Public interface (Component users may manipulate these fields/methods)
  //
  //////////////////////////////////////////////////////////////////////////////
  apb_config cfg;

  // The following are the verification components that make up
  // this agent
  apb_master_driver driver;
  apb_master_sequencer sequencer;
  apb_master_monitor monitor;
  virtual apb_if vif;

  // USER: Add your fields here

  // This macro performs UVM object creation, type control manipulation, and 
  // factory registration
  `uvm_component_utils_begin(apb_master_agent)
    // USER: Register your fields here
  `uvm_component_utils_end

  // new - constructor
  extern function new (string name, uvm_component parent);

  // uvm build phase
  extern function void build();

  // uvm connection phase
  extern function void connect();
  
  // This method assigns the virtual interfaces to the agent's children
  extern function void assign_vi(virtual apb_if vif);

  //////////////////////////////////////////////////////////////////////////////
  //
  //  Implementation (private) interface
  //
  //////////////////////////////////////////////////////////////////////////////


endclass : apb_master_agent

`endif // APB_MASTER_AGENT_SVH

