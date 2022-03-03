`include "alu.vh"
module control(
        input is_IF_ID_valid,
        input [5:0] opcode,
        input [5:0] func,

        input is_eq,

        output next_pc_is_next,
        output next_pc_is_branch_target,
        output next_pc_is_jar_target,
        output next_pc_is_jr_target,

        output imm_is_sign_extend,

        output is_mult,
        output is_multu,
        output is_div,
        output is_divu,
        output lo_wen,
        output hi_wen,

        output [11:0] alu_op,
        output alu_a_is_pc,
        output alu_a_is_rs_data,
        output alu_a_is_shamt,

        output alu_b_is_rt_data,
        output alu_b_is_imm,
        output alu_b_is_8,

        output is_result_alu,
        output is_result_lo,
        output is_result_hi,

        output data_sram_en,
        output [3:0] data_sram_wen,

        output reg_write,
        output reg_write_addr_is_rd,
        output reg_write_addr_is_rt,
        output reg_write_addr_is_31,
        output reg_write_is_alu,
        output reg_write_is_mem
    );
    wire data_sram_wen_1_bit;
    assign data_sram_wen = {4{data_sram_wen_1_bit}};


    wire is_R_type = opcode == 6'b000000;
    wire imm_arith;

    wire is_addi   = opcode == 6'b001000;
    wire is_addiu  = opcode == 6'b001001;
    wire is_andi   = opcode == 6'b001100;
    wire is_beq    = opcode == 6'b000100;
    wire is_blez   = opcode == 6'b000110;
    wire is_bne    = opcode == 6'b000101;
    wire is_bgtz   = opcode == 6'b000111;
    wire is_lb     = opcode == 6'b100000;
    wire is_lbu    = opcode == 6'b100100;
    wire is_lhu    = opcode == 6'b100101;
    wire is_lui    = opcode == 6'b001111;
    wire is_lw     = opcode == 6'b100011;
    wire is_ori    = opcode == 6'b001101;
    wire is_xori   = opcode == 6'b001110;
    wire is_sb     = opcode == 6'b101000;
    wire is_sh     = opcode == 6'b101001;
    wire is_slti   = opcode == 6'b001010;
    wire is_sltiu  = opcode == 6'b001011;
    wire is_sw     = opcode == 6'b101011;
    wire is_j      = opcode == 6'b000010;
    wire is_jal    = opcode == 6'b000011;

    wire func_add   = func == 6'b100000;
    wire func_addu  = func == 6'b100001;
    wire func_and   = func == 6'b100100;
    wire func_div   = func == 6'b011010;
    wire func_divu  = func == 6'b011011;
    wire func_jalr  = func == 6'b001001;
    wire func_jr    = func == 6'b001000;
    wire func_mfhi  = func == 6'b010000;
    wire func_mthi  = func == 6'b010001;
    wire func_mflo  = func == 6'b010010;
    wire func_mtlo  = func == 6'b010011;
    wire func_mult  = func == 6'b011000;
    wire func_multu = func == 6'b011001;
    wire func_nor   = func == 6'b100111;
    wire func_xor   = func == 6'b100110;
    wire func_or    = func == 6'b100101;
    wire func_slt   = func == 6'b101010;
    wire func_sltu  = func == 6'b101011;
    wire func_sll   = func == 6'b000000;
    wire func_sllv  = func == 6'b000100;
    wire func_srl   = func == 6'b000010;
    wire func_srlv  = func == 6'b000110;
    wire func_sra   = func == 6'b000011;
    wire func_srav  = func == 6'b000111;
    wire func_sub   = func == 6'b100010;
    wire func_subu  = func == 6'b100011;

    assign next_pc_is_branch_target = is_IF_ID_valid & ((is_beq & is_eq) | (is_bne & ~is_eq));
    assign next_pc_is_jar_target    = is_IF_ID_valid & is_jal;
    assign next_pc_is_jr_target     = is_IF_ID_valid & is_R_type & func_jr;
    assign next_pc_is_next          =
           ~next_pc_is_branch_target & ~next_pc_is_jar_target & ~next_pc_is_jr_target;

    assign imm_arith =
           is_addiu | is_addi | is_slti | is_sltiu | is_lui |
           is_andi  | is_ori  | is_xori;

    assign imm_is_sign_extend = ~(is_andi | is_ori | is_xori);

    assign reg_write =
           (is_R_type)
           | is_lw | is_jal
           | imm_arith;
    assign reg_write_addr_is_rd = is_R_type;
    assign reg_write_addr_is_31 = is_jal;
    assign reg_write_addr_is_rt = ~reg_write_addr_is_31 & ~reg_write_addr_is_rd;

    assign reg_write_is_mem = is_lw;
    assign reg_write_is_alu = ~reg_write_is_mem;

    wire shift_const = is_R_type & (func_sll | func_srl | func_sra);

    assign alu_a_is_pc      = is_jal;
    assign alu_a_is_shamt = shift_const;
    assign alu_a_is_rs_data = ~alu_a_is_pc & ~alu_a_is_shamt;

    assign alu_b_is_rt_data = is_R_type;
    assign alu_b_is_imm     =
           is_sw | is_lw |
           imm_arith;
    assign alu_b_is_8       = is_jal;

    assign data_sram_en = 1;

    assign data_sram_wen_1_bit = is_sw;


    assign alu_op =
           {12{
                (is_R_type & (func_add | func_addu))
                | is_addiu | is_addi | is_lw | is_sw | is_jal
            }} & `ALU_OP(`ALU_ADD) |
           {12{
                (is_R_type & (func_subu | func_sub))
            }} & `ALU_OP(`ALU_SUB) |
           {12{
                (is_R_type & func_slt) | is_slti
            }} & `ALU_OP(`ALU_SLT) |
           {12{
                (is_R_type & func_sltu) | is_sltiu
            }} & `ALU_OP(`ALU_SLTU)|
           {12{
                (is_R_type & (func_sll | func_sllv))
            }} & `ALU_OP(`ALU_SLL) |
           {12{
                (is_R_type & (func_srl | func_srlv))
            }} & `ALU_OP(`ALU_SRL) |
           {12{
                (is_R_type & (func_sra | func_srav ))
            }} & `ALU_OP(`ALU_SRA) |
           {12{
                (is_lui)
            }} & `ALU_OP(`ALU_LUI) |
           {12{
                (is_R_type & func_or)
                | is_ori
            }} & `ALU_OP(`ALU_OR)  |
           {12{
                (is_R_type & func_xor)
                | is_xori
            }} & `ALU_OP(`ALU_XOR) |
           {12{
                (is_R_type & func_and)
                | is_andi
            }} & `ALU_OP(`ALU_AND) |
           {12{
                (is_R_type & func_nor)
            }} & `ALU_OP(`ALU_NOR)
           ;

    assign is_result_hi = is_R_type & func_mfhi;
    assign is_result_lo = is_R_type & func_mflo;
    assign is_result_alu = ~is_result_lo & ~ is_result_hi;

    assign is_mult = is_R_type & func_mult;
    assign is_multu = is_R_type & func_multu;
    assign is_div = is_R_type & func_div;
    assign is_divu = is_R_type & func_divu;

    assign lo_wen = is_R_type & func_mtlo;
    assign hi_wen = is_R_type & func_mthi;
endmodule
