module mycpu_top #
    (
        //
        // These parameters are the source of truth.
        //
        parameter I_NUM_WAY = 2,
        // BYTES_PER_LINE * NUM_LINE must <= 4096
        parameter I_BYTES_PER_LINE = 16,
        parameter I_NUM_LINE = 128,
        parameter D_NUM_WAY = 2,
        // BYTES_PER_LINE * NUM_LINE must <= 4096
        parameter D_BYTES_PER_LINE = 16,
        parameter D_NUM_LINE = 128
    )
    (
        input aclk,
        input aresetn,

        input [5:0] ext_int,

        output [3:0] arid,
        output [31:0] araddr,
        output [7:0] arlen,
        output [2:0] arsize,
        output [1:0] arburst,
        output [1:0] arlock,
        output [3:0] arcache,
        output [2:0] arprot,
        output arvalid,
        input arready,
        input [3:0] rid,
        input [31:0] rdata,
        input [1 :0] rresp,
        input rlast,
        input rvalid,
        output rready,
        output [3:0] awid,
        output [31:0] awaddr,
        output [7:0] awlen,
        output [2:0] awsize,
        output [1:0] awburst,
        output [1:0] awlock,
        output [3:0] awcache,
        output [2:0] awprot,
        output awvalid,
        input awready,
        output [3:0] wid,
        output [31:0] wdata,
        output [3 :0] wstrb,
        output wlast,
        output wvalid,
        input wready,
        input [3:0] bid,
        input [1:0] bresp,
        input bvalid,
        output bready,

        output [31:0] debug_wb_pc,
        output [3 :0] debug_wb_rf_wen,
        output [4 :0] debug_wb_rf_wnum,
        output [31:0] debug_wb_rf_wdata
    );
    //cpu inst sram
    wire        cpu_inst_req;
    wire        cpu_inst_cached;
    wire        cpu_inst_wr;
    wire [1 :0] cpu_inst_size;
    wire [3 :0] cpu_inst_wstrb;
    wire [31:0] cpu_inst_addr;
    wire [31:0] cpu_inst_wdata;
    wire        cpu_inst_addr_ok;
    wire        cpu_inst_data_ok;
    wire [31:0] cpu_inst_rdata;

    wire cpu_inst_cacheop;
    wire cpu_inst_cacheop_index;
    wire cpu_inst_cacheop_hit;
    wire cpu_inst_cacheop_wb;
    wire [31:0] cpu_inst_cacheop_addr;
    wire cpu_inst_cacheop_ok1;
    wire cpu_inst_cacheop_ok2;

    //cpu data sram
    wire        cpu_data_req;
    wire        cpu_data_cached;
    wire        cpu_data_wr;
    wire [1 :0] cpu_data_size;
    wire [3 :0] cpu_data_wstrb;
    wire [31:0] cpu_data_addr;
    wire [31:0] cpu_data_wdata;
    wire        cpu_data_addr_ok;
    wire        cpu_data_data_ok;
    wire [31:0] cpu_data_rdata;

    wire cpu_data_cacheop;
    wire cpu_data_cacheop_index;
    wire cpu_data_cacheop_hit;
    wire cpu_data_cacheop_wb;
    wire [31:0] cpu_data_cacheop_addr;
    wire cpu_data_cacheop_ok1;
    wire cpu_data_cacheop_ok2;

    //debug signals

    cpu_sram # (
                 .I_NUM_WAY(I_NUM_WAY),
                 .I_BYTES_PER_LINE(I_BYTES_PER_LINE),
                 .I_NUM_LINE(I_NUM_LINE),
                 .D_NUM_WAY(D_NUM_WAY),
                 .D_BYTES_PER_LINE(D_BYTES_PER_LINE),
                 .D_NUM_LINE(D_NUM_LINE),
                 .START_PC(32'h802cf038),
                 .TLB(1),
                 .TLBNUM(2)
             )
             cpu_sram
             (
                 .clk              (aclk   ),
                 .resetn           (aresetn),  //low active

                 .ext_int          (ext_int),

                 .inst_sram_req    (cpu_inst_req    ),
                 .inst_sram_cached (cpu_inst_cached ),
                 .inst_sram_wr     (cpu_inst_wr     ),
                 .inst_sram_size   (cpu_inst_size   ),
                 .inst_sram_wstrb  (cpu_inst_wstrb  ),
                 .inst_sram_addr   (cpu_inst_addr   ),
                 .inst_sram_wdata  (cpu_inst_wdata  ),
                 .inst_sram_addr_ok(cpu_inst_addr_ok),
                 .inst_sram_data_ok(cpu_inst_data_ok),
                 .inst_sram_rdata  (cpu_inst_rdata  ),
                 .inst_cacheop     (cpu_inst_cacheop),
                 .inst_cacheop_index(cpu_inst_cacheop_index),
                 .inst_cacheop_hit (cpu_inst_cacheop_hit),
                 .inst_cacheop_wb  (cpu_inst_cacheop_wb),
                 .inst_cacheop_addr(cpu_inst_cacheop_addr),
                 .inst_cacheop_ok1 (cpu_inst_cacheop_ok1),
                 .inst_cacheop_ok2 (cpu_inst_cacheop_ok2),

                 .data_sram_req    (cpu_data_req    ),
                 .data_sram_cached (cpu_data_cached ),
                 .data_sram_wr     (cpu_data_wr     ),
                 .data_sram_size   (cpu_data_size   ),
                 .data_sram_wstrb  (cpu_data_wstrb  ),
                 .data_sram_addr   (cpu_data_addr   ),
                 .data_sram_wdata  (cpu_data_wdata  ),
                 .data_sram_addr_ok(cpu_data_addr_ok),
                 .data_sram_data_ok(cpu_data_data_ok),
                 .data_sram_rdata  (cpu_data_rdata  ),
                 .data_cacheop     (cpu_data_cacheop),
                 .data_cacheop_index(cpu_data_cacheop_index),
                 .data_cacheop_hit (cpu_data_cacheop_hit),
                 .data_cacheop_wb  (cpu_data_cacheop_wb),
                 .data_cacheop_addr(cpu_data_cacheop_addr),
                 .data_cacheop_ok1 (cpu_data_cacheop_ok1),
                 .data_cacheop_ok2 (cpu_data_cacheop_ok2),

                 //debug interface
                 .debug_wb_pc      (debug_wb_pc      ),
                 .debug_wb_rf_wen  (debug_wb_rf_wen  ),
                 .debug_wb_rf_wnum (debug_wb_rf_wnum ),
                 .debug_wb_rf_wdata(debug_wb_rf_wdata)
             );

    sram_to_axi #
        (
            .I_NUM_WAY(I_NUM_WAY),
            .I_BYTES_PER_LINE(I_BYTES_PER_LINE),
            .I_NUM_LINE(I_NUM_LINE),
            .D_NUM_WAY(D_NUM_WAY),
            .D_BYTES_PER_LINE(D_BYTES_PER_LINE),
            .D_NUM_LINE(D_NUM_LINE)
        )
        sram_to_axi(
            .clk(aclk),
            .reset(~aresetn),

            .i_req    (cpu_inst_req    ),
            .i_uncached(~cpu_inst_cached),
            .i_wr     (cpu_inst_wr     ),
            .i_size   (cpu_inst_size   ),
            .i_wstrb  (cpu_inst_wstrb  ),
            .i_addr   (cpu_inst_addr   ),
            .i_wdata  (cpu_inst_wdata  ),
            .i_addr_ok(cpu_inst_addr_ok),
            .i_data_ok(cpu_inst_data_ok),
            .i_rdata  (cpu_inst_rdata  ),
            .i_cacheop     (cpu_inst_cacheop),
            .i_cacheop_index(cpu_inst_cacheop_index),
            .i_cacheop_hit (cpu_inst_cacheop_hit),
            .i_cacheop_wb  (cpu_inst_cacheop_wb),
            .i_cacheop_addr(cpu_inst_cacheop_addr),
            .i_cacheop_ok1 (cpu_inst_cacheop_ok1),
            .i_cacheop_ok2 (cpu_inst_cacheop_ok2),


            .d_req    (cpu_data_req    ),
            .d_uncached(~cpu_data_cached),
            .d_wr     (cpu_data_wr     ),
            .d_size   (cpu_data_size   ),
            .d_wstrb  (cpu_data_wstrb  ),
            .d_addr   (cpu_data_addr   ),
            .d_wdata  (cpu_data_wdata  ),
            .d_addr_ok(cpu_data_addr_ok),
            .d_data_ok(cpu_data_data_ok),
            .d_rdata  (cpu_data_rdata  ),
            .d_cacheop     (cpu_data_cacheop),
            .d_cacheop_index(cpu_data_cacheop_index),
            .d_cacheop_hit (cpu_data_cacheop_hit),
            .d_cacheop_wb  (cpu_data_cacheop_wb),
            .d_cacheop_addr(cpu_data_cacheop_addr),
            .d_cacheop_ok1 (cpu_data_cacheop_ok1),
            .d_cacheop_ok2 (cpu_data_cacheop_ok2),


            .arid(arid),
            .araddr(araddr),
            .arlen(arlen),
            .arsize(arsize),
            .arburst(arburst),
            .arlock(arlock),
            .arcache(arcache),
            .arprot(arprot),
            .arvalid(arvalid),
            .arready(arready),

            .rid(rid),
            .rdata(rdata),
            .rresp(rresp),
            .rlast(rlast),
            .rvalid(rvalid),
            .rready(rready),

            .awid(awid),
            .awaddr(awaddr),
            .awlen(awlen),
            .awsize(awsize),
            .awburst(awburst),
            .awlock(awlock),
            .awcache(awcache),
            .awprot(awprot),
            .awvalid(awvalid),
            .awready(awready),

            .wid(wid),
            .wdata(wdata),
            .wstrb(wstrb),
            .wlast(wlast),
            .wvalid(wvalid),
            .wready(wready),

            .bid(bid),
            .bresp(bresp),
            .bvalid(bvalid),
            .bready(bready)
        );

endmodule
