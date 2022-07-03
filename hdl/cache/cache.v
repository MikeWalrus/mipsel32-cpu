module cache #
    (
        parameter NUM_WAY = 2,
        parameter BYTES_PER_LINE = 16,
        parameter NUM_LINE = 256,

        parameter NUM_WAY_WIDTH = $clog2(NUM_WAY),
        parameter OFFSET_WIDTH = $clog2(BYTES_PER_LINE),
        parameter INDEX_WIDTH = $clog2(NUM_LINE),
        parameter TAG_WIDTH = 32 - OFFSET_WIDTH - INDEX_WIDTH,
        parameter WORDS_PER_LINE = BYTES_PER_LINE / 4,
        parameter BITS_PER_LINE = BYTES_PER_LINE * 8,
        parameter BANK_NUM_WIDTH = $clog2(WORDS_PER_LINE)
    )
    (
        input clk,
        input reset,
        input valid,
        input write,
        input uncached,
        input [31:0] addr,
        input [1:0] size,
        input [3:0] wstrb,
        input [31:0] wdata,

        output addr_ok,
        output burst,
        output data_ok,
        output [31:0] rdata,

        output rd_req,
        output [31:0] rd_addr,
        output [1:0] rd_size,
        input rd_rdy,
        input ret_valid,
        input ret_last,
        input [31:0] ret_data,

        output wr_req,
        output [31:0] wr_addr,
        output [3:0] wr_strb,
        output [1:0] wr_size,
        output [BITS_PER_LINE-1:0] wr_data,
        input wr_rdy,

        input cacheop,
        input cacheop_index,
        input cacheop_hit,
        input cacheop_wb,
        input [31:0] cacheop_addr,
        output cacheop_ok1, // similar to addr_ok
        output cacheop_ok2  // similar to data_ok
    );
    // cache table
    wire [(TAG_WIDTH*NUM_WAY)-1:0] read_tags;
    wire [BITS_PER_LINE*NUM_WAY-1:0] read_lines;
    wire [NUM_WAY-1:0] hit_way;
    wire [NUM_WAY-1:0] v_ways;
    wire [NUM_WAY-1:0] dirty_ways;

    wire [NUM_WAY-1:0] table_d_write_way;
    wire table_d_write;
    wire [INDEX_WIDTH-1:0] d_index;
    wire [NUM_WAY-1:0] d_way;
    wire dirty;

    wire [31:0] table_rdata;
    wire [INDEX_WIDTH-1:0] table_index;
    wire [TAG_WIDTH-1:0] table_tag;
    wire [BANK_NUM_WIDTH-1:0] table_bank_num;
    wire [NUM_WAY-1:0] read_way;
    wire [BITS_PER_LINE-1:0] read_line;
    wire [TAG_WIDTH-1:0] read_tag;

    wire table_write;
    wire [INDEX_WIDTH-1:0] table_write_index;
    wire [NUM_WAY-1:0] table_write_way;
    wire [BANK_NUM_WIDTH-1:0] table_write_bank_num;
    wire [31:0] table_write_data;
    wire [3:0] table_write_strb;
    wire [NUM_WAY-1:0] table_tag_v_write_way;
    wire [TAG_WIDTH-1:0] table_tag_write;
    wire table_v_write;

    cache_table
        #(
            .NUM_WAY(NUM_WAY),
            .BYTES_PER_LINE(BYTES_PER_LINE),
            .NUM_LINE(NUM_LINE)
        ) cache_table (
            .clk(clk),
            .reset(reset),

            .tag(table_tag),
            .index(table_index),
            .bank_num(table_bank_num),
            .hit_way(hit_way),
            .v_ways(v_ways),
            .rdata(table_rdata),
            .read_way(read_way),
            .read_line(read_line),
            .read_lines(read_lines),
            .read_tag(read_tag),
            .read_tags(read_tags),

            .write(table_write),
            .write_way(table_write_way),
            .write_index(table_write_index),
            .write_bank_num(table_write_bank_num),
            .write_data(table_write_data),
            .write_strb(table_write_strb),

            .d_write_way(table_d_write_way),
            .d_write(table_d_write),
            .d_way(d_way),
            .d_index(d_index),
            .dirty(dirty),
            .dirty_ways(dirty_ways),

            .tag_v_write_way(table_tag_v_write_way),
            .tag_write(table_tag_write),
            .v_write(table_v_write)
        );

    wire [INDEX_WIDTH-1:0] index;
    wire [TAG_WIDTH-1:0] tag;
    wire [OFFSET_WIDTH-1:0] offset;
    addr_parse #
        (
            .BYTES_PER_LINE(BYTES_PER_LINE),
            .NUM_LINE(NUM_LINE)
        )
        addr_parse(
            .addr(cacheop ? cacheop_addr : addr),
            .index(index),
            .tag(tag),
            .offset(offset)
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
    reg [1:0] req_buf_size;
    reg [31:0] req_buf_wdata;
    reg req_buf_uncached;
    reg req_buf_cacheop;
    reg req_buf_cacheop_index;
    reg req_buf_cacheop_hit;
    reg req_buf_cacheop_wb;
    always @(posedge clk) begin
        if (state_next == LOOKUP) begin
            req_buf_index <= index;
            req_buf_tag <= tag;
            req_buf_offset <= offset;
            req_buf_write <= write;
            req_buf_wstrb <= wstrb;
            req_buf_size <= size;
            req_buf_wdata <= wdata;
            req_buf_uncached <= uncached;
            req_buf_cacheop <= cacheop;
            req_buf_cacheop_index <= cacheop_index;
            req_buf_cacheop_hit <= cacheop_hit;
            req_buf_cacheop_wb <= cacheop_wb;
        end
    end

    // replace buffer
    reg [INDEX_WIDTH-1:0] replace_buf_index;
    reg [TAG_WIDTH-1:0] replace_buf_tag_new;
    reg [NUM_WAY-1:0] replace_buf_replace_way;
    reg [NUM_WAY-1:0] replace_buf_hit_way;
    reg [OFFSET_WIDTH-1:0] replace_buf_offset;
    reg replace_buf_write;
    reg [31:0] replace_buf_wdata;
    reg [3:0] replace_buf_wstrb;
    reg [1:0] replace_buf_size;
    wire [BANK_NUM_WIDTH-1:0] replace_buf_bank_num =
         get_bank_num(replace_buf_offset);
    reg replace_buf_uncached;
    reg replace_buf_cacheop;
    reg replace_buf_cacheop_hit;
    reg [(BITS_PER_LINE*NUM_WAY)-1:0] replace_buf_read_lines;
    reg [(TAG_WIDTH*NUM_WAY)-1:0] replace_buf_read_tags;
    wire [NUM_WAY-1:0] replace_way;
    always @(posedge clk) begin
        if (state == LOOKUP) begin
            replace_buf_index <= req_buf_index;
            replace_buf_tag_new <= req_buf_tag;
            replace_buf_replace_way <= replace_way;
            replace_buf_hit_way <= hit_way;
            replace_buf_offset <= req_buf_offset;
            replace_buf_write <= req_buf_write;
            replace_buf_wdata <= req_buf_wdata;
            replace_buf_wstrb <= req_buf_wstrb;
            replace_buf_size <= req_buf_size;
            replace_buf_uncached <= req_buf_uncached;
            replace_buf_cacheop <= req_buf_cacheop;
            replace_buf_cacheop_hit <= req_buf_cacheop_hit;
            replace_buf_read_lines <= read_lines;
            replace_buf_read_tags <= read_tags;
        end
    end
    reg [NUM_WAY-1:0] wb_ways;
    wire [NUM_WAY-1:0] wb_way;
    wire [NUM_WAY-1:0] wb_ways_next = wb_ways & ~wb_way;
    wire wb_last_way = wb_ways_next == 0;
    wire replace_to_dirty_miss;
    always @(posedge clk) begin
        if (state == LOOKUP)
            wb_ways <= (req_buf_cacheop_hit ? hit_way : v_ways) & dirty_ways;
        else begin
            if (replace_to_dirty_miss)
                wb_ways <= wb_ways_next;
        end
    end
    isolate_rightmost #
        (.WIDTH(NUM_WAY))
        wb_way_gen(
            .en(1),
            .in(wb_ways),
            .out(wb_way)
        );


    wire hit = (~req_buf_uncached | req_buf_cacheop) & |hit_way & (state == LOOKUP);
    wire _hit = (~req_buf_cacheop & hit) | (req_buf_cacheop & req_buf_cacheop_hit & ~hit);
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

    // read after write hazard
    wire write_overlap = ~write_buf_idle & (write_buf_bank_num == bank_num);
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

    wire req = valid | cacheop;

    // IDLE to ...
    wire idle_to_idle   = (state == IDLE) & (~req | write_overlap);
    wire idle_to_lookup = (state == IDLE) & ~idle_to_idle;
    // LOOKUP to ...
    wire lookup_to_lookup = (state == LOOKUP) & (req & ~write_overlap & _hit);
    wire lookup_to_idle   = (state == LOOKUP) & (~lookup_to_lookup & _hit);
    wire lookup_to_refill = (state == LOOKUP) &
         (
             req_buf_cacheop & ~req_buf_cacheop_wb &
             (
                 (req_buf_cacheop_hit & hit)
                 | req_buf_cacheop_index
             )
         );
    wire lookup_to_miss       = (state == LOOKUP) &
         (~_hit & ~req_buf_cacheop & (req_buf_uncached ? ~req_buf_write : ~dirty));
    wire lookup_to_dirty_miss = (state == LOOKUP) &
         (~_hit & (req_buf_cacheop ? req_buf_cacheop_wb : (req_buf_uncached ? req_buf_write : dirty)));
    // MISS to ...
    wire miss_to_miss   = (state == MISS) & ~rd_rdy;
    wire miss_to_refill = (state == MISS) & rd_rdy;
    // DIRTY_MISS to ...
    wire dirty_miss_to_dirty_miss = (state == DIRTY_MISS) & ~wr_rdy;
    wire dirty_miss_to_replace    = (state == DIRTY_MISS) & wr_rdy;
    // REPLACE to ...
    wire replace_to_replace      = (state == REPLACE) & ~replace_buf_cacheop & ~rd_rdy;
    assign replace_to_dirty_miss = (state == REPLACE) & (replace_buf_cacheop & ~wb_last_way);
    wire replace_to_refill       = (state == REPLACE) &
         (replace_buf_cacheop ?
          wb_last_way :
          (~replace_to_dirty_miss & rd_rdy & ~replace_buf_uncached));
    wire replace_to_idle       = (state == REPLACE) & replace_buf_uncached & ~replace_buf_cacheop;
    // REFILL to ...
    wire refill_to_refill = (state == REFILL) & ~replace_buf_cacheop & ~(ret_valid && ret_last);
    wire refill_to_idle   = (state == REFILL) & ~refill_to_refill;

    mux_1h #(.num_port(STATE_NUM), .data_width(STATE_BITS)) state_next_mux
           (
               .select(
                   {
                       idle_to_idle | lookup_to_idle | refill_to_idle | replace_to_idle,
                       idle_to_lookup | lookup_to_lookup,
                       lookup_to_miss | miss_to_miss,
                       lookup_to_dirty_miss | dirty_miss_to_dirty_miss | replace_to_dirty_miss,
                       dirty_miss_to_replace | replace_to_replace,
                       miss_to_refill | replace_to_refill | refill_to_refill | lookup_to_refill
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

    replace_way_gen #(.NUM_WAY(NUM_WAY)) replace_way_gen(
                        .clk(clk),
                        .reset(reset),
                        .en(state == LOOKUP && ~hit), // update lfsr on miss
                        .v_ways(v_ways),
                        .replace_way(replace_way)
                    );

    // D table read ports
    assign d_way = replace_way;
    assign d_index = (state == LOOKUP) ? req_buf_index : replace_buf_index;

    ////
    // DIRTY_MISS
    // Read the cache table with the contents of the replace buffer.
    ////

    ////
    // REPLACE
    // Output the cache line that needs to be replaced.
    ////
    wire [BITS_PER_LINE-1:0] wr_data_cacheop;
    mux_1h #(.num_port(NUM_WAY), .data_width(BITS_PER_LINE))
           wr_data_cacheop_mux (
               .select(wb_way),
               .in(replace_buf_read_lines),
               .out(wr_data_cacheop)
           );
    mux_1h #(.num_port(3), .data_width(BITS_PER_LINE))
           wr_data_mux (
               .select(
                   {
                       ~replace_buf_cacheop & ~replace_buf_uncached,
                       ~replace_buf_cacheop & replace_buf_uncached,
                       replace_buf_cacheop
                   }),
               .in(
                   {
                       read_line,
                       {{(WORDS_PER_LINE-1)*32{1'b0}}, replace_buf_wdata},
                       wr_data_cacheop
                   }),
               .out(wr_data)
           );
    wire [TAG_WIDTH-1:0] wr_addr_cacheop_tag;
    mux_1h #(.num_port(NUM_WAY), .data_width(TAG_WIDTH))
           wr_addr_cacheop_tag_mux (
               .select(wb_way),
               .in(replace_buf_read_tags),
               .out(wr_addr_cacheop_tag)
           );
    wire [TAG_WIDTH-1:0]wr_addr_tag;
    mux_1h #(.num_port(3), .data_width(TAG_WIDTH))
           wr_addr_tag_mux (
               .select(
                   {
                       ~replace_buf_cacheop & replace_buf_uncached,
                       ~replace_buf_cacheop & ~replace_buf_uncached,
                       replace_buf_cacheop
                   }),
               .in(
                   {
                       replace_buf_tag_new,
                       read_tag,
                       wr_addr_cacheop_tag
                   }),
               .out(wr_addr_tag)
           );
    assign wr_addr =
           {
               wr_addr_tag,
               replace_buf_index,
               (~replace_buf_cacheop & replace_buf_uncached) ?
               replace_buf_offset : {OFFSET_WIDTH{1'b0}}
           };
    assign wr_strb = replace_buf_cacheop ? 4'b1111 : replace_buf_wstrb;

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
            if (ret_valid & (state == REFILL))
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
    wire [NUM_WAY-1:0] invalidate_ways = replace_buf_cacheop_hit ?
         replace_buf_hit_way : {NUM_WAY{1'b1}};
    mux_1h #
        (
            .num_port(3),
            .data_width(
                1 + INDEX_WIDTH + BANK_NUM_WIDTH + NUM_WAY + 32 + 4
                + NUM_WAY + 1 + TAG_WIDTH
                + NUM_WAY + 1
            )
        )
        table_write_mux
        (
            .select(
                {
                    (state == REFILL) && ~replace_buf_cacheop,
                    (state == REFILL) && replace_buf_cacheop,
                    state != REFILL
                }),
            .in(
                {
                    {
                        ret_valid & ~replace_buf_uncached, // table_write,
                        replace_buf_index,       // table_write_index,
                        refill_buf_ptr,          // table_write_bank_num,
                        replace_buf_replace_way, // table_write_way,
                        refill_word,             // table_write_data,
                        4'b1111,                 // table_write_strb,
                        replace_buf_replace_way, // table_tag_v_write_way,
                        1'b1,                    // table_v_write,
                        replace_buf_tag_new,     // table_tag_write,
                        replace_buf_replace_way, // table_d_write_way,
                        replace_buf_write        // table_d_write
                    },
                    {
                        1'b1,                    // table_write,
                        replace_buf_index,       // table_write_index,
                        {BANK_NUM_WIDTH{1'b0}},  // table_write_bank_num,
                        {NUM_WAY{1'b0}},         // table_write_way,
                        32'b0,                   // table_write_data,
                        4'b0,                    // table_write_strb,
                        invalidate_ways,         // table_tag_v_write_way,
                        1'b0,                    // table_v_write,
                        {TAG_WIDTH{1'bx}},       // table_tag_write
                        invalidate_ways,         // table_d_write_way,
                        1'b0                     // table_d_write
                    },
                    {
                        ~write_buf_idle,         // table_write,
                        write_buf_index,         // table_write_index,
                        write_buf_bank_num,      // table_write_bank_num,
                        write_buf_way,           // table_write_way,
                        write_buf_wdata,         // table_write_data,
                        write_buf_wstrb,         // table_write_strb,
                        {NUM_WAY{1'b0}},         // table_tag_v_write_way,
                        1'bx,                    // table_v_write,
                        {TAG_WIDTH{1'bx}},       // table_tag_write
                        write_buf_way,           // table_d_write_way,
                        1'b1                     // table_d_write
                    }
                }),
            .out(
                {
                    table_write,
                    table_write_index,
                    table_write_bank_num,
                    table_write_way,
                    table_write_data,
                    table_write_strb,
                    table_tag_v_write_way,
                    table_v_write,
                    table_tag_write,
                    table_d_write_way,
                    table_d_write
                })
        );


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
    assign table_bank_num = req_buf_bank_num;
    assign read_way = replace_buf_replace_way;

    // I/O
    assign addr_ok = (state_next == LOOKUP) && ~cacheop;
    assign cacheop_ok1 = (state == LOOKUP) && req_buf_cacheop;
    assign burst = ~replace_buf_uncached;
    wire lookup_data_ok = (state == LOOKUP) && ~req_buf_cacheop
         && (hit | req_buf_write /* writes don't stall */);
    wire refill_data_ok_cached = (state == REFILL) &&
         ~replace_buf_cacheop && ~replace_buf_uncached
         && refill_requested_word && ret_valid && (~replace_buf_write);
    wire refill_data_ok_uncached = (state == REFILL) &&
         ~replace_buf_cacheop && replace_buf_uncached
         && ret_valid && ret_last;
    assign data_ok = |{
               refill_data_ok_cached,
               refill_data_ok_uncached,
               lookup_data_ok
           };
    assign cacheop_ok2 =
           |{
               (state == LOOKUP) & req_buf_cacheop & req_buf_cacheop_hit & ~hit,
               (state == REFILL) & replace_buf_cacheop
           };
    mux_1h #(.num_port(3), .data_width(32)) rdata_mux(
               .select({lookup_data_ok, refill_data_ok_cached, refill_data_ok_uncached}),
               .in(    {lookup_rdata  , refill_word          , ret_data               }),
               .out(rdata)
           );

    assign rd_req = (state == REPLACE && ~replace_buf_cacheop) || (state == MISS);
    assign rd_addr =
           {
               replace_buf_tag_new,
               replace_buf_index,
               replace_buf_uncached ?  replace_buf_offset : {OFFSET_WIDTH{1'b0}}
           };
    assign rd_size = replace_buf_size;
    assign wr_req = first_cycle_of_REPLACE;
    assign wr_size = replace_buf_size;
endmodule
