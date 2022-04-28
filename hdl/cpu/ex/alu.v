`include "alu.vh"
module alu(
        input [11:0] op, // one-hot
        input [31:0] a,
        input [31:0] b,
        output overflow,
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
    wire signed_overflow = (adder_a[31] == adder_b[31])
         && (adder_a[31] != adder_out[31]);
    assign overflow = signed_overflow;

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

    wire bnegate = is_sub | is_slt | is_sltu;
    assign binvert = bnegate;
    assign cin = bnegate;

    wire [4:0] shamt = a[4:0];

    wire [31:0] sra_result = $signed(b) >>> shamt;

    mux_1h #(.num_port(11), .data_width(32)) result_mux(
               .select(
                   {
                       is_add | is_sub,
                       is_and,
                       is_slt,
                       is_sltu,
                       is_sll,
                       is_srl,
                       is_sra,
                       is_lui,
                       is_or,
                       is_xor,
                       is_nor
                   }),
               .in(
                   {
                       adder_out,
                       a & b,
                       {{31{1'b0}}, adder_out[31] ^ signed_overflow},
                       {{31{1'b0}}, ~cout},
                       (b << shamt),
                       (b >> shamt),
                       sra_result,
                       {b[15:0],{16{1'b0}}},
                       (a | b),
                       (a ^ b),
                       ~(a | b)
                   }
               ),
               .out(result)
           );
endmodule
