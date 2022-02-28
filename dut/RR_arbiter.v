module RR_arbiter(
    clk_i,
    rst_n_i,
    req_vec_i,
    win_vec_o,
    trigger_i   
);
    input                    clk_i;
    input                    rst_n_i;

    //Request
    input  [3:0]             req_vec_i;
    
    //Winner
    output [3:0]             win_vec_o;
    
    input                    trigger_i   ; // trigger a aound of calculation
//--------------------------------------------------------------------------------------------------------
reg  [3:0] cp_vec_r ; // current priority pointer. e.g. 0100: 1 stand for position of highest priority. 

wire [3:0] filter_L_s, filter_R_s, req_msb1_L_s, req_msb1_R_s, req_FL_L_s, req_FL_R_s, req_R_s, req_L_s;
wire [3:0] win_L_s   , win_R_s    ;
reg  [3:0] win_vec_s;
reg  [3:0] win_vec_r;
wire       req_all0_L_s, req_all0_R_s ;

//--------------------------------------------------------------------------------------------------------
// Generate filter L/R from cp_vec_r
// e.g. cp_vec_r : 0100
//      r_filter : 0111 
//                      r3: c3
//                      r2: c3 | c2
//                      r1: c3 | c2 | c1
//                      r0: c3 | c2 | c1 | c0
//      l_filter : 1000 (not r_filter)
//--------------------------------------------------------------------------------------------------------
assign filter_L_s[3] = cp_vec_r[3];
assign filter_L_s[2] = cp_vec_r[3] || cp_vec_r[2] ;
assign filter_L_s[1] = cp_vec_r[3] || cp_vec_r[2] || cp_vec_r[1] ;
assign filter_L_s[0] = cp_vec_r[3] || cp_vec_r[2] || cp_vec_r[1] || cp_vec_r[0];

assign filter_R_s    = ~ filter_L_s ;

//--------------------------------------------------------------------------------------------------------
// generate L/R parts with filter
// e.g. req      = 001100
//      cp       = 000100
//      filter_L = 111000 
//      filter_R = 000111
//      req_L    = 001000 
//      req_R    = 000100 
//--------------------------------------------------------------------------------------------------------
assign req_L_s = req_vec_i & filter_R_s ;
assign req_R_s = req_vec_i & filter_L_s ;

//--------------------------------------------------------------------------------------------------------
// fill 1s into req lower part (right is lower)
// e.g. req      = 001100
//      cp       = 000100
//      filter_L = 111000 
//      filter_R = 000111
//      req_L    = 001000 
//      req_R    = 000100 
//      req_FL_L = 001111 
//      req_FL_R = 000111 
//--------------------------------------------------------------------------------------------------------
assign req_FL_L_s[3] = req_L_s[3];
assign req_FL_L_s[2] = req_L_s[3] || req_L_s[2] ;
assign req_FL_L_s[1] = req_L_s[3] || req_L_s[2] || req_L_s[1] ;
assign req_FL_L_s[0] = req_L_s[3] || req_L_s[2] || req_L_s[1] || req_L_s[0]  ;

assign req_FL_R_s[3] = req_R_s[3];
assign req_FL_R_s[2] = req_R_s[3] || req_R_s[2] ;
assign req_FL_R_s[1] = req_R_s[3] || req_R_s[2] || req_R_s[1] ;
assign req_FL_R_s[0] = req_R_s[3] || req_R_s[2] || req_R_s[1] || req_R_s[0]  ;

//--------------------------------------------------------------------------------------------------------
// Find the bit 1 from the Left most
// e.g. req          = 001100
//      cp           = 000100
//      filter_L     = 111000 
//      filter_R     = 000111
//      req_L        = 001000 
//      req_R        = 000100 
//      req_FL_L     = 001111 
//      req_FL_R     = 000111 
//      req_MSB1_L   = 001000
//      req_MSB1_R   = 000100
//--------------------------------------------------------------------------------------------------------
assign req_msb1_L_s[3] = req_FL_L_s[3] ;
assign req_msb1_L_s[2] =   req_msb1_L_s[3]                                  ? 1'b0 : req_FL_L_s[2] ;
assign req_msb1_L_s[1] = |{req_msb1_L_s[3],req_msb1_L_s[2]}                 ? 1'b0 : req_FL_L_s[1] ;
assign req_msb1_L_s[0] = |{req_msb1_L_s[3],req_msb1_L_s[2],req_msb1_L_s[1]} ? 1'b0 : req_FL_L_s[0] ;

assign req_msb1_R_s[3] = req_FL_R_s[3] ;
assign req_msb1_R_s[2] =   req_msb1_R_s[3]                                 ? 1'b0 : req_FL_R_s[2] ;
assign req_msb1_R_s[1] = |{req_msb1_R_s[3],req_msb1_R_s[2]                }? 1'b0 : req_FL_R_s[1] ;
assign req_msb1_R_s[0] = |{req_msb1_R_s[3],req_msb1_R_s[2],req_msb1_R_s[1]}? 1'b0 : req_FL_R_s[0] ;

//assign req_msb1_L_s[3] = req_FL_L_s[3] ;
//assign req_msb1_L_s[2] = req_FL_L_s[3] ^ req_FL_L_s[2] ;
//assign req_msb1_L_s[1] = req_FL_L_s[3] ^ req_FL_L_s[2] ^ req_FL_L_s[1] ;
//assign req_msb1_L_s[0] = req_FL_L_s[3] ^ req_FL_L_s[2] ^ req_FL_L_s[1] ^ req_FL_L_s[0] ;
//
//assign req_msb1_R_s[3] = req_FL_R_s[3] ;
//assign req_msb1_R_s[2] = req_FL_R_s[3] ^ req_FL_R_s[2] ;
//assign req_msb1_R_s[1] = req_FL_R_s[3] ^ req_FL_R_s[2] ^ req_FL_R_s[1] ;
//assign req_msb1_R_s[0] = req_FL_R_s[3] ^ req_FL_R_s[2] ^ req_FL_R_s[1] ^ req_FL_R_s[0] ;

//--------------------------------------------------------------------------------------------------------
// select final result.
// priority left is higher than right
// mask winner in right if left is not all 0.
//--------------------------------------------------------------------------------------------------------
assign req_all0_L_s = ~(|req_msb1_L_s) ;
assign req_all0_R_s = ~(|req_msb1_R_s) ;

always @(req_all0_L_s or req_all0_R_s or req_msb1_R_s or req_msb1_L_s)
begin
    //win_vec_s <= req_msb1_R_s;
    case ({req_all0_L_s, req_all0_R_s})
        2'b11: win_vec_s <= 4'b0000      ; // NO 1, select nothing 
        2'b10: win_vec_s <= req_msb1_R_s ; // all0 in left , then select Right side
        2'b01: win_vec_s <= req_msb1_L_s ; // all0 in right, then select Left  side 
        2'b00: win_vec_s <= req_msb1_R_s ; // both sides have 1, select Right side 
    endcase
end

assign win_vec_o = win_vec_r;
//--------------------------------------------------------------------------------------------------------
// current priority logic
// reset value is "1000"
// loop and right shift for every round
//--------------------------------------------------------------------------------------------------------
always @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        cp_vec_r  <= 4'b1000;
        win_vec_r <= 4'b0000;
    end else begin
        if (trigger_i) begin
            // cp_vec_r[0] <= cp_vec_r[1];
            // cp_vec_r[1] <= cp_vec_r[2];
            // cp_vec_r[2] <= cp_vec_r[3];
            // cp_vec_r[3] <= cp_vec_r[0]; // loop back

            // cp_vec_r  <= win_vec_s;

            cp_vec_r[0] <= win_vec_s[1];
            cp_vec_r[1] <= win_vec_s[2];
            cp_vec_r[2] <= win_vec_s[3];
            cp_vec_r[3] <= win_vec_s[0]; // loop back
            //
            win_vec_r <= win_vec_s;
        end

    end 
end 


endmodule
