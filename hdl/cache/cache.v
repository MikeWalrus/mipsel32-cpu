module cache #
    (
        parameter NUM_WAY = 2,
        parameter BYTES_PER_LINE = 16,
        parameter NUM_LINE = 256, // must <= 256 if VIPT

        parameter OFFSET_WIDTH = $clog2(BYTES_PER_LINE),
        parameter INDEX_WIDTH = $clog2(NUM_LINE),
        parameter TAG_WIDTH = 32 - OFFSET_WIDTH - INDEX_WIDTH,
        parameter WORDS_PER_LINE = BYTES_PER_LINE / 4,
        parameter BANK_NUM_WIDTH = $clog2(WORDS_PER_LINE)
    )
    (
        input clk,
        input reset,
        input valid,
        input write,
        input uncached,
        input [INDEX_WIDTH-1:0] index,
        input [TAG_WIDTH-1:0] tag,
        input [OFFSET_WIDTH-1:0] offset,
        input [3:0] wstrb,
        input [31:0] wdata,

        output addr_ok,
        output burst,
        output data_ok,
        output [31:0] rdata,

        output rd_req,
        output [31:0] rd_addr,
        input rd_rdy,
        input ret_valid,
        input ret_last,
        input [31:0] ret_data,

        output wr_req,
        output [31:0] wr_addr,
        output [BYTES_PER_LINE*8-1:0] wr_data,
        input wr_rdy
    );
    function [BANK_NUM_WIDTH-1:0] get_bank_num(
            // verilator lint_off UNUSED
            input [OFFSET_WIDTH-1:0] byte_offset
            // verilator lint_on UNUSED
        );
        get_bank_num = byte_offset[2+:BANK_NUM_WIDTH];
    endfunction

    localparam STATE_NUM = 6;
    localparam STATE_BITS = $clog2(STATE_NUM);
    reg [STATE_BITS-1:0] state;
    wire [STATE_BITS-1:0] state_next;

    localparam [STATE_BITS-1:0] IDLE = 'd0;
    localparam [STATE_BITS-1:0] LOOKUP = 'd1;
    localparam [STATE_BITS-1:0] MISS = 'd2;
    localparam [STATE_BITS-1:0] DIRTY_MISS = 'd3;
    localparam [STATE_BITS-1:0] REPLACE = 'd4;
    localparam [STATE_BITS-1:0] REFILL = 'd5;

    wire [BANK_NUM_WIDTH-1:0] bank_num = get_bank_num(offset);

    // request buffer
    reg [INDEX_WIDTH-1:0] req_buf_index;
    reg [OFFSET_WIDTH-1:0] req_buf_offset;
    wire [BANK_NUM_WIDTH-1:0] req_buf_bank_num = get_bank_num(req_buf_offset);
    reg req_buf_write;
    reg [TAG_WIDTH-1:0] req_buf_tag;
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

    // cache table
    wire [NUM_WAY-1:0] hit_way;
    wire [NUM_WAY-1:0] v_ways;

    wire [NUM_WAY-1:0] d_write_way;
    wire [INDEX_WIDTH-1:0] d_write_index;
    wire d_write;
    wire [INDEX_WIDTH-1:0] d_index;
    wire [NUM_WAY-1:0] d_way;
    wire dirty;

    wire [NUM_WAY-1:0] tag_v_write_way;
    wire [TAG_WIDTH-1:0] tag_write;
    wire v_write;

    wire [31:0] table_rdata;
    wire [INDEX_WIDTH-1:0] table_index;
    wire [TAG_WIDTH-1:0] table_tag;
    wire [BANK_NUM_WIDTH-1:0] table_bank_num;
    wire [NUM_WAY-1:0] read_way;
    wire [BYTES_PER_LINE*8-1:0] read_line;
    wire [TAG_WIDTH-1:0] read_tag;

    wire table_write;
    wire [INDEX_WIDTH-1:0] table_write_index;
    wire [NUM_WAY-1:0] table_write_way;
    wire [BANK_NUM_WIDTH-1:0] table_write_bank_num;
    wire [31:0] table_write_data;
    wire [3:0] table_write_strb;
    cache_table
        #(
            .NUM_WAY(NUM_WAY),
            .BYTES_PER_LINE(BYTES_PER_LINE),
            .NUM_LINE(NUM_LINE)
        ) cache_table (
            .clk(clk),

            .tag(table_tag),
            .index(table_index),
            .bank_num(table_bank_num),
            .hit_way(hit_way),
            .v_ways(v_ways),
            .rdata(table_rdata),
            .read_way(read_way),
            .read_line(read_line),
            .read_tag(read_tag),

            .write(table_write),
            .write_way(table_write_way),
            .write_index(table_write_index),
            .write_bank_num(table_write_bank_num),
            .write_data(table_write_data),
            .write_strb(table_write_strb),

            .d_write_way(d_write_way),
            .d_write_index(d_write_index),
            .d_write(d_write),
            .d_way(d_way),
            .d_index(d_index),
            .dirty(dirty),

            .tag_v_write_way(tag_v_write_way),
            .tag_write(tag_write),
            .v_write(v_write)
        );

    wire hit = |hit_way & (state == LOOKUP);
    wire hit_write = hit & req_buf_write;

    // write buffer
    reg [NUM_WAY-1:0] write_buf_way; // one-hot
    reg [INDEX_WIDTH-1:0] write_buf_index;
    reg [3:0] write_buf_wstrb;
    reg [31:0] write_buf_wdata;
    reg [BANK_NUM_WIDTH-1:0] write_buf_bank_num;
    always @(posedge clk) begin
        write_buf_way <= hit_way;
        write_buf_index <= req_buf_index;
        write_buf_wstrb <= req_buf_wstrb;
        write_buf_wdata <= req_buf_wdata;
        write_buf_bank_num <= req_buf_bank_num;
    end

    // write buffer FSM
    reg write_buf_idle;
    wire write_buf_idle_next = ~hit_write;
    always @(posedge clk) begin
        if (reset)
            write_buf_idle <= 1;
        else
            write_buf_idle <= write_buf_idle_next;
    end

    // write buffer hazard
    wire write_overlap = write & hit_write & (req_buf_bank_num == bank_num);
    wire [3:0] forword_byte_from_write_buffer =
         {4{hit & ~write_buf_idle
            & (write_buf_index == req_buf_index)
            & (write_buf_way == hit_way)
            & (write_buf_bank_num == req_buf_bank_num)}}
         & write_buf_wstrb;

    // main FSM
    always @(posedge clk) begin
        if (reset)
            state <= IDLE;
        else
            state <= state_next;
    end

    wire idle_to_idle = (state == IDLE) & (~valid | write_overlap);
    wire idle_to_lookup = (state == IDLE) & ~idle_to_idle;

    wire lookup_to_lookup = (state == LOOKUP) & (hit & valid & ~write_overlap);
    wire lookup_to_idle = (state == LOOKUP) & (hit & ~lookup_to_lookup);
    wire lookup_to_miss = (state == LOOKUP) & (~hit & ~dirty);
    wire lookup_to_dirty_miss = (state == LOOKUP) & (~hit & dirty);

    wire miss_to_miss = (state == MISS) & ~rd_rdy;
    wire miss_to_refill = (state == MISS) & rd_rdy;

    wire dirty_miss_to_dirty_miss = (state == DIRTY_MISS) & ~wr_rdy;
    wire dirty_miss_to_replace = (state == DIRTY_MISS) & wr_rdy;

    wire replace_to_replace = (state == REPLACE) & ~rd_rdy;
    wire replace_to_refill = (state == REPLACE) & rd_rdy;

    wire refill_to_refill = (state == REFILL) & ~(ret_valid && (ret_last));
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
               .out(state_next)
           );
    ////
    // LOOKUP
    // hit: Select the correct bytes.
    // miss: Check whether the line to replace is dirty.
    ////
    genvar i;
    wire [31:0] lookup_rdata;
    for (i = 0; i < 4; i = i + 1) begin
        assign lookup_rdata[i*8+:8] = forword_byte_from_write_buffer[i] ?
               write_buf_wdata[i*8+:8] : table_rdata[i*8+:8];
    end

    wire [NUM_WAY-1:0] replace_way;
    replace_way_gen #(.NUM_WAY(NUM_WAY)) replace_way_gen(
                        .clk(clk),
                        .reset(reset),
                        .en(state == LOOKUP && ~hit), // update lfsr on miss
                        .v_ways(v_ways),
                        .replace_way(replace_way)
                    );

    // D table read ports
    assign d_way = replace_way;
    assign d_index = req_buf_index;

    // replace buffer
    reg [INDEX_WIDTH-1:0] replace_buf_index;
    reg [TAG_WIDTH-1:0] replace_buf_tag_new;
    reg [NUM_WAY-1:0] replace_buf_replace_way;
    reg [OFFSET_WIDTH-1:0] replace_buf_offset;
    reg replace_buf_write;
    reg [31:0] replace_buf_wdata;
    reg [3:0] replace_buf_wstrb;
    wire [BANK_NUM_WIDTH-1:0] replace_buf_bank_num =
         get_bank_num(replace_buf_offset);
    always @(posedge clk) begin
        if (state == LOOKUP) begin
            replace_buf_index <= req_buf_index;
            replace_buf_tag_new <= req_buf_tag;
            replace_buf_replace_way <= replace_way;
            replace_buf_offset <= req_buf_offset;
            replace_buf_write <= req_buf_write;
            replace_buf_wdata <= req_buf_wdata;
            replace_buf_wstrb <= req_buf_wstrb;
        end
    end

    ////
    // DIRTY_MISS
    // Read the cache table with the contents of the replace buffer.
    ////

    ////
    // REPLACE
    // Output the cache line that needs to be replaced.
    ////
    assign wr_data = read_line;
    assign wr_addr = {
               read_tag,
               replace_buf_index,
               replace_buf_offset
           };

    reg first_cycle_of_REPLACE;
    always @(posedge clk) begin
        first_cycle_of_REPLACE <= dirty_miss_to_replace;
    end

    ////
    // REFILL
    // Receive and refill the cache line.
    ////

    // refill buffer
    reg [$clog2(WORDS_PER_LINE)-1:0] refill_buf_ptr;
    always @(posedge clk) begin
        if (state == IDLE) begin
            refill_buf_ptr <= 0;
        end else begin
            if (ret_valid)
                refill_buf_ptr <= refill_buf_ptr + 1;
        end
    end

    wire [31:0] modified_ret_data;
    for (i = 0; i < 4; i = i + 1) begin
        assign modified_ret_data[i*8 +: 8] = replace_buf_wstrb[i] ?
               replace_buf_wdata[i*8 +: 8] : ret_data[i*8 +: 8];
    end

    wire refill_requested_word = replace_buf_bank_num == refill_buf_ptr;
    wire [31:0] refill_word =
         (replace_buf_write && refill_requested_word) ?
         modified_ret_data : ret_data ;

    // cache table inputs
    assign {
            table_write,
            table_write_index,
            table_write_bank_num,
            table_write_way,
            table_write_data,
            table_write_strb
        } = (state == REFILL) ?
        {
            ret_valid,
            replace_buf_index,
            refill_buf_ptr,
            replace_buf_replace_way,
            refill_word,
            4'b1111
        } :
        {
            ~write_buf_idle,
            write_buf_index,
            write_buf_bank_num,
            write_buf_way,
            write_buf_wdata,
            write_buf_wstrb
        };

    wire [NUM_WAY-1:0] replace_buf_replace_way_wen =
         {NUM_WAY{state == REFILL}} & replace_buf_replace_way;
    assign {
            d_write_way,
            d_write_index,
            d_write
        } = ~write_buf_idle ? {
            write_buf_way,
            write_buf_index,
            1'b1
        } :
        {
            replace_buf_replace_way_wen,
            replace_buf_index,
            replace_buf_write
        };

    assign tag_v_write_way = replace_buf_replace_way_wen;
    assign tag_write = replace_buf_tag_new;
    assign v_write = 1'b1;

    mux_1h #(.num_port(2), .data_width(INDEX_WIDTH))
           table_index_mux(
               .select(
                   {
                       state == IDLE || state == LOOKUP,
                       state == DIRTY_MISS || state == REFILL
                   }),
               .in(
                   {
                       index,
                       replace_buf_index
                   }),
               .out(table_index)
           );
    mux_1h #(.num_port(2), .data_width(TAG_WIDTH))
           table_tag_mux(
               .select(
                   {
                       state == LOOKUP,
                       state == REFILL
                   }),
               .in(
                   {
                       req_buf_tag,
                       replace_buf_tag_new
                   }),
               .out(table_tag)
           );
    assign table_bank_num = bank_num;
    assign read_way = replace_buf_replace_way;

    // I/O
    assign addr_ok = state_next == LOOKUP;
    wire refill_data_ok = (state == REFILL)
         && refill_requested_word && ret_valid && (~replace_buf_write);
    wire lookup_data_ok = (state == LOOKUP)
         && (hit | req_buf_write /* writes don't stall */);
    assign data_ok = refill_data_ok | lookup_data_ok;
    assign rdata = refill_data_ok ? refill_word : lookup_rdata;

    assign rd_req = (state == REPLACE) || (state == MISS);
    assign rd_addr = {replace_buf_tag_new, replace_buf_index, {OFFSET_WIDTH{1'b0}}};
    assign wr_req = first_cycle_of_REPLACE;

endmodule
