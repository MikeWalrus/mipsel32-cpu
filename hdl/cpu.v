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

    // control signals
    wire reg_write;
    wire [11:0] alu_op;

    wire [31:0] curr_pc;
    wire [31:0] next_pc;
    pc pc(
           .clk(clk),
           .reset(reset),
           .next(next_pc),
           .out(curr_pc)
       );

    wire next_pc_is_next;
    wire next_pc_is_target;
    wire next_pc_is_jar_target;
    wire next_pc_is_jr_target;
    mux_1h #(.num_port(4)) next_pc_mux(
               .select({next_pc_is_next, next_pc_is_target, next_pc_is_jar_target, next_pc_is_jr_target}),
               .in({curr_pc+32'd4, branch_target, jar_target, jr_target}),
               .out(next_pc)
           );

    reg is_delay_slot;
    reg branch;
    reg jar;
    reg jr;
    reg [31:0] prev_inst;
    reg [31:0] jr_target;
    wire branch_next;
    wire jar_next;
    wire jr_next;
    wire is_delay_slot_next;
    always @(posedge clk) begin
        if (reset) begin
            is_delay_slot <= 0;
            branch <= 0;
            jar <= 0;
            jr_target <= 0;
            jr <= 0;
        end
        else begin
            is_delay_slot <= is_delay_slot_next;
            branch <= branch_next;
            prev_inst <= instruction;
            jar <= jar_next;
            jr_target <= rs_data;
            jr <= jr_next;
        end
    end

    addr_trans addr_trans_inst(
                   .virt_addr(curr_pc),
                   .phy_addr(inst_sram_addr)
               );

    wire [31:0] instruction;
    assign instruction = inst_sram_rdata;

    wire [5:0] opcode;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [4:0] shamt;
    wire [15:0] inst_imm;
    wire [5:0] func;

    assign opcode   = instruction[31:26];
    assign rs       = instruction[25:21];
    assign rt       = instruction[20:16];
    assign rd       = instruction[15:11];
    assign shamt    = instruction[10:6];
    assign inst_imm = instruction[15:0];
    assign func     = instruction[5:0];

    wire [31:0] rs_data;
    wire [31:0] rt_data;
    wire [31:0] reg_write_data;
    wire [4:0] reg_write_addr;
    regfile regfile (
                .clk(clk),
                .r_addr1(rs),
                .r_data1(rs_data),
                .r_addr2(rt),
                .r_data2(rt_data),
                .w_enable(reg_write),
                .w_addr(reg_write_addr),
                .w_data(reg_write_data)
            );

    assign data_sram_wdata = rt_data;
    wire is_eq = rs_data == rt_data;

    wire [31:0] branch_target;
    branch_target_gen branch_target_gen(
                          .pc(curr_pc),
                          .offset(prev_inst[15:0]),
                          .target(branch_target)
                      );
    wire [31:0] jar_target = {curr_pc[31:28] ,prev_inst[25:0], {2{1'b0}}};

    wire [31:0] alu_a;
    wire [31:0] alu_b;
    wire [31:0] alu_result;
    alu alu(
            .op(alu_op),
            .a(alu_a),
            .b(alu_b),
            .result(alu_result)
        );
    wire alu_a_is_rs_data;
    wire alu_a_is_rt_data;
    wire alu_a_is_pc;
    mux_1h #(.num_port(3)) alu_a_mux(
               .select({alu_a_is_rs_data, alu_a_is_rt_data, alu_a_is_pc}),
               .in(    {rs_data         , rt_data         , curr_pc    }),
               .out(alu_a)
           );

    wire alu_b_is_rt_data;
    wire alu_b_is_imm;
    wire alu_b_is_8;
    wire alu_b_is_shamt;
    mux_1h #(.num_port(4)) alu_b_mux(
               .select({alu_b_is_rt_data , alu_b_is_imm , alu_b_is_8 , alu_b_is_shamt            }),
               .in(    {rt_data          , imm          , 32'h8      , {{27{1'b0}}, {shamt[4:0]}}}),
               .out(alu_b)
           );

    wire [31:0] imm;
    imm_gen imm_gen(
                .inst_imm(inst_imm),
                .imm(imm)
            );

    addr_trans addr_trans_data(
                   .virt_addr(alu_result),
                   .phy_addr(data_sram_addr)
               );

    wire reg_write_addr_is_rt;
    wire reg_write_addr_is_rd;
    wire reg_write_addr_is_31;
    mux_1h #(.num_port(3), .data_width(5)) reg_write_addr_mux(
               .select({reg_write_addr_is_rd, reg_write_addr_is_rt, reg_write_addr_is_31}),
               .in({rd, rt, 5'd31}),
               .out(reg_write_addr)
           );

    wire reg_write_is_alu;
    wire reg_write_is_mem;
    wire reg_write_is_imm;
    mux_1h #(.num_port(3)) reg_write_data_mux(
               .select({reg_write_is_alu , reg_write_is_mem , reg_write_is_imm}),
               .in(    {alu_result       , data_sram_rdata  , imm}),
               .out(reg_write_data)
           );

    control control(
                .opcode(opcode),
                .func(func),

                .is_eq(is_eq),
                .is_delay_slot(is_delay_slot),
                .is_delay_slot_next(is_delay_slot_next),
                .jar(jar),
                .jar_next(jar_next),
                .jr(jr),
                .jr_next(jr_next),

                .next_pc_is_next(next_pc_is_next),
                .next_pc_is_target(next_pc_is_target),
                .next_pc_is_jar_target(next_pc_is_jar_target),
                .next_pc_is_jr_target(next_pc_is_jr_target),

                .alu_op(alu_op),
                .alu_a_is_pc(alu_a_is_pc),
                .alu_a_is_rs_data(alu_a_is_rs_data),
                .alu_a_is_rt_data(alu_a_is_rt_data),
                .alu_b_is_rt_data(alu_b_is_rt_data),
                .alu_b_is_imm(alu_b_is_imm),
                .alu_b_is_8(alu_b_is_8),
                .alu_b_is_shamt(alu_b_is_shamt),

                .data_sram_en(data_sram_en),
                .data_sram_wen(data_sram_wen),

                .reg_write(reg_write),
                .reg_write_addr_is_rd(reg_write_addr_is_rd),
                .reg_write_addr_is_rt(reg_write_addr_is_rt),
                .reg_write_addr_is_31(reg_write_addr_is_31),
                .reg_write_is_alu(reg_write_is_alu),
                .reg_write_is_mem(reg_write_is_mem),
                .reg_write_is_imm(reg_write_is_imm),

                .branch(branch),
                .branch_next(branch_next)
            );

    assign debug_wb_pc = curr_pc;
    assign debug_wb_rf_wen = {4{reg_write}};
    assign debug_wb_rf_wnum = reg_write_addr;
    assign debug_wb_rf_wdata = reg_write_data;
endmodule
