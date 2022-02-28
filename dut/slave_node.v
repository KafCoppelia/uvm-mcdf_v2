module slave_node (
    clk_i          , // 
    rst_n_i        , // 
    
    
    // From uplink
    data_i         , // 
    data_p_i       , // one bit parity of data_i
    valid_i        , // 
    slv_en_i       , // 
    wait_o         , //
    parity_err_o   , //
    
    
    // To downlink
    data_o         , // 
    freeslot_o     , // 
    valid_o        , // 
    fetch_i        ,

    
    // From Reg
    parity_err_clr_i       

);     
    input                                clk_i          ; // 
    input                                rst_n_i        ; // 
    
    // IO with driver
    input  [31:0]                        data_i         ; // 
    input                                data_p_i       ; // 
    input                                valid_i        ; // 
    input                                slv_en_i       ; // 
    output                               wait_o         ; //
    output                               parity_err_o   ; //
    
    // IO with Arbiter
    output  [31:0]                       data_o         ; // 
    output  [ 5:0]                       freeslot_o     ; // 
    output                               valid_o        ; // 
    output                               fetch_i        ;

    // IO with register
    input                                parity_err_clr_i      ;

reg             parity_err_r ;

wire            parity_err_s, wait_s, fifo_full_s, fifo_wr_s, fifo_rd_s, fifo_empty_s; 
//--------------------------------------------------------------------------------------------------------
// Parity Stick Bit
//--------------------------------------------------------------------------------------------------------
assign parity_err_s = valid_i && ^{data_i,data_p_i}  ;

always @ (posedge clk_i or negedge rst_n_i)
begin : Parity_Err
    if (!rst_n_i) begin
       parity_err_r <= 1'b0;
    end else begin
       // parity error flag
       if (parity_err_s    ) parity_err_r <= 1'b1 ; 
       if (parity_err_clr_i) parity_err_r <= 1'b0 ;
    end 
end

assign parity_err_o = parity_err_r;

//--------------------------------------------------------------------------------------------------------
assign wait_s       = fifo_full_s || parity_err_r ; //wait until fifo is not full and parity_err is dispear
assign fifo_wr_s    = valid_i && !parity_err_r  && !wait_s && slv_en_i ;
assign fifo_rd_s    = fetch_i && !fifo_empty_s;

//--------------------------------------------------------------------------------------------------------
// wait is asserted on condition
// a. fifo_full
// b. parity error
assign wait_o = !slv_en_i || fifo_full_s || parity_err_r ;

//--------------------------------------------------------------------------------------------------------
sync_dff_fifo inst_fifo  (
    .clk_i(clk_i             ),
    .rst_n_i(rst_n_i         ),
    .data_i(data_i           ),
    .rd_i(fifo_rd_s          ),
    .wr_i(fifo_wr_s          ),
    .full_o(fifo_full_s      ),
    .empty_o(fifo_empty_s    ),
    .data_o(data_o           ),
    .freeslot_o(freeslot_o   )
);     

assign valid_o = !fifo_empty_s;

endmodule 
