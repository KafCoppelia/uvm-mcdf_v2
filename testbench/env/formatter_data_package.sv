`ifndef __FORMATTER_DATA_PACKAGE_SV
`define __FORMATTER_DATA_PACKAGE_SV

typedef enum {SHORT_FIFO, MED_FIFO, LONG_FIFO, ULTRA_FIFO} fmt_fifo_t;
typedef enum {LOW_WIDTH, MED_WIDTH, HIGH_WIDTH, ULTRA_WIDTH} fmt_bandwidth_t;

/* formatter sequence item  */
class formatter_transaction extends uvm_sequence_item;
    rand fmt_fifo_t fifo;
    rand fmt_bandwidth_t bandwidth;
    bit [7:0] length;
    bit [31:0] data[];
    bit [7:0] ch_id;
    bit [31:0] parity;
    bit rsp;
    realtime start_time;

    constraint cstr{
            soft fifo == MED_FIFO;
            soft bandwidth == MED_WIDTH;
    };

    `uvm_object_utils_begin(formatter_transaction)
        `uvm_field_enum(fmt_fifo_t, fifo, UVM_ALL_ON)
        `uvm_field_enum(fmt_bandwidth_t, bandwidth, UVM_ALL_ON)
        `uvm_field_int(length, UVM_ALL_ON)
        `uvm_field_array_int(data, UVM_ALL_ON)
        `uvm_field_int(ch_id, UVM_ALL_ON)
        `uvm_field_int(rsp, UVM_ALL_ON)
    `uvm_object_utils_end

    function new (string name = "formatter_transaction");
        super.new(name);
    endfunction
endclass

/* formatter driver */
class formatter_driver extends uvm_driver #(formatter_transaction);
    local virtual interface_formatter vif;

    local mailbox #(bit[31:0]) fifo;
    local int fifo_bound;
    local int data_consum_peroid;

    `uvm_component_utils(formatter_driver)

    function new (string name = "formatter_driver", uvm_component parent);
        super.new(name, parent);
        this.fifo = new();
        this.fifo_bound = 4096;
        this.data_consum_peroid = 1;
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual interface_formatter)::get(this, "", "vif", this.vif))
            `uvm_fatal(get_type_name(), "virtual interface must be set for vif!!!");
    endfunction

    task run_phase(uvm_phase phase);
        fork
            this.do_receive();
            this.do_consume();
            this.do_config();
            this.do_reset();
        join
    endtask

    task do_config();
        formatter_transaction req, rsp;
        forever begin
            seq_item_port.get_next_item(req);
            case(req.fifo)
                SHORT_FIFO: this.fifo_bound = 64;
                MED_FIFO: this.fifo_bound = 256;
                LONG_FIFO: this.fifo_bound = 512;
                ULTRA_FIFO: this.fifo_bound = 2048;
            endcase
            this.fifo = new(this.fifo_bound);
            case(req.bandwidth)
                LOW_WIDTH: this.data_consum_peroid = 8;
                MED_WIDTH: this.data_consum_peroid = 4;
                HIGH_WIDTH: this.data_consum_peroid = 2;
                ULTRA_WIDTH: this.data_consum_peroid = 1;
            endcase
            void'($cast(rsp, req.clone()));
            rsp.rsp = 1;
            rsp.set_sequence_id(req.get_sequence_id());
            seq_item_port.item_done(rsp);
        end
    endtask

    task do_reset();
        forever begin
            @(negedge vif.rstn) 
            vif.fmt_ready <= 0;
        end
    endtask

    task do_receive();
        forever begin
            @(vif.drv_ck); #10ps;
            if(vif.fmt_valid === 1'b1) begin
                forever begin
                    if((this.fifo_bound-this.fifo.num()) >= 1)
                        break;
                    @(vif.drv_ck); #10ps;
                end
                this.fifo.put(vif.fmt_data);
                #1ps; vif.fmt_ready <= 1;
            end
            else begin
                #1ps; vif.fmt_ready <= 0;
            end
        end
    endtask

    task do_consume();
        bit[31:0] data;
        forever begin
            void'(this.fifo.try_get(data));
            repeat($urandom_range(1, this.data_consum_peroid)) @(posedge vif.clk);
        end
    endtask
endclass: formatter_driver

class formatter_sequencer extends uvm_sequencer #(formatter_transaction);
    `uvm_component_utils(formatter_sequencer)
    function new (string name = "formatter_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction
endclass: formatter_sequencer

/* formatter monitor    */
class formatter_monitor extends uvm_monitor;
    local string name;
    local virtual interface_formatter vif;
    uvm_analysis_port #(formatter_transaction) mon_aport;

    `uvm_component_utils(formatter_monitor)

    function new(string name="formatter_monitor", uvm_component parent);
        super.new(name, parent);
        mon_aport = new("mon_aport", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual interface_formatter)::get(this, "", "vif", this.vif))
            `uvm_fatal(get_type_name(), "virtual interface must be set for vif!!!");
    endfunction

    task run_phase(uvm_phase phase);
        formatter_transaction mtr;
        string s;
        forever begin
            @(vif.mon_ck iff vif.mon_ck.fmt_first && vif.mon_ck.fmt_valid && vif.mon_ck.fmt_ready);
            mtr = new();
            mtr.length = vif.mon_ck.fmt_data[23:16];
            mtr.ch_id = vif.mon_ck.fmt_data[31:24];
            mtr.data = new[mtr.length + 3];
            foreach(mtr.data[i]) begin
                mtr.data[i] = vif.mon_ck.fmt_data;
                if(i == 1) mtr.start_time = $realtime();
                if(i == mtr.data.size()-1) mtr.parity = mtr.data[i];
                if(i < mtr.data.size()-1) @(vif.mon_ck iff vif.mon_ck.fmt_valid && vif.mon_ck.fmt_ready);
            end
            mon_aport.write(mtr);
            s = $sformatf("=======================================\n");
            s = {s, $sformatf("%0t %s monitored a packet: \n", $time, this.m_name)};
            s = {s, $sformatf("length = %0d: \n", mtr.length)};
            s = {s, $sformatf("chid = %0d: \n", mtr.ch_id)};
            foreach(mtr.data[i]) s = {s, $sformatf("data[%0d] = %8x \n", i, mtr.data[i])};
            s = {s, $sformatf("=======================================\n")};
            `uvm_info(get_type_name(), s, UVM_HIGH)
        end
    endtask

endclass: formatter_monitor

/* formatter agent      */
class formatter_agent extends uvm_agent;
    formatter_driver driver;
    formatter_monitor monitor;
    formatter_sequencer sequencer;
    local virtual interface_formatter vif;

    `uvm_component_utils(formatter_agent)

    function new(string name = "formatter_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // get virtual interface
        if(!uvm_config_db#(virtual interface_formatter)::get(this,"","fmt_vif", vif)) begin
            `uvm_fatal("GETVIF","cannot get vif handle from config DB")
        end
        driver      = formatter_driver::type_id::create("driver", this);
        monitor     = formatter_monitor::type_id::create("monitor", this);
        sequencer   = formatter_sequencer::type_id::create("sequencer", this);

        uvm_config_db#(virtual interface_formatter)::set(this, "driver", "vif", this.vif);
        uvm_config_db#(virtual interface_formatter)::set(this, "monitor", "vif", this.vif);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
endclass

/* formatter config sequence  */
class formatter_config_sequence extends uvm_sequence #(formatter_transaction);
    rand fmt_fifo_t fifo = MED_FIFO;
    rand fmt_bandwidth_t bandwidth = MED_WIDTH;
    constraint cstr{
        soft fifo == MED_FIFO;
        soft bandwidth == MED_WIDTH;
    }

    `uvm_object_utils_begin(formatter_config_sequence)
        `uvm_field_enum(fmt_fifo_t, fifo, UVM_ALL_ON)
        `uvm_field_enum(fmt_bandwidth_t, bandwidth, UVM_ALL_ON)
    `uvm_object_utils_end
    `uvm_declare_p_sequencer(formatter_sequencer)

    function new (string name = "formatter_config_sequence");
        super.new(name);
    endfunction

    task body();
        formatter_transaction req, rsp;
        `uvm_do_with(req, {local::fifo != MED_FIFO -> fifo == local::fifo; 
                                             local::bandwidth != MED_WIDTH -> bandwidth == local::bandwidth;
                                            })
        `uvm_info(get_type_name(), req.sprint(), UVM_HIGH)
        get_response(rsp);
        `uvm_info(get_type_name(), rsp.sprint(), UVM_HIGH)
        assert(rsp.rsp)
            else $error("[RSPERR] %0t error response received!", $time);
    endtask

    function void post_randomize();
        string s;
        s = {s, "After randomization \n"};
        s = {s, "formatter_config_sequence object content is as below: \n"};
        s = {s, super.sprint()};
        `uvm_info(get_type_name(), s, UVM_LOW)
    endfunction
endclass: formatter_config_sequence

`endif
