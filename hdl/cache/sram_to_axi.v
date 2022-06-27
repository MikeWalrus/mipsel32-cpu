module sram_to_axi #
    (
        parameter I_NUM_WAY = 2,
        // BYTES_PER_LINE * NUM_LINE must <= 4096
        parameter I_BYTES_PER_LINE = 32,
        parameter I_NUM_LINE = 128,
        parameter D_NUM_WAY = 2,
        // BYTES_PER_LINE * NUM_LINE must <= 4096
        parameter D_BYTES_PER_LINE = 16,
        parameter D_NUM_LINE = 256,

        parameter I_OFFSET_WIDTH = $clog2(I_BYTES_PER_LINE),
        parameter I_INDEX_WIDTH = $clog2(I_NUM_LINE),
        parameter I_TAG_WIDTH = 32 - I_OFFSET_WIDTH - I_INDEX_WIDTH,
        parameter I_WORDS_PER_LINE = I_BYTES_PER_LINE / 4,
        parameter I_BANK_NUM_WIDTH = $clog2(I_WORDS_PER_LINE),
        parameter I_LINE_WIDTH = I_WORDS_PER_LINE * 32,

        parameter D_OFFSET_WIDTH = $clog2(D_BYTES_PER_LINE),
        parameter D_INDEX_WIDTH = $clog2(D_NUM_LINE),
        parameter D_TAG_WIDTH = 32 - D_OFFSET_WIDTH - D_INDEX_WIDTH,
        parameter D_WORDS_PER_LINE = D_BYTES_PER_LINE / 4,
        parameter D_BANK_NUM_WIDTH = $clog2(D_WORDS_PER_LINE),
        parameter D_LINE_WIDTH = D_WORDS_PER_LINE * 32
    )
    (
        input clk,
        input reset,

        //inst sram-like
        input         i_req     ,
        input         i_wr      ,
        input  [1 :0] i_size    ,
        input  [31:0] i_addr    ,
        input  [31:0] i_wdata   ,
        input  [3 :0] i_wstrb   ,
        output [31:0] i_rdata   ,
        output        i_addr_ok ,
        output        i_data_ok ,
        input         i_uncached,

        //data sram-like
        input         d_req     ,
        input         d_wr      ,
        input  [1 :0] d_size    ,
        input  [3 :0] d_wstrb   ,
        input  [31:0] d_addr    ,
        input  [31:0] d_wdata   ,
        output [31:0] d_rdata   ,
        output        d_addr_ok ,
        output        d_data_ok ,
        input         d_uncached,

        //axi
        //ar
        output [3 :0] arid         ,
        output [31:0] araddr       ,
        output [7 :0] arlen        ,
        output [2 :0] arsize       ,
        output [1 :0] arburst      ,
        output [1 :0] arlock       ,
        output [3 :0] arcache      ,
        output [2 :0] arprot       ,
        output        arvalid      ,
        input         arready      ,
        //r
        // verilator lint_off UNUSED
        input  [3 :0] rid          ,
        // verilator lint_on UNUSED
        input  [31:0] rdata        ,
        // verilator lint_off UNUSED
        input  [1 :0] rresp        ,
        // verilator lint_on UNUSED
        input         rlast        ,
        input         rvalid       ,
        output        rready       ,
        //aw
        output [3 :0] awid         ,
        output [31:0] awaddr       ,
        output [7 :0] awlen        ,
        output [2 :0] awsize       ,
        output [1 :0] awburst      ,
        output [1 :0] awlock       ,
        output [3 :0] awcache      ,
        output [2 :0] awprot       ,
        output        awvalid      ,
        input         awready      ,
        //w
        output [3 :0] wid          ,
        output [31:0] wdata        ,
        output [3 :0] wstrb        ,
        output        wlast        ,
        output        wvalid       ,
        input         wready       ,
        //b
// verilator lint_off UNUSED
        input  [3 :0] bid          ,
        input  [1 :0] bresp        ,
// verilator lint_on UNUSED
        input         bvalid       ,
        output        bready
    );
    localparam [1:0] BURST_FIXED = 2'b00;
    localparam [1:0] BURST_INCR = 2'b01;

    // Burst Length = AxLEN[3:0] + 1
    localparam [7:0] I_AXI_LEN = I_BYTES_PER_LINE/4-1;
    localparam [7:0] D_AXI_LEN = D_BYTES_PER_LINE/4-1;

    wire i_cache_ar_now;
    wire d_cache_ar_now;

    wire i_cache_req = i_req;
    wire i_cache_addr_ok;
    wire i_cache_burst;
    wire i_cache_data_ok;
    wire [31:0] i_cache_rdata;
    wire i_cache_rd_req;
    wire [31:0] i_cache_rd_addr;
    wire [1:0] i_cache_rd_size;
    wire i_cache_rd_rdy = arready & i_cache_ar_now;
    wire i_cache_ret_valid = rvalid;
// verilator lint_off UNUSED
    wire i_cache_wr_req;
    wire [31:0] i_cache_wr_addr;
    wire [1:0] i_cache_wr_size;
    wire [I_LINE_WIDTH-1:0] i_cache_wr_data;
    wire i_cache_wr_rdy = 0;
    wire [3:0] i_cache_wr_strb;
// verilator lint_on UNUSED

    cache
        #(
            .NUM_WAY    (I_NUM_WAY),
            .BYTES_PER_LINE (I_BYTES_PER_LINE),
            .NUM_LINE   (I_NUM_LINE)
        )
        i_cache
        (
            .clk    (clk),
            .reset  (reset),
            .valid  (i_cache_req),
            .size   (i_size),
            .write  (i_wr),
            .uncached(i_uncached),
            .index  (i_addr[(31-I_TAG_WIDTH)-:I_INDEX_WIDTH]),
            .tag    (i_addr[31-:I_TAG_WIDTH]),
            .offset (i_addr[0+:I_OFFSET_WIDTH]),
            .wstrb  (i_wstrb),
            .wdata  (i_wdata),

            .addr_ok    (i_cache_addr_ok),
            .burst      (i_cache_burst),
            .data_ok    (i_cache_data_ok),
            .rdata      (i_cache_rdata),

            .rd_req     (i_cache_rd_req),
            .rd_addr    (i_cache_rd_addr),
            .rd_size    (i_cache_rd_size),
            .rd_rdy     (i_cache_rd_rdy),
            .ret_valid  (i_cache_ret_valid),
            .ret_last   (rlast),
            .ret_data   (rdata),

            .wr_req     (i_cache_wr_req),
            .wr_addr    (i_cache_wr_addr),
            .wr_size    (i_cache_wr_size),
            .wr_strb    (i_cache_wr_strb),
            .wr_data    (i_cache_wr_data),
            .wr_rdy     (i_cache_wr_rdy)
        );

    wire d_cache_req = d_req;
    wire d_cache_addr_ok;
    wire d_cache_burst;
    wire d_cache_data_ok;
    wire [31:0] d_cache_rdata;
    wire d_cache_rd_req;
    wire [31:0] d_cache_rd_addr;
    wire [1:0] d_cache_rd_size;
    wire d_cache_rd_rdy = arready & d_cache_ar_now;
    wire d_cache_ret_valid = rvalid;
    wire d_cache_wr_req;
    wire [31:0] d_cache_wr_addr;
    wire [1:0] d_cache_wr_size;
    wire [D_LINE_WIDTH-1:0] d_cache_wr_data;
    wire d_cache_wr_buf_data_ready;
    wire d_cache_wr_rdy = d_cache_wr_buf_data_ready;
    wire [3:0] d_cache_wr_strb;

    cache
        #(
            .NUM_WAY    (D_NUM_WAY),
            .BYTES_PER_LINE (D_BYTES_PER_LINE),
            .NUM_LINE   (D_NUM_LINE)
        )
        d_cache
        (
            .clk    (clk),
            .reset  (reset),
            .valid  (d_cache_req),
            .write  (d_wr),
            .uncached(d_uncached),
            .size   (d_size),
            .index  (d_addr[(31-D_TAG_WIDTH)-:D_INDEX_WIDTH]),
            .tag    (d_addr[31-:D_TAG_WIDTH]),
            .offset (d_addr[0+:D_OFFSET_WIDTH]),
            .wstrb  (d_wstrb),
            .wdata  (d_wdata),

            .addr_ok    (d_cache_addr_ok),
            .burst      (d_cache_burst),
            .data_ok    (d_cache_data_ok),
            .rdata      (d_cache_rdata),

            .rd_req     (d_cache_rd_req),
            .rd_addr    (d_cache_rd_addr),
            .rd_size    (d_cache_rd_size),
            .rd_rdy     (d_cache_rd_rdy),
            .ret_valid  (d_cache_ret_valid),
            .ret_last   (rlast),
            .ret_data   (rdata),

            .wr_req     (d_cache_wr_req),
            .wr_addr    (d_cache_wr_addr),
            .wr_size    (d_cache_wr_size),
            .wr_strb    (d_cache_wr_strb),
            .wr_data    (d_cache_wr_data),
            .wr_rdy     (d_cache_wr_rdy)
        );

    reg waiting_for_rvalid;
    reg waiting_for_bvalid;

    assign i_addr_ok = i_cache_addr_ok;
    assign d_addr_ok = d_cache_addr_ok;

    reg i_arvalid_reg;
    reg d_arvalid_reg;
    always @(posedge clk) begin
        if (reset) begin
            i_arvalid_reg <= 0;
            d_arvalid_reg <= 0;
        end else begin
            i_arvalid_reg <= i_cache_ar_now;
            d_arvalid_reg <= d_cache_ar_now;
        end
    end
    wire allow_ar = {(~waiting_for_rvalid | rvalid) & (~waiting_for_bvalid | bvalid)};
    isolate_rightmost
        #(.WIDTH(2)) priority_ar (
            .en(allow_ar),
            .in(
                {
                    i_cache_rd_req & ~d_arvalid_reg,
                    d_cache_rd_req & ~i_arvalid_reg
                }
            ),
            .out(
                {
                    i_cache_ar_now,
                    d_cache_ar_now
                })
        );
    mux_1h
        #(.num_port(4), .data_width(3 + 2 + 8)) ar_mux (
            .select(
                {
                    i_cache_ar_now & ~i_cache_burst,
                    i_cache_ar_now & i_cache_burst,
                    d_cache_ar_now & ~d_cache_burst,
                    d_cache_ar_now & d_cache_burst
                }),
            .in(
                {
                    {{1'b0, i_cache_rd_size}, BURST_FIXED, 8'b0},
                    {3'b011, BURST_INCR, I_AXI_LEN},
                    {{1'b0, d_cache_rd_size}, BURST_FIXED, 8'b0},
                    {3'b011, BURST_INCR, D_AXI_LEN}
                }),
            .out(
                {arsize, arburst, arlen}
            )
        );
    assign araddr = i_cache_ar_now ? i_cache_rd_addr : d_cache_rd_addr;
    assign arvalid = |{
               i_cache_ar_now,
               d_cache_ar_now
           };

    assign arid    = 4'd0;
    assign arlock  = 2'd0;
    assign arcache = 4'd0;
    assign arprot  = 3'd0;

    always @(posedge clk) begin
        if (reset) begin
            waiting_for_rvalid <= 0;
        end else begin
            if (arvalid & arready) begin
                waiting_for_rvalid <= 1;
            end else begin
                if (rvalid)
                    waiting_for_rvalid <= 0;
            end
        end
    end

    assign rready = 1;


    assign i_rdata = i_cache_rdata;
    assign i_data_ok = i_cache_data_ok;

    assign d_rdata = d_cache_rdata;
    assign d_data_ok = d_cache_data_ok;

    reg [D_LINE_WIDTH-1:0] d_cache_wr_buf_data;
    reg [31:0] d_cache_wr_buf_addr;
    reg d_cache_wr_buf_burst;
    reg [1:0] d_cache_wr_buf_size;
    reg [3:0] d_cache_wr_buf_strb;
    reg d_cache_wr_buf_data_empty;
    reg [D_BANK_NUM_WIDTH-1:0] d_cache_wr_buf_data_ptr;

    wire d_cache_wr_buf_data_last = d_cache_wr_buf_burst ? &d_cache_wr_buf_data_ptr : 1'b1;
    wire d_cache_wr_buf_data_finish = d_cache_wr_buf_data_last & wready;
    assign d_cache_wr_buf_data_ready = d_cache_wr_buf_data_empty | d_cache_wr_buf_data_finish;
    wire d_cache_wr_buf_data_accept = d_cache_wr_buf_data_ready & d_cache_wr_req;
    always @(posedge clk) begin
        if (reset) begin
            d_cache_wr_buf_data_empty <= 1;
        end else begin
            if (d_cache_wr_buf_data_accept) begin
                d_cache_wr_buf_data_empty <= 0;
            end else if (d_cache_wr_buf_data_finish) begin
                d_cache_wr_buf_data_empty <= 1;
            end
        end
    end

    reg wvalid_reg;
    always @(posedge clk) begin
        if (reset) begin
            wvalid_reg <= 0;
        end else begin
            if (d_cache_wr_buf_data_accept)
                wvalid_reg <= 1;
            else if (d_cache_wr_buf_data_finish)
                wvalid_reg <= 0;
        end
    end

    always @(posedge clk) begin
        if (d_cache_wr_buf_data_accept) begin
            d_cache_wr_buf_data_ptr <= 0;
            d_cache_wr_buf_data <= d_cache_wr_data;
            d_cache_wr_buf_addr <= d_cache_wr_addr;
            d_cache_wr_buf_burst <= d_cache_burst;
            d_cache_wr_buf_strb <= d_cache_wr_strb;
            d_cache_wr_buf_size <= d_cache_wr_size;
        end else begin
            if (wready)
                d_cache_wr_buf_data_ptr <= d_cache_wr_buf_data_ptr + 1;
        end
    end

    reg d_cache_wr_reg;
    wire d_cache_wr_now = (~waiting_for_bvalid | bvalid) & (d_cache_wr_buf_data_accept | d_cache_wr_reg);

    always @(posedge clk) begin
        if (reset) begin
            d_cache_wr_reg <= 0;
        end else begin
            d_cache_wr_reg <= d_cache_wr_now & ~awready;
        end
    end

    assign awvalid = d_cache_wr_now;

    // TODO: Remove this if unused
    reg waiting_for_awready;
    always @(posedge clk) begin
        if (reset) begin
            waiting_for_awready <= 0;
        end else begin
            if (awvalid) begin
                waiting_for_awready <= 1;
            end else begin
                if (awready) begin
                    waiting_for_awready <= 0;
                end
            end
        end
    end

    always @(posedge clk) begin
        if (reset)
            waiting_for_bvalid <= 0;
        else begin
            if (awready & awvalid)
                waiting_for_bvalid <= 1;
            else if (bvalid)
                waiting_for_bvalid <= 0;
        end
    end

    mux_1h
        #(.num_port(4), .data_width(32 + 3 + 2 + 8)) wr_mux (
            .select(
                {
                    d_cache_wr_buf_data_accept & d_cache_burst,
                    d_cache_wr_reg & d_cache_wr_buf_burst,
                    d_cache_wr_buf_data_accept & ~d_cache_burst,
                    d_cache_wr_reg & ~d_cache_wr_buf_burst
                }),
            .in(
                {
                    {d_cache_wr_addr, 3'b011, BURST_INCR, D_AXI_LEN},
                    {d_cache_wr_buf_addr, 3'b011, BURST_INCR, D_AXI_LEN},
                    {d_cache_wr_addr, {1'b0, d_cache_wr_size}, BURST_FIXED, 8'b0},
                    {d_cache_wr_buf_addr, {1'b0, d_cache_wr_buf_size}, BURST_FIXED, 8'b0}
                }
            ),
            .out({awaddr, awsize, awburst, awlen})
        );
    assign {wdata, wstrb, wlast, wvalid} =
           {d_cache_wr_buf_data[d_cache_wr_buf_data_ptr * 32 +: 32], d_cache_wr_buf_strb, d_cache_wr_buf_data_last, wvalid_reg};

    assign awid = 0;
    assign awlock = 0;
    assign awcache = 0;
    assign awprot = 0;
    assign wid = 0;

    assign bready = 1;
endmodule
