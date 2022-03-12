
`ifndef APB_CONFIG_SV
`define APB_CONFIG_SV

class apb_config extends uvm_object;

  `uvm_object_utils(apb_config)

  // USER to specify the config items
  uvm_active_passive_enum  is_active = UVM_ACTIVE;
  
  function new (string name = "apb_config");
    super.new(name);
  endfunction : new


endclass

`endif // APB_CONFIG_SV
