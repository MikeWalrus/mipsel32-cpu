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
    reg [INDEX_WIDTH-1:0] req_buf_index;
    reg req_buf_write;
    reg [TAG_WIDTH-1:0] req_buf_tag;
    reg [OFFSET_WIDTH-1:0] req_buf_offset;
    reg [3:0] req_buf_wstrb;
    reg [31:0] req_buf_wdata;
    always @(posedge clk) begin
        req_buf_index <= index;
        req_buf_tag <= tag;
        req_buf_offset <= offset;
        req_buf_write <= write;
        req_buf_wstrb <= wstrb;
        req_buf_wdata <= wdata;
    end

    wire [NUM_WAY-1:0] hit_way_sel;
    wire [32*NUM_WAY-1:0] data_words;
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

        assign hit_way_sel[i] = v_read & tag_read == req_buf_tag;

        reg [NUM_LINE-1:0] d;
        wire d_we;
        wire d_write;
        wire d_read = d[index];
        always @(posedge clk) begin
            if (d_we)
                d[index] <= d_write;
        end

        wire [31:0] data [WORDS_PER_LINE-1:0];
        assign data_words[32*i +: 32] = data[req_buf_offset[3:2]];
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
                     .dout(data[j]),
                     .din(bank_write),
                     .we(we)
                 );
        end
    end

    wire hit = |hit_way_sel;

    wire [31:0] load_result;
    mux_1h #(.num_port(NUM_WAY)) load_result_mux
           (
               .select(hit_way_sel),
               .in(data_words),
               .out(load_result)
           );

    localparam STATE_NUM = 6;
    localparam STATE_BITS = $clog2(STATE_NUM);

    localparam [STATE_BITS-1:0] IDLE = 'd0;
    localparam [STATE_BITS-1:0] LOOKUP = 'd1;
    localparam [STATE_BITS-1:0] MISS = 'd2;
    localparam [STATE_BITS-1:0] DIRTY_MISS = 'd3;
    localparam [STATE_BITS-1:0] REPLACE = 'd4;
    localparam [STATE_BITS-1:0] REFILL = 'd5;

    reg [STATE_BITS-1:0] state;
    wire [STATE_BITS-1:0] next_state;
    always @(posedge clk) begin
        state <= next_state;
    end

    wire idle_to_idle = (state == IDLE) & (~valid /* TODO write_overlap */);
    wire idle_to_lookup = (state == IDLE) & ~idle_to_idle;

    wire lookup_to_lookup = (state == LOOKUP) & (hit & valid /* & TODO write_overlap */);
    wire lookup_to_idle = (state == LOOKUP) & (hit & ~lookup_to_lookup);
    wire lookup_to_miss = (state == LOOKUP) & (~hit /* TODO ~replace_dirty */);
    wire lookup_to_dirty_miss = (state == LOOKUP) & (~hit /* TODO replace_dirty */);

    wire miss_to_miss = (state == MISS) & ~rd_rdy;
    wire miss_to_refill = (state == MISS) & rd_rdy;

    wire dirty_miss_to_dirty_miss = (state == DIRTY_MISS) & ~wr_rdy;
    wire dirty_miss_to_replace = (state == DIRTY_MISS) & wr_rdy;

    wire replace_to_replace = (state == REPLACE) & ~rd_rdy;
    wire replace_to_refill = (state == REPLACE) & rd_rdy;

    wire refill_to_refill = (state == REFILL) & ~(ret_valid && (ret_last == 2'b1));
    wire refill_to_idle = (state == REFILL) & ~refill_to_refill;

    mux_1h #(.num_port(STATE_NUM), .data_width(STATE_BITS)) next_state_mux
           (
               .select(
                   {
                       idle_to_idle | lookup_to_idle | refill_to_idle,
                       idle_to_lookup | lookup_to_lookup,
                       lookup_to_miss | miss_to_miss,
                       lookup_to_dirty_miss | dirty_miss_to_dirty_miss,
                       dirty_miss_to_replace | replace_to_replace,
                       miss_to_refill | replace_to_refill | refill_to_refill
                   }),
               .in(
                   {
                       IDLE,
                       LOOKUP,
                       MISS,
                       DIRTY_MISS,
                       REPLACE,
                       REFILL
                   }),
               .out(next_state)
           );

endmodule
