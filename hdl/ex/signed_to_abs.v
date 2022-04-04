module signed_to_abs #
(
    parameter WIDTH = 32
)
(
    input [WIDTH-1:0] num,
    output [WIDTH-1:0] abs_value,
    output sign
);
    assign sign = num[WIDTH-1];
    assign abs_value = sign ? -num : num;
endmodule
