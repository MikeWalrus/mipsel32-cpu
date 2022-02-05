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

    wire [3:0] data_sram_wen_ID;
    wire [3:0] data_sram_wen_EX;

    wire [31:0] instruction_IF = inst_sram_rdata;
    wire [31:0] instruction_ID;

    wire [11:0] alu_op_ID;

    wire [31:0] curr_pc_IF;
    wire [31:0] curr_pc_ID;
    wire [31:0] next_pc;

    wire next_pc_is_next;
    wire next_pc_is_branch_target;
    wire next_pc_is_jar_target;
    wire next_pc_is_jr_target;

    wire [31:0] rs_data_ID;
    wire [31:0] rt_data_ID;
    (*MARK_DEBUG = "TRUE"*) wire is_eq = rs_data_ID == rt_data_ID;


    wire [31:0] jr_target = rs_data_ID;
    wire [31:0] branch_target;
    wire [31:0] jar_target = {curr_pc_IF[31:28] ,instruction_ID[25:0], {2{1'b0}}};

    wire [5:0] opcode;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [4:0] shamt_ID;
    wire [15:0] inst_imm;
    wire [5:0] func;

    wire [31:0] imm_ID;
    wire [31:0] imm_EX;
    wire [31:0] imm_MEM;
    wire [31:0] imm_WB;

    wire [31:0] rs_data_EX;
    wire [31:0] rt_data_EX;

    wire [31:0] curr_pc_EX;
    wire [31:0] curr_pc_MEM;
    (*mark_debug = "true"*) wire [31:0] curr_pc_WB;

    wire [4:0]  shamt_EX;

    wire [31:0] alu_a;
    wire [31:0] alu_b;

    wire [31:0] alu_result_EX;
    wire [31:0] alu_result_MEM;
    wire [31:0] alu_result_WB;

    wire [11:0] alu_op_EX;

    wire alu_a_is_rs_data_ID;
    wire alu_a_is_rt_data_ID;
    wire alu_a_is_pc_ID;

    wire alu_a_is_rs_data_EX;
    wire alu_a_is_rt_data_EX;
    wire alu_a_is_pc_EX;

    wire alu_b_is_rt_data_ID;
    wire alu_b_is_imm_ID;
    wire alu_b_is_8_ID;
    wire alu_b_is_shamt_ID;

    wire alu_b_is_rt_data_EX;
    wire alu_b_is_imm_EX;
    wire alu_b_is_8_EX;
    wire alu_b_is_shamt_EX;

    wire [18:0] alu_ctrl_ID;
    wire [18:0] alu_ctrl_EX;

    wire [31:0] data_sram_rdata_MEM = data_sram_rdata;
    wire [31:0] data_sram_rdata_WB;

    wire reg_write_ID;
    wire reg_write_addr_is_rt_ID;
    wire reg_write_addr_is_rd_ID;
    wire reg_write_addr_is_31_ID;
    wire reg_write_is_alu_ID;
    wire reg_write_is_mem_ID;
    wire reg_write_is_imm_ID;

    wire [16:0] reg_write_sig_ID;
    wire [16:0] reg_write_sig_EX;
    wire [16:0] reg_write_sig_MEM;
    wire [16:0] reg_write_sig_WB;

    wire reg_write_WB;
    wire reg_write_addr_is_rt_WB;
    wire reg_write_addr_is_rd_WB;
    wire reg_write_addr_is_31_WB;
    wire reg_write_is_alu_WB;
    wire reg_write_is_mem_WB;
    wire reg_write_is_imm_WB;

    wire [4:0] rd_WB;
    wire [4:0] rt_WB;

    wire [31:0] reg_write_data;
    wire [4:0] reg_write_addr;

    // pipeline registers
    wire IF_ID_reg_valid_out;
    wire IF_ID_reg_allow_out;

    wire ID_EX_reg_valid_in = IF_ID_reg_valid_out;
    wire ID_EX_reg_valid_out;
    wire ID_EX_reg_allow_out;

    wire EX_MEM_reg_valid_in = ID_EX_reg_valid_out;
    wire EX_MEM_reg_valid_out;
    wire EX_MEM_reg_allow_out;

    wire MEM_WB_reg_valid_in = EX_MEM_reg_valid_out;
    wire MEM_WB_reg_valid_out;
    wire MEM_WB_reg_allow_out = 1;

    pc pc(
           .clk(clk),
           .reset(reset),
           .next(next_pc),
           .out(curr_pc_IF)
       );

    mux_1h #(.num_port(4)) next_pc_mux(
               .select({next_pc_is_next , next_pc_is_branch_target, next_pc_is_jar_target, next_pc_is_jr_target}),
               .in(    {curr_pc_IF+32'd4, branch_target           , jar_target           , jr_target           }),
               .out(next_pc)
           );


    addr_trans addr_trans_inst(
                   .virt_addr(next_pc),
                   .phy_addr(inst_sram_addr)
               );


    reg start;
    always @(posedge clk) begin
        if (reset)
            start <= 0;
        else
            start <= 1;
    end

    pipeline_reg #(.WIDTH(32 + 32)) IF_ID_reg(
                     .clk(clk),
                     .reset(reset),
                     .valid_in(start),
                     .allow_in(),
                     .allow_out(IF_ID_reg_allow_out),
                     .valid_out(IF_ID_reg_valid_out),
                     .in({curr_pc_IF, instruction_IF}),
                     .out({curr_pc_ID, instruction_ID})
                 );


    assign opcode   = instruction_ID[31:26];
    assign rs       = instruction_ID[25:21];
    assign rt       = instruction_ID[20:16];
    assign rd       = instruction_ID[15:11];
    assign shamt_ID = instruction_ID[10:6];
    assign inst_imm = instruction_ID[15:0];
    assign func     = instruction_ID[5:0];

    regfile regfile (
                .clk(clk),
                .r_addr1(rs),
                .r_data1(rs_data_ID),
                .r_addr2(rt),
                .r_data2(rt_data_ID),
                .w_enable(reg_write_WB & MEM_WB_reg_valid_out),
                .w_addr(reg_write_addr),
                .w_data(reg_write_data)
            );

    imm_gen imm_gen(
                .inst_imm(inst_imm),
                .imm(imm_ID)
            );


    pipeline_reg #(.WIDTH(32 + 32 + 32 + 32 + 19 + 17 + 4 + 5)) ID_EX_reg(
                     .clk(clk),
                     .reset(reset),
                     .valid_in(ID_EX_reg_valid_in),
                     .allow_in(IF_ID_reg_allow_out),
                     .valid_out(ID_EX_reg_valid_out),
                     .allow_out(ID_EX_reg_allow_out),
                     .in({curr_pc_ID, rs_data_ID, rt_data_ID, imm_ID, alu_ctrl_ID,
                          reg_write_sig_ID, data_sram_wen_ID, shamt_ID}),
                     .out({curr_pc_EX, rs_data_EX, rt_data_EX, imm_EX, alu_ctrl_EX,
                           reg_write_sig_EX, data_sram_wen_EX, shamt_EX})
                 );

    assign data_sram_wdata = rt_data_EX;

    branch_target_gen branch_target_gen(
                          .pc(curr_pc_IF),
                          .offset(inst_imm),
                          .target(branch_target)
                      );

    alu alu(
            .op(alu_op_EX),
            .a(alu_a),
            .b(alu_b),
            .result(alu_result_EX)
        );

    assign alu_ctrl_ID = {
               alu_a_is_pc_ID,
               alu_a_is_rs_data_ID,
               alu_a_is_rt_data_ID,
               alu_b_is_8_ID,
               alu_b_is_imm_ID,
               alu_b_is_shamt_ID,
               alu_b_is_rt_data_ID,
               alu_op_ID
           };
    assign {
            alu_a_is_pc_EX,
            alu_a_is_rs_data_EX,
            alu_a_is_rt_data_EX,
            alu_b_is_8_EX,
            alu_b_is_imm_EX,
            alu_b_is_shamt_EX,
            alu_b_is_rt_data_EX,
            alu_op_EX
        } = alu_ctrl_EX;

    mux_1h #(.num_port(3)) alu_a_mux(
               .select({alu_a_is_rs_data_EX, alu_a_is_rt_data_EX, alu_a_is_pc_EX}),
               .in(    {rs_data_EX         , rt_data_EX         , curr_pc_EX }),
               .out(alu_a)
           );
    mux_1h #(.num_port(4)) alu_b_mux(
               .select({alu_b_is_rt_data_EX, alu_b_is_imm_EX, alu_b_is_8_EX, alu_b_is_shamt_EX}),
               .in(    {rt_data_EX         , imm_EX         , 32'h8        , {{27{1'b0}}, {shamt_EX[4:0]}}}),
               .out(alu_b)
           );

    assign data_sram_wen = data_sram_wen_EX;
    addr_trans addr_trans_data(
                   .virt_addr(alu_result_EX),
                   .phy_addr(data_sram_addr)
               );

    pipeline_reg #(.WIDTH(32 + 17 + 32 + 32)) EX_MEM_reg(
                     .clk(clk),
                     .reset(reset),
                     .valid_in(EX_MEM_reg_valid_in),
                     .allow_in(ID_EX_reg_allow_out),
                     .valid_out(EX_MEM_reg_valid_out),
                     .allow_out(EX_MEM_reg_allow_out),
                     .in({curr_pc_EX, reg_write_sig_EX, alu_result_EX, imm_EX}),
                     .out({curr_pc_MEM, reg_write_sig_MEM, alu_result_MEM, imm_MEM})
                 );


    pipeline_reg #(.WIDTH(32 + 32 + 17 + 32 + 32)) MEM_WB_reg(
                     .clk(clk),
                     .reset(reset),
                     .valid_in(MEM_WB_reg_valid_in),
                     .allow_in(EX_MEM_reg_allow_out),
                     .valid_out(MEM_WB_reg_valid_out),
                     .allow_out(MEM_WB_reg_allow_out),
                     .in({curr_pc_MEM, data_sram_rdata_MEM, reg_write_sig_MEM, alu_result_MEM, imm_MEM}),
                     .out({curr_pc_WB, data_sram_rdata_WB, reg_write_sig_WB, alu_result_WB, imm_WB})
                 );


    assign reg_write_sig_ID = {
               reg_write_ID,
               reg_write_addr_is_rt_ID,
               reg_write_addr_is_rd_ID,
               reg_write_addr_is_31_ID,
               reg_write_is_alu_ID,
               reg_write_is_mem_ID,
               reg_write_is_imm_ID,
               rd,
               rt
           };
    assign {
            reg_write_WB,
            reg_write_addr_is_rt_WB,
            reg_write_addr_is_rd_WB,
            reg_write_addr_is_31_WB,
            reg_write_is_alu_WB,
            reg_write_is_mem_WB,
            reg_write_is_imm_WB,
            rd_WB,
            rt_WB
        } = reg_write_sig_WB;

    mux_1h #(.num_port(3), .data_width(5)) reg_write_addr_mux(
               .select({reg_write_addr_is_rd_WB, reg_write_addr_is_rt_WB, reg_write_addr_is_31_WB}),
               .in(    {rd_WB                  , rt_WB                  , 5'd31                  }),
               .out(reg_write_addr)
           );

    mux_1h #(.num_port(3)) reg_write_data_mux(
               .select({reg_write_is_alu_WB, reg_write_is_mem_WB, reg_write_is_imm_WB}),
               .in(    {alu_result_WB      , data_sram_rdata_WB , imm_WB             }),
               .out(reg_write_data)
           );


    control control(
                .is_IF_ID_valid(IF_ID_reg_valid_out),
                .opcode(opcode),
                .func(func),

                .is_eq(is_eq),

                .next_pc_is_next(next_pc_is_next),
                .next_pc_is_branch_target(next_pc_is_branch_target),
                .next_pc_is_jar_target(next_pc_is_jar_target),
                .next_pc_is_jr_target(next_pc_is_jr_target),

                .alu_op(alu_op_ID),
                .alu_a_is_pc(alu_a_is_pc_ID),
                .alu_a_is_rs_data(alu_a_is_rs_data_ID),
                .alu_a_is_rt_data(alu_a_is_rt_data_ID),
                .alu_b_is_rt_data(alu_b_is_rt_data_ID),
                .alu_b_is_imm(alu_b_is_imm_ID),
                .alu_b_is_8(alu_b_is_8_ID),
                .alu_b_is_shamt(alu_b_is_shamt_ID),

                .data_sram_en(data_sram_en),
                .data_sram_wen(data_sram_wen_ID),

                .reg_write(reg_write_ID),
                .reg_write_addr_is_rd(reg_write_addr_is_rd_ID),
                .reg_write_addr_is_rt(reg_write_addr_is_rt_ID),
                .reg_write_addr_is_31(reg_write_addr_is_31_ID),
                .reg_write_is_alu(reg_write_is_alu_ID),
                .reg_write_is_mem(reg_write_is_mem_ID),
                .reg_write_is_imm(reg_write_is_imm_ID)
            );

    assign debug_wb_pc = curr_pc_WB;
    assign debug_wb_rf_wen = {4{reg_write_WB & MEM_WB_reg_valid_out}};
    assign debug_wb_rf_wnum = reg_write_addr;
    assign debug_wb_rf_wdata = reg_write_data;
endmodule
