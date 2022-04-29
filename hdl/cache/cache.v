module cache #
    (
        parameter NUM_WAY = 2,
        parameter BYTES_PER_LINE = 16,
        parameter NUM_LINE = 256, // must <= 256 if VIPT

        parameter OFFSET_WIDTH = $clog2(BYTES_PER_LINE),
        parameter INDEX_WIDTH = $clog2(NUM_LINE),
        parameter TAG_WIDTH = 32 - OFFSET_WIDTH - INDEX_WIDTH,
        parameter WORDS_PER_LINE = BYTES_PER_LINE / 4
    )
    (
        input clk,
        input reset,
        input valid,
        input write,
        input [INDEX_WIDTH-1:0] index,
        input [TAG_WIDTH-1:0] tag,
        input [OFFSET_WIDTH-1:0] offset,
        input [3:0] wstrb,
        input [31:0] wdata,

        output addr_ok,
        output data_ok,
        output [31:0] rdata,

        output rd_req,
        output [2:0] rd_type, // byte: 000, halfword: 010, word: 100
        output [31:0] rd_addr,
        input rd_rdy,
        input ret_valid,
        input [1:0] ret_last,
        input [31:0] ret_data,

        output wr_req,
        output [2:0] wr_type,
        output [31:0] wr_addr,
        output [3:0] wr_wstrb,
        output [BYTES_PER_LINE*8-1:0] wr_data,
        input wr_rdy
    );
    genvar i;
    genvar j;
    for (i = 0; i < NUM_WAY; i = i + 1) begin :way
        wire [TAG_WIDTH-1:0] tag_write;
        wire v_write;
        wire [TAG_WIDTH-1:0] tag_read;
        wire v_read;
        wire tag_v_we;
        bram #(
                 .DEPTH(NUM_LINE),
                 .WIDTH(TAG_WIDTH + 1)
             ) tag_v (
                 .addr(index),
                 .clk(clk),
                 .din({tag_write, v_write}),
                 .dout({tag_read, v_read}),
                 .we(tag_v_we)
             );

        reg [NUM_LINE-1:0] d;
        wire d_we;
        wire d_write;
        wire d_read = d[index];
        always @(posedge clk) begin
            if (d_we)
                d[index] <= d_write;
        end

        for (j = 0; j < WORDS_PER_LINE; j = j + 1) begin :bank
            wire [31:0] bank_read;
            wire [31:0] bank_write;
            wire [3:0] we;
            bram #(
                     .DEPTH(NUM_LINE),
                     .WIDTH(32),
                     .WRITE_BYTE(1)
                 ) bank (
                     .addr(index),
                     .clk(clk),
                     .dout(bank_read),
                     .din(bank_write),
                     .we(we)
                 );
        end
    end
endmodule
