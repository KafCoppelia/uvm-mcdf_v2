`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "apb_pkg.sv"
import apb_pkg::*;

`include "interface_pkg.sv"
`include "apb_interface.sv"

`include "channel_data_write_basic_config_test.sv"

module tb_top;

    logic         clk;
    logic         rstn;

    interface_channel chnl0_if(.*);
    interface_channel chnl1_if(.*);
    interface_channel chnl2_if(.*);
    interface_channel chnl3_if(.*);
    apb_interface  apb_if(.*);
    interface_formatter fmt_if(.*);
    interface_mcdf mcdf_if(.*);
  
    mcdf dut(
        .clk_i               (clk                     ) ,
        .rst_n_i             (rstn                    ) ,
        .slv0_data_i         (chnl0_if.ch_data        ) , // 
        .slv0_data_p_i       (chnl0_if.ch_data_p      ) , // one bit parity of data_i
        .slv0_valid_i        (chnl0_if.ch_valid       ) , // 
        .slv0_wait_o         (chnl0_if.ch_wait        ) , //
        .slv0_parity_err_o   (chnl0_if.ch_parity_err  ) , //
        .slv1_data_i         (chnl1_if.ch_data        ) , // 
        .slv1_data_p_i       (chnl1_if.ch_data_p      ) , // one bit parity of data_i
        .slv1_valid_i        (chnl1_if.ch_valid       ) , // 
        .slv1_wait_o         (chnl1_if.ch_wait        ) , //
        .slv1_parity_err_o   (chnl1_if.ch_parity_err  ) , //
        .slv2_data_i         (chnl2_if.ch_data        ) , // 
        .slv2_data_p_i       (chnl2_if.ch_data_p      ) , // one bit parity of data_i
        .slv2_valid_i        (chnl2_if.ch_valid       ) , // 
        .slv2_wait_o         (chnl2_if.ch_wait        ) , //
        .slv2_parity_err_o   (chnl2_if.ch_parity_err  ) , //
        .slv3_data_i         (chnl3_if.ch_data        ) , // 
        .slv3_data_p_i       (chnl3_if.ch_data_p      ) , // one bit parity of data_i
        .slv3_valid_i        (chnl3_if.ch_valid       ) , // 
        .slv3_wait_o         (chnl3_if.ch_wait        ) , //
        .slv3_parity_err_o   (chnl3_if.ch_parity_err  ) , //
        .paddr_i             (apb_if.paddr[7:0]       ) ,
        .pwr_i               (apb_if.pwrite           ) ,
        .pen_i               (apb_if.penable          ) ,
        .psel_i              (apb_if.psel             ) ,
        .pwdata_i            (apb_if.pwdata           ) ,
        .prdata_o            (apb_if.prdata           ) ,
        .pready_o            (apb_if.pready           ) ,
        .pslverr_o           (apb_if.pslverr          ) , 
        .rev_rdy_i           (fmt_if.fmt_ready        ) , // receiver rdy
        .pkg_vld_o           (fmt_if.fmt_valid        ) , // data is valid
        .pkg_dat_o           (fmt_if.fmt_data         ) , // data/payload
        .pkg_fst_o           (fmt_if.fmt_first        ) , // header indicator
        .pkg_lst_o           (fmt_if.fmt_last         )   // parirty data
    );

    initial begin
        // set the format for time display
        $timeformat(-9, 2, "ns", 10); 
        // do interface configuration from tb_top (HW) to verification env (SW)     
        uvm_config_db#(virtual interface_channel)::set(uvm_root::get(),     "uvm_test_top.env", "ch0_vif",  chnl0_if);
        uvm_config_db#(virtual interface_channel)::set(uvm_root::get(),     "uvm_test_top.env", "ch1_vif",  chnl1_if);
        uvm_config_db#(virtual interface_channel)::set(uvm_root::get(),     "uvm_test_top.env", "ch2_vif",  chnl2_if);
        uvm_config_db#(virtual interface_channel)::set(uvm_root::get(),     "uvm_test_top.env", "ch3_vif",  chnl3_if);
        uvm_config_db#(virtual apb_interface)::set(uvm_root::get(),         "uvm_test_top.env", "apb_vif",  apb_if);
        uvm_config_db#(virtual interface_formatter)::set(uvm_root::get(),   "uvm_test_top.env", "fmt_vif",  fmt_if);
        uvm_config_db#(virtual interface_mcdf)::set(uvm_root::get(),        "uvm_test_top.env", "mcdf_vif", mcdf_if);      
        // uvm_config_db#(virtual interface_arbiter)::set(uvm_root::get(),     "uvm_test_top.env", "arb_vif",  arb_if);
        // start run the test
        run_test();
    end

	// clock generation
    initial begin 
        clk <= 1'b0;
        forever begin
            #5 clk <= !clk;
        end
    end
      
    // reset trigger
    initial begin 
        #10 rstn <= 1'b0;
        repeat(10) @(posedge clk);
        rstn <= 1'b1;
    end


    initial begin 
        string testname;
        if($value$plusargs("TESTNAME=%s", testname)) begin
            $fsdbDumpfile({testname, "_sim_dir/", testname, ".fsdb"});
        end else begin
            $fsdbDumpfile("tb.fsdb");
        end
        $fsdbDumpvars(0, tb_top);
    end

endmodule
