`include "cp0.vh"
module cpu_sram #
    (
        // TLB
        parameter TLB = 0,
        parameter TLBNUM = 2,
        parameter TLBNUM_WIDTH = $clog2(TLBNUM),

        // Cache
        parameter I_NUM_WAY = 2,
        // BYTES_PER_LINE * NUM_LINE must <= 4096
        parameter I_BYTES_PER_LINE = 32,
        parameter I_NUM_LINE = 128,
        parameter D_NUM_WAY = 2,
        // BYTES_PER_LINE * NUM_LINE must <= 4096
        parameter D_BYTES_PER_LINE = 16,
        parameter D_NUM_LINE = 256
    )
    (
        input clk,
        input resetn,

        input [5:0] ext_int,

        output inst_sram_req,
        output inst_sram_cached,
        output inst_sram_wr,
        output [1:0] inst_sram_size,
        output [3:0] inst_sram_wstrb,
        output [31:0] inst_sram_addr,
        output [31:0] inst_sram_wdata,
        input inst_sram_addr_ok,
        input inst_sram_data_ok,
        input [31:0] inst_sram_rdata,

        output inst_cacheop,
        output inst_cacheop_index,
        output inst_cacheop_hit,
        output inst_cacheop_wb,
        output [31:0] inst_cacheop_addr,
        input inst_cacheop_ok1,
        input inst_cacheop_ok2,

        (* MARK_DEBUG = "TRUE" *)output data_sram_req,
        (* MARK_DEBUG = "TRUE" *)output data_sram_cached,
        output data_sram_wr,
        output [1:0] data_sram_size,
        output [3:0] data_sram_wstrb,
        (* MARK_DEBUG = "TRUE" *)output [31:0] data_sram_addr,
        output [31:0] data_sram_wdata,
        input data_sram_addr_ok,
        input data_sram_data_ok,
        input [31:0] data_sram_rdata,

        output data_cacheop,
        output data_cacheop_index,
        output data_cacheop_hit,
        output data_cacheop_wb,
        output [31:0] data_cacheop_addr,
        input data_cacheop_ok1,
        input data_cacheop_ok2,

        output [31:0] debug_wb_pc,
        (* MARK_DEBUG = "TRUE" *)output [3:0] debug_wb_rf_wen,
        (* MARK_DEBUG = "TRUE" *)output [4:0] debug_wb_rf_wnum,
        (* MARK_DEBUG = "TRUE" *)output [31:0] debug_wb_rf_wdata
    );
    wire reset;
    assign reset = ~resetn;

    wire mem_en_ID;
    wire mem_en_EX;
    wire mem_wen_ID;
    wire mem_wen_EX;
    wire data_sram_req_MEM;
    wire inst_cacheop_MEM;
    wire data_cacheop_MEM;

    // pc
    (* MARK_DEBUG = "TRUE" *)wire [31:0] curr_pc_pre_IF;
    (* MARK_DEBUG = "TRUE" *)wire [31:0] curr_pc_IF;
    (* MARK_DEBUG = "TRUE" *)wire [31:0] curr_pc_ID;
    (* MARK_DEBUG = "TRUE" *)wire [31:0] curr_pc_EX;
    (* MARK_DEBUG = "TRUE" *)wire [31:0] curr_pc_MEM;
    (* MARK_DEBUG = "TRUE" *)wire [31:0] curr_pc_WB;


    // instruction
    wire [31:0] instruction_IF;
    (* MARK_DEBUG = "TRUE" *)wire [31:0] instruction_ID;
    wire [5:0] opcode;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [15:0] inst_imm;
    wire [4:0] shamt_ID;
    wire [4:0] shamt_EX;
    wire [5:0] func;

    // imm
    wire [31:0] imm_sign_extended;
    wire imm_is_sign_extend;
    wire [31:0] imm_ID;
    wire [31:0] imm_EX;

    // register read
    wire [31:0] rs_data_ID_compare;
    wire [31:0] rt_data_ID_compare;
    wire [31:0] rs_data_ID;
    wire [31:0] rt_data_ID;
    wire [31:0] rs_data_EX;
    wire [31:0] rt_data_EX;
    wire [31:0] rt_data_MEM;
    wire [31:0] rt_data_WB;

    // control transfer
    wire is_branch_ID;
    wire branch_or_jump_ID;

    wire next_pc_is_next;
    wire next_pc_is_branch_target;
    wire next_pc_is_jal_target;
    wire next_pc_is_jr_target;

    wire [31:0] next_pc_without_exception;

    wire [31:0] jr_target = rs_data_ID_compare; // jr, jalr
    wire [31:0] branch_target;          // b*
    wire [31:0] jal_target =            // jal, j
         {curr_pc_IF[31:28] ,instruction_ID[25:0], {2{1'b0}}};
    wire [31:0] cp0_epc;

    reg is_delay_slot_ID;
    wire is_delay_slot_WB;

    // signals that choose the result
    // from hi/lo or alu result
    wire [31:0] result_EX;
    wire [31:0] result_MEM;
    wire [31:0] result_not_product_EX;
    wire is_result_alu_ID;
    wire is_result_lo_ID;
    wire is_result_hi_ID;
    wire is_result_product_ID;
    wire is_result_alu_EX;
    wire is_result_lo_EX;
    wire is_result_hi_EX;
    wire is_result_product_EX;

    // alu
    wire [14:0] alu_op_ID;
    wire [14:0] alu_op_EX;

    wire overflow_en_ID;
    wire overflow_en_EX;

    // alu src
    wire [31:0] alu_a;
    wire [31:0] alu_b;

    wire alu_a_is_rs_data_ID;
    wire alu_a_is_shamt_ID;
    wire alu_a_is_pc_ID;

    wire alu_a_is_rs_data_EX;
    wire alu_a_is_shamt_EX;
    wire alu_a_is_pc_EX;

    wire alu_b_is_rt_data_ID;
    wire alu_b_is_imm_ID;
    wire alu_b_is_8_ID;

    wire alu_b_is_rt_data_EX;
    wire alu_b_is_imm_EX;
    wire alu_b_is_8_EX;

    // alu control signals
    // that go through pipeline registers
    wire [21:0] alu_ctrl_ID;
    wire [21:0] alu_ctrl_EX;
    assign alu_ctrl_ID = {
               alu_a_is_pc_ID,
               alu_a_is_rs_data_ID,
               alu_a_is_shamt_ID,
               alu_b_is_8_ID,
               alu_b_is_imm_ID,
               alu_b_is_rt_data_ID,
               alu_op_ID,
               overflow_en_ID
           };
    assign {
            alu_a_is_pc_EX,
            alu_a_is_rs_data_EX,
            alu_a_is_shamt_EX,
            alu_b_is_8_EX,
            alu_b_is_imm_EX,
            alu_b_is_rt_data_EX,
            alu_op_EX,
            overflow_en_EX
        } = alu_ctrl_EX;

    // multiplication and division
    wire is_div_ID;
    wire is_divu_ID;
    wire is_mult_ID;
    wire is_multu_ID;
    wire hi_wen_ID;
    wire lo_wen_ID;

    wire is_div_EX;
    wire is_divu_EX;
    wire is_mult_EX;
    wire is_multu_EX;
    wire hi_wen_EX;
    wire lo_wen_EX;

    // multiplication and division control signals
    // that go through pipeline registers
    wire [9:0] mult_div_ctrl_ID;
    wire [9:0] mult_div_ctrl_EX;
    assign mult_div_ctrl_ID = {
               is_div_ID,
               is_divu_ID,
               is_mult_ID,
               is_multu_ID,
               hi_wen_ID,
               lo_wen_ID,
               is_result_lo_ID,
               is_result_hi_ID,
               is_result_product_ID,
               is_result_alu_ID
           };
    assign {
            is_div_EX,
            is_divu_EX,
            is_mult_EX,
            is_multu_EX,
            hi_wen_EX,
            lo_wen_EX,
            is_result_lo_EX,
            is_result_hi_EX,
            is_result_product_EX,
            is_result_alu_EX
        } = mult_div_ctrl_EX;

    // data memory
    wire [31:0] mem_read_data;
    wire [1:0] byte_offset_EX;
    wire [1:0] byte_offset_MEM;

    // data memory read control
    wire mem_w_ID;
    wire mem_b_ID;
    wire mem_bu_ID;
    wire mem_h_ID;
    wire mem_hu_ID;
    wire mem_wl_ID;
    wire mem_wr_ID;

    wire mem_w_EX;
    wire mem_b_EX;
    wire mem_bu_EX;
    wire mem_h_EX;
    wire mem_hu_EX;
    wire mem_wl_EX;
    wire mem_wr_EX;

    wire mem_w_MEM;
    wire mem_b_MEM;
    wire mem_bu_MEM;
    wire mem_h_MEM;
    wire mem_hu_MEM;
    wire mem_wl_MEM;
    wire mem_wr_MEM;

    wire [6:0] mem_ctrl_ID;
    wire [6:0] mem_ctrl_EX;
    wire [6:0] mem_ctrl_MEM;
    assign mem_ctrl_ID = {
               mem_w_ID,
               mem_b_ID,
               mem_bu_ID,
               mem_h_ID,
               mem_hu_ID,
               mem_wl_ID,
               mem_wr_ID
           };
    assign {
            mem_w_EX,
            mem_b_EX,
            mem_bu_EX,
            mem_h_EX,
            mem_hu_EX,
            mem_wl_EX,
            mem_wr_EX
        } = mem_ctrl_EX;
    assign {
            mem_w_MEM,
            mem_b_MEM,
            mem_bu_MEM,
            mem_h_MEM,
            mem_hu_MEM,
            mem_wl_MEM,
            mem_wr_MEM
        } = mem_ctrl_MEM;


    // cacheop
    wire cacheop_i_ID;
    wire cacheop_d_ID;
    wire cacheop_index_ID;
    wire cacheop_hit_ID;
    wire cacheop_wb_ID;
    wire [4:0] cacheop_ID = {
             cacheop_i_ID,
             cacheop_d_ID,
             cacheop_index_ID,
             cacheop_hit_ID,
             cacheop_wb_ID
         };
    wire cacheop_i_EX;
    wire cacheop_d_EX;
    wire cacheop_index_EX;
    wire cacheop_hit_EX;
    wire cacheop_wb_EX;
    wire [4:0] cacheop_EX;
    assign {
            cacheop_i_EX,
            cacheop_d_EX,
            cacheop_index_EX,
            cacheop_hit_EX,
            cacheop_wb_EX
        } = cacheop_EX;

    // conditional move
    wire cond_mov_ID;

    // register write
    wire reg_write_ID;
    wire reg_write_addr_is_rt_ID;
    wire reg_write_addr_is_rd_ID;
    wire reg_write_addr_is_31_ID;
    wire reg_write_is_alu_ID;
    wire reg_write_is_mem_ID;
    wire [4:0] reg_write_addr_ID;

    wire reg_write_EX;
    // verilator lint_off unused
    wire reg_write_is_alu_EX;
    // verilator lint_on unused
    wire reg_write_is_mem_EX; // for load-use hazard detection
    wire [4:0] reg_write_addr_EX;

    wire reg_write_MEM;
    wire reg_write_is_alu_MEM;
    wire reg_write_is_mem_MEM;
    wire [4:0] reg_write_addr_MEM;

    wire reg_write_WB;
    wire [4:0] reg_write_addr_WB;

    wire [31:0] reg_write_data_MEM;
    wire [31:0] reg_write_data_WB_not_mfc0;
    wire [31:0] reg_write_data_WB;


    // register write signals
    // that go through pipeline registers
    wire [7:0] reg_write_sig_ID;
    wire [7:0] reg_write_sig_EX;
    wire [7:0] reg_write_sig_MEM;
    wire [37:0] reg_write_sig_WB;

    assign reg_write_sig_ID = {
               reg_write_ID,
               reg_write_addr_ID,
               reg_write_is_alu_ID,
               reg_write_is_mem_ID
           };
    assign {
            reg_write_EX,
            reg_write_addr_EX,
            reg_write_is_alu_EX,
            reg_write_is_mem_EX
        } = reg_write_sig_EX;
    assign {
            reg_write_MEM,
            reg_write_addr_MEM,
            reg_write_is_alu_MEM,
            reg_write_is_mem_MEM
        } = reg_write_sig_MEM;
    assign {
            reg_write_WB,
            reg_write_addr_WB,
            reg_write_data_WB_not_mfc0
        } = reg_write_sig_WB;

    // cp0
    wire [4:0] cp0_reg_num_ID = rd;
    wire [4:0] cp0_reg_num_WB;
    wire cp0_reg_sel_ID = func[0];
    wire cp0_reg_sel_WB;

    wire mtc0_ID;
    wire mtc0_WB;
    wire mfc0_ID;
    wire mfc0_WB;
    wire [8:0] cp0_signals_ID;
    wire [8:0] cp0_signals_EX;
    wire [8:0] cp0_signals_MEM;
    wire [8:0] cp0_signals_WB;
    assign cp0_signals_ID =
           {
               mtc0_ID,
               mfc0_ID,
               cp0_reg_num_ID,
               is_delay_slot_ID,
               cp0_reg_sel_ID
           };
    assign {
            mtc0_WB,
            mfc0_WB,
            cp0_reg_num_WB,
            is_delay_slot_WB,
            cp0_reg_sel_WB
        } = cp0_signals_WB;
    // NOTE: These indices is related to the order of assignment above.
    wire mtc0_EX = cp0_signals_EX[8];
    wire mfc0_EX = cp0_signals_EX[7];
    wire mtc0_MEM = cp0_signals_MEM[8];
    wire mfc0_MEM = cp0_signals_MEM[7];
    wire exception_now;
    wire eret_now;
    wire refetch_now;
    wire exception_now_pre_IF;
    wire eret_now_pre_IF;
    wire refetch_now_pre_IF;
    wire exception_like_now = exception_now | eret_now | refetch_now;
    wire tlb_refill_now_pre_IF;

    wire [31:0] refetch_pc = curr_pc_WB;
    wire [31:0] refetch_pc_pre_IF;

    wire [31:0] badvaddr_IF;
    wire [31:0] badvaddr_ID;
    wire [31:0] badvaddr_EX_old;
    wire [31:0] badvaddr_EX;
    wire [31:0] badvaddr_MEM;
    wire [31:0] badvaddr_WB;

    wire [7:0] cp0_cause_ip;
    wire [7:0] cp0_status_im;
    wire cp0_status_exl;
    wire cp0_status_ie;
    wire [18:0] cp0_entry_hi_vpn2;
    wire [7:0] cp0_entry_hi_asid;
    wire [2:0] cp0_config_k0;

    wire [TLBNUM_WIDTH:0] tlbp_result_EX;
    wire [TLBNUM_WIDTH:0] tlbp_result_MEM;
    wire [TLBNUM_WIDTH:0] tlbp_result_WB;

    // pipeline registers control signals
    wire _pre_IF_reg_valid_in = ~reset;
    wire _pre_IF_reg_valid_out;
    wire _pre_IF_reg_allow_out;
    wire _pre_IF_reg_valid;
    // verilator lint_off unused
    wire _pre_IF_reg_allow_in;
    // verilator lint_on unused
    wire _pre_IF_reg_stall;
    wire _pre_IF_reg_flush = 0;
    wire leaving_pre_IF = _pre_IF_reg_valid_out && _pre_IF_reg_allow_out;

    wire pre_IF_IF_reg_valid_in = _pre_IF_reg_valid_out;
    wire pre_IF_IF_reg_valid_out;
    wire pre_IF_IF_reg_allow_out;
    wire pre_IF_IF_reg_valid;

    wire pre_IF_IF_reg_flush;
    wire pre_IF_IF_reg_stall_wait_for_data;
    wire pre_IF_IF_reg_stall_discard_instruction;
    wire pre_IF_IF_reg_stall =
         |{pre_IF_IF_reg_stall_wait_for_data,
           pre_IF_IF_reg_stall_discard_instruction};

    wire IF_ID_reg_valid_in = pre_IF_IF_reg_valid_out;
    wire IF_ID_reg_valid_out;
    wire IF_ID_reg_allow_out;
    wire IF_ID_reg_valid;
    wire IF_ID_reg_flush;
    wire leaving_ID = IF_ID_reg_valid_out && IF_ID_reg_allow_out;

    wire IF_ID_reg_stall_hazard;
    wire IF_ID_reg_stall = IF_ID_reg_stall_hazard;

    wire ID_EX_reg_valid_in = IF_ID_reg_valid_out;
    wire ID_EX_reg_valid_out;
    wire ID_EX_reg_allow_out;
    wire ID_EX_reg_valid;
    wire ID_EX_reg_flush;

    wire ID_EX_reg_stall_mem_not_ready;
    wire ID_EX_reg_stall_div_not_complete;
    wire ID_EX_reg_stall =
         |{ID_EX_reg_stall_mem_not_ready, ID_EX_reg_stall_div_not_complete};

    wire EX_MEM_reg_valid_in = ID_EX_reg_valid_out;
    wire EX_MEM_reg_valid_out;
    wire EX_MEM_reg_allow_out;
    wire EX_MEM_reg_valid;
    wire EX_MEM_reg_flush;

    wire EX_MEM_reg_stall_wait_for_data;
    wire EX_MEM_reg_stall = EX_MEM_reg_stall_wait_for_data;

    wire MEM_WB_reg_valid_in = EX_MEM_reg_valid_out;
    // verilator lint_off unused
    wire MEM_WB_reg_valid_out;
    // verilator lint_on unused
    wire MEM_WB_reg_allow_out = 1;
    wire MEM_WB_reg_stall = 0;
    wire MEM_WB_reg_valid;
    wire MEM_WB_reg_flush;

    // exception signals
    wire exception_pre_IF;
    wire exception_IF;
    wire exception_ID;
    wire exception_EX;
    wire exception_MEM;
    wire exception_WB;
    wire exception_IF_old;
    wire exception_ID_old;
    wire exception_EX_old;
    wire exception_MEM_old;
    wire exception_WB_old;

    wire exception_EX_MEM_WB =
         |{exception_EX & ID_EX_reg_valid,
           exception_MEM & EX_MEM_reg_valid,
           exception_WB & MEM_WB_reg_valid};

    wire [4:0] exccode_pre_IF;
    wire [4:0] exccode_IF;
    wire [4:0] exccode_ID;
    wire [4:0] exccode_EX;
    wire [4:0] exccode_MEM;
    wire [4:0] exccode_WB;
    wire [4:0] exccode_IF_old; // from pre-IF
    wire [4:0] exccode_ID_old; // from IF
    wire [4:0] exccode_EX_old; // from ID
    wire [4:0] exccode_MEM_old; // from EX
    wire [4:0] exccode_WB_old; // from MEM

    assign exception_MEM = exception_MEM_old;
    assign exception_WB = exception_WB_old;
    assign exccode_MEM = exccode_MEM_old;
    assign exccode_WB = exccode_WB_old;

    wire tlb_refill_pre_IF;
    wire tlb_refill_IF;
    wire tlb_refill_ID;
    wire tlb_refill_EX_old; // from ID
    wire tlb_refill_EX;
    wire tlb_refill_MEM;
    wire tlb_refill_WB;

    wire [18:0] tlb_error_vpn2_pre_IF;
    wire [18:0] tlb_error_vpn2_IF;
    wire [18:0] tlb_error_vpn2_ID;
    wire [18:0] tlb_error_vpn2_EX_old; // from ID
    wire [18:0] tlb_error_vpn2_EX;
    wire [18:0] tlb_error_vpn2_MEM;
    wire [18:0] tlb_error_vpn2_WB;

    wire exc_syscall_ID;
    wire exc_reserved_ID;
    wire exc_break_ID;
    wire eret_ID;

    wire tlbp_ID;
    wire tlbp_EX;
    wire tlbp_MEM;
    wire tlbp_WB;
    wire tlbwi_ID;
    wire tlbwi_EX;
    wire tlbwi_MEM;
    wire tlbwi_WB;
    wire tlbr_ID;
    wire tlbr_EX;
    wire tlbr_MEM;
    wire tlbr_WB;

    // pipeline registers
    pipeline_reg
        #(
            .WIDTH(3 + 32 + 1)
        )
        _pre_IF_reg(
            .clk(clk),
            .reset(reset),
            .stall(_pre_IF_reg_stall),
            .flush(_pre_IF_reg_flush),

            .valid_in(_pre_IF_reg_valid_in),
            .allow_in(_pre_IF_reg_allow_in),
            .allow_out(_pre_IF_reg_allow_out),
            .valid_out(_pre_IF_reg_valid_out),
            .valid(_pre_IF_reg_valid),

            .in(
                {
                    exception_now,
                    eret_now,
                    refetch_now,
                    refetch_pc,
                    tlb_refill_WB
                }),
            .out(
                {
                    exception_now_pre_IF,
                    eret_now_pre_IF,
                    refetch_now_pre_IF,
                    refetch_pc_pre_IF,
                    tlb_refill_now_pre_IF
                })
        );

    pipeline_reg
        #(
            .WIDTH(32 + 1 + 5 + 1 + 19),
            .RESET(1),
            .RESET_VALUE({32'hBFC0_0000 - 32'h4, 7'bxxxxxxx, 19'HXXX})
        )
        pre_IF_IF_reg(
            .clk(clk),
            .reset(reset),
            .stall(pre_IF_IF_reg_stall),
            .flush(pre_IF_IF_reg_flush),

            .valid_in(pre_IF_IF_reg_valid_in),
            .allow_in(_pre_IF_reg_allow_out),
            .allow_out(pre_IF_IF_reg_allow_out),
            .valid_out(pre_IF_IF_reg_valid_out),
            .valid(pre_IF_IF_reg_valid),

            .in(
                {
                    curr_pc_pre_IF,
                    exception_pre_IF,
                    exccode_pre_IF,
                    tlb_refill_pre_IF,
                    tlb_error_vpn2_pre_IF
                }),
            .out(
                {
                    curr_pc_IF,
                    exception_IF_old,
                    exccode_IF_old,
                    tlb_refill_IF,
                    tlb_error_vpn2_IF
                })
        );

    pipeline_reg #(.WIDTH(32 + 32 + 1 + 5 + 32 + 1 + 19)) IF_ID_reg(
                     .clk(clk),
                     .reset(reset),
                     .stall(IF_ID_reg_stall),
                     .flush(IF_ID_reg_flush),

                     .valid_in(IF_ID_reg_valid_in),
                     .allow_in(pre_IF_IF_reg_allow_out),
                     .valid_out(IF_ID_reg_valid_out),
                     .allow_out(IF_ID_reg_allow_out),
                     .in(
                         {
                             curr_pc_IF,
                             instruction_IF,
                             exception_IF,
                             exccode_IF,
                             badvaddr_IF,
                             tlb_refill_IF,
                             tlb_error_vpn2_IF
                         }),
                     .out(
                         {
                             curr_pc_ID,
                             instruction_ID,
                             exception_ID_old,
                             exccode_ID_old,
                             badvaddr_ID,
                             tlb_refill_ID,
                             tlb_error_vpn2_ID
                         }),
                     .valid(IF_ID_reg_valid)
                 );

    pipeline_reg #(.WIDTH(32 + 32 + 32 + 32 +
                          22 + 8 +
                          5 + 10 + 7 +
                          9 + 1 + 5 +
                          32 + 1 + 1 +
                          1 + 1 + 1 +
                          1 +
                          19 +
                          5
                         ))
                 ID_EX_reg(
                     .clk(clk),
                     .reset(reset),
                     .stall(ID_EX_reg_stall),
                     .flush(ID_EX_reg_flush),

                     .valid_in(ID_EX_reg_valid_in),
                     .allow_in(IF_ID_reg_allow_out),
                     .valid_out(ID_EX_reg_valid_out),
                     .allow_out(ID_EX_reg_allow_out),
                     .in(
                         {
                             curr_pc_ID, rs_data_ID, rt_data_ID, imm_ID,
                             alu_ctrl_ID, reg_write_sig_ID,
                             shamt_ID, mult_div_ctrl_ID, mem_ctrl_ID,
                             cp0_signals_ID, exception_ID, exccode_ID,
                             badvaddr_ID, mem_en_ID, mem_wen_ID,
                             tlbp_ID, tlbwi_ID, tlbr_ID,
                             tlb_refill_ID,
                             tlb_error_vpn2_ID,
                             cacheop_ID
                         }),
                     .out(
                         {
                             curr_pc_EX, rs_data_EX, rt_data_EX, imm_EX,
                             alu_ctrl_EX, reg_write_sig_EX,
                             shamt_EX, mult_div_ctrl_EX, mem_ctrl_EX,
                             cp0_signals_EX, exception_EX_old, exccode_EX_old,
                             badvaddr_EX_old, mem_en_EX, mem_wen_EX,
                             tlbp_EX, tlbwi_EX, tlbr_EX,
                             tlb_refill_EX_old,
                             tlb_error_vpn2_EX_old,
                             cacheop_EX
                         }),
                     .valid(ID_EX_reg_valid)
                 );

    pipeline_reg #(.WIDTH(32 + 8 +
                          32 + 2 +
                          7 + 32 +
                          9 +
                          1 + 5 +
                          32 +
                          3 +
                          TLBNUM_WIDTH+1 +
                          1 + 1 + 1 +
                          1 +
                          19))
                 EX_MEM_reg(
                     .clk(clk),
                     .reset(reset),
                     .stall(EX_MEM_reg_stall),
                     .flush(EX_MEM_reg_flush),

                     .valid_in(EX_MEM_reg_valid_in),
                     .allow_in(ID_EX_reg_allow_out),
                     .valid_out(EX_MEM_reg_valid_out),
                     .allow_out(EX_MEM_reg_allow_out),
                     .in(
                         {
                             curr_pc_EX, reg_write_sig_EX,
                             result_EX, byte_offset_EX,
                             mem_ctrl_EX, rt_data_EX,
                             cp0_signals_EX,
                             exception_EX, exccode_EX,
                             badvaddr_EX,
                             data_sram_req, data_cacheop, inst_cacheop,
                             tlbp_result_EX,
                             tlbp_EX, tlbwi_EX, tlbr_EX,
                             tlb_refill_EX,
                             tlb_error_vpn2_EX
                         }),
                     .out(
                         {
                             curr_pc_MEM, reg_write_sig_MEM,
                             result_MEM, byte_offset_MEM,
                             mem_ctrl_MEM, rt_data_MEM,
                             cp0_signals_MEM,
                             exception_MEM_old, exccode_MEM_old,
                             badvaddr_MEM,
                             data_sram_req_MEM, data_cacheop_MEM, inst_cacheop_MEM,
                             tlbp_result_MEM,
                             tlbp_MEM, tlbwi_MEM, tlbr_MEM,
                             tlb_refill_MEM,
                             tlb_error_vpn2_MEM
                         }),
                     .valid(EX_MEM_reg_valid)
                 );

    pipeline_reg #(.WIDTH(
                       32 + 38 + 32 + 9 + 1 + 5 + 32 + TLBNUM_WIDTH+1 + 1 + 1 + 1 + 1 + 19))
                 MEM_WB_reg(
                     .clk(clk),
                     .reset(reset),
                     .stall(MEM_WB_reg_stall),
                     .flush(MEM_WB_reg_flush),

                     .valid_in(MEM_WB_reg_valid_in),
                     .allow_in(EX_MEM_reg_allow_out),
                     .valid_out(MEM_WB_reg_valid_out),
                     .allow_out(MEM_WB_reg_allow_out),
                     .in({
                             curr_pc_MEM,
                             {reg_write_MEM,
                              reg_write_addr_MEM,
                              reg_write_data_MEM},
                             rt_data_MEM,
                             cp0_signals_MEM,
                             exception_MEM,
                             exccode_MEM,
                             badvaddr_MEM,
                             tlbp_result_MEM,
                             tlbp_MEM,
                             tlbwi_MEM,
                             tlbr_MEM,
                             tlb_refill_MEM,
                             tlb_error_vpn2_MEM
                         }),
                     .out(
                         {
                             curr_pc_WB,
                             reg_write_sig_WB,
                             rt_data_WB,
                             cp0_signals_WB,
                             exception_WB_old,
                             exccode_WB_old,
                             badvaddr_WB,
                             tlbp_result_WB,
                             tlbp_WB,
                             tlbwi_WB,
                             tlbr_WB,
                             tlb_refill_WB,
                             tlb_error_vpn2_WB
                         }),
                     .valid(MEM_WB_reg_valid)
                 );

    // TLB
    // search port 0
    wire [18:0] s0_vpn2;
    wire s0_odd_page;
    wire [7:0] s0_asid = cp0_entry_hi_asid;
    wire s0_found;
    // verilator lint_off unused
    wire [$clog2(TLBNUM)-1:0] s0_index;
    // verilator lint_on unused
    wire [19:0] s0_pfn;
    wire [2:0] s0_c;
    // verilator lint_off unused
    wire s0_d;
    // verilator lint_on unused
    wire s0_v;

    // search port 1
    wire [18:0] s1_vpn2;
    wire s1_odd_page;
    wire [7:0] s1_asid = cp0_entry_hi_asid;
    wire s1_found;
    wire [$clog2(TLBNUM)-1:0] s1_index;
    wire [19:0] s1_pfn;
    wire [2:0] s1_c;
    wire s1_d;
    wire s1_v;

    // write port
    wire tlb_we; // write enable
    wire [$clog2(TLBNUM)-1:0] w_index;
    wire [18:0] w_vpn2;
    wire [7:0] w_asid;
    wire w_g;
    wire [19:0] w_pfn0;
    wire [2:0] w_c0;
    wire w_d0;
    wire w_v0;
    wire [19:0] w_pfn1;
    wire [2:0] w_c1;
    wire w_d1;
    wire w_v1;

    // read port
    wire [$clog2(TLBNUM)-1:0] r_index;
    wire [18:0] r_vpn2;
    wire [7:0] r_asid;
    wire r_g;
    wire [19:0] r_pfn0;
    wire [2:0] r_c0;
    wire r_d0;
    wire r_v0;
    wire [19:0] r_pfn1;
    wire [2:0] r_c1;
    wire r_d1;
    wire r_v1;

    if (TLB) begin
        // search port 0
        tlb #(.TLBNUM(TLBNUM)) tlb(
                .clk(clk),

                .s0_vpn2(s0_vpn2),
                .s0_odd_page(s0_odd_page),
                .s0_asid(s0_asid),
                .s0_found(s0_found),
                .s0_index(s0_index),
                .s0_pfn(s0_pfn),
                .s0_c(s0_c),
                .s0_d(s0_d),
                .s0_v(s0_v),

                .s1_vpn2(s1_vpn2),
                .s1_odd_page(s1_odd_page),
                .s1_asid(s1_asid),
                .s1_found(s1_found),
                .s1_index(s1_index),
                .s1_pfn(s1_pfn),
                .s1_c(s1_c),
                .s1_d(s1_d),
                .s1_v(s1_v),

                .we(tlb_we),
                .w_index(w_index),
                .w_vpn2(w_vpn2),
                .w_asid(w_asid),
                .w_g(w_g),
                .w_pfn0(w_pfn0),
                .w_c0(w_c0),
                .w_d0(w_d0),
                .w_v0(w_v0),
                .w_pfn1(w_pfn1),
                .w_c1(w_c1),
                .w_d1(w_d1),
                .w_v1(w_v1),

                .r_index(r_index),
                .r_vpn2(r_vpn2),
                .r_asid(r_asid),
                .r_g(r_g),
                .r_pfn0(r_pfn0),
                .r_c0(r_c0),
                .r_d0(r_d0),
                .r_v0(r_v0),
                .r_pfn1(r_pfn1),
                .r_c1(r_c1),
                .r_d1(r_d1),
                .r_v1(r_v1)
            );
    end

    //
    // pre-IF Stage
    //

    pre_IF #(.TLB(TLB)) pre_IF(
               .clk(clk),
               .reset(reset),

               .inst_sram_req(inst_sram_req),
               .inst_sram_cached(inst_sram_cached),
               .inst_sram_wr(inst_sram_wr),
               .inst_sram_size(inst_sram_size),
               .inst_sram_wstrb(inst_sram_wstrb),
               .inst_sram_addr(inst_sram_addr),
               .inst_sram_wdata(inst_sram_wdata),
               .inst_sram_addr_ok(inst_sram_addr_ok),
               .inst_sram_data_ok(inst_sram_data_ok),

               ._pre_IF_reg_valid(_pre_IF_reg_valid),
               ._pre_IF_reg_allow_out(_pre_IF_reg_allow_out),
               ._pre_IF_reg_stall(_pre_IF_reg_stall),
               .leaving_pre_IF(leaving_pre_IF),

               .pre_IF_IF_reg_valid(pre_IF_IF_reg_valid),
               .pre_IF_IF_reg_stall_wait_for_data(
                   pre_IF_IF_reg_stall_wait_for_data
               ),
               .pre_IF_IF_reg_stall_discard_instruction(
                   pre_IF_IF_reg_stall_discard_instruction
               ),

               .IF_ID_reg_valid_out(IF_ID_reg_valid_out),

               .exception_like_now(exception_like_now),
               .exception_now_pre_IF(exception_now_pre_IF),
               .eret_now_pre_IF(eret_now_pre_IF),
               .refetch_now_pre_IF(refetch_now_pre_IF),
               .tlb_refill_now_pre_IF(tlb_refill_now_pre_IF),

               .cp0_epc(cp0_epc),
               .refetch_pc_pre_IF(refetch_pc_pre_IF),

               .next_pc_is_next(next_pc_is_next),

               .next_pc_without_exception(next_pc_without_exception),
               .curr_pc_IF(curr_pc_IF),
               .curr_pc_pre_IF(curr_pc_pre_IF),

               .exception_pre_IF(exception_pre_IF),
               .exccode_pre_IF(exccode_pre_IF),

               .vpn2(s0_vpn2),
               .odd_page(s0_odd_page),
               .pfn(s0_pfn),
               .found(s0_found),
               .v(s0_v),
               .c(s0_c),

               .cp0_config_k0(cp0_config_k0),

               .tlb_refill(tlb_refill_pre_IF)
           );
    assign tlb_error_vpn2_pre_IF = s0_vpn2;

    //
    // IF Stage
    //

    mux_1h #(.num_port(4)) next_pc_mux(
               .select(
                   {
                       next_pc_is_next,
                       next_pc_is_branch_target,
                       next_pc_is_jal_target,
                       next_pc_is_jr_target
                   }),
               .in(
                   {
                       curr_pc_IF+32'd4,
                       branch_target,
                       jal_target,
                       jr_target
                   }),
               .out(next_pc_without_exception)
           );

    reg [31:0] instruction_latched;
    reg instruction_latched_valid;
    always @(posedge clk) begin
        if (reset)
            instruction_latched_valid <= 0;
        else if (pre_IF_IF_reg_valid & inst_sram_data_ok) begin
            if (!pre_IF_IF_reg_allow_out) begin
                instruction_latched <= inst_sram_rdata;
                instruction_latched_valid <= 1;
            end else
                instruction_latched_valid <= 0;
        end else
            if (instruction_latched_valid &
                    IF_ID_reg_allow_out & IF_ID_reg_valid_out)
                instruction_latched_valid <= 0;
    end

    wire instruction_not_available =
         ~inst_sram_data_ok & pre_IF_IF_reg_valid;

    assign instruction_IF =
           (instruction_not_available & instruction_latched_valid) ?
           instruction_latched : inst_sram_rdata;

    assign pre_IF_IF_reg_stall_wait_for_data =
           instruction_not_available
           & ~instruction_latched_valid
           & ~(exception_IF & (exccode_IF == `EXC_AdEL
                               || exccode_IF == `EXC_TLBL));

    assign badvaddr_IF = curr_pc_IF;

    exception_combine
        refetch_as_exception(
            .exception_h(exception_IF_old),
            .exccode_h(exccode_IF_old),
            .exception_l(
                |{cacheop_i_ID, mtc0_ID, tlbwi_ID, tlbr_ID} & IF_ID_reg_valid
                | |{cacheop_i_EX, mtc0_EX, tlbwi_EX, tlbr_EX} & ID_EX_reg_valid
                | |{mtc0_MEM, tlbwi_MEM, tlbr_MEM} & EX_MEM_reg_valid
                | |{mtc0_WB, tlbwi_WB, tlbr_WB} & MEM_WB_reg_valid
            ),
            .exccode_l(`REFETCH),
            .exception_out(exception_IF),
            .exccode_out(exccode_IF)
        );


    //
    // ID Stage
    //

    assign opcode   = instruction_ID[31:26];
    assign rs       = instruction_ID[25:21];
    assign rt       = instruction_ID[20:16];
    assign rd       = instruction_ID[15:11];
    assign shamt_ID = instruction_ID[10:6];
    assign inst_imm = instruction_ID[15:0];
    assign func     = instruction_ID[5:0];

    control control_unit(
                .is_IF_ID_valid(IF_ID_reg_valid),
                .opcode(opcode),
                .func(func),
                .rt(rt),
                .rs(rs),

                .rs_data(rs_data_ID_compare),
                .rt_data(rt_data_ID_compare),

                .is_branch(is_branch_ID),
                .branch_or_jump(branch_or_jump_ID),

                .next_pc_is_next(next_pc_is_next),
                .next_pc_is_branch_target(next_pc_is_branch_target),
                .next_pc_is_jal_target(next_pc_is_jal_target),
                .next_pc_is_jr_target(next_pc_is_jr_target),

                .imm_is_sign_extend(imm_is_sign_extend),

                .is_mult(is_mult_ID),
                .is_multu(is_multu_ID),
                .is_div(is_div_ID),
                .is_divu(is_divu_ID),
                .lo_wen(lo_wen_ID),
                .hi_wen(hi_wen_ID),

                .alu_op(alu_op_ID),
                .alu_a_is_pc(alu_a_is_pc_ID),
                .alu_a_is_rs_data(alu_a_is_rs_data_ID),
                .alu_a_is_shamt(alu_a_is_shamt_ID),
                .alu_b_is_rt_data(alu_b_is_rt_data_ID),
                .alu_b_is_imm(alu_b_is_imm_ID),
                .alu_b_is_8(alu_b_is_8_ID),

                .overflow_en(overflow_en_ID),

                .is_result_alu(is_result_alu_ID),
                .is_result_lo(is_result_lo_ID),
                .is_result_hi(is_result_hi_ID),
                .is_result_product(is_result_product_ID),

                .mem_b(mem_b_ID),
                .mem_h(mem_h_ID),
                .mem_w(mem_w_ID),
                .mem_bu(mem_bu_ID),
                .mem_hu(mem_hu_ID),
                .mem_wl(mem_wl_ID),
                .mem_wr(mem_wr_ID),

                .mem_en(mem_en_ID),
                .mem_wen(mem_wen_ID),

                .cond_mov(cond_mov_ID),

                .reg_write(reg_write_ID),
                .reg_write_addr_is_rd(reg_write_addr_is_rd_ID),
                .reg_write_addr_is_rt(reg_write_addr_is_rt_ID),
                .reg_write_addr_is_31(reg_write_addr_is_31_ID),
                .reg_write_is_alu(reg_write_is_alu_ID),
                .reg_write_is_mem(reg_write_is_mem_ID),

                .mtc0(mtc0_ID),
                .mfc0(mfc0_ID),

                .exc_syscall(exc_syscall_ID),
                .exc_reserved(exc_reserved_ID),
                .exc_break(exc_break_ID),
                .eret(eret_ID),
                .tlbp(tlbp_ID),
                .tlbwi(tlbwi_ID),
                .tlbr(tlbr_ID),

                .cacheop_i(cacheop_i_ID),
                .cacheop_d(cacheop_d_ID),
                .cacheop_hit(cacheop_hit_ID),
                .cacheop_index(cacheop_index_ID),
                .cacheop_wb(cacheop_wb_ID)
            );

    always @(posedge clk) begin
        if (reset | IF_ID_reg_flush) begin
            is_delay_slot_ID <= 0;
        end else begin
            if (branch_or_jump_ID) begin
                is_delay_slot_ID <= 1;
            end else begin
                if (is_delay_slot_ID & leaving_ID) begin
                    is_delay_slot_ID <= 0;
                end
            end
        end
    end

    wire [31:0] rs_data_ID_no_forward;
    wire [31:0] rt_data_ID_no_forward;
    wire regfile_w_enable = reg_write_WB & MEM_WB_reg_valid & ~exception_WB;
    regfile regfile (
                .clk(clk),
                .r_addr1(rs),
                .r_data1(rs_data_ID_no_forward),
                .r_addr2(rt),
                .r_data2(rt_data_ID_no_forward),
                .w_enable(regfile_w_enable),
                .w_addr(reg_write_addr_WB),
                .w_data(reg_write_data_WB)
            );

    assign imm_ID = imm_is_sign_extend ? imm_sign_extended : {16'b0,inst_imm};

    imm_gen imm_gen(
                .inst_imm(inst_imm),
                .imm(imm_sign_extended)
            );

    wire rs_data_ID_is_no_forward;
    wire rs_data_ID_is_from_ex;
    wire rs_data_ID_is_from_mem;
    wire rs_data_ID_is_from_wb;

    mux_1h #(.num_port(4)) rs_data_mux(
               .select(
                   {
                       rs_data_ID_is_no_forward,
                       rs_data_ID_is_from_ex,
                       rs_data_ID_is_from_mem,
                       rs_data_ID_is_from_wb
                   }),
               .in(
                   {
                       rs_data_ID_no_forward,
                       result_not_product_EX,
                       reg_write_data_MEM,
                       reg_write_data_WB
                   }),
               .out(rs_data_ID)
           );

    mux_1h #(.num_port(3)) rs_data_compare_mux(
               .select(
                   {
                       ~((rs_data_ID_is_from_mem & reg_write_is_alu_MEM) | rs_data_ID_is_from_wb),
                       rs_data_ID_is_from_mem & reg_write_is_alu_MEM,
                       rs_data_ID_is_from_wb
                   }
               ),
               .in(
                   {
                       rs_data_ID_no_forward,
                       result_MEM,
                       reg_write_data_WB
                   }
               ),
               .out(rs_data_ID_compare)
           );

    wire rt_data_ID_is_no_forward;
    wire rt_data_ID_is_from_ex;
    wire rt_data_ID_is_from_mem;
    wire rt_data_ID_is_from_wb;

    mux_1h #(.num_port(4)) rt_data_mux(
               .select(
                   {
                       rt_data_ID_is_no_forward,
                       rt_data_ID_is_from_ex,
                       rt_data_ID_is_from_mem,
                       rt_data_ID_is_from_wb
                   }),
               .in(
                   {
                       rt_data_ID_no_forward,
                       result_not_product_EX,
                       reg_write_data_MEM,
                       reg_write_data_WB
                   }),
               .out(rt_data_ID)
           );

    mux_1h #(.num_port(3)) rt_data_compare_mux(
               .select(
                   {
                       ~((rt_data_ID_is_from_mem & reg_write_is_alu_MEM) | rt_data_ID_is_from_wb),
                       rt_data_ID_is_from_mem & reg_write_is_alu_MEM,
                       rt_data_ID_is_from_wb
                   }
               ),
               .in(
                   {
                       rt_data_ID_no_forward,
                       result_MEM,
                       reg_write_data_WB
                   }
               ),
               .out(rt_data_ID_compare)
           );

    forwarding forwarding_rs(
                   .r1(rs),
                   .reg_write_addr_EX(reg_write_addr_EX),
                   .reg_write_EX(reg_write_EX),
                   .reg_write_addr_MEM(reg_write_addr_MEM),
                   .reg_write_MEM(reg_write_MEM),
                   .reg_write_addr_WB(reg_write_addr_WB),
                   .reg_write_WB(reg_write_WB),
                   .r1_data_ID_is_no_forward(rs_data_ID_is_no_forward),
                   .r1_data_ID_is_from_ex(rs_data_ID_is_from_ex),
                   .r1_data_ID_is_from_mem(rs_data_ID_is_from_mem),
                   .r1_data_ID_is_from_wb(rs_data_ID_is_from_wb),
                   .is_ID_EX_valid(ID_EX_reg_valid),
                   .is_EX_MEM_valid(EX_MEM_reg_valid),
                   .is_MEM_WB_valid(MEM_WB_reg_valid)
               );

    forwarding forwarding_rt(
                   .r1(rt),
                   .reg_write_addr_EX(reg_write_addr_EX),
                   .reg_write_EX(reg_write_EX),
                   .reg_write_addr_MEM(reg_write_addr_MEM),
                   .reg_write_MEM(reg_write_MEM),
                   .reg_write_addr_WB(reg_write_addr_WB),
                   .reg_write_WB(reg_write_WB),
                   .r1_data_ID_is_no_forward(rt_data_ID_is_no_forward),
                   .r1_data_ID_is_from_ex(rt_data_ID_is_from_ex),
                   .r1_data_ID_is_from_mem(rt_data_ID_is_from_mem),
                   .r1_data_ID_is_from_wb(rt_data_ID_is_from_wb),
                   .is_ID_EX_valid(ID_EX_reg_valid),
                   .is_EX_MEM_valid(EX_MEM_reg_valid),
                   .is_MEM_WB_valid(MEM_WB_reg_valid)
               );

    hazard_detect hazard_detect(
                      .en(IF_ID_reg_valid),
                      .compare_in_ID(
                          |{
                              is_branch_ID,
                              next_pc_is_jal_target,
                              next_pc_is_jr_target,
                              cond_mov_ID
                          }),
                      .reg_write_is_mem_EX(reg_write_is_mem_EX),
                      .reg_write_is_mem_MEM(reg_write_is_mem_MEM),
                      .mem_wait_for_data(EX_MEM_reg_stall_wait_for_data),
                      .mfc0_EX(mfc0_EX),
                      .mfc0_MEM(mfc0_MEM),
                      .is_result_product_EX(is_result_product_EX),

                      .rs_data_ID_is_from_ex(rs_data_ID_is_from_ex),
                      .rt_data_ID_is_from_ex(rt_data_ID_is_from_ex),
                      .rs_data_ID_is_from_mem(rs_data_ID_is_from_mem),
                      .rt_data_ID_is_from_mem(rt_data_ID_is_from_mem),
                      .IF_ID_reg_stall(IF_ID_reg_stall_hazard)
                  );

    wire exc_interrupt;
    interrupt interrupt(
                  .cp0_cause_ip(cp0_cause_ip),
                  .cp0_status_im(cp0_status_im),
                  .cp0_status_ie(cp0_status_ie),
                  .cp0_status_exl(cp0_status_exl),
                  .exc_interrupt(exc_interrupt)
              );

    exception_multiple #(.NUM(5)) exception_multiple_ID(
                           .exception_old(exception_ID_old),
                           .exccode_old(exccode_ID_old),
                           .exceptions(
                               {
                                   exc_interrupt,
                                   exc_reserved_ID,
                                   eret_ID,
                                   exc_syscall_ID,
                                   exc_break_ID
                               }),
                           .exccodes(
                               {
                                   `EXC_Int,
                                   `EXC_RI,
                                   `ERET,
                                   `EXC_Sys,
                                   `EXC_Bp
                               }),
                           .exception_out(exception_ID),
                           .exccode_out(exccode_ID)
                       );

    branch_target_gen branch_target_gen(
                          // Use curr_pc_ID to calculate curr_pc_IF,
                          // as curr_pc_IF may not be valid now.
                          .pc(curr_pc_ID + 32'd4),
                          .offset(inst_imm),
                          .target(branch_target)
                      );


    //
    // EX Stage
    //

    wire [31:0] alu_result;
    wire overflow;

    wire [31:0] alu_address_out;
    alu alu(
            .op(alu_op_EX),
            .a(alu_a),
            .b(alu_b),
            .overflow(overflow),
            .result(alu_result),
            .address(alu_address_out)
        );

    mux_1h #(.num_port(3)) alu_a_mux(
               .select(
                   {
                       alu_a_is_rs_data_EX,
                       alu_a_is_shamt_EX,
                       alu_a_is_pc_EX
                   }),
               .in({
                       rs_data_EX,
                       {{27{1'b0}},
                        {shamt_EX[4:0]}},
                       curr_pc_EX
                   }),
               .out(alu_a)
           );
    mux_1h #(.num_port(3)) alu_b_mux(
               .select({alu_b_is_rt_data_EX, alu_b_is_imm_EX, alu_b_is_8_EX}),
               .in(    {rt_data_EX         , imm_EX         , 32'h8        }),
               .out(alu_b)
           );

    wire exc_overflow = overflow_en_EX & overflow;

    wire mult_div_complete;
    assign ID_EX_reg_stall_div_not_complete = ~mult_div_complete;
    wire [31:0] hi;
    wire [31:0] lo;
    wire [31:0] product;
    mult_div mult_div(
                 .clk(clk),
                 .en(~exception_EX_MEM_WB & ID_EX_reg_valid),
                 .reset(reset),
                 .is_mult(is_mult_EX),
                 .is_multu(is_multu_EX),
                 .is_div(is_div_EX),
                 .is_divu(is_divu_EX),
                 .hi_wen(hi_wen_EX),
                 .lo_wen(lo_wen_EX),
                 .rs_data(rs_data_EX),
                 .rt_data(rt_data_EX),
                 .hi(hi),
                 .lo(lo),
                 .product(product),
                 .complete(mult_div_complete)
             );

    mux_1h #(.num_port(3)) result_mux (
               .select({is_result_alu_EX, is_result_lo_EX, is_result_hi_EX}),
               .in(    {alu_result      , lo             , hi             }),
               .out(result_not_product_EX)
           );
    assign result_EX = is_result_product_EX ? product : result_not_product_EX;

    wire mem_addr_unaligned;
    wire [18:0] s1_vpn2_req;
    wire tlb_refill_d;
    wire tlb_error_d;
    wire tlb_mod;
    data_sram_request #
        (.TLB(TLB))
        data_sram_request(
            .data_sram_req(data_sram_req),
            .data_sram_cached(data_sram_cached),
            .data_sram_wr(data_sram_wr),
            .data_sram_size(data_sram_size),
            .data_sram_wstrb(data_sram_wstrb),
            .data_sram_addr(data_sram_addr),
            .data_sram_wdata(data_sram_wdata),
            .data_sram_addr_ok(data_sram_addr_ok),

            .inst_cacheop(inst_cacheop),
            .inst_cacheop_index(inst_cacheop_index),
            .inst_cacheop_hit(inst_cacheop_hit),
            .inst_cacheop_wb(inst_cacheop_wb),
            .inst_cacheop_addr(inst_cacheop_addr),
            .inst_cacheop_ok1(inst_cacheop_ok1),

            .data_cacheop(data_cacheop),
            .data_cacheop_index(data_cacheop_index),
            .data_cacheop_hit(data_cacheop_hit),
            .data_cacheop_wb(data_cacheop_wb),
            .data_cacheop_addr(data_cacheop_addr),
            .data_cacheop_ok1(data_cacheop_ok1),

            .mem_ren_EX(mem_en_EX),
            .mem_wen_EX(mem_wen_EX),

            .data(rt_data_EX),
            .virt_addr(alu_address_out),

            .ID_EX_reg_valid(ID_EX_reg_valid),
            .ID_EX_reg_allow_out(ID_EX_reg_allow_out),
            .exception_EX_MEM_WB(exception_EX_MEM_WB),
            .mem_w_EX(mem_w_EX),
            .mem_h_EX(mem_h_EX),
            .mem_b_EX(mem_b_EX),
            .mem_hu_EX(mem_hu_EX),
            .mem_bu_EX(mem_bu_EX),
            .mem_wl_EX(mem_wl_EX),
            .mem_wr_EX(mem_wr_EX),

            .mem_addr_unaligned(mem_addr_unaligned),
            .ID_EX_reg_stall_mem_not_ready(
                ID_EX_reg_stall_mem_not_ready
            ),
            .byte_offset_EX(byte_offset_EX),

            .vpn2(s1_vpn2_req),
            .odd_page(s1_odd_page),
            .pfn(s1_pfn),
            .found(s1_found),
            .v(s1_v),
            .d(s1_d),
            .c(s1_c),

            .tlb_refill(tlb_refill_d),
            .tlb_error(tlb_error_d),
            .tlb_mod(tlb_mod),

            .cacheop_i(cacheop_i_EX),
            .cacheop_d(cacheop_d_EX),
            .cacheop_index(cacheop_index_EX),
            .cacheop_hit(cacheop_hit_EX),
            .cacheop_wb(cacheop_wb_EX),

            .cp0_config_k0(cp0_config_k0)
        );
    assign s1_vpn2 = tlbp_EX ? cp0_entry_hi_vpn2 : s1_vpn2_req;
    assign tlbp_result_EX = {~s1_found, s1_index};

    assign badvaddr_EX = exception_EX_old ? badvaddr_EX_old : alu_result;

    exception_multiple #(.NUM(4))
                       EX_exceptions(
                           .exception_old(exception_EX_old),
                           .exccode_old(exccode_EX_old),
                           .exceptions(
                               {
                                   exc_overflow,
                                   mem_addr_unaligned,
                                   tlb_error_d,
                                   tlb_mod
                               }),
                           .exccodes(
                               {
                                   `EXC_Ov,
                                   mem_wen_EX ? `EXC_AdES : `EXC_AdEL,
                                   mem_wen_EX ? `EXC_TLBS : `EXC_TLBL,
                                   `EXC_MOD
                               }),
                           .exception_out(exception_EX),
                           .exccode_out(exccode_EX)
                       );
    assign tlb_refill_EX =
           exception_EX_old ? tlb_refill_EX_old : tlb_refill_d;
    assign tlb_error_vpn2_EX =
           exception_EX_old ? tlb_error_vpn2_EX_old : s1_vpn2;

    //
    // MEM Stage
    //

    assign EX_MEM_reg_stall_wait_for_data =
           EX_MEM_reg_valid &
           |{
               (data_sram_req_MEM & ~data_sram_data_ok),
               (data_cacheop_MEM & ~data_cacheop_ok2),
               (inst_cacheop_MEM & ~inst_cacheop_ok2)
           };

    mem_read mem_read(
                 .data_sram_rdata(data_sram_rdata),
                 .byte_offset(byte_offset_MEM),
                 .read_w(mem_w_MEM),
                 .read_b(mem_b_MEM),
                 .read_h(mem_h_MEM),
                 .read_bu(mem_bu_MEM),
                 .read_hu(mem_hu_MEM),
                 .mem_read_data(mem_read_data)
             );

    wire [31:0] lwl_merged;
    wire [31:0] lwr_merged;

    wire [31:0] mem_result;

    merge #(.left(1)) lwl_merge(
              .mem_word(mem_read_data),
              .reg_word(rt_data_MEM),
              .byte_addr(byte_offset_MEM),
              .merged_word(lwl_merged)
          );
    merge #(.left(0)) lwr_merge(
              .mem_word(mem_read_data),
              .reg_word(rt_data_MEM),
              .byte_addr(byte_offset_MEM),
              .merged_word(lwr_merged)
          );

    mux_1h #(.num_port(3)) mem_result_mux(
               .select(
                   {
                       mem_wl_MEM,
                       mem_wr_MEM,
                       ~mem_wl_MEM & ~mem_wr_MEM
                   }),
               .in(
                   {
                       lwl_merged,
                       lwr_merged,
                       mem_read_data
                   }),
               .out(mem_result)
           );

    mux_1h #(.num_port(2)) reg_write_data_mux(
               .select({reg_write_is_alu_MEM, reg_write_is_mem_MEM}),
               .in({result_MEM, mem_result}),
               .out(reg_write_data_MEM)
           );


    //
    // WB Stage
    //

    mux_1h #(.num_port(3), .data_width(5)) reg_write_addr_mux(
               .select(
                   {
                       reg_write_addr_is_rd_ID,
                       reg_write_addr_is_rt_ID,
                       reg_write_addr_is_31_ID
                   }),
               .in(
                   {
                       rd,
                       rt,
                       5'd31
                   }
               ),
               .out(reg_write_addr_ID)
           );

    wire [31:0] cp0_reg;
    wire cp0_reg_wen =
         mtc0_WB & MEM_WB_reg_valid & ~exception_WB;
    cp0 #(
            .TLBNUM(TLBNUM),
            .I_NUM_WAY(I_NUM_WAY),
            .I_BYTES_PER_LINE(I_BYTES_PER_LINE),
            .I_NUM_LINE(I_NUM_LINE),
            .D_NUM_WAY(D_NUM_WAY),
            .D_BYTES_PER_LINE(D_BYTES_PER_LINE),
            .D_NUM_LINE(D_NUM_LINE)
        ) cp0(
            .clk(clk),
            .reset(reset),
            .reg_num(cp0_reg_num_WB),
            .sel(cp0_reg_sel_WB),
            .reg_in(rt_data_WB),

            .wen(cp0_reg_wen),
            .exception_like(exception_WB & MEM_WB_reg_valid),
            .is_delay_slot(is_delay_slot_WB),
            .pc(curr_pc_WB),
            .interrupt(ext_int),
            .exccode(exccode_WB),
            .badvaddr_in(badvaddr_WB),
            .tlbp(tlbp_WB & ~exception_WB & MEM_WB_reg_valid),
            .tlbp_result(tlbp_result_WB),
            .tlbr(tlbr_WB & ~exception_WB & MEM_WB_reg_valid),
            .tlb_error_vpn2(tlb_error_vpn2_WB),

            .reg_out(cp0_reg),

            .epc(cp0_epc),
            .cause_ip(cp0_cause_ip),
            .status_im(cp0_status_im),
            .status_ie(cp0_status_ie),
            .status_exl(cp0_status_exl),
            .entry_hi_vpn2(cp0_entry_hi_vpn2),
            .entry_hi_asid(cp0_entry_hi_asid),
            .config_k0(cp0_config_k0),

            .exception_now(exception_now),
            .eret_now(eret_now),
            .refetch_now(refetch_now),

            .w_index(w_index),
            .w_vpn2(w_vpn2),
            .w_asid(w_asid),
            .w_g(w_g),
            .w_pfn0(w_pfn0),
            .w_c0(w_c0),
            .w_d0(w_d0),
            .w_v0(w_v0),
            .w_pfn1(w_pfn1),
            .w_c1(w_c1),
            .w_d1(w_d1),
            .w_v1(w_v1),

            .r_index(r_index),
            .r_vpn2(r_vpn2),
            .r_asid(r_asid),
            .r_g(r_g),
            .r_pfn0(r_pfn0),
            .r_c0(r_c0),
            .r_d0(r_d0),
            .r_v0(r_v0),
            .r_pfn1(r_pfn1),
            .r_c1(r_c1),
            .r_d1(r_d1),
            .r_v1(r_v1)
        );
    assign tlb_we = tlbwi_WB & ~exception_WB & MEM_WB_reg_valid;

    assign {
            pre_IF_IF_reg_flush,
            IF_ID_reg_flush,
            ID_EX_reg_flush,
            EX_MEM_reg_flush,
            MEM_WB_reg_flush
        } = {5{exception_like_now}};

    assign reg_write_data_WB =
           mfc0_WB ? cp0_reg : reg_write_data_WB_not_mfc0;

    assign debug_wb_pc = curr_pc_WB;
    assign debug_wb_rf_wen = {4{regfile_w_enable}};
    assign debug_wb_rf_wnum = reg_write_addr_WB;
    assign debug_wb_rf_wdata = reg_write_data_WB;
endmodule
