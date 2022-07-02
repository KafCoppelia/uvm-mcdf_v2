`ifndef __REFERENCE_MODEL_AND_SCOREBOARD_SV
`define __REFERENCE_MODEL_AND_SCOREBOARD_SV

`include "mcdf_register_model_package.sv"

/* MCDF reference model     */
class mcdf_refmodel extends uvm_component;
    mcdf_regmodel rgm;
    uvm_blocking_get_peek_port #(channel_data_monitor_transaction) in_bgpk_ports[4];
    uvm_tlm_analysis_fifo #(formatter_transaction) out_tlm_fifos[4];

    `uvm_component_utils(mcdf_refmodel) 
    function new (string name = "mcdf_refmodel", uvm_component parent);
        super.new(name, parent);
        foreach(in_bgpk_ports[i]) in_bgpk_ports[i] = new($sformatf("in_bgpk_ports[%0d]", i), this);
        foreach(out_tlm_fifos[i]) out_tlm_fifos[i] = new($sformatf("out_tlm_fifos[%0d]", i), this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(mcdf_regmodel)::get(this,"","rgm", rgm)) begin
            `uvm_fatal("GETRGM","cannot get RGM handle from config DB")
        end
    endfunction

    task run_phase(uvm_phase phase);
        fork
            do_packet(0);
            do_packet(1);
            do_packet(2);
            do_packet(3);
        join
    endtask

    task do_packet(int ch);
        formatter_transaction out_tr;
        channel_data_monitor_transaction in_tr;
        forever begin
            this.in_bgpk_ports[ch].peek(in_tr);
            out_tr = new();
            out_tr.length = rgm.get_reg_field_length(ch);
            out_tr.ch_id = rgm.get_reg_field_id(ch);
            out_tr.data = new[out_tr.length+3];
            foreach(out_tr.data[m]) begin
                if(m == 0) begin
                    out_tr.data[m] = (out_tr.ch_id<<24) + (out_tr.length<<16);
                    out_tr.parity = out_tr.data[m];
                end 
                else if(m == out_tr.data.size()-1) begin
                    out_tr.data[m] = out_tr.parity;
                end
                else begin
                    this.in_bgpk_ports[ch].get(in_tr);
                    out_tr.data[m] = in_tr.data;
                    out_tr.parity ^= in_tr.data;
                end
            end
            this.out_tlm_fifos[ch].put(out_tr);
        end
    endtask
endclass: mcdf_refmodel

/* MCDF  scoreboard     */
class mcdf_scoreboard extends uvm_scoreboard;
    local int err_count;
    local int total_count;
    local int chnl_count[4];
    local virtual interface_channel chnl_vifs[4]; 
    local virtual interface_mcdf mcdf_vif;
    local mcdf_refmodel refmod;
    mcdf_regmodel rgm;

    uvm_tlm_analysis_fifo #(channel_data_monitor_transaction) chnl_tlm_fifos[4];
    uvm_tlm_analysis_fifo #(formatter_transaction) fmt_tlm_fifo;

    uvm_blocking_get_port #(formatter_transaction) exp_bg_ports[4];

    `uvm_component_utils(mcdf_scoreboard)

    function new (string name = "mcdf_scoreboard", uvm_component parent);
        super.new(name, parent);
        this.err_count = 0;
        this.total_count = 0;
        foreach(this.chnl_count[i]) this.chnl_count[i] = 0;
        foreach(chnl_tlm_fifos[i]) chnl_tlm_fifos[i] = new($sformatf("chnl_tlm_fifos[%0d]", i), this);
        fmt_tlm_fifo = new("fmt_tlm_fifo", this);
        foreach(exp_bg_ports[i]) exp_bg_ports[i] = new($sformatf("exp_bg_ports[%0d]", i), this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // get virtual interface
        foreach(chnl_vifs[i]) begin
            if(!uvm_config_db#(virtual interface_channel)::get(this,"",$sformatf("chnl_vifs[%0d]",i), chnl_vifs[i])) begin
                `uvm_fatal("GETVIF","cannot get vif handle from config DB")
            end
        end
        if(!uvm_config_db#(virtual interface_mcdf)::get(this,"","mcdf_vif", mcdf_vif)) begin
            `uvm_fatal("GETVIF","cannot get vif handle from config DB")
        end
        if(!uvm_config_db#(mcdf_regmodel)::get(this,"","rgm", rgm)) begin
            `uvm_fatal("GETRGM","cannot get RGM handle from config DB")
        end
        this.refmod = mcdf_refmodel::type_id::create("refmod", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        foreach(refmod.in_bgpk_ports[i]) refmod.in_bgpk_ports[i].connect(chnl_tlm_fifos[i].blocking_get_peek_export);
        foreach(exp_bg_ports[i]) begin
            exp_bg_ports[i].connect(refmod.out_tlm_fifos[i].blocking_get_export);
        end
    endfunction

    task run_phase(uvm_phase phase);
        fork
            this.do_channel_disable_check(0);
            this.do_channel_disable_check(1);
            this.do_channel_disable_check(2);
            this.do_channel_disable_check(3);
            this.do_data_compare();
        join
    endtask

    task do_data_compare();
        formatter_transaction expt, mont;
        bit cmp;
        int ch_idx;
        forever begin
            this.fmt_tlm_fifo.get(mont);
            ch_idx = this.rgm.get_chnl_index(mont.ch_id);
            this.exp_bg_ports[ch_idx].get(expt);
            cmp = mont.compare(expt);   
            this.total_count++;
            this.chnl_count[ch_idx]++;
            if(cmp == 0) begin
                this.err_count++; #1ns;
                `uvm_info("[CMPERR]", $sformatf("monitored formatter data packet:\n %s", mont.sprint()), UVM_MEDIUM)
                `uvm_info("[CMPERR]", $sformatf("expected formatter data packet:\n %s", expt.sprint()), UVM_MEDIUM)
                `uvm_error("[CMPERR]", $sformatf("%0dth times comparing but failed! MCDF monitored output packet is different with reference model output", this.total_count))
            end
            else begin
                `uvm_info("[CMPSUC]",$sformatf("%0dth times comparing and succeeded! MCDF monitored output packet is the same with reference model output", this.total_count), UVM_LOW)
            end
        end
    endtask

    task do_channel_disable_check(int id);
        forever begin
            @(posedge this.mcdf_vif.clk iff (this.mcdf_vif.rstn && this.mcdf_vif.mon_ck.chnl_en[id]===0));
            if(this.chnl_vifs[id].mon_ck.ch_valid===1 && this.chnl_vifs[id].mon_ck.ch_wait===0)
                `uvm_error("[CHKERR]", "ERROR! when channel disabled, wait signal low when valid high") 
        end
    endtask

    function void report_phase(uvm_phase phase);
        string s;
        super.report_phase(phase);
        s = "\n---------------------------------------------------------------\n";
        s = {s, "CHECKER SUMMARY \n"}; 
        s = {s, $sformatf("total comparison count: %0d \n", this.total_count)}; 
        foreach(this.chnl_count[i]) s = {s, $sformatf(" channel[%0d] comparison count: %0d \n", i, this.chnl_count[i])};
        s = {s, $sformatf("total error count: %0d \n", this.err_count)}; 
        foreach(this.chnl_tlm_fifos[i]) begin
            if(this.chnl_tlm_fifos[i].size() != 0)
                s = {s, $sformatf("WARNING:: chnl_tlm_fifos[%0d] is not empty! size = %0d \n", i, this.chnl_tlm_fifos[i].size())}; 
        end
        if(this.fmt_tlm_fifo.size() != 0)
                s = {s, $sformatf("WARNING:: fmt_tlm_fifo is not empty! size = %0d \n", this.fmt_tlm_fifo.size())}; 
        s = {s, "---------------------------------------------------------------\n"};
        `uvm_info(get_type_name(), s, UVM_LOW)
    endfunction
endclass: mcdf_scoreboard

`endif
