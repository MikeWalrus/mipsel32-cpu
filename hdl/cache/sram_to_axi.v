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
        input         i_cacheop,
        input         i_cacheop_index,
        input         i_cacheop_hit,
        input         i_cacheop_wb,
        input  [31:0] i_cacheop_addr,
        output        i_cacheop_ok1,
        output        i_cacheop_ok2,

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
        input         d_cacheop,
        input         d_cacheop_index,
        input         d_cacheop_hit,
        input         d_cacheop_wb,
        input  [31:0] d_cacheop_addr,
        output        d_cacheop_ok1,
        output        d_cacheop_ok2,

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
        input  [3 :0] bid          ,
        input  [1 :0] bresp        ,
        input         bvalid       ,
        output        bready
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
