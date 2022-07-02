`ifndef __CHANNEL_DATA_WRITE_BASIC_CONFIG_SEQUENCE_SV
`define __CHANNEL_DATA_WRITE_BASIC_CONFIG_SEQUENCE_SV

class channel_data_write_basic_config_sequence extends uvm_sequence;
    channel_data_sequence chnl_data_seq;
    formatter_config_sequence fmt_config_seq;
    mcdf_regmodel rgm;

    `uvm_object_utils(channel_data_write_basic_config_sequence)
    `uvm_declare_p_sequencer(mcdf_virtual_sequencer)

    function new (string name = "channel_data_write_basic_config_sequence");
        super.new(name);
    endfunction

    virtual task body();
      `uvm_info(get_type_name(), "\n=====================Started=====================", UVM_LOW)
      rgm = p_sequencer.rgm;

      this.do_reg();
      this.do_formatter();
      this.do_data();

      `uvm_info(get_type_name(), "\n=====================Finished=====================", UVM_LOW)
    endtask


    task do_reg();
        bit[31:0] wr_val, rd_val;
        uvm_status_e status;
        //reset the register block
        @(negedge p_sequencer.mcdf_vif.rstn);
        rgm.reset();
        @(posedge p_sequencer.mcdf_vif.rstn);
        this.wait_cycles(10);
        // slv3 with len=64, en=1
        // slv2 with len=32, en=1
        // slv1 with len=16, en=1
        // slv0 with len=8,  en=1
        wr_val = ('b1<<3) + ('b1<<2) + ('b1<<1) + 1;
        rgm.slv_en.write(status, wr_val);
        rgm.slv_en.read(status, rd_val);
        // void'(this.diff_value(wr_val, rd_val, "SLV_EN_REG"));
        wr_val = (63<<24) + (31<<16) + (15<<8) + 7;
        rgm.slv_len.write(status, wr_val);
        rgm.slv_len.read(status, rd_val);
        // void'(this.diff_value(wr_val, rd_val, "SLV_LEN_REG"));
    endtask
    task do_formatter();
        `uvm_do_on_with(fmt_config_seq, p_sequencer.fmt_sqr, {fifo == LONG_FIFO; bandwidth == HIGH_WIDTH;})
    endtask
    task do_data();
        fork
            `uvm_do_on_with(chnl_data_seq, p_sequencer.chnl_sqrs[0], {ntrans==20; ch_id==0; data_nidles==0; pkt_nidles==1; data_size==64;})
            `uvm_do_on_with(chnl_data_seq, p_sequencer.chnl_sqrs[1], {ntrans==20; ch_id==1; data_nidles==1; pkt_nidles==4; data_size==64;})
            `uvm_do_on_with(chnl_data_seq, p_sequencer.chnl_sqrs[2], {ntrans==20; ch_id==2; data_nidles==2; pkt_nidles==8; data_size==64;})
            `uvm_do_on_with(chnl_data_seq, p_sequencer.chnl_sqrs[3], {ntrans==20; ch_id==3; data_nidles==1; pkt_nidles==2; data_size==64;})
        join
        #10us; // wait until all data haven been transfered through MCDF
    endtask
    task wait_cycles(int n);
        repeat(n) @(posedge p_sequencer.mcdf_vif.clk);
    endtask

endclass: channel_data_write_basic_config_sequence

`endif

