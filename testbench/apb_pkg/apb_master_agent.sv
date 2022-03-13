
`ifndef APB_MASTER_AGENT_SV
`define APB_MASTER_AGENT_SV

function apb_master_agent::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


function void apb_master_agent::build();
  super.build();
  // get config
  if( !uvm_config_db#(apb_config)::get(this,"","cfg", cfg)) begin
    `uvm_warning("GETCFG","cannot get config object from config DB")
     cfg = apb_config::type_id::create("cfg");
  end
  // get virtual interface
  if( !uvm_config_db#(virtual apb_if)::get(this,"","vif", vif)) begin
    `uvm_fatal("GETVIF","cannot get vif handle from config DB")
  end
  monitor = apb_master_monitor::type_id::create("monitor",this);
  monitor.cfg = cfg;
  if(cfg.is_active == UVM_ACTIVE) begin
    sequencer = apb_master_sequencer::type_id::create("sequencer",this);
    sequencer.cfg = cfg;
    driver = apb_master_driver::type_id::create("driver",this);
    driver.cfg = cfg;
  end
endfunction : build

function void apb_master_agent::connect();
  assign_vi(vif);

  if(is_active == UVM_ACTIVE) begin
    driver.seq_item_port.connect(sequencer.seq_item_export);       
  end

endfunction : connect
  
function void apb_master_agent::assign_vi(virtual apb_if vif);
   monitor.vif = vif;
   if (is_active == UVM_ACTIVE) begin
      sequencer.vif = vif; 
      driver.vif = vif; 
    end
endfunction : assign_vi



`endif // APB_MASTER_AGENT_SV

