module mult_div(
        input clk,
        input en,
        input reset,
        input is_mult,
        input is_multu,
        input is_div,
        input is_divu,
        input hi_wen,
        input lo_wen,
        input [31:0] rs_data,
        input [31:0] rt_data,
        output reg [31:0] hi,
        output reg [31:0] lo,
        output [31:0] product,
        output complete
    );
    wire [63:0] unsigned_product = rs_data * rt_data;
    wire [63:0] signed_product = $signed(rs_data) * $signed(rt_data);
    assign product = signed_product[31:0];

    wire div_en = en & (is_div | is_divu);
    wire [31:0] quotient;
    wire [31:0] remainder;
    wire div_complete;
    assign complete = ~div_en | div_complete;

    div div(
            .clk(clk),
            .reset(reset),
            .en(div_en),
            .is_signed(is_div),
            .dividend(rs_data),
            .divisor(rt_data),
            .quotient(quotient),
            .remainder(remainder),
            .complete(div_complete)
        );


    always @(posedge clk) begin
        if (en) begin
            if (is_mult)
                {hi, lo} <= signed_product;
            else if (is_multu)
                {hi, lo} <= unsigned_product;
            else if (hi_wen)
                hi <= rs_data;
            else if (lo_wen)
                lo <= rs_data;
            else if (div_en) begin
                lo <= quotient;
                hi <= remainder;
            end
        end
    end
endmodule
