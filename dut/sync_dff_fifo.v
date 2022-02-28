module sync_dff_fifo (
    clk_i        , 
    rst_n_i      , 
    
    data_i       ,             
    rd_i         ,             
    wr_i         ,              
    full_o       ,
    empty_o      ,
    overflow_o   ,
    data_o       ,            
    freeslot_o          
);     

    input                       clk_i        ; 
    input                       rst_n_i      ; 
    
    input  [31:0]               data_i       ;             
    input                       rd_i         ;             
    input                       wr_i         ;              
    output                      full_o       ;
    output                      empty_o      ;
    output                      overflow_o   ;
    
    output [31:0]               data_o       ;            
    output [ 5:0]               freeslot_o   ;       
//--------------------------------------------------------------------------------------------------------
parameter ADDR_W_C   = 5   ;
parameter DEPTH_C    = 32  ; 
//--------------------------------------------------------------------------------------------------------
reg  [ADDR_W_C-1 :0]      wr_p_r ;
reg  [ADDR_W_C-1 :0]      rd_p_r ;
reg  [31:0]               mem [DEPTH_C-1:0] ; 
reg  [ADDR_W_C   :0]      freeslot_r ;


wire full_s, empty_s; 
reg  overflow_r ;

//--------------------------------------------------------------------------------------------------------
// Freeline and empty/full logic
//--------------------------------------------------------------------------------------------------------

always @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin

         freeslot_r <= DEPTH_C;
         rd_p_r     <= 0;
         wr_p_r     <= 0;
         overflow_r <= 1'b0;
     end else begin
         if(rd_i) rd_p_r     <= rd_p_r    +1 ;
         if(wr_i) wr_p_r     <= wr_p_r    +1 ;
         //---------------------------------------
         // Only Read 
         //---------------------------------------
         if ( rd_i && ~wr_i ) begin
            freeslot_r <= freeslot_r+1 ; // cnt++ on only read
         end
         //---------------------------------------
         // Only Write
         //---------------------------------------
         if (~rd_i && wr_i ) begin
            if (~full_s) begin
                freeslot_r <= freeslot_r-1 ; // cnt-- on only write
            end else begin
                overflow_r <= 1'b1;
            end
         end
         //---------------------------------------
         // Data stored in Mem 
         //---------------------------------------
         if (wr_i) begin
             mem[wr_p_r] <= data_i ;
         end
     end
end

assign full_s  = freeslot_r ==       0 ? 1 : 0  ; 
assign empty_o = freeslot_r == DEPTH_C ? 1 : 0  ; 
assign full_o  = full_s ;
assign overflow_o = overflow_r;
assign data_o  = mem[rd_p_r];
assign freeslot_o = freeslot_r ;

endmodule 
