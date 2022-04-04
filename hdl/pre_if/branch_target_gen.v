module branch_target_gen(
        input [31:0] pc,
        input [15:0] offset,
        output [31:0] target
    );
    wire [31:0] sign_extended_imm;
    imm_gen imm_gen(
                .inst_imm(offset),
                .imm(sign_extended_imm)
            );
    assign target = pc + {sign_extended_imm[29:0], {2{1'b0}}};
endmodule
