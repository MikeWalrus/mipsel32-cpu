module mycpu_top(
        input clk,
        input resetn,

        output inst_sram_en,
        output [3:0] inst_sram_wen,
        output [31:0] inst_sram_addr,
        output [31:0] inst_sram_wdata,
        input [31:0] inst_sram_rdata,

        output data_sram_en,
        output [3:0] data_sram_wen,
        output [31:0] data_sram_addr,
        output [31:0] data_sram_wdata,
        input [31:0] data_sram_rdata,

        output [31:0] debug_wb_pc,
        output [3:0] debug_wb_rf_wen,
        output [4:0] debug_wb_rf_wnum,
        output [31:0] debug_wb_rf_wdata
    );
    wire reset;
    assign reset = ~resetn;
    assign inst_sram_en = 1;

    // hack: delay one cycle
    reg start;
    always @(posedge clk) begin
        if (reset)
            start <= 0;
        else
            start <= 1;
    end

    wire mem_wen_ID;
    wire mem_wen_EX;

    // pc
    wire [31:0] curr_pc_IF;
    wire [31:0] curr_pc_ID;
    wire [31:0] curr_pc_EX;
    wire [31:0] curr_pc_MEM;
    (*MARK_DEBUG = "true"*) wire [31:0] curr_pc_WB;


    // instruction
    wire [31:0] instruction_IF = inst_sram_rdata;
    wire [31:0] instruction_ID;
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
    wire [31:0] rs_data_ID;
    wire [31:0] rt_data_ID;
    wire [31:0] rs_data_EX;
    wire [31:0] rt_data_EX;
    wire [31:0] rt_data_MEM;

    // control transfer
    wire [31:0] next_pc;

    wire next_pc_is_next;
    wire next_pc_is_branch_target;
    wire next_pc_is_jal_target;
    wire next_pc_is_jr_target;

    wire [31:0] jr_target = rs_data_ID; // jr, jalr
    wire [31:0] branch_target;          // b*
    wire [31:0] jal_target =            // jal, j
         {curr_pc_IF[31:28] ,instruction_ID[25:0], {2{1'b0}}};

    // signals that choose the result
    // from hi/lo or alu result
    wire [31:0] result_EX;
    wire [31:0] result_MEM;
    wire is_result_alu_ID;
    wire is_result_lo_ID;
    wire is_result_hi_ID;
    wire is_result_alu_EX;
    wire is_result_lo_EX;
    wire is_result_hi_EX;

    // alu
    wire [11:0] alu_op_ID;
    wire [11:0] alu_op_EX;

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
    wire [17:0] alu_ctrl_ID;
    wire [17:0] alu_ctrl_EX;
    assign alu_ctrl_ID = {
               alu_a_is_pc_ID,
               alu_a_is_rs_data_ID,
               alu_a_is_shamt_ID,
               alu_b_is_8_ID,
               alu_b_is_imm_ID,
               alu_b_is_rt_data_ID,
               alu_op_ID
           };
    assign {
            alu_a_is_pc_EX,
            alu_a_is_rs_data_EX,
            alu_a_is_shamt_EX,
            alu_b_is_8_EX,
            alu_b_is_imm_EX,
            alu_b_is_rt_data_EX,
            alu_op_EX
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
    wire [8:0] mult_div_ctrl_ID;
    wire [8:0] mult_div_ctrl_EX;
    assign mult_div_ctrl_ID = {
               is_div_ID,
               is_divu_ID,
               is_mult_ID,
               is_multu_ID,
               hi_wen_ID,
               lo_wen_ID,
               is_result_lo_ID,
               is_result_hi_ID,
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


    // register write
    wire reg_write_ID;
    wire reg_write_addr_is_rt_ID;
    wire reg_write_addr_is_rd_ID;
    wire reg_write_addr_is_31_ID;
    wire reg_write_is_alu_ID;
    wire reg_write_is_mem_ID;
    wire [4:0] reg_write_addr_ID;

    wire reg_write_EX;
    wire reg_write_is_alu_EX;
    wire reg_write_is_mem_EX; // for load-use hazard detection
    wire [4:0] reg_write_addr_EX;

    wire reg_write_MEM;
    wire reg_write_is_alu_MEM;
    wire reg_write_is_mem_MEM;
    wire [4:0] reg_write_addr_MEM;

    wire reg_write_WB;
    wire [4:0] reg_write_addr_WB;

    wire [31:0] reg_write_data_MEM;
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
            reg_write_data_WB
        } = reg_write_sig_WB;

    // pipeline registers control signals
    wire IF_ID_reg_valid_out;
    wire IF_ID_reg_allow_out;
    wire IF_ID_reg_stall;
    wire IF_ID_reg_valid;
    wire IF_ID_reg_allow_in;

    wire ID_EX_reg_valid_in = IF_ID_reg_valid_out;
    wire ID_EX_reg_valid_out;
    wire ID_EX_reg_allow_out;
    wire ID_EX_reg_stall;
    wire ID_EX_reg_valid;

    wire EX_MEM_reg_valid_in = ID_EX_reg_valid_out;
    wire EX_MEM_reg_valid_out;
    wire EX_MEM_reg_allow_out;
    wire EX_MEM_reg_stall = 0;
    wire EX_MEM_reg_valid;

    wire MEM_WB_reg_valid_in = EX_MEM_reg_valid_out;
    wire MEM_WB_reg_valid_out;
    wire MEM_WB_reg_allow_out = 1;
    wire MEM_WB_reg_stall = 0;
    wire MEM_WB_reg_valid;

    // pipeline registers
    pipeline_reg #(.WIDTH(32 + 32)) IF_ID_reg(
                     .clk(clk),
                     .reset(reset),
                     .stall(IF_ID_reg_stall),
                     .valid_in(start),
                     .allow_in(IF_ID_reg_allow_in),
                     .allow_out(IF_ID_reg_allow_out),
                     .valid_out(IF_ID_reg_valid_out),
                     .in({curr_pc_IF, instruction_IF}),
                     .out({curr_pc_ID, instruction_ID}),
                     .valid(IF_ID_reg_valid)
                 );

    pipeline_reg #(.WIDTH(32 + 32 + 32 + 32 +
                          18 + 8 + 1 +
                          5 + 9 + 7))
                 ID_EX_reg(
                     .clk(clk),
                     .reset(reset),
                     .stall(ID_EX_reg_stall),
                     .valid_in(ID_EX_reg_valid_in),
                     .allow_in(IF_ID_reg_allow_out),
                     .valid_out(ID_EX_reg_valid_out),
                     .allow_out(ID_EX_reg_allow_out),
                     .in(
                         {
                             curr_pc_ID, rs_data_ID, rt_data_ID, imm_ID,
                             alu_ctrl_ID, reg_write_sig_ID, mem_wen_ID,
                             shamt_ID, mult_div_ctrl_ID, mem_ctrl_ID
                         }),
                     .out(
                         {
                             curr_pc_EX, rs_data_EX, rt_data_EX, imm_EX,
                             alu_ctrl_EX, reg_write_sig_EX, mem_wen_EX,
                             shamt_EX, mult_div_ctrl_EX, mem_ctrl_EX
                         }),
                     .valid(ID_EX_reg_valid)
                 );

    pipeline_reg #(.WIDTH(32 + 8 + 32 + 2 + 7 + 32)) EX_MEM_reg(
                     .clk(clk),
                     .reset(reset),
                     .stall(EX_MEM_reg_stall),
                     .valid_in(EX_MEM_reg_valid_in),
                     .allow_in(ID_EX_reg_allow_out),
                     .valid_out(EX_MEM_reg_valid_out),
                     .allow_out(EX_MEM_reg_allow_out),
                     .in(
                         {
                             curr_pc_EX, reg_write_sig_EX,
                             result_EX, byte_offset_EX,
                             mem_ctrl_EX, rt_data_EX
                         }),
                     .out(
                         {
                             curr_pc_MEM, reg_write_sig_MEM,
                             result_MEM, byte_offset_MEM,
                             mem_ctrl_MEM, rt_data_MEM
                         }),
                     .valid(EX_MEM_reg_valid)
                 );

    pipeline_reg #(.WIDTH(32 + 38)) MEM_WB_reg(
                     .clk(clk),
                     .reset(reset),
                     .stall(MEM_WB_reg_stall),
                     .valid_in(MEM_WB_reg_valid_in),
                     .allow_in(EX_MEM_reg_allow_out),
                     .valid_out(MEM_WB_reg_valid_out),
                     .allow_out(MEM_WB_reg_allow_out),
                     .in({
                             curr_pc_MEM,
                             reg_write_MEM,
                             reg_write_addr_MEM,
                             reg_write_data_MEM
                         }),
                     .out(
                         {
                             curr_pc_WB,
                             reg_write_sig_WB
                         }),
                     .valid(MEM_WB_reg_valid)
                 );


    //
    // IF Stage
    //

    pc pc(
           .clk(clk),
           .reset(reset),
           .next(next_pc),
           .out(curr_pc_IF)
       );

    wire [31:0] next_pc_if_no_stall;
    assign next_pc = IF_ID_reg_allow_in ? next_pc_if_no_stall : curr_pc_IF;
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
               .out(next_pc_if_no_stall)
           );


    addr_trans addr_trans_inst(
                   .virt_addr(next_pc),
                   .phy_addr(inst_sram_addr)
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

    control control(
                .is_IF_ID_valid(IF_ID_reg_valid),
                .opcode(opcode),
                .func(func),
                .rt(rt),

                .rs_data(rs_data_ID),
                .rt_data(rt_data_ID),

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

                .is_result_alu(is_result_alu_ID),
                .is_result_lo(is_result_lo_ID),
                .is_result_hi(is_result_hi_ID),

                .mem_b(mem_b_ID),
                .mem_h(mem_h_ID),
                .mem_w(mem_w_ID),
                .mem_bu(mem_bu_ID),
                .mem_hu(mem_hu_ID),
                .mem_wl(mem_wl_ID),
                .mem_wr(mem_wr_ID),

                .data_sram_en(data_sram_en),
                .mem_wen(mem_wen_ID),

                .reg_write(reg_write_ID),
                .reg_write_addr_is_rd(reg_write_addr_is_rd_ID),
                .reg_write_addr_is_rt(reg_write_addr_is_rt_ID),
                .reg_write_addr_is_31(reg_write_addr_is_31_ID),
                .reg_write_is_alu(reg_write_is_alu_ID),
                .reg_write_is_mem(reg_write_is_mem_ID)
            );

    wire [31:0] rs_data_ID_no_forward;
    wire [31:0] rt_data_ID_no_forward;
    regfile regfile (
                .clk(clk),
                .r_addr1(rs),
                .r_data1(rs_data_ID_no_forward),
                .r_addr2(rt),
                .r_data2(rt_data_ID_no_forward),
                .w_enable(reg_write_WB & MEM_WB_reg_valid),
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
                       result_EX,
                       reg_write_data_MEM,
                       reg_write_data_WB
                   }),
               .out(rs_data_ID)
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
                       result_EX,
                       reg_write_data_MEM,
                       reg_write_data_WB
                   }),
               .out(rt_data_ID)
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
                      .reg_write_is_mem_EX(reg_write_is_mem_EX),
                      .rs_data_ID_is_from_ex(rs_data_ID_is_from_ex),
                      .rt_data_ID_is_from_ex(rt_data_ID_is_from_ex),
                      .IF_ID_reg_stall(IF_ID_reg_stall)
                  );


    //
    // EX Stage
    //

    branch_target_gen branch_target_gen(
                          .pc(curr_pc_IF),
                          .offset(inst_imm),
                          .target(branch_target)
                      );

    wire [31:0] alu_result;

    alu alu(
            .op(alu_op_EX),
            .a(alu_a),
            .b(alu_b),
            .result(alu_result)
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

    wire mult_div_complete;
    assign ID_EX_reg_stall = ~mult_div_complete;
    wire [31:0] hi;
    wire [31:0] lo;
    mult_div mult_div(
                 .clk(clk),
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
                 .complete(mult_div_complete)
             );

    mux_1h #(.num_port(3)) result_mux (
               .select({is_result_alu_EX, is_result_lo_EX, is_result_hi_EX}),
               .in(    {alu_result      , lo             , hi             }),
               .out(result_EX)
           );

    addr_trans addr_trans_data(
                   .virt_addr(result_EX),
                   .phy_addr(data_sram_addr)
               );
    assign byte_offset_EX = data_sram_addr[1:0];

    mem_wen_gen mem_wen_gen(
                    .byte_offset(byte_offset_EX),
                    .wen_1b(mem_wen_EX),
                    .write_b(mem_b_EX),
                    .write_h(mem_h_EX),
                    .write_w(mem_w_EX),
                    .swl(mem_wl_EX),
                    .swr(mem_wr_EX),
                    .wen_4b(data_sram_wen)
                );

    mem_write_data_gen mem_write_data_gen(
                           .data(rt_data_EX),
                           .write_b(mem_b_EX),
                           .write_h(mem_h_EX),
                           .write_w(mem_w_EX),
                           .swl(mem_wl_EX),
                           .swr(mem_wr_EX),
                           .byte_offset(byte_offset_EX),
                           .mem_write_data(data_sram_wdata)
                       );

    //
    // MEM Stage
    //

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

    mux_1h #(.num_port(2)) reg_write_data_mux(
               .select({reg_write_is_alu_MEM, reg_write_is_mem_MEM}),
               .in({result_MEM, mem_result}),
               .out(reg_write_data_MEM)
           );

    assign debug_wb_pc = curr_pc_WB;
    assign debug_wb_rf_wen = {4{reg_write_WB & MEM_WB_reg_valid}};
    assign debug_wb_rf_wnum = reg_write_addr_WB;
    assign debug_wb_rf_wdata = reg_write_data_WB;
endmodule
