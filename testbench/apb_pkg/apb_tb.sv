`timescale 1ps/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "apb_tests.svh"
`include "apb_interface.sv"
module apb_tb;
  bit clk, rstn;
  initial begin
    fork
      begin 
        forever #5ns clk = !clk;
      end
      begin
        #100ns;
        rstn <= 1'b1;
        #100ns;
        rstn <= 1'b0;
        #100ns;
        rstn <= 1'b1;
      end
    join_none
  end

  apb_interface intf(clk, rstn);

  initial begin
    uvm_config_db#(virtual apb_interface)::set(uvm_root::get(), "uvm_test_top.env.mst", "vif", intf);
    uvm_config_db#(virtual apb_interface)::set(uvm_root::get(), "uvm_test_top.env.slv", "vif", intf);
    run_test("apb_single_transaction_test");
  end

`ifdef DUMP_FSDB
    initial begin 
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars(0, apb_tb, "+all");
    end 
`endif 

endmodule
