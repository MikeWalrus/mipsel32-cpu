module imm_gen #
    (
        parameter input_width = 16,
        parameter output_width = 32
    )
    (
        input [input_width - 1:0] inst_imm,
        output [output_width - 1:0] imm
    );
    assign imm = {{output_width-input_width{inst_imm[input_width-1]}}, inst_imm};
endmodule
