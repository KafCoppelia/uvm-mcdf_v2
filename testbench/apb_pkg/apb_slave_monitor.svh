
`ifndef APB_SLAVE_MONITOR_SVH
`define APB_SLAVE_MONITOR_SVH

class apb_slave_monitor extends uvm_monitor;

  //////////////////////////////////////////////////////////////////////////////
  //
  //  Public interface (Component users may manipulate these fields/methods)
  //
  //////////////////////////////////////////////////////////////////////////////
  apb_config cfg;

  // This field controls if this monitor has its checkers enabled
  // (by default checkers are on)
  bit checks_enable = 1;

  // This field controls if this monitor has its coverage enabled
  // (by default coverage is on)
  bit coverage_enable = 1;

  // This property is the virtual interfaced needed for this component to drive
  // and view HDL signals. 
  virtual apb_if vif;
  // USER: Add your fields here

  // The following is the analysis port that allows this monitor's transaction
  // information to be sent to other verification componets such as
  // scoreboards
  uvm_analysis_port #(apb_transfer) item_collected_port;

  // This macro performs UVM object creation, type control manipulation, and 
  // factory registration
  `uvm_component_utils_begin(apb_slave_monitor)
     `uvm_field_int(checks_enable, UVM_ALL_ON)
     `uvm_field_int(coverage_enable, UVM_ALL_ON)
     // USER: Register fields here
  `uvm_component_utils_end

  // new - constructor     
  extern function new(string name, uvm_component parent=null);

  // uvm build phase
  extern function void build();

  // uvm run phase
  extern virtual task run();

  // Events needed to trigger covergroups
  event apb_slave_cov_transaction;

  // Transfer collected covergroup
  covergroup apb_slave_cov_trans @apb_slave_cov_transaction;
    // USER implemented coverpoints
  endgroup : apb_slave_cov_trans

  //////////////////////////////////////////////////////////////////////////////
  //
  //  Implementation (private) interface
  //
  //////////////////////////////////////////////////////////////////////////////

  //This is the transaction being collected by this monitor	
  protected apb_transfer trans_collected;

  // This method is responsible for collecting transactions, checking,
  // and updating coverage 
  extern virtual protected task monitor_transactions();

  // This is the methods that collects transactions
  extern virtual protected task collect_transfer();

  // This is the method that performs checks on a transaction
  extern protected function void perform_transfer_checks();

  // This is the method that updates coverage based on a transaction
  extern protected function void perform_transfer_coverage();

endclass : apb_slave_monitor

`endif // APB_SLAVE_MONITOR_SVH

