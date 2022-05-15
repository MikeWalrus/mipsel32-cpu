module bin_to_1h #
    (
        parameter OUTPUT_WIDTH = 2,
        parameter INPUT_WIDTH = $clog2(OUTPUT_WIDTH)
    )
    (
        input [INPUT_WIDTH-1:0] binary,
        output [OUTPUT_WIDTH-1:0] one_hot
    );
    genvar i;
    for (i = 0; i < OUTPUT_WIDTH; i = i + 1) begin
        assign one_hot[i] = binary == i;
    end
endmodule
