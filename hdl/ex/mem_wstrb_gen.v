module mem_wstrb_gen(
        input [1:0] byte_offset,
        input wen_1b,
        input write_b,
        input write_h,
        input write_w,
        input swl,
        input swr,
        output reg [3:0] wstrb
    );
    wire halfword_offset = byte_offset[1];

    genvar i;
    for (i = 0; i < 4; i = i + 1) begin: l
        wire [3:0] wen = 4'b1111 >> (3 - i);
    end
    wire [3:0] swl_wen [3:0];
    for (i = 0; i < 4; i = i + 1) begin
        assign swl_wen[i] = l[i].wen;
    end

    for (i = 0; i < 4; i = i + 1) begin: r
        wire [3:0] wen = 4'b1111 << i;
    end
    wire [3:0] swr_wen [3:0];
    for (i = 0; i < 4; i = i + 1) begin
        assign swr_wen[i] = r[i].wen;
    end

    always @(*) begin
        if (wen_1b) begin
            wstrb = {4{1'b0}};
            if (write_b) begin
                wstrb[byte_offset] = 1'b1;
            end else if (write_h) begin
                wstrb[halfword_offset*2 +: 2] = 2'b11;
            end else if (write_w) begin
                wstrb = 4'b1111;
            end else if (swl) begin
                wstrb = swl_wen[byte_offset];
            end else if (swr) begin
                wstrb = swr_wen[byte_offset];
            end
        end else begin
            wstrb = {4{1'b0}};
        end
    end
endmodule
