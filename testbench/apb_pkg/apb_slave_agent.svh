
`ifndef APB_SLAVE_AGENT_SVH
`define APB_SLAVE_AGENT_SVH

class apb_slave_agent extends uvm_agent;

  //////////////////////////////////////////////////////////////////////////////
  //
  //  Public interface (Component users may manipulate these fields/methods)
  //
  //////////////////////////////////////////////////////////////////////////////
  apb_config cfg;

  // The following are the verification components that make up
  // this agent
  apb_slave_driver driver;
  apb_slave_sequencer sequencer;
  apb_slave_monitor monitor;
  virtual apb_if vif;

  // USER: Add your fields here

  // This macro performs UVM object creation, type control manipulation, and 
  // factory registration
  `uvm_component_utils_begin(apb_slave_agent)
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


endclass : apb_slave_agent

`endif // APB_SLAVE_AGENT_SVH

