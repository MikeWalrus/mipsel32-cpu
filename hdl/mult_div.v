module mult_div(
        input clk,
        input is_mult,
        input is_multu,
        input is_div,
        input [31:0] a,
        input [31:0] b,
        output reg [31:0] hi,
        output reg [31:0] lo
    );
    wire [63:0] unsigned_product = a * b;
    wire [63:0] signed_product = $signed(a) * $signed(b);
    always @(posedge clk) begin
        if (is_mult)
            {hi, lo} <= signed_product;
        else if (is_multu)
            {hi, lo} <= unsigned_product;
    end
endmodule
