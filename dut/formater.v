module formater(
    input                      clk_i,
    input                      rst_n_i,
                          
    // IO with slavenode
    input     [31:0]           data_slv0_i,
    input     [31:0]           data_slv1_i,
    input     [31:0]           data_slv2_i,
    input     [31:0]           data_slv3_i,

    input     [7:0]            id_slv0_i,
    input     [7:0]            id_slv1_i,
    input     [7:0]            id_slv2_i,
    input     [7:0]            id_slv3_i,

    input     [7:0]            len_slv0_i,
    input     [7:0]            len_slv1_i,
    input     [7:0]            len_slv2_i,
    input     [7:0]            len_slv3_i,

    input     [3:0]            req_vec_i ,
    output    [3:0]            fetch_vec_o,

    // IO with RR arbiter
    input     [3:0]            win_vec_i, // valid and win (one hot or all zero)
    output                     trigger_start_o,

    // IO with outside (package receiver)
    input                      rev_rdy_i, // receiver rdy
    output                     pkg_vld_o, // data is valid
    output   [31:0]            pkg_dat_o, // data/payload
    output                     pkg_fst_o, // header indicator
    output                     pkg_lst_o  // parirty data
);

parameter [2:0] ST_RST     = 3'b000;
parameter [2:0] ST_Run_RR  = 3'b001;
parameter [2:0] ST_Header  = 3'b010;  
parameter [2:0] ST_Payload = 3'b011;
parameter [2:0] ST_Parity  = 3'b100;

reg [2:0] cur_st, nxt_st; 

wire [31:0] data_slv0_win_s ;
wire [31:0] data_slv1_win_s ;
wire [31:0] data_slv2_win_s ;
wire [31:0] data_slv3_win_s ;
wire [31:0] data_win_s      ;

wire [7:0] id_slv0_win_s   ;
wire [7:0] id_slv1_win_s   ;
wire [7:0] id_slv2_win_s   ;
wire [7:0] id_slv3_win_s   ;
wire [7:0] id_win_s        ;

wire [7:0] len_slv0_win_s  ;
wire [7:0] len_slv1_win_s  ;
wire [7:0] len_slv2_win_s  ;
wire [7:0] len_slv3_win_s  ;
wire [7:0] len_win_s       ;
//

wire is_st_run_rr_s     ;
wire is_st_header_s     ;
wire is_st_payload_s    ;
wire is_st_parity_s     ;

wire send_header_s      ;
wire send_payload_s     ;
wire send_parity_s      ;
wire pkg_lst_s          ;
wire [3:0] win_req_vec_s      ;
wire win_req_s          ;
wire any_win_s          ;
wire any_req_s          ;
wire pkg_vld_s          ;  
reg  [31:0] tx_d_s      ;
reg  [31:0] parity_r    ;
reg  [7:0]  len_cnt_r   ;
wire [3:0]  fetch_vec_s ;
//========================================================================================================
// RTL Start ...
//========================================================================================================

assign win_req_vec_s = win_vec_i & req_vec_i ;
assign win_req_s     = |win_req_vec_s ;
assign any_win_s     = |win_vec_i ;
assign any_req_s     = |req_vec_i ;


//--------------------------------------------------------------------------------------------------------
// State Passing
//--------------------------------------------------------------------------------------------------------
always @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) cur_st <= ST_RST    ; 
    else          cur_st <= nxt_st    ;

end 

//--------------------------------------------------------------------------------------------------------
// State Transition 
//--------------------------------------------------------------------------------------------------------
// ST_Run_RR : wait for valid and trigger RR arbiter
// ST_Header : Send Header when receiver is ready 
// St_Payload: Send the length size of PL when receiver is ready 
// ST_parity : Send the parity as the last word
always @(*) begin
    nxt_st <= cur_st;
    case (cur_st)
        ST_RST     : if (                          any_req_s) nxt_st <= ST_Run_RR   ;
        ST_Run_RR  : if (                          any_req_s) nxt_st <= ST_Header   ; 
        ST_Header  : if (             rev_rdy_i && any_req_s) nxt_st <= ST_Payload  ; 
        ST_Payload : if (pkg_lst_s && rev_rdy_i && win_req_s) nxt_st <= ST_Parity   ; 
        ST_Parity  : if (             rev_rdy_i             ) nxt_st <= ST_Run_RR   ;
    endcase
end 


//--------------------------------------------------------------------------------------------------------
// Action in State
//--------------------------------------------------------------------------------------------------------
//Select winner for data/id/len
assign data_slv0_win_s = win_vec_i[0] ? data_slv0_i: 0 ;
assign data_slv1_win_s = win_vec_i[1] ? data_slv1_i: 0 ;
assign data_slv2_win_s = win_vec_i[2] ? data_slv2_i: 0 ;
assign data_slv3_win_s = win_vec_i[3] ? data_slv3_i: 0 ;
assign data_win_s      = data_slv0_win_s | data_slv1_win_s | data_slv2_win_s | data_slv3_win_s ; 

assign id_slv0_win_s   = win_vec_i[0] ? id_slv0_i  : 0 ;
assign id_slv1_win_s   = win_vec_i[1] ? id_slv1_i  : 0 ;
assign id_slv2_win_s   = win_vec_i[2] ? id_slv2_i  : 0 ;
assign id_slv3_win_s   = win_vec_i[3] ? id_slv3_i  : 0 ;
assign id_win_s        = id_slv0_win_s | id_slv1_win_s | id_slv2_win_s | id_slv3_win_s  ; 

assign len_slv0_win_s  = win_vec_i[0] ? len_slv0_i : 0 ;
assign len_slv1_win_s  = win_vec_i[1] ? len_slv1_i : 0 ;
assign len_slv2_win_s  = win_vec_i[2] ? len_slv2_i : 0 ;
assign len_slv3_win_s  = win_vec_i[3] ? len_slv3_i : 0 ;
assign len_win_s       = len_slv0_win_s | len_slv1_win_s | len_slv2_win_s | len_slv3_win_s ;

assign is_st_run_rr_s     = (cur_st==ST_Run_RR )? 1'b1 : 1'b0 ; 
assign is_st_header_s     = (cur_st==ST_Header )? 1'b1 : 1'b0 ; 
assign is_st_payload_s    = (cur_st==ST_Payload)? 1'b1 : 1'b0 ; 
assign is_st_parity_s     = (cur_st==ST_Parity )? 1'b1 : 1'b0 ; 

assign send_header_s      = is_st_header_s   && rev_rdy_i ;
assign send_payload_s     = is_st_payload_s  && rev_rdy_i && win_req_s ; 
assign send_parity_s      = is_st_parity_s   && rev_rdy_i ;
//assign trigger_start_o    = send_header_s ;
assign trigger_start_o    = is_st_run_rr_s ;
assign pkg_lst_s          = ~|(len_cnt_r)    ;// last pacage data is on condition of (len counter = 0)

//--------------------------------------------------------------------------------------------------------
// Package Composition
//--------------------------------------------------------------------------------------------------------
always @(*)
begin
    tx_d_s   <= 0;
    // Header <= ID + LEN
    if (is_st_header_s) begin
        tx_d_s   <= {id_win_s, len_win_s,16'h0000};
    end 
    // Payload
    if (is_st_payload_s) begin
        tx_d_s   <= data_win_s ;
    end 
    // Parity
    if (is_st_parity_s) begin
        tx_d_s   <= parity_r;
    end

end


//--------------------------------------------------------------------------------------------------------
//Parity Gen
//--------------------------------------------------------------------------------------------------------
always @(posedge clk_i or negedge rst_n_i)
begin
    if (~rst_n_i) begin
        parity_r <= 0 ;
        len_cnt_r <= 0 ;
    end else begin
        // Load the 1st data in buffer
        if (send_header_s) begin
            parity_r  <= {id_win_s, len_win_s,16'h0000};
            len_cnt_r <= len_win_s ;
        end 

        // XOR payload
        if (send_payload_s) begin
            parity_r <= data_win_s ^ parity_r ; 
            len_cnt_r<= len_cnt_r - 1;
        end 

        //
        if (send_parity_s) begin
            parity_r  <= 0 ;
            len_cnt_r <= 0 ;
        end 
    end 
end 

// fetch asserted when 
// 1. downlink's recieve_ready is asserted &
// 2. selected fifo data is valid
assign fetch_vec_s = {4{rev_rdy_i && is_st_payload_s }} & win_vec_i ;
assign fetch_vec_o = fetch_vec_s ;

//--------------------------------------------------------------------------------------------------------
assign pkg_dat_o = tx_d_s ;
assign pkg_fst_o = send_header_s  ;
assign pkg_lst_o = send_parity_s  ;
//---------------------------------------
// pkg_vld_o asserted when
// a. header phase
// b. send payload phase and payload is valid
// c. parity phase
assign pkg_vld_s = is_st_header_s || (is_st_payload_s && win_req_s) || is_st_parity_s ; 
assign pkg_vld_o = pkg_vld_s ;


endmodule 
 
