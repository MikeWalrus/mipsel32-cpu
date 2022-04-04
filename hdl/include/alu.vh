`define ALU_ADD 0
`define ALU_SUB 1
`define ALU_SLT 2
`define ALU_SLTU 3 
`define ALU_AND 4
`define ALU_NOR 5
`define ALU_OR 6
`define ALU_XOR 7
`define ALU_SLL 8
`define ALU_SRL 9
`define ALU_SRA 10
`define ALU_LUI 11

// use it like 
// alu_op = `ALU_OP(`ALU_ADD);
`define ALU_OP(i) 1<<i
