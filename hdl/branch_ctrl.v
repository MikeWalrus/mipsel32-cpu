module branch_ctrl(
        input en,
        input [5:0] opcode,
        input [4:0] rt,
        input [31:0] rs_data,
        input [31:0] rt_data,
        output take,
        output link
    );
    wire is_REGIMM = opcode == 6'b000001;

    wire is_beq    = opcode == 6'b000100;
    wire is_bne    = opcode == 6'b000101;
    wire is_bgtz   = opcode == 6'b000111;
    wire is_bgez   = is_REGIMM && (rt == 5'b00001);
    wire is_bgezal = is_REGIMM && (rt == 5'b10001);
    wire is_blez   = opcode == 6'b000110;
    wire is_bltz   = is_REGIMM && (rt == 5'b00000);
    wire is_bltzal = is_REGIMM && (rt == 5'b10000);

    wire bgez = is_bgez | is_bgezal;
    wire bltz = is_bltz | is_bltzal;

    wire eq = rs_data == rt_data;

    assign take = en &
           ((is_beq & eq)
            | (is_bne & ~eq)
            | (is_bgtz & ($signed(rs_data) > 0))
            | (bgez & ($signed(rs_data) >= 0))
            | (is_blez & ($signed(rs_data) <= 0))
            | (bltz & ($signed(rs_data) < 0))
           );

    assign link = en &
           |{is_bltzal,is_bgezal};
endmodule
