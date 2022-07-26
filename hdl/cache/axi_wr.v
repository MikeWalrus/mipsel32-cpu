module axi_wr #
    (
        parameter D_BYTES_PER_LINE = 16,
        parameter D_WORDS_PER_LINE = D_BYTES_PER_LINE / 4,

        parameter D_BANK_NUM_WIDTH = $clog2(D_WORDS_PER_LINE),
        parameter D_LINE_WIDTH = D_WORDS_PER_LINE * 32
    )
    (
        input clk,
        input reset,
        output wr_idle,

        // d cache
        input wr_req,
        output wr_rdy,
        input burst,
        input [D_LINE_WIDTH-1:0] data,
        input [31:0] addr,
        input [1:0] size,
        input [3:0] strb,

        // ar r
        (* MARK_DEBUG = "TRUE" *)input read_unfinish,

        // aw
        output [3 :0] awid,
        output [31:0] awaddr,
        output [7 :0] awlen,
        output [2 :0] awsize,
        output [1 :0] awburst,
        output [1 :0] awlock,
        output [3 :0] awcache,
        output [2 :0] awprot,
        output        awvalid,
        input         awready,

        // w
        output [3 :0] wid,
        output [31:0] wdata,
        output [3 :0] wstrb,
        output        wlast,
        output        wvalid,
        input         wready,

        // b
        // verilator lint_off UNUSED
        input  [3 :0] bid,
        input  [1 :0] bresp,
        // verilator lint_on UNUSED
        input         bvalid,
        output        bready
    );

    (* MARK_DEBUG = "TRUE" *)reg        buf_empty;
    reg [D_LINE_WIDTH-1:0] buf_data;
    reg [D_BANK_NUM_WIDTH-1:0] buf_data_ptr;
    reg [31:0] buf_addr;
    reg        buf_burst;
    reg [1:0]  buf_size;
    reg [3:0]  buf_strb;

    localparam NUM_STATE = 5;
    localparam STATE_WIDTH = $clog2(NUM_STATE);
    (* MARK_DEBUG = "TRUE" *) reg [STATE_WIDTH-1:0] state;

    localparam [STATE_WIDTH-1:0] IDLE  = 0;
    localparam [STATE_WIDTH-1:0] AW_W  = 1;
    localparam [STATE_WIDTH-1:0] AW    = 2;
    localparam [STATE_WIDTH-1:0] W     = 3;
    localparam [STATE_WIDTH-1:0] WAIT  = 4;

    wire state_idle = state == IDLE;
    wire state_aw_w = state == AW_W;
    wire state_aw   = state == AW;
    wire state_w    = state == W;
    wire state_wait = state == WAIT;

    wire w_last = buf_burst ? &buf_data_ptr : 1'b1;
    wire w_handshake = wready & wvalid;
    wire w_finish = w_last & w_handshake;

    wire idle_to_aw_w = state_idle & ~buf_empty & ~read_unfinish;
    wire idle_to_idle = state_idle & ~idle_to_aw_w;

    wire aw_w_to_wait = state_aw_w & w_finish & awready;
    wire aw_w_to_aw   = state_aw_w & w_finish & ~awready;
    wire aw_w_to_w    = state_aw_w & ~w_finish & awready;
    wire aw_w_to_aw_w = state_aw_w & ~w_finish & ~awready;

    wire aw_to_wait = state_aw & awready;
    wire aw_to_aw   = state_aw & ~awready;

    wire w_to_wait = state_w & w_finish;
    wire w_to_w    = state_w & ~w_finish;

    wire wait_to_idle = state_wait & bvalid;

    wire [STATE_WIDTH-1:0] state_next;
    mux_1h #(.num_port(NUM_STATE), .data_width(STATE_WIDTH)) next_mux
           (
               .select(
                   {
                       idle_to_idle | wait_to_idle,
                       idle_to_aw_w | aw_w_to_aw_w,
                       aw_to_aw | aw_w_to_aw,
                       aw_w_to_w | w_to_w,
                       aw_w_to_wait | aw_to_wait | w_to_wait
                   }),
               .in({
                       IDLE,
                       AW_W,
                       AW,
                       W,
                       WAIT
                   }),
               .out(state_next)
           );
    always @(posedge clk) begin
        if (reset)
            state <= IDLE;
        else
            state <= state_next;
    end

    always @(posedge clk) begin
        if (wr_req) begin // TODO
            buf_data_ptr <= 0;
            buf_data     <= data;
            buf_addr     <= addr;
            buf_burst    <= burst;
            buf_strb     <= strb;
            buf_size     <= size;
        end else begin
            if (w_handshake)
                buf_data_ptr <= buf_data_ptr + 1;
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            buf_empty <= 1;
        end else begin
            if (wr_req)
                buf_empty <= 0;
            else if (state_next == WAIT)
                buf_empty <= 1;
        end
    end

    localparam [1:0] BURST_FIXED = 2'b00;
    localparam [1:0] BURST_INCR = 2'b01;
    localparam [7:0] D_AXI_LEN = D_BYTES_PER_LINE/4-1;
    mux_1h
        #(.num_port(2), .data_width(32 + 3 + 2 + 8 + 4)) wr_mux (
            .select(
                {
                    buf_burst,
                    ~buf_burst
                }),
            .in(
                {
                    {buf_addr, 3'h2, BURST_INCR, D_AXI_LEN, 4'b1111},
                    {buf_addr, {1'b0, buf_size}, BURST_FIXED, 8'b0, buf_strb}
                }
            ),
            .out({awaddr, awsize, awburst, awlen, wstrb})
        );

    // d cache
    assign wr_rdy = buf_empty | (state_next == WAIT);

    // aw
    assign awvalid = state_aw_w | state_aw;
    assign awid = 0;
    assign awlock = 0;
    assign awcache = 0;
    assign awprot = 0;

    // w
    assign wvalid = state_aw_w | state_w;
    assign wdata = buf_data[buf_data_ptr * 32 +: 32];
    assign wlast = w_last;
    assign wid = 0;

    // b
    assign bready = 1;

    // sram_to_axi
    assign wr_idle = state_idle;
endmodule
