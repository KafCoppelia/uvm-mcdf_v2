`ifndef __MCDF_REGISTER_MODEL_PACKAGE_SV
`define __MCDF_REGISTER_MODEL_PACKAGE_SV

class slv_en_reg extends uvm_reg;
    `uvm_object_utils(slv_en_reg)
    rand uvm_reg_field en;
    rand uvm_reg_field reserved;
    covergroup value_cg;
        option.per_instance = 1;
        en: coverpoint en.value[3:0];
        reserved: coverpoint reserved.value[27:0];
    endgroup
    function new(string name = "slv_en_reg");
        super.new(name, 32, UVM_CVR_ALL);
        void'(set_coverage(UVM_CVR_FIELD_VALS));
        if(has_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg = new();
        end
    endfunction
    virtual function void build();
        en = uvm_reg_field::type_id::create("en");
        reserved = uvm_reg_field::type_id::create("reserved");
        en.configure(this, 4, 0, "RW", 0, 'h0, 1, 1, 0);
        reserved.configure(this, 28, 4, "RO", 0, 'h0, 1, 0, 0);
    endfunction
    function void sample(
        uvm_reg_data_t data,
        uvm_reg_data_t byte_en,
        bit            is_read,
        uvm_reg_map    map
    );
        super.sample(data, byte_en, is_read, map);
        sample_values(); 
    endfunction
    function void sample_values();
        super.sample_values();
        if (get_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg.sample();
        end
    endfunction
endclass

class parity_err_clr_reg extends uvm_reg;
    `uvm_object_utils(parity_err_clr_reg)
    rand uvm_reg_field err_clr;
    rand uvm_reg_field reserved;
    covergroup value_cg;
        option.per_instance = 1;
        err_clr: coverpoint err_clr.value[3:0];
        reserved: coverpoint reserved.value[27:0];
    endgroup
    function new(string name = "parity_err_clr_reg");
        super.new(name, 32, UVM_CVR_ALL);
        void'(set_coverage(UVM_CVR_FIELD_VALS));
        if(has_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg = new();
        end
    endfunction
    virtual function void build();
        err_clr = uvm_reg_field::type_id::create("err_clr");
        reserved = uvm_reg_field::type_id::create("reserved");
        err_clr.configure(this, 4, 0, "RW", 0, 'h0, 1, 1, 0);
        reserved.configure(this, 28, 4, "RO", 0, 'h0, 1, 0, 0);
    endfunction
    function void sample(
        uvm_reg_data_t data,
        uvm_reg_data_t byte_en,
        bit            is_read,
        uvm_reg_map    map
    );
        super.sample(data, byte_en, is_read, map);
        sample_values(); 
    endfunction
    function void sample_values();
        super.sample_values();
        if (get_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg.sample();
        end
    endfunction
endclass

class slv_id_reg extends uvm_reg;
    `uvm_object_utils(slv_id_reg)
    rand uvm_reg_field slv0_id;
    rand uvm_reg_field slv1_id;
    rand uvm_reg_field slv2_id;
    rand uvm_reg_field slv3_id;
    covergroup value_cg;
        option.per_instance = 1;
        slv0_id: coverpoint slv0_id.value[7:0];
        slv1_id: coverpoint slv1_id.value[7:0];
        slv2_id: coverpoint slv2_id.value[7:0];
        slv3_id: coverpoint slv3_id.value[7:0];
    endgroup
    function new(string name = "slv_id_reg");
        super.new(name, 32, UVM_CVR_ALL);
        void'(set_coverage(UVM_CVR_FIELD_VALS));
        if(has_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg = new();
        end
    endfunction
    virtual function void build();
        slv0_id = uvm_reg_field::type_id::create("slv0_id");
        slv1_id = uvm_reg_field::type_id::create("slv1_id");
        slv2_id = uvm_reg_field::type_id::create("slv2_id");
        slv3_id = uvm_reg_field::type_id::create("slv3_id");
        slv0_id.configure(this, 8, 0, "RW", 0, 'h0, 1, 1, 0);
        slv1_id.configure(this, 8, 8, "RW", 0, 'h1, 1, 1, 0);
        slv2_id.configure(this, 8, 16, "RW", 0, 'h2, 1, 1, 0);
        slv3_id.configure(this, 8, 24, "RW", 0, 'h3, 1, 1, 0);
    endfunction
    function void sample(
        uvm_reg_data_t data,
        uvm_reg_data_t byte_en,
        bit            is_read,
        uvm_reg_map    map
    );
        super.sample(data, byte_en, is_read, map);
        sample_values(); 
    endfunction
    function void sample_values();
        super.sample_values();
        if (get_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg.sample();
        end
    endfunction
endclass

class slv_len_reg extends uvm_reg;
    `uvm_object_utils(slv_len_reg)
    rand uvm_reg_field slv0_len;
    rand uvm_reg_field slv1_len;
    rand uvm_reg_field slv2_len;
    rand uvm_reg_field slv3_len;
    covergroup value_cg;
        option.per_instance = 1;
        slv0_len: coverpoint slv0_len.value[7:0];
        slv1_len: coverpoint slv1_len.value[7:0];
        slv2_len: coverpoint slv2_len.value[7:0];
        slv3_len: coverpoint slv3_len.value[7:0];
    endgroup
    function new(string name = "slv_len_reg");
        super.new(name, 32, UVM_CVR_ALL);
        void'(set_coverage(UVM_CVR_FIELD_VALS));
        if(has_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg = new();
        end
    endfunction
    virtual function void build();
        slv0_len = uvm_reg_field::type_id::create("slv0_len");
        slv1_len = uvm_reg_field::type_id::create("slv1_len");
        slv2_len = uvm_reg_field::type_id::create("slv2_len");
        slv3_len = uvm_reg_field::type_id::create("slv3_len");
        slv0_len.configure(this, 8, 0, "RW", 0, 'h0, 1, 1, 0);
        slv1_len.configure(this, 8, 8, "RW", 0, 'h0, 1, 1, 0);
        slv2_len.configure(this, 8, 16, "RW", 0, 'h0, 1, 1, 0);
        slv3_len.configure(this, 8, 24, "RW", 0, 'h0, 1, 1, 0);
    endfunction
    function void sample(
        uvm_reg_data_t data,
        uvm_reg_data_t byte_en,
        bit            is_read,
        uvm_reg_map    map
    );
        super.sample(data, byte_en, is_read, map);
        sample_values(); 
    endfunction
    function void sample_values();
        super.sample_values();
        if (get_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg.sample();
        end
    endfunction
endclass

class slv0_free_slot_reg extends uvm_reg;
    `uvm_object_utils(slv0_free_slot_reg)
    rand uvm_reg_field free_slot;
    rand uvm_reg_field reserved;
    covergroup value_cg;
        option.per_instance = 1;
        free_slot: coverpoint free_slot.value[5:0];
        reserved: coverpoint reserved.value[25:0];
    endgroup
    function new(string name = "slv0_free_slot_reg");
        super.new(name, 32, UVM_CVR_ALL);
        void'(set_coverage(UVM_CVR_FIELD_VALS));
        if(has_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg = new();
        end
    endfunction
    virtual function void build();
        free_slot = uvm_reg_field::type_id::create("free_slot");
        reserved = uvm_reg_field::type_id::create("reserved");
        free_slot.configure(this, 6, 0, "RO", 0, 'h20, 1, 0, 0);
        reserved.configure(this, 26, 6, "RO", 0, 'h0, 1, 0, 0);
    endfunction
    function void sample(
        uvm_reg_data_t data,
        uvm_reg_data_t byte_en,
        bit            is_read,
        uvm_reg_map    map
    );
        super.sample(data, byte_en, is_read, map);
        sample_values(); 
    endfunction
    function void sample_values();
        super.sample_values();
        if (get_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg.sample();
        end
    endfunction
endclass

class slv1_free_slot_reg extends uvm_reg;
    `uvm_object_utils(slv1_free_slot_reg)
    rand uvm_reg_field free_slot;
    rand uvm_reg_field reserved;
    covergroup value_cg;
        option.per_instance = 1;
        free_slot: coverpoint free_slot.value[5:0];
        reserved: coverpoint reserved.value[25:0];
    endgroup
    function new(string name = "slv1_free_slot_reg");
        super.new(name, 32, UVM_CVR_ALL);
        void'(set_coverage(UVM_CVR_FIELD_VALS));
        if(has_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg = new();
        end
    endfunction
    virtual function void build();
        free_slot = uvm_reg_field::type_id::create("free_slot");
        reserved = uvm_reg_field::type_id::create("reserved");
        free_slot.configure(this, 6, 0, "RO", 0, 'h20, 1, 0, 0);
        reserved.configure(this, 26, 6, "RO", 0, 'h0, 1, 0, 0);
    endfunction
    function void sample(
        uvm_reg_data_t data,
        uvm_reg_data_t byte_en,
        bit            is_read,
        uvm_reg_map    map
    );
        super.sample(data, byte_en, is_read, map);
        sample_values(); 
    endfunction
    function void sample_values();
        super.sample_values();
        if (get_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg.sample();
        end
    endfunction
endclass

class slv2_free_slot_reg extends uvm_reg;
    `uvm_object_utils(slv2_free_slot_reg)
    rand uvm_reg_field free_slot;
    rand uvm_reg_field reserved;
    covergroup value_cg;
        option.per_instance = 1;
        free_slot: coverpoint free_slot.value[5:0];
        reserved: coverpoint reserved.value[25:0];
    endgroup
    function new(string name = "slv2_free_slot_reg");
        super.new(name, 32, UVM_CVR_ALL);
        void'(set_coverage(UVM_CVR_FIELD_VALS));
        if(has_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg = new();
        end
    endfunction
    virtual function void build();
        free_slot = uvm_reg_field::type_id::create("free_slot");
        reserved = uvm_reg_field::type_id::create("reserved");
        free_slot.configure(this, 6, 0, "RO", 0, 'h20, 1, 0, 0);
        reserved.configure(this, 26, 6, "RO", 0, 'h0, 1, 0, 0);
    endfunction
    function void sample(
        uvm_reg_data_t data,
        uvm_reg_data_t byte_en,
        bit            is_read,
        uvm_reg_map    map
    );
        super.sample(data, byte_en, is_read, map);
        sample_values(); 
    endfunction
    function void sample_values();
        super.sample_values();
        if (get_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg.sample();
        end
    endfunction
endclass

class slv3_free_slot_reg extends uvm_reg;
    `uvm_object_utils(slv3_free_slot_reg)
    rand uvm_reg_field free_slot;
    rand uvm_reg_field reserved;
    covergroup value_cg;
        option.per_instance = 1;
        free_slot: coverpoint free_slot.value[5:0];
        reserved: coverpoint reserved.value[25:0];
    endgroup
    function new(string name = "slv3_free_slot_reg");
        super.new(name, 32, UVM_CVR_ALL);
        void'(set_coverage(UVM_CVR_FIELD_VALS));
        if(has_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg = new();
        end
    endfunction
    virtual function void build();
        free_slot = uvm_reg_field::type_id::create("free_slot");
        reserved = uvm_reg_field::type_id::create("reserved");
        free_slot.configure(this, 6, 0, "RO", 0, 'h20, 1, 0, 0);
        reserved.configure(this, 26, 6, "RO", 0, 'h0, 1, 0, 0);
    endfunction
    function void sample(
        uvm_reg_data_t data,
        uvm_reg_data_t byte_en,
        bit            is_read,
        uvm_reg_map    map
    );
        super.sample(data, byte_en, is_read, map);
        sample_values(); 
    endfunction
    function void sample_values();
        super.sample_values();
        if (get_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg.sample();
        end
    endfunction
endclass

class slv0_parity_err_reg extends uvm_reg;
    `uvm_object_utils(slv0_parity_err_reg)
    rand uvm_reg_field parity_err;
    rand uvm_reg_field reserved;
    covergroup value_cg;
        option.per_instance = 1;
        parity_err: coverpoint parity_err.value[0:0];
        reserved: coverpoint reserved.value[30:0];
    endgroup
    function new(string name = "slv0_parity_err_reg");
        super.new(name, 32, UVM_CVR_ALL);
        void'(set_coverage(UVM_CVR_FIELD_VALS));
        if(has_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg = new();
        end
    endfunction
    virtual function void build();
        parity_err = uvm_reg_field::type_id::create("parity_err");
        reserved = uvm_reg_field::type_id::create("reserved");
        parity_err.configure(this, 1, 0, "RO", 0, 'h0, 1, 0, 0);
        reserved.configure(this, 31, 1, "RO", 0, 'h0, 1, 0, 0);
    endfunction
    function void sample(
        uvm_reg_data_t data,
        uvm_reg_data_t byte_en,
        bit            is_read,
        uvm_reg_map    map
    );
        super.sample(data, byte_en, is_read, map);
        sample_values(); 
    endfunction
    function void sample_values();
        super.sample_values();
        if (get_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg.sample();
        end
    endfunction
endclass

class slv1_parity_err_reg extends uvm_reg;
    `uvm_object_utils(slv1_parity_err_reg)
    rand uvm_reg_field parity_err;
    rand uvm_reg_field reserved;
    covergroup value_cg;
        option.per_instance = 1;
        parity_err: coverpoint parity_err.value[0:0];
        reserved: coverpoint reserved.value[30:0];
    endgroup
    function new(string name = "slv1_parity_err_reg");
        super.new(name, 32, UVM_CVR_ALL);
        void'(set_coverage(UVM_CVR_FIELD_VALS));
        if(has_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg = new();
        end
    endfunction
    virtual function void build();
        parity_err = uvm_reg_field::type_id::create("parity_err");
        reserved = uvm_reg_field::type_id::create("reserved");
        parity_err.configure(this, 1, 0, "RO", 0, 'h0, 1, 0, 0);
        reserved.configure(this, 31, 1, "RO", 0, 'h0, 1, 0, 0);
    endfunction
    function void sample(
        uvm_reg_data_t data,
        uvm_reg_data_t byte_en,
        bit            is_read,
        uvm_reg_map    map
    );
        super.sample(data, byte_en, is_read, map);
        sample_values(); 
    endfunction
    function void sample_values();
        super.sample_values();
        if (get_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg.sample();
        end
    endfunction
endclass

class slv2_parity_err_reg extends uvm_reg;
    `uvm_object_utils(slv2_parity_err_reg)
    rand uvm_reg_field parity_err;
    rand uvm_reg_field reserved;
    covergroup value_cg;
        option.per_instance = 1;
        parity_err: coverpoint parity_err.value[0:0];
        reserved: coverpoint reserved.value[30:0];
    endgroup
    function new(string name = "slv2_parity_err_reg");
        super.new(name, 32, UVM_CVR_ALL);
        void'(set_coverage(UVM_CVR_FIELD_VALS));
        if(has_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg = new();
        end
    endfunction
    virtual function void build();
        parity_err = uvm_reg_field::type_id::create("parity_err");
        reserved = uvm_reg_field::type_id::create("reserved");
        parity_err.configure(this, 1, 0, "RO", 0, 'h0, 1, 0, 0);
        reserved.configure(this, 31, 1, "RO", 0, 'h0, 1, 0, 0);
    endfunction
    function void sample(
        uvm_reg_data_t data,
        uvm_reg_data_t byte_en,
        bit            is_read,
        uvm_reg_map    map
    );
        super.sample(data, byte_en, is_read, map);
        sample_values(); 
    endfunction
    function void sample_values();
        super.sample_values();
        if (get_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg.sample();
        end
    endfunction
endclass

class slv3_parity_err_reg extends uvm_reg;
    `uvm_object_utils(slv3_parity_err_reg)
    rand uvm_reg_field parity_err;
    rand uvm_reg_field reserved;
    covergroup value_cg;
        option.per_instance = 1;
        parity_err: coverpoint parity_err.value[0:0];
        reserved: coverpoint reserved.value[30:0];
    endgroup
    function new(string name = "slv3_parity_err_reg");
        super.new(name, 32, UVM_CVR_ALL);
        void'(set_coverage(UVM_CVR_FIELD_VALS));
        if(has_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg = new();
        end
    endfunction
    virtual function void build();
        parity_err = uvm_reg_field::type_id::create("parity_err");
        reserved = uvm_reg_field::type_id::create("reserved");
        parity_err.configure(this, 1, 0, "RO", 0, 'h0, 1, 0, 0);
        reserved.configure(this, 31, 1, "RO", 0, 'h0, 1, 0, 0);
    endfunction
    function void sample(
        uvm_reg_data_t data,
        uvm_reg_data_t byte_en,
        bit            is_read,
        uvm_reg_map    map
    );
        super.sample(data, byte_en, is_read, map);
        sample_values(); 
    endfunction
    function void sample_values();
        super.sample_values();
        if (get_coverage(UVM_CVR_FIELD_VALS)) begin
            value_cg.sample();
        end
    endfunction
endclass

class mcdf_regmodel extends uvm_reg_block;
    `uvm_object_utils(mcdf_regmodel)
    rand slv_en_reg slv_en;
    rand parity_err_clr_reg parity_err_clr;
    rand slv_id_reg slv_id;
    rand slv_len_reg slv_len;
    rand slv0_free_slot_reg slv0_free_slot;
    rand slv1_free_slot_reg slv1_free_slot;
    rand slv2_free_slot_reg slv2_free_slot;
    rand slv3_free_slot_reg slv3_free_slot;
    rand slv0_parity_err_reg slv0_parity_err;
    rand slv1_parity_err_reg slv1_parity_err;
    rand slv2_parity_err_reg slv2_parity_err;
    rand slv3_parity_err_reg slv3_parity_err;
    uvm_reg_map map;
    function new(string name = "mcdf_regmodel");
        super.new(name, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
        slv_en = slv_en_reg::type_id::create("slv_en");
        slv_en.configure(this);
        slv_en.build();
        parity_err_clr = parity_err_clr_reg::type_id::create("parity_err_clr");
        parity_err_clr.configure(this);
        parity_err_clr.build();
        slv_id = slv_id_reg::type_id::create("slv_id");
        slv_id.configure(this);
        slv_id.build();
        slv_len = slv_len_reg::type_id::create("slv_len");
        slv_len.configure(this);
        slv_len.build();
        slv0_free_slot = slv0_free_slot_reg::type_id::create("slv0_free_slot");
        slv0_free_slot.configure(this);
        slv0_free_slot.build();
        slv1_free_slot = slv1_free_slot_reg::type_id::create("slv1_free_slot");
        slv1_free_slot.configure(this);
        slv1_free_slot.build();
        slv2_free_slot = slv2_free_slot_reg::type_id::create("slv2_free_slot");
        slv2_free_slot.configure(this);
        slv2_free_slot.build();
        slv3_free_slot = slv3_free_slot_reg::type_id::create("slv3_free_slot");
        slv3_free_slot.configure(this);
        slv3_free_slot.build();
        slv0_parity_err = slv0_parity_err_reg::type_id::create("slv0_parity_err");
        slv0_parity_err.configure(this);
        slv0_parity_err.build();
        slv1_parity_err = slv1_parity_err_reg::type_id::create("slv1_parity_err");
        slv1_parity_err.configure(this);
        slv1_parity_err.build();
        slv2_parity_err = slv2_parity_err_reg::type_id::create("slv2_parity_err");
        slv2_parity_err.configure(this);
        slv2_parity_err.build();
        slv3_parity_err = slv3_parity_err_reg::type_id::create("slv3_parity_err");
        slv3_parity_err.configure(this);
        slv3_parity_err.build();
        map = create_map("map", 'h0, 4, UVM_LITTLE_ENDIAN);
        map.add_reg(slv_en, 32'h00, "RW");
        map.add_reg(parity_err_clr, 32'h04, "RW");
        map.add_reg(slv_id, 32'h08, "RW");
        map.add_reg(slv_len, 32'h0C, "RW");
        map.add_reg(slv0_free_slot, 32'h80, "RO");
        map.add_reg(slv1_free_slot, 32'h84, "RO");
        map.add_reg(slv2_free_slot, 32'h88, "RO");
        map.add_reg(slv3_free_slot, 32'h8C, "RO");
        map.add_reg(slv0_parity_err, 32'h90, "RO");
        map.add_reg(slv1_parity_err, 32'h94, "RO");
        map.add_reg(slv2_parity_err, 32'h98, "RO");
        map.add_reg(slv3_parity_err, 32'h9C, "RO");
        slv_en.add_hdl_path_slice("ctrl_mem[0]", 0, 32);
        parity_err_clr.add_hdl_path_slice("ctrl_mem[1]", 0, 32);
        slv_id.add_hdl_path_slice("ctrl_mem[2]", 0, 32);
        slv_len.add_hdl_path_slice("ctrl_mem[3]", 0, 32);
        slv0_free_slot.add_hdl_path_slice("ro_mem[0]", 0, 32);
        slv1_free_slot.add_hdl_path_slice("ro_mem[1]", 0, 32);
        slv2_free_slot.add_hdl_path_slice("ro_mem[2]", 0, 32);
        slv3_free_slot.add_hdl_path_slice("ro_mem[3]", 0, 32);
        slv0_parity_err.add_hdl_path_slice("ro_mem[4]", 0, 32);
        slv1_parity_err.add_hdl_path_slice("ro_mem[5]", 0, 32);
        slv2_parity_err.add_hdl_path_slice("ro_mem[6]", 0, 32);
        slv3_parity_err.add_hdl_path_slice("ro_mem[7]", 0, 32);
        add_hdl_path("tb.dut.inst_reg_if");
        lock_model();
    endfunction

    function int get_reg_field_length(int ch);
        int fd;
        case(ch)
            0: fd = slv_len.slv0_len.get();
            1: fd = slv_len.slv1_len.get();
            2: fd = slv_len.slv2_len.get();
            3: fd = slv_len.slv3_len.get();
            default: `uvm_error("TYPERR", $sformatf("channel number should not be %0d", ch))
        endcase
        return fd;
    endfunction

    function int get_reg_field_id(int ch);
        int fd;
        case(ch)
            0: fd = slv_id.slv0_id.get();
            1: fd = slv_id.slv1_id.get();
            2: fd = slv_id.slv2_id.get();
            3: fd = slv_id.slv3_id.get();
            default: `uvm_error("TYPERR", $sformatf("channel number should not be %0d", ch))
        endcase
        return fd;
    endfunction
    function int get_chnl_index(int ch_id);
        int fd_id;
        for(int i=0; i<4; i++) begin
            fd_id = get_reg_field_id(i);
            if(fd_id == ch_id)
                return i;
        end
        `uvm_error("CHIDERR", $sformatf("unrecognized channel ID : %0d and could not find the corresponding channel index", ch_id))
        return -1;
    endfunction
endclass

`endif
