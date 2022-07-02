`ifndef __CHANNEL_DATA_WRITE_BASIC_CONFIG_TEST_SV
`define __CHANNEL_DATA_WRITE_BASIC_CONFIG_TEST_SV

`include "mcdf_base_test.sv"
`include "channel_data_write_basic_config_sequence.sv"

class channel_data_write_basic_config_test extends mcdf_base_test;
    channel_data_write_basic_config_sequence top_seq;

    `uvm_component_utils(channel_data_write_basic_config_test)

    function new(string name = "channel_data_write_basic_config_test", uvm_component parent);
      super.new(name, parent);
    endfunction

    task main_phase(uvm_phase phase);
        // NOTE:: raise objection to prevent simulation stopping
        phase.raise_objection(this);

        top_seq = new("top_seq");
        this.top_seq.start(env.virt_sqr);

        // NOTE:: drop objection to request simulation stopping
        phase.drop_objection(this);
    endtask

endclass: channel_data_write_basic_config_test

`endif
