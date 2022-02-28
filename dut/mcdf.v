module mcdf(
	input        clk_i              ,
	input        rst_n_i            ,

	// From Driver
	input  [31:0]    slv0_data_i         , // 
	input            slv0_data_p_i       , // one bit parity of data_i
	input            slv0_valid_i        , // 
	output           slv0_wait_o         , //
	output           slv0_parity_err_o   , //

	input  [31:0]    slv1_data_i         , // 
	input            slv1_data_p_i       , // one bit parity of data_i
	input            slv1_valid_i        , // 
	output           slv1_wait_o         , //
	output           slv1_parity_err_o   , //
		
	input  [31:0]    slv2_data_i         , // 
	input            slv2_data_p_i       , // one bit parity of data_i
	input            slv2_valid_i        , // 
	output           slv2_wait_o         , //
	output           slv2_parity_err_o   , //
		
	input  [31:0]    slv3_data_i         , // 
	input            slv3_data_p_i       , // one bit parity of data_i
	input            slv3_valid_i        , // 
	output           slv3_wait_o         , //
	output           slv3_parity_err_o   , //
		
	// APB IF
	input  [7:0]     paddr_i        ,
	input            pwr_i          ,
	input            pen_i          ,
	input            psel_i         ,
	input  [31:0]    pwdata_i       ,

	output [31:0]    prdata_o       ,
	output           pready_o       ,
	output           pslverr_o      , 

	// IO with outside (package receiver)
	input            rev_rdy_i      , // receiver rdy
	output           pkg_vld_o      , // data is valid
	output [31:0]    pkg_dat_o      , // data/payload
	output           pkg_fst_o      , // header indicator
	output           pkg_lst_o        // parirty data
	);

	wire    [31:0] slv0_data_s,slv1_data_s, slv2_data_s, slv3_data_s ;
	wire    [5 :0] slv0_freeslot_s, slv1_freeslot_s, slv2_freeslot_s, slv3_freeslot_s;
	wire    [7 :0] slv0_id_s,slv1_id_s,slv2_id_s,slv3_id_s ;
	wire    [7 :0] slv0_len_s,slv1_len_s,slv2_len_s,slv3_len_s ;

	wire    [3 :0] err_clr_vec_s, fetch_vec_s, req_vec_s,  slv_en_vec_s, win_vec_s; 
	wire           trigger_s,slv3_fetch_s ,slv2_fetch_s ,slv1_fetch_s ,slv0_fetch_s  ;

	//---------------------------------------
	// APB IF
	//---------------------------------------
	reg_if  inst_reg_if (
		.clk_i               (clk_i                      ),
		.rst_n_i             (rst_n_i                    ),
		.paddr_i             (paddr_i                    ),
		.pwr_i               (pwr_i                      ),
		.pen_i               (pen_i                      ),
		.psel_i              (psel_i                     ),
		.pwdata_i            (pwdata_i                   ),
		.prdata_o            (prdata_o                   ),
		.pready_o            (pready_o                   ),
		.pslverr_o           (pslverr_o                  ), 
		.slv_en_o            (slv_en_vec_s               ),  
		.err_clr_o           (err_clr_vec_s              ),
		.slv0_id_o           (slv0_id_s                  ),
		.slv1_id_o           (slv1_id_s                  ),
		.slv2_id_o           (slv2_id_s                  ),
		.slv3_id_o           (slv3_id_s                  ),
		.slv0_len_o          (slv0_len_s                 ),
		.slv1_len_o          (slv1_len_s                 ),
		.slv2_len_o          (slv2_len_s                 ),
		.slv3_len_o          (slv3_len_s                 ),
		.slv0_parity_err_i   (slv0_parity_err_s          ),
		.slv1_parity_err_i   (slv1_parity_err_s          ),
		.slv2_parity_err_i   (slv2_parity_err_s          ),
		.slv3_parity_err_i   (slv3_parity_err_s          ),
		.slv0_free_slot_i    (slv0_freeslot_s            ),
		.slv1_free_slot_i    (slv1_freeslot_s            ),
		.slv2_free_slot_i    (slv2_freeslot_s            ),
		.slv3_free_slot_i    (slv3_freeslot_s            )
	);                        


	//---------------------------------------
	// SLV NODE #0
	//---------------------------------------
	slave_node inst_slave_node_0 (
		.clk_i               (clk_i                      ),
		.rst_n_i             (rst_n_i                    ),
		.data_i              (slv0_data_i                ),
		.data_p_i            (slv0_data_p_i              ),
		.valid_i             (slv0_valid_i               ),
		.slv_en_i            (slv_en_vec_s[0]            ),
		.wait_o              (slv0_wait_o                ),
		.parity_err_o        (slv0_parity_err_s          ),
		.data_o              (slv0_data_s                ),
		.freeslot_o          (slv0_freeslot_s            ),
		.valid_o             (slv0_valid_o_s             ),
		.fetch_i             (slv0_fetch_s               ),
		.parity_err_clr_i    (err_clr_vec_s[0]           )       
	);     
	assign  slv0_parity_err_o = slv0_parity_err_s;

	//---------------------------------------
	// SLV NODE #1
	//---------------------------------------
	slave_node inst_slave_node_1 (
		.clk_i               (clk_i                      ),
		.rst_n_i             (rst_n_i                    ),
		.data_i              (slv1_data_i                ),
		.data_p_i            (slv1_data_p_i              ),
		.valid_i             (slv1_valid_i               ),
		.slv_en_i            (slv_en_vec_s[1]            ),
		.wait_o              (slv1_wait_o                ),
		.parity_err_o        (slv1_parity_err_s          ),
		.data_o              (slv1_data_s                ),
		.freeslot_o          (slv1_freeslot_s            ),
		.valid_o             (slv1_valid_o_s             ),
		.fetch_i             (slv1_fetch_s               ),
		.parity_err_clr_i    (err_clr_vec_s[1]           )       
	);     
	assign  slv1_parity_err_o = slv1_parity_err_s;

	//---------------------------------------
	// SLV NODE #2
	//---------------------------------------
	slave_node inst_slave_node_2 (
		.clk_i               (clk_i                      ),
		.rst_n_i             (rst_n_i                    ),
		.data_i              (slv2_data_i                ),
		.data_p_i            (slv2_data_p_i              ),
		.valid_i             (slv2_valid_i               ),
		.slv_en_i            (slv_en_vec_s[2]            ),
		.wait_o              (slv2_wait_o                ),
		.parity_err_o        (slv2_parity_err_s          ),
		.data_o              (slv2_data_s                ),
		.freeslot_o          (slv2_freeslot_s            ),
		.valid_o             (slv2_valid_o_s             ),
		.fetch_i             (slv2_fetch_s               ),
		.parity_err_clr_i    (err_clr_vec_s[2]           )
	);     
	assign  slv2_parity_err_o = slv2_parity_err_s;


	//---------------------------------------
	// SLV NODE #3
	//---------------------------------------
	slave_node inst_slave_node_3 (
		.clk_i               (clk_i                      ),
		.rst_n_i             (rst_n_i                    ),
		.data_i              (slv3_data_i                ),
		.data_p_i            (slv3_data_p_i              ),
		.valid_i             (slv3_valid_i               ),
		.slv_en_i            (slv_en_vec_s[3]            ),
		.wait_o              (slv3_wait_o                ),
		.parity_err_o        (slv3_parity_err_s          ),
		.data_o              (slv3_data_s                ),
		.freeslot_o          (slv3_freeslot_s            ),
		.valid_o             (slv3_valid_o_s             ),
		.fetch_i             (slv3_fetch_s               ),
		.parity_err_clr_i    (err_clr_vec_s[3]           )       
	);     
	assign  slv3_parity_err_o = slv3_parity_err_s;


	//---------------------------------------
	// Arbiter
	//---------------------------------------
	assign req_vec_s = {slv3_valid_o_s,slv2_valid_o_s,slv1_valid_o_s,slv0_valid_o_s};
	RR_arbiter inst_arb (
		.clk_i               (clk_i                      ),
		.rst_n_i             (rst_n_i                    ),
		.req_vec_i           (req_vec_s                  ),
		.win_vec_o           (win_vec_s                  ),
		.trigger_i           (trigger_s                  )   
	);

	formater inst_formatter (
		.clk_i               (clk_i                      ),
		.rst_n_i             (rst_n_i                    ),
		.data_slv0_i         (slv0_data_s                ),
		.data_slv1_i         (slv1_data_s                ),
		.data_slv2_i         (slv2_data_s                ),
		.data_slv3_i         (slv3_data_s                ),
		.id_slv0_i           (slv0_id_s                  ),
		.id_slv1_i           (slv1_id_s                  ),
		.id_slv2_i           (slv2_id_s                  ),
		.id_slv3_i           (slv3_id_s                  ),
		.len_slv0_i          (slv0_len_s                 ),
		.len_slv1_i          (slv1_len_s                 ),
		.len_slv2_i          (slv2_len_s                 ),
		.len_slv3_i          (slv3_len_s                 ),
		.req_vec_i           (req_vec_s                  ),
		.fetch_vec_o         (fetch_vec_s                ),
		.win_vec_i           (win_vec_s                  ), 
		.trigger_start_o     (trigger_s                  ),
		.rev_rdy_i           (rev_rdy_i                  ),
		.pkg_vld_o           (pkg_vld_o                  ),
		.pkg_dat_o           (pkg_dat_o                  ),
		.pkg_fst_o           (pkg_fst_o                  ),
		.pkg_lst_o           (pkg_lst_o                  )
	);

	assign slv0_fetch_s = fetch_vec_s[0];
	assign slv1_fetch_s = fetch_vec_s[1];
	assign slv2_fetch_s = fetch_vec_s[2];
	assign slv3_fetch_s = fetch_vec_s[3];

endmodule
