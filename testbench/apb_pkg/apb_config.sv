
`ifndef APB_CONFIG_SV
`define APB_CONFIG_SV

class apb_config extends uvm_object;

  // COMMON configuration parameter
  uvm_active_passive_enum  is_active = UVM_ACTIVE;

  // MASTER configuration parameter
  uvm_severity master_pslverr_status_severity = UVM_WARNING; // {UVM_WARNING, UVM_ERROR}

  // SLAVE configuration parameter
  rand bit slave_pready_random  = 1;
  rand bit slave_pslverr_random = 0;
  rand bit slave_pready_default_value = 0;

  `uvm_object_utils(apb_config)

  function new (string name = "apb_config");
    super.new(name);
  endfunction : new

  virtual function get_pready_additional_cycles();
    if(slave_pready_random)
      return $urandom_range(0, 2);
    else
      return 0;
  endfunction

  virtual function get_pslverr_status();
    if(slave_pslverr_random && $urandom_range(0, 20) == 0)
      return 1;
    else 
      return 0;
  endfunction


endclass

`endif // APB_CONFIG_SV
