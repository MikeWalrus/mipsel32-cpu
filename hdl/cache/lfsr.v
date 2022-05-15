module lfsr #
    (
        parameter WIDTH = 4
    )
    (
        input clk,
        input reset,
        input en,
        input [WIDTH-1:0] seed,
        output [WIDTH-1:0] out
    );
    reg [WIDTH-1:0] lfsr_reg;
    wire [WIDTH-1:0] lfsr_reg_next;
    always @(posedge clk) begin
        if (reset)
            lfsr_reg <= seed;
        else if (en)
            lfsr_reg <= lfsr_reg_next;
    end
    assign out = lfsr_reg;

    // Generated using script/mlpoly_min_bits.py
    // and https://github.com/hayguen/mlpolygen.
    localparam [33*32-1:0] all_taps =
               {32'h1, 32'h1, 32'h3, 32'h5,
                32'h9, 32'h12, 32'h21, 32'h41,
                32'h8e, 32'h108, 32'h204, 32'h402,
                32'h829, 32'h100d, 32'h2015, 32'h4001,
                32'h8016, 32'h10004, 32'h20040, 32'h40013,
                32'h80004, 32'h100002, 32'h200001, 32'h400010,
                32'h80000d, 32'h1000004, 32'h2000023, 32'h4000013,
                32'h8000004, 32'h10000002, 32'h20000029, 32'h40000004,
                32'h80000062};
    localparam [WIDTH-1:0] taps = all_taps[32*(32-WIDTH) +: WIDTH];
    // verilator lint_off UNUSED
    wire [WIDTH-1:0] _taps = taps;
    // verilator lint_on UNUSED
    wire new_bit = ^(lfsr_reg & taps); // 0's don't affect the result of XOR
    assign lfsr_reg_next = {lfsr_reg[WIDTH-2:0], new_bit};
endmodule
