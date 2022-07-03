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
        (* MARK_DEBUG = "TRUE" *) input         i_req     ,
        (* MARK_DEBUG = "TRUE" *) input         i_wr      ,
        (* MARK_DEBUG = "TRUE" *) input  [1 :0] i_size    ,
        (* MARK_DEBUG = "TRUE" *) input  [31:0] i_addr    ,
        (* MARK_DEBUG = "TRUE" *) input  [31:0] i_wdata   ,
        (* MARK_DEBUG = "TRUE" *) input  [3 :0] i_wstrb   ,
        (* MARK_DEBUG = "TRUE" *) output [31:0] i_rdata   ,
        (* MARK_DEBUG = "TRUE" *) output        i_addr_ok ,
        (* MARK_DEBUG = "TRUE" *) output        i_data_ok ,
        (* MARK_DEBUG = "TRUE" *) input         i_uncached,
        (* MARK_DEBUG = "TRUE" *) input         i_cacheop,
        (* MARK_DEBUG = "TRUE" *) input         i_cacheop_index,
        (* MARK_DEBUG = "TRUE" *) input         i_cacheop_hit,
        (* MARK_DEBUG = "TRUE" *) input         i_cacheop_wb,
        (* MARK_DEBUG = "TRUE" *) input  [31:0] i_cacheop_addr,
        (* MARK_DEBUG = "TRUE" *) output        i_cacheop_ok1,
        (* MARK_DEBUG = "TRUE" *) output        i_cacheop_ok2,

        //data sram-like
        (* MARK_DEBUG = "TRUE" *) input         d_req     ,
        (* MARK_DEBUG = "TRUE" *) input         d_wr      ,
        (* MARK_DEBUG = "TRUE" *) input  [1 :0] d_size    ,
        (* MARK_DEBUG = "TRUE" *) input  [3 :0] d_wstrb   ,
        (* MARK_DEBUG = "TRUE" *) input  [31:0] d_addr    ,
        (* MARK_DEBUG = "TRUE" *) input  [31:0] d_wdata   ,
        (* MARK_DEBUG = "TRUE" *) output [31:0] d_rdata   ,
        (* MARK_DEBUG = "TRUE" *) output        d_addr_ok ,
        (* MARK_DEBUG = "TRUE" *) output        d_data_ok ,
        (* MARK_DEBUG = "TRUE" *) input         d_uncached,
        (* MARK_DEBUG = "TRUE" *) input         d_cacheop,
        (* MARK_DEBUG = "TRUE" *) input         d_cacheop_index,
        (* MARK_DEBUG = "TRUE" *) input         d_cacheop_hit,
        (* MARK_DEBUG = "TRUE" *) input         d_cacheop_wb,
        (* MARK_DEBUG = "TRUE" *) input  [31:0] d_cacheop_addr,
        (* MARK_DEBUG = "TRUE" *) output        d_cacheop_ok1,
        (* MARK_DEBUG = "TRUE" *) output        d_cacheop_ok2,

        //axi
        //ar
        (* MARK_DEBUG = "TRUE" *) output [3 :0] arid         ,
        (* MARK_DEBUG = "TRUE" *) output [31:0] araddr       ,
        (* MARK_DEBUG = "TRUE" *) output [7 :0] arlen        ,
        (* MARK_DEBUG = "TRUE" *) output [2 :0] arsize       ,
        (* MARK_DEBUG = "TRUE" *) output [1 :0] arburst      ,
        (* MARK_DEBUG = "TRUE" *) output [1 :0] arlock       ,
        (* MARK_DEBUG = "TRUE" *) output [3 :0] arcache      ,
        (* MARK_DEBUG = "TRUE" *) output [2 :0] arprot       ,
        (* MARK_DEBUG = "TRUE" *) output        arvalid      ,
        (* MARK_DEBUG = "TRUE" *) input         arready      ,
        //r
        // verilator lint_off UNUSED
        input  [3 :0] rid          ,
        // verilator lint_on UNUSED
        input  [31:0] rdata        ,
        // verilator lint_off UNUSED
        input  [1 :0] rresp        ,
        // verilator lint_on UNUSED
        (* MARK_DEBUG = "TRUE" *) input         rlast        ,
        (* MARK_DEBUG = "TRUE" *) input         rvalid       ,
        (* MARK_DEBUG = "TRUE" *) output        rready       ,
        //aw
        (* MARK_DEBUG = "TRUE" *) output [3 :0] awid         ,
        (* MARK_DEBUG = "TRUE" *) output [31:0] awaddr       ,
        (* MARK_DEBUG = "TRUE" *) output [7 :0] awlen        ,
        (* MARK_DEBUG = "TRUE" *) output [2 :0] awsize       ,
        (* MARK_DEBUG = "TRUE" *) output [1 :0] awburst      ,
        (* MARK_DEBUG = "TRUE" *) output [1 :0] awlock       ,
        (* MARK_DEBUG = "TRUE" *) output [3 :0] awcache      ,
        (* MARK_DEBUG = "TRUE" *) output [2 :0] awprot       ,
        (* MARK_DEBUG = "TRUE" *) output        awvalid      ,
        (* MARK_DEBUG = "TRUE" *) input         awready      ,
        //w
        (* MARK_DEBUG = "TRUE" *) output [3 :0] wid          ,
        (* MARK_DEBUG = "TRUE" *) output [31:0] wdata        ,
        (* MARK_DEBUG = "TRUE" *) output [3 :0] wstrb        ,
        (* MARK_DEBUG = "TRUE" *) output        wlast        ,
        (* MARK_DEBUG = "TRUE" *) output        wvalid       ,
        (* MARK_DEBUG = "TRUE" *) input         wready       ,
        //b
        (* MARK_DEBUG = "TRUE" *) input  [3 :0] bid          ,
        (* MARK_DEBUG = "TRUE" *) input  [1 :0] bresp        ,
        (* MARK_DEBUG = "TRUE" *) input         bvalid       ,
        (* MARK_DEBUG = "TRUE" *) output        bready
    );
    localparam [1:0] BURST_FIXED = 2'b00;
    localparam [1:0] BURST_INCR = 2'b01;

    // Burst Length = AxLEN[3:0] + 1
    localparam [7:0] I_AXI_LEN = I_BYTES_PER_LINE/4-1;
    localparam [7:0] D_AXI_LEN = D_BYTES_PER_LINE/4-1;

    wire wr_idle;

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
            .addr (i_addr),
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
            .wr_rdy     (i_cache_wr_rdy),

            .cacheop    (i_cacheop),
            .cacheop_addr(i_cacheop_addr),
            .cacheop_index(i_cacheop_index),
            .cacheop_hit(i_cacheop_hit),
            .cacheop_wb (i_cacheop_wb),
            .cacheop_ok1(i_cacheop_ok1),
            .cacheop_ok2(i_cacheop_ok2)
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
    wire d_cache_wr_rdy;
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
            .addr   (d_addr),
            .size   (d_size),
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
            .wr_rdy     (d_cache_wr_rdy),

            .cacheop    (d_cacheop),
            .cacheop_addr(d_cacheop_addr),
            .cacheop_index(d_cacheop_index),
            .cacheop_hit(d_cacheop_hit),
            .cacheop_wb (d_cacheop_wb),
            .cacheop_ok1(d_cacheop_ok1),
            .cacheop_ok2(d_cacheop_ok2)
        );

    reg waiting_for_rvalid;

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
    wire allow_ar = (~waiting_for_rvalid | (rvalid & rlast)) & wr_idle;
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
                    {3'b010, BURST_INCR, I_AXI_LEN},
                    {{1'b0, d_cache_rd_size}, BURST_FIXED, 8'b0},
                    {3'b010, BURST_INCR, D_AXI_LEN}
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
                if (rvalid & rlast)
                    waiting_for_rvalid <= 0;
            end
        end
    end

    assign rready = 1;

    assign i_rdata = i_cache_rdata;
    assign i_data_ok = i_cache_data_ok;

    assign d_rdata = d_cache_rdata;
    assign d_data_ok = d_cache_data_ok;

    axi_wr #
        (
            .D_BYTES_PER_LINE(D_BYTES_PER_LINE),
            .D_WORDS_PER_LINE(D_WORDS_PER_LINE)
        )
        axi_wr
        (

            .clk    (clk),
            .reset  (reset),
            .wr_idle(wr_idle),

            // d cache
            .wr_req (d_cache_wr_req),
            .wr_rdy (d_cache_wr_rdy),
            .burst  (d_cache_burst),
            .data   (d_cache_wr_data),
            .addr   (d_cache_wr_addr),
            .size   (d_cache_wr_size),
            .strb   (d_cache_wr_strb),

            // ar r
            .read_unfinish(|{i_arvalid_reg, d_arvalid_reg, waiting_for_rvalid}),

            // aw
            .awid   (awid),
            .awaddr (awaddr),
            .awlen  (awlen),
            .awsize (awsize),
            .awburst(awburst),
            .awlock (awlock),
            .awcache(awcache),
            .awprot (awprot),
            .awvalid(awvalid),
            .awready(awready),

            // w
            .wid    (wid),
            .wdata  (wdata),
            .wstrb  (wstrb),
            .wlast  (wlast),
            .wvalid (wvalid),
            .wready (wready),

            // b
            .bid    (bid),
            .bresp  (bresp),
            .bvalid (bvalid),
            .bready (bready)
        );
endmodule
