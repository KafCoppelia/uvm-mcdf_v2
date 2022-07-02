`ifndef __MCDF_BASE_TEST
`define __MCDF_BASE_TEST

`include "mcdf_top_environment.sv"

/* MCDF base test   */
class mcdf_base_test extends uvm_test;
    mcdf_env env;
    apb_config cfg;

    `uvm_component_utils(mcdf_base_test)

    function new(string name = "mcdf_base_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = mcdf_env::type_id::create("env", this);
        cfg = apb_config::type_id::create("cfg");
        uvm_config_db#(apb_config)::set(this,"env.*","cfg", cfg);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_root::get().set_report_verbosity_level_hier(UVM_HIGH);
        uvm_root::get().set_report_max_quit_count(1);
        uvm_root::get().set_timeout(10ms);
    endfunction

    function void report_phase(uvm_phase phase);
        uvm_report_server server;
        integer fid;
        int err_num;
        string testname;
        $value$plusargs("TESTNAME=%s", testname);
        super.report_phase(phase);
    
        server = get_report_server();
        err_num = server.get_severity_count(UVM_ERROR);
    
        $system("date +[%F/%T] >> sim_result.log");
        fid = $fopen("sim_result.log","a");
    
        if( err_num != 0 ) begin
            $display("============================================================");
            $display("%s TestCase Failed !!!", testname);
            $display("It has %0d error(s).", err_num);
            $display("!!!!!!!!!!!!!!!!!!");
            $fwrite( fid, $sformatf("TestCase Failed: %s\n\n", testname) );
        end else begin
            $display("============================================================");
            $display("TestCase Passed: %s", testname);
            $display("============================================================");
            $fwrite( fid, $sformatf("TestCase Passed: %s\n\n", testname) );
        end
    
    endfunction

endclass: mcdf_base_test

`endif
