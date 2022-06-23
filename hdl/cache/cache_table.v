module cache_table #
    (
        parameter NUM_WAY = 2,
        parameter BYTES_PER_LINE = 16,
        parameter NUM_LINE = 256,

        parameter OFFSET_WIDTH = $clog2(BYTES_PER_LINE),
        parameter INDEX_WIDTH = $clog2(NUM_LINE),
        parameter TAG_WIDTH = 32 - OFFSET_WIDTH - INDEX_WIDTH,
        parameter WORDS_PER_LINE = BYTES_PER_LINE / 4,
        parameter BANK_NUM_WIDTH = $clog2(WORDS_PER_LINE)
    )
    (
        input clk,

        input [TAG_WIDTH-1:0] tag, // next cycle
        input [INDEX_WIDTH-1:0] index,
        input [BANK_NUM_WIDTH-1:0] bank_num, // next cycle
        output [NUM_WAY-1:0] hit_way, // next cycle
        output [NUM_WAY-1:0] v_ways, // next cycle
        output [31:0] rdata,          // next cycle
        input [NUM_WAY-1:0] read_way,
        output [BYTES_PER_LINE*8-1:0] read_line, // next cycle
        output [TAG_WIDTH-1:0] read_tag, // next cycle

        input write,
        input [NUM_WAY-1:0] write_way,
        input [INDEX_WIDTH-1:0] write_index,
        input [BANK_NUM_WIDTH-1:0] write_bank_num,
        input [31:0] write_data,
        input [3:0] write_strb,

        input [NUM_WAY-1:0] d_write_way,
        input [INDEX_WIDTH-1:0] d_write_index,
        input d_write,
        input [INDEX_WIDTH-1:0] d_index,
        input [NUM_WAY-1:0] d_way,
        output dirty,

        input [NUM_WAY-1:0] tag_v_write_way,
        input [TAG_WIDTH-1:0] tag_write,
        input v_write
    );
    wire [WORDS_PER_LINE*32*NUM_WAY-1:0] read_lines;
    wire [(TAG_WIDTH*NUM_WAY)-1:0] read_tags;
    wire [32*NUM_WAY-1:0] word_all_ways;
    wire [NUM_WAY-1:0] dirty_ways;
    genvar i;
    genvar j;
    for (i = 0; i < NUM_WAY; i = i + 1) begin :way
        wire [TAG_WIDTH-1:0] tag_read;
        wire v_read;
        bram #(
                 .DEPTH(NUM_LINE),
                 .WIDTH(TAG_WIDTH + 1)
             ) tag_v (
                 .addr(index),
                 .clk(clk),
                 .din({tag_write, v_write}),
                 .dout({tag_read, v_read}),
                 .we(tag_v_write_way[i])
             );

        assign read_tags[i*TAG_WIDTH +: TAG_WIDTH] = tag_read;
        assign hit_way[i] = v_read & (tag_read == tag);
        assign v_ways[i] = v_read;

        reg [NUM_LINE-1:0] d;
        assign dirty_ways[i] = d[d_index];
        always @(posedge clk) begin
            if (d_write_way[i])
                d[d_write_index] <= d_write;
        end
        // TODO: remove this after implementing cache instructions
        integer n;
        initial begin
            for (n = 0; n < 2 ** INDEX_WIDTH; n = n + 1)
                d[n] = 0;
        end

        wire [31:0] bank_out [WORDS_PER_LINE-1:0];
        assign word_all_ways[32*i +: 32] = bank_out[bank_num];
        for (j = 0; j < WORDS_PER_LINE; j = j + 1) begin :bank
            wire bank_we = write & (write_bank_num == j) & write_way[i];
            bram #(
                     .DEPTH(NUM_LINE),
                     .WIDTH(32),
                     .WRITE_BYTE(1)
                 ) bank (
                     .addr(bank_we ? write_index : index),
                     .clk(clk),
                     .dout(bank_out[j]),
                     .din(write_data),
                     .we({4{bank_we}} & write_strb)
                 );
            assign read_lines[i*WORDS_PER_LINE*32 + j*32 +: 32] = bank_out[j];
        end
    end

    mux_1h #(.num_port(NUM_WAY)) rdata_mux
           (
               .select(hit_way),
               .in(word_all_ways),
               .out(rdata)
           );

    mux_1h #(.num_port(NUM_WAY), .data_width(1)) dirty_mux
           (
               .select(d_way),
               .in(dirty_ways),
               .out(dirty)
           );
    mux_1h #(.num_port(NUM_WAY), .data_width(WORDS_PER_LINE * 32)) line_mux
           (
               .select(read_way),
               .in(read_lines),
               .out(read_line)
           );
    mux_1h #(.num_port(NUM_WAY), .data_width(TAG_WIDTH)) tag_mux
           (
               .select(read_way),
               .in(read_tags),
               .out(read_tag)
           );
endmodule
