module mem_wen_gen(
    input [1:0] byte_offset,
    input wen_1b,
    input write_b,
    input write_h,
    input write_w,
    output reg [3:0] wen_4b
);
    wire halfword_offset = byte_offset[1];
    always @(*) begin
        if (wen_1b) begin
            wen_4b = {4{1'b0}};
            if (write_b) begin
                wen_4b[byte_offset] = 1'b1;
            end else if (write_h) begin
                wen_4b[halfword_offset*2 +: 2] = 2'b11;
            end else if (write_w) begin
                wen_4b = 4'b1111;
            end
        end else begin
            wen_4b = {4{1'b0}};
        end
    end
endmodule
