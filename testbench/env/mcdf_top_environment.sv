`ifndef __MCDF_TOP_ENVIRONMENT_SV
`define __MCDF_TOP_ENVIRONMENT_SV

`include "channel_slave_node_package.sv"
`include "formatter_data_package.sv"
`include "reference_model_and_scoreboard.sv"

class mcdf_virtual_sequencer extends uvm_sequencer;
    apb_master_sequencer reg_sqr;
    formatter_sequencer fmt_sqr;
    channel_slave_node_sequencer chnl_sqrs[4];
    mcdf_regmodel rgm;
    virtual interface_mcdf mcdf_vif;

    `uvm_component_utils(mcdf_virtual_sequencer)

    function new (string name = "mcdf_virtual_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual interface_mcdf)::get(this,"","mcdf_vif", mcdf_vif)) begin
            `uvm_fatal("GETVIF","cannot get vif handle from config DB")
        end
        if(!uvm_config_db#(mcdf_regmodel)::get(this,"","rgm", rgm)) begin
            `uvm_fatal("GETRGM","cannot get RGM handle from config DB")
        end
    endfunction
endclass

class reg2mcdf_adapter extends uvm_reg_adapter;
    `uvm_object_utils(reg2mcdf_adapter)

    function new(string name = "reg2mcdf_adapter");
        super.new(name);
        provides_responses = 1;
    endfunction

    function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        apb_transfer t = apb_transfer::type_id::create("t");
        t.trans_kind = (rw.kind == UVM_WRITE) ? WRITE : READ;
        t.addr = rw.addr;
        t.data = rw.data;
        t.idle_cycles = 1;
        return t;
    endfunction
    
    function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        apb_transfer t;
        if (!$cast(t, bus_item)) begin
            `uvm_fatal("CASTFAIL","Provided bus_item is not of the correct type")
            return;
        end
        rw.kind = (t.trans_kind == WRITE) ? UVM_WRITE : UVM_READ;
        rw.addr = t.addr;
        rw.data = t.data;
        rw.status = t.trans_status == OK ? UVM_IS_OK : UVM_NOT_OK;
    endfunction
endclass

class mcdf_bus_analyzer extends uvm_component;
    parameter int unsigned MCDF_REG_ADDR_START = 'h0000 ;
    mcdf_regmodel rgm;
    realtime time_window;
    uvm_tlm_analysis_fifo #(apb_transfer) reg_tlm_fifo;
    uvm_tlm_analysis_fifo #(channel_data_monitor_transaction) chnl_tlm_fifos[4];
    uvm_tlm_analysis_fifo #(formatter_transaction) fmt_tlm_fifo;
    `uvm_component_utils(mcdf_bus_analyzer)
    function new (string name = "mcdf_bus_analyzer", uvm_component parent);
        super.new(name, parent);
        reg_tlm_fifo = new("reg_tlm_fifo", this);
        foreach(chnl_tlm_fifos[i]) chnl_tlm_fifos[i] = new($sformatf("chnl_tlm_fifos[%0d]", i), this);
        fmt_tlm_fifo = new("fmt_tlm_fifo", this);
        time_window = 1000ns;
    endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(mcdf_regmodel)::get(this,"","rgm", rgm)) begin
            `uvm_fatal("GETRGM","cannot get RGM handle from config DB")
        end
    endfunction
    task run_phase(uvm_phase phase);
        fork
            do_reg_analysis();
            do_data_analysis();
        join
    endtask
    // register access anlysis
    task do_reg_analysis();
        apb_transfer t;
        uvm_reg r;
        forever begin
            reg_tlm_fifo.get(t);
            r = rgm.map.get_reg_by_offset(t.addr - MCDF_REG_ADDR_START);
            `uvm_info("REGANA", $sformatf("%s REG %s with DATA 'h%8x",t.trans_kind, r.get_type_name(), t.data), UVM_LOW)
        end
    endtask
    // channle data input and formatter data output performance analysis
    task do_data_analysis();
        formatter_transaction t, tq[$];
        realtime delay;
        real bandwidth;
        forever begin
            #time_window;
            while(fmt_tlm_fifo.try_get(t)) begin
                calculate_delay(t, delay);
                tq.push_back(t);
            end
            calculate_bandwidth(tq, bandwidth);
        end
    endtask

    task calculate_delay(formatter_transaction ft, output realtime delay);
        channel_data_monitor_transaction ct;
        int ch_idx = this.rgm.get_chnl_index(ft.ch_id);
        forever begin
            chnl_tlm_fifos[ch_idx].get(ct);
            if(ct.data == ft.data[1]) begin
                delay = ft.start_time - ct.start_time;
                `uvm_info("DATAANA", $sformatf("New packet first data 'h%8x from CHNL[%0d] to FORMATTER delay is %.2f ns", ct.data, ct.id, (delay/1.0ns)), UVM_LOW)
                break;
            end
        end
    endtask

    task calculate_bandwidth(formatter_transaction tq[$], output real bandwidth);
        formatter_transaction t;
        int data_num = 0;
        foreach(tq[i]) begin
            data_num += tq[i].length + 3;
        end
        // bandwidth = bits_transferred/time(ns) = N(Gb)
        bandwidth = (data_num * 32) / (time_window/1.0ns);
        `uvm_info("DATAANA", $sformatf("From time %0t to %0t, MCDF formatter bandwidth is %.2f Gb", $time-time_window, $time, bandwidth), UVM_LOW)
    endtask
endclass

// MCDF top environment
class mcdf_env extends uvm_env;
    channel_slave_node_agent chnl_agts[4];
    apb_master_agent reg_agt;
    formatter_agent fmt_agt;
    mcdf_scoreboard scoreboard;
    mcdf_virtual_sequencer virt_sqr;
    mcdf_regmodel rgm;
    reg2mcdf_adapter adapter;
    mcdf_bus_analyzer analyzer;
    uvm_reg_predictor #(apb_transfer) predictor;

    local virtual interface_channel chnl_if[4];
    local virtual apb_interface  apb_if;
    local virtual interface_formatter fmt_if;
    local virtual interface_mcdf mcdf_if;

    `uvm_component_utils(mcdf_env)

    function new (string name = "mcdf_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        this.scoreboard = mcdf_scoreboard::type_id::create("scoreboard", this);
        foreach(chnl_agts[i]) begin
            this.chnl_agts[i] = channel_slave_node_agent::type_id::create($sformatf("chnl_agts[%0d]",i), this);
        end
        this.reg_agt = apb_master_agent::type_id::create("reg_agt", this);
        this.fmt_agt = formatter_agent::type_id::create("fmt_agt", this);
        virt_sqr = mcdf_virtual_sequencer::type_id::create("virt_sqr", this);
        rgm = mcdf_regmodel::type_id::create("rgm", this);
        rgm.build();
        uvm_config_db#(mcdf_regmodel)::set(this,"*","rgm", rgm);
        adapter = reg2mcdf_adapter::type_id::create("adapter", this);
        predictor = uvm_reg_predictor#(apb_transfer)::type_id::create("predictor", this);
        analyzer = mcdf_bus_analyzer::type_id::create("analyzer", this);

        foreach(chnl_agts[i]) begin
            if(!uvm_config_db#(virtual interface_channel)::get(this, "", $sformatf("ch%0d_vif",i), this.chnl_if[i])) begin
                `uvm_fatal(get_type_name(), "virtual interface must be set for vif!!!");
            end
            else begin
                uvm_config_db#(virtual interface_channel)::set(this, $sformatf("chnl_agts[%0d]",i), "ch_vif", this.chnl_if[i]);
                uvm_config_db#(virtual interface_channel)::set(this, "scoreboard", $sformatf("chnl_vifs[%0d]",i), this.chnl_if[i]);
            end
        end
        if(!uvm_config_db#(virtual apb_interface)::get(this, "", "apb_vif", this.apb_if)) begin
            `uvm_fatal(get_type_name(), "virtual interface must be set for vif!!!");
        end
        else begin
            uvm_config_db#(virtual apb_interface)::set(this, "reg_agt", "vif", this.apb_if);
        end
        if(!uvm_config_db#(virtual interface_formatter)::get(this, "", "fmt_vif", fmt_if)) begin
            `uvm_fatal(get_type_name(), "virtual interface must be set for vif!!!");
        end
        else begin
            uvm_config_db#(virtual interface_formatter)::set(this, "fmt_agt", "fmt_vif", this.fmt_if);
        end
        if(!uvm_config_db#(virtual interface_mcdf)::get(this, "", "mcdf_vif", this.mcdf_if)) begin
            `uvm_fatal(get_type_name(), "virtual interface must be set for vif!!!");
        end
        else begin
            uvm_config_db#(virtual interface_mcdf)::set(this, "scoreboard", "mcdf_vif", this.mcdf_if);
            uvm_config_db#(virtual interface_mcdf)::set(this, "virt_sqr", "mcdf_vif", this.mcdf_if);
        end

    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        foreach(chnl_agts[i]) begin
            chnl_agts[i].monitor.mon_aport.connect(scoreboard.chnl_tlm_fifos[i].analysis_export);
            chnl_agts[i].monitor.mon_aport.connect(analyzer.chnl_tlm_fifos[i].analysis_export);
        end
        reg_agt.monitor.item_collected_port.connect(analyzer.reg_tlm_fifo.analysis_export);
        fmt_agt.monitor.mon_aport.connect(scoreboard.fmt_tlm_fifo.analysis_export);
        fmt_agt.monitor.mon_aport.connect(analyzer.fmt_tlm_fifo.analysis_export);
        virt_sqr.reg_sqr = reg_agt.sequencer;
        virt_sqr.fmt_sqr = fmt_agt.sequencer;
        foreach(virt_sqr.chnl_sqrs[i]) virt_sqr.chnl_sqrs[i] = chnl_agts[i].sequencer;
        rgm.map.set_sequencer(reg_agt.sequencer, adapter);
        reg_agt.monitor.item_collected_port.connect(predictor.bus_in);
        predictor.map = rgm.map;
        predictor.adapter = adapter;
    endfunction
endclass: mcdf_env

`endif
