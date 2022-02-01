`include "alu.vh"
module control(
        input [5:0] opcode,
        input [5:0] func,

        input is_eq,
        input is_delay_slot,
        output is_delay_slot_next,
        input jar,
        output jar_next,
        input jr,
        output jr_next,

        output next_pc_is_next,
        output next_pc_is_target,
        output next_pc_is_jar_target,
        output next_pc_is_jr_target,

        output [11:0] alu_op,
        output alu_a_is_pc,
        output alu_a_is_rs_data,
        output alu_a_is_rt_data,

        output alu_b_is_rt_data,
        output alu_b_is_imm,
        output alu_b_is_8,
        output alu_b_is_shamt,

        output data_sram_en,
        output [3:0] data_sram_wen,

        output reg_write,
        output reg_write_addr_is_rd,
        output reg_write_addr_is_rt,
        output reg_write_addr_is_31,
        output reg_write_is_alu,
        output reg_write_is_mem,
        output reg_write_is_imm,

        input branch,
        output branch_next
    );
    wire data_sram_wen_1_bit;
    assign data_sram_wen = {4{data_sram_wen_1_bit}};


    wire is_R_type = opcode == 6'b000000;

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
    wire is_sb     = opcode == 6'b101000;
    wire is_sh     = opcode == 6'b101001;
    wire is_slti   = opcode == 6'b001010;
    wire is_sltiu  = opcode == 6'b001011;
    wire is_sw     = opcode == 6'b101011;
    wire is_j      = opcode == 6'b000010;
    wire is_jal    = opcode == 6'b000011;

    assign branch_next = (is_beq & is_eq) | (is_bne & ~is_eq);
    assign jar_next = is_jal;
    assign jr_next = is_R_type & func_jr;

    assign next_pc_is_target     = is_delay_slot & branch;
    assign next_pc_is_jar_target = is_delay_slot & jar;
    assign next_pc_is_jr_target  = is_delay_slot & jr;
    assign next_pc_is_next       =
           ~next_pc_is_target & ~next_pc_is_jar_target & ~next_pc_is_jr_target;

    assign is_delay_slot_next = is_beq | is_bne | is_jal | (is_R_type & func_jr);

    assign reg_write =
           (is_R_type)
           | is_addiu | is_lw | is_jal | is_lui;
    assign reg_write_addr_is_rd = is_R_type;
    assign reg_write_addr_is_31 = is_jal;
    assign reg_write_addr_is_rt = ~reg_write_addr_is_31 & ~reg_write_addr_is_rd;

    assign reg_write_is_mem = is_lw;
    assign reg_write_is_imm = 0;
    assign reg_write_is_alu = ~reg_write_is_mem & ~reg_write_is_imm;

    wire is_shift = is_R_type & (func_sll | func_srl | func_sra);

    assign alu_a_is_pc = is_jal;
    assign alu_a_is_rt_data = is_shift;
    assign alu_a_is_rs_data = ~alu_a_is_pc & ~alu_a_is_rt_data;

    assign alu_b_is_rt_data = is_R_type & ~is_shift;
    assign alu_b_is_imm     = is_addiu | is_sw | is_lw | is_lui;
    assign alu_b_is_8       = is_jal;
    assign alu_b_is_shamt   = is_shift;

    assign data_sram_en = 1;

    assign data_sram_wen_1_bit = is_sw;

    wire func_add   = func == 6'b000001;
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
    wire func_srl   = func == 6'b000010;
    wire func_sra   = func == 6'b000011;
    wire func_sub   = func == 6'b100010;
    wire func_subu  = func == 6'b100011;

    assign alu_op =
           {12{
                (is_R_type & (func_add | func_addu))
                | is_addiu | is_lw | is_sw | is_jal
            }} & `ALU_OP(`ALU_ADD) |
           {12{
                (is_R_type & func_subu)
            }} & `ALU_OP(`ALU_SUB) |
           {12{
                (is_R_type & func_slt)
            }} & `ALU_OP(`ALU_SLT) |
           {12{
                (is_R_type & func_sltu)
            }} & `ALU_OP(`ALU_SLTU)|
           {12{
                (is_R_type & func_sll)
            }} & `ALU_OP(`ALU_SLL) |
           {12{
                (is_R_type & func_srl)
            }} & `ALU_OP(`ALU_SRL) |
           {12{
                (is_R_type & func_sra)
            }} & `ALU_OP(`ALU_SRA) |
           {12{
                (is_lui)
            }} & `ALU_OP(`ALU_LUI) |
           {12{
                (is_R_type & func_or)
            }} & `ALU_OP(`ALU_OR)  |
           {12{
                (is_R_type & func_xor)
            }} & `ALU_OP(`ALU_XOR) |
           {12{
                (is_R_type & func_and)
            }} & `ALU_OP(`ALU_AND) |
           {12{
                (is_R_type & func_nor)
            }} & `ALU_OP(`ALU_NOR)
           ;
endmodule
