`include "alu.vh"
module alu(
        input [11:0] op, // one-hot
        input [31:0] a,
        input [31:0] b,
        output [31:0] result
    );
    wire cin;
    wire cout;
    wire binvert;

    wire [31:0] adder_out;
    wire [31:0] adder_a;
    wire [31:0] adder_b;

    assign adder_a = a;
    assign adder_b = binvert ? ~b : b;
    assign {cout, adder_out} = adder_a + adder_b + {{32{1'b0}},cin};
    wire signed_overflow = (a[31] != b[31]) && (a[31] != adder_out[31]);

    wire is_add  = op[`ALU_ADD];
    wire is_sub  = op[`ALU_SUB];
    wire is_and  = op[`ALU_AND];
    wire is_slt  = op[`ALU_SLT];
    wire is_sltu = op[`ALU_SLTU];
    wire is_sll  = op[`ALU_SLL];
    wire is_srl  = op[`ALU_SRL];
    wire is_sra  = op[`ALU_SRA];
    wire is_lui  = op[`ALU_LUI];
    wire is_or   = op[`ALU_OR];
    wire is_xor  = op[`ALU_XOR];
    wire is_nor  = op[`ALU_NOR];

    wire bnegate = (is_sub | is_slt | is_sltu) ? 1 : 0;
    assign binvert = bnegate;
    assign cin = bnegate;

    wire [31:0] sra_result = $signed(b) >>> a;

    assign result =
           ({32{is_add|is_sub}} & adder_out) |
           ({32{is_and}}        & (a & b)) |
           ({32{is_slt}}        & {{31{1'b0}}, adder_out[31] ^ signed_overflow}) |
           ({32{is_sltu}}       & {{31{1'b0}}, ~cout}) |
           ({32{is_sll}}        & (b << a)) |
           ({32{is_srl}}        & (b >> a)) |
           ({32{is_sra}}        & sra_result) |
           ({32{is_lui}}        & {b[15:0],{16{1'b0}}}) |
           ({32{is_or}}         & (a | b)) |
           ({32{is_xor}}        & (a ^ b)) |
           ({32{is_nor}}        & ~(a | b))
           ;

endmodule
