module extend #
(
    parameter in_width = 8,
    parameter out_width = 32,
    parameter sign_extend = 1
)
(
    input [in_width-1:0] in,
    output [out_width-1:0] out
);
    localparam extend_width = out_width - in_width;
    wire extend_bit;
    if (sign_extend)
        assign extend_bit = in[in_width-1];
    else
        assign extend_bit = 0;
    assign out = {{extend_width{extend_bit}}, in};
endmodule
