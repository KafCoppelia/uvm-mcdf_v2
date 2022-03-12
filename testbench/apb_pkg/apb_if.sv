
`ifndef APB_IF_SV
`define APB_IF_SV

interface apb_if (input clk, input rstn);

  logic [31:0] paddr;
  logic        pwrite;
  logic        psel;
  logic        penable;
  logic [31:0] pwdata;
  logic [31:0] prdata;

  // Control flags
  bit                has_checks = 1;
  bit                has_coverage = 1;

  // Actual Signals 
  // USER: Add interface signals

  clocking cb_mst @(posedge clk);
    // USER: Add clocking block detail
    default input #1ps output #1ps;
    output paddr, pwrite, psel, penable, pwdata;
    input prdata;
  endclocking : cb_mst

  clocking cb_slv @(posedge clk);
   // USER: Add clocking block detail
    default input #1ps output #1ps;
    input paddr, pwrite, psel, penable, pwdata;
    output prdata;
  endclocking : cb_slv

  clocking cb_mon @(posedge clk);
   // USER: Add clocking block detail
    default input #1ps output #1ps;
    input paddr, pwrite, psel, penable, pwdata, prdata;
  endclocking : cb_mon

  // Coverage and assertions to be implemented here.
  // USER: Add assertions/coverage here

  // APB command covergroup
  covergroup cg_apb_command @(posedge clk iff rstn);
    pwrite: coverpoint pwrite{
      type_option.weight = 0;
      bins write = {1};
      bins read  = {0};

    }
    psel : coverpoint psel{
      type_option.weight = 0;
      bins sel   = {1};
      bins unsel = {0};
    }
    cmd  : cross pwrite, psel{
      bins cmd_write = binsof(psel.sel) && binsof(pwrite.write);
      bins cmd_read  = binsof(psel.sel) && binsof(pwrite.read);
      bins cmd_idle  = binsof(psel.unsel);
    }
  endgroup

  // APB transaction timing group
  covergroup cg_apb_trans_timing_group @(posedge clk iff rstn);
    psel: coverpoint psel{
      bins single   = (0 => 1 => 1  => 0); 
      bins burst_2  = (0 => 1 [*4]  => 0); 
      bins burst_4  = (0 => 1 [*8]  => 0); 
      bins burst_8  = (0 => 1 [*16] => 0); 
      bins burst_16 = (0 => 1 [*32] => 0); 
      bins burst_32 = (0 => 1 [*64] => 0); 
    }
    penable: coverpoint penable {
      bins single = (0 => 1 => 0 [*2:10] => 1);
      bins burst  = (0 => 1 => 0         => 1);
    }
  endgroup

  // APB write & read order group
  covergroup cg_apb_write_read_order_group @(posedge clk iff (rstn && penable));
    write_read_order: coverpoint pwrite{
      bins write_write = (1 => 1);
      bins write_read  = (1 => 0);
      bins read_write  = (0 => 1);
      bins read_read   = (0 => 0);
    } 
  endgroup

  initial begin
    automatic cg_apb_command cg0 = new();
    automatic cg_apb_trans_timing_group cg1 = new();
    automatic cg_apb_write_read_order_group cg2 = new();
  end

endinterface : apb_if

`endif // APB_IF_SV
