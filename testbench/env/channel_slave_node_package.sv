`ifndef __CHANNEL_SLAVE_NODE_PACKAGE_SV
`define __CHANNEL_SLAVE_NODE_PACKAGE_SV

/* channel slave node sequence item    */
class channel_slave_node_transaction extends uvm_sequence_item;
    rand bit[31:0] data[];
    rand int ch_id;
    rand int pkt_id;
    rand int data_nidles;
    rand int pkt_nidles;
    bit rsp;

    constraint cstr{
        soft data.size inside {[4:32]};
        foreach(data[i]) soft data[i] == 'hC000_0000 + (this.ch_id<<24) + (this.pkt_id<<8) + i;
        soft ch_id == 0;
        soft pkt_id == 0;
        soft data_nidles inside {[0:2]};
        soft pkt_nidles inside {[1:10]};
    };
  
    `uvm_object_utils_begin(channel_slave_node_transaction)
        `uvm_field_array_int(data, UVM_NORECORD)
        `uvm_field_int(ch_id, UVM_ALL_ON)
        `uvm_field_int(pkt_id, UVM_ALL_ON)
        `uvm_field_int(data_nidles, UVM_NORECORD)
        `uvm_field_int(pkt_nidles, UVM_NORECORD)
        `uvm_field_int(rsp, UVM_ALL_ON)
    `uvm_object_utils_end
  
    function new (string name = "channel_slave_node_transaction");
        super.new(name);
    endfunction
    
    function void do_record(uvm_recorder recorder);
        super.do_record(recorder);
        `uvm_record_attribute(recorder.tr_handle, "data_size", data.size());
    endfunction
endclass: channel_slave_node_transaction

/* channel data monitor sequence item */
class channel_data_monitor_transaction extends uvm_sequence_item;
    bit[31:0] data;
    bit[1:0] id;

    realtime start_time;
    `uvm_object_utils(channel_data_monitor_transaction)
    function new (string name = "channel_data_monitor_transaction");
        super.new(name);
    endfunction
endclass: channel_data_monitor_transaction

/* channel slave node driver    */
class channel_slave_node_driver extends uvm_driver #(channel_slave_node_transaction);
    local virtual interface_channel vif;

    `uvm_component_utils(channel_slave_node_driver)

    function new (string name = "channel_slave_node_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual interface_channel)::get(this, "", "vif", this.vif))
            `uvm_fatal(get_type_name(), "virtual interface must be set for vif!!!");
    endfunction

    virtual task run_phase(uvm_phase phase);
        fork
            this.do_drive();
            this.do_reset();
        join
    endtask

    task do_reset();
        forever begin
            @(negedge vif.rstn);
            vif.ch_valid <= 0;
            vif.ch_data <= 0;
            vif.ch_data_p <= 0;
        end
    endtask
  
    task do_drive();
        channel_slave_node_transaction req, rsp;
        @(posedge vif.rstn);
        forever begin
            seq_item_port.get_next_item(req);
            this.channl_data_write(req);
            void'($cast(rsp, req.clone()));
            rsp.rsp = 1;
            rsp.set_sequence_id(req.get_sequence_id());
            seq_item_port.item_done(rsp);
        end
    endtask
    
    task channl_data_write(input channel_slave_node_transaction tr);
        foreach(tr.data[i]) begin
            @(posedge vif.clk);
            vif.drv_ck.ch_valid <= 1;
            vif.drv_ck.ch_data <= tr.data[i];
            vif.drv_ck.ch_data_p <= get_data_parity(tr.data[i]);
            @(negedge vif.clk);
            wait(vif.ch_wait === 'b0);
            `uvm_info(get_type_name(), $sformatf("sent data 'h%8x", tr.data[i]), UVM_HIGH)
            repeat(tr.data_nidles) channel_idle();
        end
        repeat(tr.pkt_nidles) channel_idle();
    endtask
      
    task channel_idle();
        @(posedge vif.clk);
        vif.drv_ck.ch_valid <= 0;
        vif.drv_ck.ch_data <= 0;
        vif.drv_ck.ch_data_p <= 0;
    endtask
  
    function get_data_parity(bit[31:0] data);
        return ^data;
    endfunction
endclass: channel_slave_node_driver

/* channel slave node sequencer     */
class channel_slave_node_sequencer extends uvm_sequencer #(channel_slave_node_transaction);
    `uvm_component_utils(channel_slave_node_sequencer)
      function new (string name = "channel_slave_node_sequencer", uvm_component parent);
        super.new(name, parent);
      endfunction
endclass: channel_slave_node_sequencer

/* channel slave node monitor  */
class channel_slave_node_monitor extends uvm_monitor;
    local virtual interface_channel vif;
    uvm_analysis_port #(channel_data_monitor_transaction) mon_aport;
  
    `uvm_component_utils(channel_slave_node_monitor)
  
    function new(string name="channel_slave_node_monitor", uvm_component parent);
        super.new(name, parent);
        mon_aport = new("mon_aport", this);
    endfunction
  
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual interface_channel)::get(this, "", "vif", this.vif))
            `uvm_fatal(get_type_name(), "virtual interface must be set for vif!!!");
    endfunction
  
    task run_phase(uvm_phase phase);
        this.mon_trans();
    endtask
  
    task mon_trans();
        channel_data_monitor_transaction mtr;
        forever begin
            @(vif.mon_ck iff (vif.mon_ck.ch_valid==='b1 && vif.mon_ck.ch_wait==='b0));
            mtr = channel_data_monitor_transaction::type_id::create("mtr");
            mtr.data = vif.mon_ck.ch_data;
            mtr.start_time = $realtime();
            mon_aport.write(mtr);
            `uvm_info(get_type_name(), $sformatf("monitored channel data 'h%8x", mtr.data), UVM_HIGH)
        end
    endtask
endclass: channel_slave_node_monitor
  
/* channel slave node agent */
class channel_slave_node_agent extends uvm_agent;
    channel_slave_node_driver driver;
    channel_slave_node_monitor monitor;
    channel_slave_node_sequencer sequencer;
    local virtual interface_channel vif;

    `uvm_component_utils(channel_slave_node_agent)

    function new(string name = "channel_slave_node_agent", uvm_component parent);
        super.new(name, parent);
    endfunction
  
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // get virtual interface
        if(!uvm_config_db#(virtual interface_channel)::get(this,"","ch_vif", vif)) begin
            `uvm_fatal("GETVIF","cannot get vif handle from config DB")
        end
        driver      = channel_slave_node_driver::type_id::create("driver", this);
        monitor     = channel_slave_node_monitor::type_id::create("monitor", this);
        sequencer   = channel_slave_node_sequencer::type_id::create("sequencer", this);

        uvm_config_db#(virtual interface_channel)::set(this, "driver", "vif", this.vif);
        uvm_config_db#(virtual interface_channel)::set(this, "monitor", "vif", this.vif);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass: channel_slave_node_agent

class channel_data_sequence extends uvm_sequence #(channel_slave_node_transaction);
    rand int pkt_id = 0;
    rand int ch_id = -1;
    rand int data_nidles = -1;
    rand int pkt_nidles = -1;
    rand int data_size = -1;
    rand int ntrans = 10;
    rand int data[];

    constraint cstr{
        soft pkt_id == 0;
        soft ch_id == -1;
        soft data_nidles == -1;
        soft pkt_nidles == -1;
        soft data_size == -1;
        soft ntrans == 10;
        soft data.size() == data_size;
        foreach(data[i]) soft data[i] == -1;
    };

    `uvm_object_utils_begin(channel_data_sequence)
        `uvm_field_int(pkt_id, UVM_ALL_ON)
        `uvm_field_int(ch_id, UVM_ALL_ON)
        `uvm_field_int(data_nidles, UVM_ALL_ON)
        `uvm_field_int(pkt_nidles, UVM_ALL_ON)
        `uvm_field_int(data_size, UVM_ALL_ON)
        `uvm_field_int(ntrans, UVM_ALL_ON)
    `uvm_object_utils_end
    
    `uvm_declare_p_sequencer(channel_slave_node_sequencer)
    
    function new (string name = "channel_data_sequence");
        super.new(name);
      endfunction
  
    virtual task body();
        repeat(ntrans) begin
            channel_slave_node_transaction req, rsp;
            `uvm_do_with(req, {local::ch_id >= 0 -> ch_id == local::ch_id; 
                                local::pkt_id >= 0 -> pkt_id == local::pkt_id;
                                local::data_nidles >= 0 -> data_nidles == local::data_nidles;
                                local::pkt_nidles >= 0 -> pkt_nidles == local::pkt_nidles;
                                local::data_size >0 -> data.size() == local::data_size; 
                                foreach(local::data[i]) local::data[i] >= 0 -> data[i] == local::data[i];
                                })
            this.pkt_id++;
            `uvm_info(get_type_name(), req.sprint(), UVM_HIGH)
            get_response(rsp);
            `uvm_info(get_type_name(), rsp.sprint(), UVM_HIGH)
            assert(rsp.rsp)
                else $error("[RSPERR] %0t error response received!", $time);
        end 
    endtask
  
    function void post_randomize();
        string s;
        s = {s, $sformatf("\nAfter randomization, channel_data_sequence body will run %0d transaction.\n", ntrans)};
        s = {s, "channel_data_sequence object content is as below: \n"};
        s = {s, super.sprint()};
        `uvm_info(get_type_name(), s, UVM_LOW)
    endfunction
endclass: channel_data_sequence

`endif
  