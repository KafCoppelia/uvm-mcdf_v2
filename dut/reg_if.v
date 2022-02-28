`include "param_def.v"
module reg_if (
clk_i,
rst_n_i,

paddr_i,
pwr_i,
pen_i,
psel_i,
pwdata_i,

prdata_o,
pready_o,
pslverr_o, 

slv_en_o,  
err_clr_o,
slv0_id_o,
slv1_id_o,
slv2_id_o,
slv3_id_o,

slv0_len_o,
slv1_len_o,
slv2_len_o,
slv3_len_o,

slv0_parity_err_i,
slv1_parity_err_i,
slv2_parity_err_i,
slv3_parity_err_i,

slv0_free_slot_i,
slv1_free_slot_i,
slv2_free_slot_i,
slv3_free_slot_i

);                        

input              clk_i;
input              rst_n_i;

input  [7:0]       paddr_i;
input              pwr_i;
input              pen_i;
input              psel_i;
input  [31:0]      pwdata_i;

output [31:0]      prdata_o;
output             pready_o;
output             pslverr_o; 

output [3:0]       slv_en_o;  
output [3:0]       err_clr_o;
output [7:0]       slv0_id_o;
output [7:0]       slv1_id_o;
output [7:0]       slv2_id_o;
output [7:0]       slv3_id_o;

output [7:0]       slv0_len_o;
output [7:0]       slv1_len_o;
output [7:0]       slv2_len_o;
output [7:0]       slv3_len_o;

input              slv0_parity_err_i;
input              slv1_parity_err_i;
input              slv2_parity_err_i;
input              slv3_parity_err_i;

input  [5:0]       slv0_free_slot_i;
input  [5:0]       slv1_free_slot_i;
input  [5:0]       slv2_free_slot_i;
input  [5:0]       slv3_free_slot_i;



parameter [1:0]     st_IDLE  =2'b00 ;
parameter [1:0]     st_SETUP =2'b01 ;
parameter [1:0]     st_ACC   =2'b10 ;

reg [1:0] last_st, cur_st ;

reg     [31:0]      ctrl_mem [3:0]; 
reg     [31:0]      ro_mem   [3:0]; 

wire                is_st_idle_s, is_st_setup_s, is_st_acc_s; 
wire                is_addr_freeslot_3_s;
wire                is_addr_freeslot_2_s;
wire                is_addr_freeslot_1_s;
wire                is_addr_freeslot_0_s;
wire                is_addr_parity_err_3_s;
wire                is_addr_parity_err_2_s;
wire                is_addr_parity_err_1_s;
wire                is_addr_parity_err_0_s;
reg     [7:0]       addr_r;
reg     [31:0]      data_rd_r;

wire                is_ctrl_rng_s;
wire                is_ro_rng_s;
wire                is_err_rng_s;

wire                idx_0_s;
wire                idx_1_s;
wire                idx_2_s;
wire                idx_3_s;

wire                is_addr_slv_en_s;
wire                is_addr_err_clr_s;
wire                is_addr_slv_id_s;
wire                is_addr_slv_len_s;


//********************************************************************************************************
//     RTL Start...
//********************************************************************************************************


//--------------------------------------------------------------------------------------------------------
// State Passing
//--------------------------------------------------------------------------------------------------------
always @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) last_st <= st_IDLE   ;
    else          last_st <= cur_st    ;
end


//--------------------------------------------------------------------------------------------------------
// State Transition 
//--------------------------------------------------------------------------------------------------------
always @(*) begin
    case (last_st)
        st_IDLE    : if (psel_i) 
                         cur_st <= st_SETUP   ;
                     else 
                         cur_st <= st_IDLE;

        st_SETUP   : cur_st <= st_ACC  ;  // PSEL=1 at this phase and goto st_ACC unconditionally

        st_ACC     : 
                     if (psel_i && pen_i) begin
                         cur_st <= st_ACC ;
                     end else begin
                         cur_st <= st_IDLE;
                     end 
    endcase
end 

assign is_st_idle_s  = (cur_st == st_IDLE ) ? 1'b1 : 1'b0 ;
assign is_st_setup_s = (cur_st == st_SETUP) ? 1'b1 : 1'b0 ;
assign is_st_acc_s   = (cur_st == st_ACC  ) ? 1'b1 : 1'b0 ;


always @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        addr_r <= 0 ;

    end else begin
        if (is_st_setup_s)  begin
            addr_r <= paddr_i ;
        end 
    end
end 

always @(*) begin
  data_rd_r <= 0; 
  if (is_st_acc_s) begin
      if (~pwr_i) begin 
          if (is_addr_slv_en_s )  data_rd_r <= ctrl_mem [0];
          if (is_addr_err_clr_s)  data_rd_r <= ctrl_mem [1];
          if (is_addr_slv_id_s )  data_rd_r <= ctrl_mem [2];
          if (is_addr_slv_len_s)  data_rd_r <= ctrl_mem [3];
          //
          if (is_addr_freeslot_0_s)  data_rd_r <= ro_mem [0];
          if (is_addr_freeslot_1_s)  data_rd_r <= ro_mem [1];
          if (is_addr_freeslot_2_s)  data_rd_r <= ro_mem [2];
          if (is_addr_freeslot_3_s)  data_rd_r <= ro_mem [3];
          //
          if (is_addr_parity_err_0_s)  data_rd_r <= ro_mem [4];
          if (is_addr_parity_err_1_s)  data_rd_r <= ro_mem [5];
          if (is_addr_parity_err_2_s)  data_rd_r <= ro_mem [6];
          if (is_addr_parity_err_3_s)  data_rd_r <= ro_mem [7];
      end  
  end  
end

assign   prdata_o  = data_rd_r ;
assign   pslverr_o = is_st_acc_s && is_err_rng_s ; 
assign   pready_o  = is_st_acc_s ;


//--------------------------------------------------------------------------------------------------------
//Address decoder
//--------------------------------------------------------------------------------------------------------
assign is_ctrl_rng_s = ~|(addr_r[7:4]) ; //0h0*
assign is_ro_rng_s   =  addr_r[7] && !addr_r[6] && !addr_r[5] ; //0h8* or 0h9*
assign is_err_rng_s  =  ~(is_ctrl_rng_s | is_ro_rng_s);

assign idx_0_s       = (addr_r[3:2]==2'b00)? 1'b1 : 1'b0;
assign idx_1_s       = (addr_r[3:2]==2'b01)? 1'b1 : 1'b0;
assign idx_2_s       = (addr_r[3:2]==2'b10)? 1'b1 : 1'b0;
assign idx_3_s       = (addr_r[3:2]==2'b11)? 1'b1 : 1'b0;

assign is_addr_slv_en_s   = is_ctrl_rng_s & idx_0_s ;
assign is_addr_err_clr_s  = is_ctrl_rng_s & idx_1_s ;
assign is_addr_slv_id_s   = is_ctrl_rng_s & idx_2_s ;
assign is_addr_slv_len_s  = is_ctrl_rng_s & idx_3_s ;

assign is_addr_freeslot_0_s  = is_ro_rng_s && !addr_r[4] && idx_0_s ;
assign is_addr_freeslot_1_s  = is_ro_rng_s && !addr_r[4] && idx_1_s ;
assign is_addr_freeslot_2_s  = is_ro_rng_s && !addr_r[4] && idx_2_s ;
assign is_addr_freeslot_3_s  = is_ro_rng_s && !addr_r[4] && idx_3_s ;

assign is_addr_parity_err_0_s  = is_ro_rng_s && addr_r[4] && idx_0_s ;
assign is_addr_parity_err_1_s  = is_ro_rng_s && addr_r[4] && idx_1_s ;
assign is_addr_parity_err_2_s  = is_ro_rng_s && addr_r[4] && idx_2_s ;
assign is_addr_parity_err_3_s  = is_ro_rng_s && addr_r[4] && idx_3_s ;

//--------------------------------------------------------------------------------------------------------
// Ctrl Proc
always @ (posedge clk_i or negedge rst_n_i) //Trace fifo's margin
begin  : CONTROL_PROC
  if (!rst_n_i)
    begin
      ctrl_mem[0] <= 32'h00000000; // slv_en
      ctrl_mem[1] <= 32'h00000000; // parity_err_clr
      ctrl_mem[2] <= 32'h03020100; // slave ID
      ctrl_mem[3] <= 32'h00000000; // length
    end else begin
      if (is_st_acc_s & pwr_i) begin
          if (is_addr_slv_en_s ) ctrl_mem [0][3:0] <= pwdata_i ;
          if (is_addr_err_clr_s) ctrl_mem [1][3:0] <= pwdata_i ;
          if (is_addr_slv_id_s ) ctrl_mem [2]      <= pwdata_i ;
          if (is_addr_slv_len_s) ctrl_mem [3]      <= pwdata_i ;
      end 
    end
end

// RO_Proc
always @ (posedge clk_i or negedge rst_n_i) //Trace fifo's margin
begin  : RO_PROC
  if (!rst_n_i)
    begin
        ro_mem[0] <= 32'h00000000; // slv_free_slot
        ro_mem[1] <= 32'h00000000; // 
        ro_mem[2] <= 32'h00000000; // 
        ro_mem[3] <= 32'h00000000; // 
        ro_mem[4] <= 32'h00000000; // slv_parity_err
        ro_mem[5] <= 32'h00000000; // 
        ro_mem[6] <= 32'h00000000; // 
        ro_mem[7] <= 32'h00000000; // 
    end else begin
        ro_mem[0][5:0] <= slv0_free_slot_i; // slv_free_slot
        ro_mem[1][5:0] <= slv1_free_slot_i; // 
        ro_mem[2][5:0] <= slv2_free_slot_i; // 
        ro_mem[3][5:0] <= slv3_free_slot_i; // 

        ro_mem[4][0] <= slv0_parity_err_i; // slv_parity_err
        ro_mem[5][0] <= slv1_parity_err_i; // 
        ro_mem[6][0] <= slv2_parity_err_i; // 
        ro_mem[7][0] <= slv3_parity_err_i; // 

    end
end

// Ctrl Reg Output
assign slv_en_o   = ctrl_mem[0][3:0];  
assign err_clr_o  = ctrl_mem[1][3:0];
assign slv0_id_o  = ctrl_mem[2][1*8-1:  0];
assign slv1_id_o  = ctrl_mem[2][2*8-1:1*8];
assign slv2_id_o  = ctrl_mem[2][3*8-1:2*8];
assign slv3_id_o  = ctrl_mem[2][4*8-1:3*8];

assign slv0_len_o = ctrl_mem[3][1*8-1:  0];
assign slv1_len_o = ctrl_mem[3][2*8-1:1*8];
assign slv2_len_o = ctrl_mem[3][3*8-1:2*8];
assign slv3_len_o = ctrl_mem[3][4*8-1:3*8];


endmodule
