
`ifndef APB_PKG_SV
`define APB_PKG_SV

package apb_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

parameter bit[31:0] DEFAULT_READ_VALUE = 32'hFFFF_FFFF;
`include "apb.svh"

endpackage : apb_pkg

   
`endif //  `ifndef APB_PKG_SV
