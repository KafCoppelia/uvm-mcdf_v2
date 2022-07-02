`ifndef _INTERFACE_PKG_SV
`define _INTERFACE_PKG_SV

interface interface_channel(input clk, input rstn);
    logic [31:0] ch_data;
    logic        ch_data_p;
    logic        ch_valid;
    logic        ch_wait;
    logic        ch_parity_err;
        
    clocking drv_ck @(posedge clk);
        default input #1ps output #1ps;
        output ch_data, ch_valid, ch_data_p;
        input ch_wait, ch_parity_err;
    endclocking
        
    clocking mon_ck @(posedge clk);
        default input #1ps output #1ps;
        input ch_data, ch_valid, ch_data_p, ch_wait, ch_parity_err;
    endclocking

endinterface

interface interface_formatter(input clk, input rstn);
    logic        fmt_ready;
    logic        fmt_valid;
    logic [31:0] fmt_data;
    logic        fmt_first;
    logic        fmt_last;
    
    clocking drv_ck @(posedge clk);
        default input #1ps output #1ps;
        input fmt_valid, fmt_data, fmt_first, fmt_last;
        output fmt_ready;
    endclocking
    
    clocking mon_ck @(posedge clk);
        default input #1ps output #1ps;
        input fmt_ready, fmt_valid, fmt_data, fmt_first, fmt_last;
    endclocking
endinterface   

interface interface_mcdf(input clk, input rstn);
    // To define those signals which do not exsit in
    // reg_if, chnl_if, fmt_if
    logic [3:0] chnl_en;
  
    clocking mon_ck @(posedge clk);
      default input #1ps output #1ps;
      input chnl_en;
    endclocking
endinterface

`endif


