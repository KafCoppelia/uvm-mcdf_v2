`timescale 1ps/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "apb_tests.svh"
`include "apb_interface.sv"

module tb_top;

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

    apb_interface apb_if(clk, rstn);

    initial begin
        uvm_config_db#(virtual apb_interface)::set(uvm_root::get(), "uvm_test_top.env.mst", "vif", apb_if);
        uvm_config_db#(virtual apb_interface)::set(uvm_root::get(), "uvm_test_top.env.slv", "vif", apb_if);
        run_test("apb_single_transaction_test");
    end

`ifdef DUMP_FSDB
	initial begin 
		$fsdbDumpfile("tb.fsdb");
		$fsdbDumpvars(0, tb_top, "+all");
	end 
`endif 

endmodule
