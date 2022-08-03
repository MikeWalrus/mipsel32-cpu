module tiny_branch_decode(
	input is_pre_IF_IF_valid,
	input [5:0] opcode,
	input [5:0] func,
	input [4:0] rt,
	output is_branch_branch_predict,
	output is_jr_branch_predict
);
    wire is_R_type = opcode == 6'b000000;
    wire is_j      = opcode == 6'b000010;
    wire is_jal    = opcode == 6'b000011;
    wire func_jalr  = func == 6'b001001;
    wire func_jr    = func == 6'b001000;
    wire is_REGIMM = opcode == 6'b000001;
    wire is_beq    = opcode == 6'b000100;
    wire is_bne    = opcode == 6'b000101;
    wire is_bgtz   = opcode == 6'b000111;
    wire is_bgez   = is_REGIMM && (rt == 5'b00001);
    wire is_bgezal = is_REGIMM && (rt == 5'b10001);
    wire is_blez   = opcode == 6'b000110;
    wire is_bltz   = is_REGIMM && (rt == 5'b00000);
    wire is_bltzal = is_REGIMM && (rt == 5'b10000);
	assign is_branch_branch_predict = is_pre_IF_IF_valid & |{
               is_beq,
               is_bne,
               is_bgtz,
               is_bgez,
               is_bgezal,
               is_blez,
               is_bltz,
               is_bltzal,
			   is_j,
			   is_jal,
			   is_R_type & func_jalr,
			   is_R_type & func_jr
		   };
	assign is_jr_branch_predict = is_R_type & (func_jalr | func_jr);
endmodule
