module tb_top(
        input clk,
        input resetn,
        output [31:0] wb_pc,
        output uart_out,
        output [7:0] uart_char
    );
    //cpu axi
    wire [3 :0] cpu_arid   ;
    wire [31:0] cpu_araddr ;
    wire [7 :0] cpu_arlen  ;
    wire [2 :0] cpu_arsize ;
    wire [1 :0] cpu_arburst;
    wire [1 :0] cpu_arlock ;
    wire [3 :0] cpu_arcache;
    wire [2 :0] cpu_arprot ;
    wire        cpu_arvalid;
    wire        cpu_arready;
    wire [3 :0] cpu_rid    ;
    wire [31:0] cpu_rdata  ;
    wire [1 :0] cpu_rresp  ;
    wire        cpu_rlast  ;
    wire        cpu_rvalid ;
    wire        cpu_rready ;
    wire [3 :0] cpu_awid   ;
    wire [31:0] cpu_awaddr ;
    wire [7 :0] cpu_awlen  ;
    wire [2 :0] cpu_awsize ;
    wire [1 :0] cpu_awburst;
    wire [1 :0] cpu_awlock ;
    wire [3 :0] cpu_awcache;
    wire [2 :0] cpu_awprot ;
    wire        cpu_awvalid;
    wire        cpu_awready;
    wire [3 :0] cpu_wid    ;
    wire [31:0] cpu_wdata  ;
    wire [3 :0] cpu_wstrb  ;
    wire        cpu_wlast  ;
    wire        cpu_wvalid ;
    wire        cpu_wready ;
    wire [3 :0] cpu_bid    ;
    wire [1 :0] cpu_bresp  ;
    wire        cpu_bvalid ;
    wire        cpu_bready ;

    //ram axi
    wire [3 :0] ram_arid   ;
    wire [31:0] ram_araddr ;
    wire [7 :0] ram_arlen  ;
    wire [2 :0] ram_arsize ;
    wire [1 :0] ram_arburst;
    wire [1 :0] ram_arlock ;
    wire [3 :0] ram_arcache;
    wire [2 :0] ram_arprot ;
    wire        ram_arvalid;
    wire        ram_arready;
    wire [3 :0] ram_rid    ;
    wire [31:0] ram_rdata  ;
    wire [1 :0] ram_rresp  ;
    wire        ram_rlast  ;
    wire        ram_rvalid ;
    wire        ram_rready ;
    wire [3 :0] ram_awid   ;
    wire [31:0] ram_awaddr ;
    wire [7 :0] ram_awlen  ;
    wire [2 :0] ram_awsize ;
    wire [1 :0] ram_awburst;
    wire [1 :0] ram_awlock ;
    wire [3 :0] ram_awcache;
    wire [2 :0] ram_awprot ;
    wire        ram_awvalid;
    wire        ram_awready;
    wire [3 :0] ram_wid    ;
    wire [31:0] ram_wdata  ;
    wire [3 :0] ram_wstrb  ;
    wire        ram_wlast  ;
    wire        ram_wvalid ;
    wire        ram_wready ;
    wire [3 :0] ram_bid    ;
    wire [1 :0] ram_bresp  ;
    wire        ram_bvalid ;
    wire        ram_bready ;

    //uart axi
    wire [3 :0] uart_arid   ;
    wire [31:0] uart_araddr ;
    wire [7 :0] uart_arlen  ;
    wire [2 :0] uart_arsize ;
    wire [1 :0] uart_arburst;
    wire [1 :0] uart_arlock ;
    wire [3 :0] uart_arcache;
    wire [2 :0] uart_arprot ;
    wire        uart_arvalid;
    wire        uart_arready;
    wire [3 :0] uart_rid    ;
    wire [31:0] uart_rdata  ;
    wire [1 :0] uart_rresp  ;
    wire        uart_rlast  ;
    wire        uart_rvalid ;
    wire        uart_rready ;
    wire [3 :0] uart_awid   ;
    wire [31:0] uart_awaddr ;
    wire [7 :0] uart_awlen  ;
    wire [2 :0] uart_awsize ;
    wire [1 :0] uart_awburst;
    wire [1 :0] uart_awlock ;
    wire [3 :0] uart_awcache;
    wire [2 :0] uart_awprot ;
    wire        uart_awvalid;
    wire        uart_awready;
    wire [3 :0] uart_wid    ;
    wire [31:0] uart_wdata  ;
    wire [3 :0] uart_wstrb  ;
    wire        uart_wlast  ;
    wire        uart_wvalid ;
    wire        uart_wready ;
    wire [3 :0] uart_bid    ;
    wire [1 :0] uart_bresp  ;
    wire        uart_bvalid ;
    wire        uart_bready ;

    mycpu_top cpu(
                  .ext_int   (6'd0          ),   //high active

                  .aclk      (clk       ),
                  .aresetn   (resetn    ),   //low active

                  .arid      (cpu_arid      ),
                  .araddr    (cpu_araddr    ),
                  .arlen     (cpu_arlen     ),
                  .arsize    (cpu_arsize    ),
                  .arburst   (cpu_arburst   ),
                  .arlock    (cpu_arlock    ),
                  .arcache   (cpu_arcache   ),
                  .arprot    (cpu_arprot    ),
                  .arvalid   (cpu_arvalid   ),
                  .arready   (cpu_arready   ),

                  .rid       (cpu_rid       ),
                  .rdata     (cpu_rdata     ),
                  .rresp     (cpu_rresp     ),
                  .rlast     (cpu_rlast     ),
                  .rvalid    (cpu_rvalid    ),
                  .rready    (cpu_rready    ),

                  .awid      (cpu_awid      ),
                  .awaddr    (cpu_awaddr    ),
                  .awlen     (cpu_awlen     ),
                  .awsize    (cpu_awsize    ),
                  .awburst   (cpu_awburst   ),
                  .awlock    (cpu_awlock    ),
                  .awcache   (cpu_awcache   ),
                  .awprot    (cpu_awprot    ),
                  .awvalid   (cpu_awvalid   ),
                  .awready   (cpu_awready   ),

                  .wid       (cpu_wid       ),
                  .wdata     (cpu_wdata     ),
                  .wstrb     (cpu_wstrb     ),
                  .wlast     (cpu_wlast     ),
                  .wvalid    (cpu_wvalid    ),
                  .wready    (cpu_wready    ),

                  .bid       (cpu_bid       ),
                  .bresp     (cpu_bresp     ),
                  .bvalid    (cpu_bvalid    ),
                  .bready    (cpu_bready    ),
                  .debug_wb_pc(wb_pc)
              );

    axi_crossbar #
        (
            .M_COUNT(2),
            .S_COUNT(1),
            .S_ID_WIDTH(4),
            .M_REGIONS(1),
            .M_BASE_ADDR({
                             64'h1fe41000_00000000
                         }),
            .M_ADDR_WIDTH({
                              32'd12, 32'd27
                          })
        ) axi_crossbar (
            .clk              ( clk     ),
            .rst            ( ~resetn   ),

            .s_axi_arid(cpu_arid),
            .s_axi_araddr(cpu_araddr),
            .s_axi_arlen(cpu_arlen),
            .s_axi_arsize(cpu_arsize),
            .s_axi_arburst(cpu_arburst),
            .s_axi_arlock(1'b0),
            .s_axi_arcache(cpu_arcache),
            .s_axi_arprot(cpu_arprot),
            .s_axi_arvalid(cpu_arvalid),
            .s_axi_arready(cpu_arready),
            .s_axi_rid(cpu_rid),
            .s_axi_rdata(cpu_rdata),
            .s_axi_rresp(cpu_rresp),
            .s_axi_rlast(cpu_rlast),
            .s_axi_rvalid(cpu_rvalid),
            .s_axi_rready(cpu_rready),
            .s_axi_awid(cpu_awid),
            .s_axi_awaddr(cpu_awaddr),
            .s_axi_awlen(cpu_awlen),
            .s_axi_awsize(cpu_awsize),
            .s_axi_awburst(cpu_awburst),
            .s_axi_awlock(0),
            .s_axi_awcache(cpu_awcache),
            .s_axi_awprot(cpu_awprot),
            .s_axi_awvalid(cpu_awvalid),
            .s_axi_awready(cpu_awready),
            .s_axi_wdata(cpu_wdata),
            .s_axi_wstrb(cpu_wstrb),
            .s_axi_wlast(cpu_wlast),
            .s_axi_wvalid(cpu_wvalid),
            .s_axi_wready(cpu_wready),
            .s_axi_bid(cpu_bid),
            .s_axi_bresp(cpu_bresp),
            .s_axi_bvalid(cpu_bvalid),
            .s_axi_bready(cpu_bready),

            .m_axi_arid({uart_arid, ram_arid}),
            .m_axi_araddr({uart_araddr, ram_araddr}),
            .m_axi_arlen({uart_arlen, ram_arlen}),
            .m_axi_arsize({uart_arsize, ram_arsize}),
            .m_axi_arburst({uart_arburst, ram_arburst}),
            .m_axi_arlock(),
            .m_axi_arcache({uart_arcache, ram_arcache}),
            .m_axi_arprot({uart_arprot, ram_arprot}),
            .m_axi_arvalid({uart_arvalid, ram_arvalid}),
            .m_axi_arready({uart_arready, ram_arready}),
            .m_axi_rid({uart_rid, ram_rid}),
            .m_axi_rdata({uart_rdata, ram_rdata}),
            .m_axi_rresp({uart_rresp, ram_rresp}),
            .m_axi_rlast({uart_rlast, ram_rlast}),
            .m_axi_rvalid({uart_rvalid, ram_rvalid}),
            .m_axi_rready({uart_rready, ram_rready}),
            .m_axi_awid({uart_awid, ram_awid}),
            .m_axi_awaddr({uart_awaddr, ram_awaddr}),
            .m_axi_awlen({uart_awlen, ram_awlen}),
            .m_axi_awsize({uart_awsize, ram_awsize}),
            .m_axi_awburst({uart_awburst, ram_awburst}),
            .m_axi_awlock(),
            .m_axi_awcache({uart_awcache, ram_awcache}),
            .m_axi_awprot({uart_awprot, ram_awprot}),
            .m_axi_awvalid({uart_awvalid, ram_awvalid}),
            .m_axi_awready({uart_awready, ram_awready}),
            .m_axi_wdata({uart_wdata, ram_wdata}),
            .m_axi_wstrb({uart_wstrb, ram_wstrb}),
            .m_axi_wlast({uart_wlast, ram_wlast}),
            .m_axi_wvalid({uart_wvalid, ram_wvalid}),
            .m_axi_wready({uart_wready, ram_wready}),
            .m_axi_bid({uart_bid, ram_bid}),
            .m_axi_bresp({uart_bresp, ram_bresp}),
            .m_axi_bvalid({uart_bvalid, ram_bvalid}),
            .m_axi_bready({uart_bready, ram_bready})
        );

    axi_ram
        #(
            .DATA_WIDTH(32),
            .ADDR_WIDTH(27),
            .ID_WIDTH(4),
            .INITIALISE(0)
        )
        ram(
            .clk            (clk),
            .rst            (~resetn),
            .s_axi_awlock(1'b0),
            .s_axi_awcache(4'b0),
            .s_axi_awprot(3'b0),
            .s_axi_arlock(1'b0),
            .s_axi_arcache(4'b0),
            .s_axi_arprot(3'b0),
            //ar
            .s_axi_arid     (ram_arid     ),
            .s_axi_araddr   (ram_araddr   ),
            .s_axi_arlen    (ram_arlen    ),
            .s_axi_arsize   (ram_arsize   ),
            .s_axi_arburst  (ram_arburst  ),
            .s_axi_arvalid  (ram_arvalid  ),
            .s_axi_arready  (ram_arready  ),
            //r
            .s_axi_rid      (ram_rid      ),
            .s_axi_rdata    (ram_rdata    ),
            .s_axi_rresp    (ram_rresp    ),
            .s_axi_rlast    (ram_rlast    ),
            .s_axi_rvalid   (ram_rvalid   ),
            .s_axi_rready   (ram_rready   ),
            //aw
            .s_axi_awid     (ram_awid     ),
            .s_axi_awaddr   (ram_awaddr   ),
            .s_axi_awlen    (ram_awlen    ),
            .s_axi_awsize   (ram_awsize   ),
            .s_axi_awburst  (ram_awburst  ),
            .s_axi_awvalid  (ram_awvalid  ),
            .s_axi_awready  (ram_awready  ),
            //w
            .s_axi_wdata    (ram_wdata    ),
            .s_axi_wstrb    (ram_wstrb    ),
            .s_axi_wlast    (ram_wlast    ),
            .s_axi_wvalid   (ram_wvalid   ),
            .s_axi_wready   (ram_wready   ),
            //b
            .s_axi_bid      (ram_bid      ),
            .s_axi_bresp    (ram_bresp    ),
            .s_axi_bvalid   (ram_bvalid   ),
            .s_axi_bready   (ram_bready   )
        );

    axi_ram
        #(
            .DATA_WIDTH(32),
            .ADDR_WIDTH(12),
            .ID_WIDTH(4),
            .INITIALISE(0)
        )
        uart_fake(
            .clk            (clk),
            .rst            (~resetn),
            .s_axi_awlock(1'b0),
            .s_axi_awcache(4'b0),
            .s_axi_awprot(3'b0),
            .s_axi_arlock(1'b0),
            .s_axi_arcache(4'b0),
            .s_axi_arprot(3'b0),
            //ar
            .s_axi_arid     (uart_arid     ),
            .s_axi_araddr   (uart_araddr   ),
            .s_axi_arlen    (uart_arlen    ),
            .s_axi_arsize   (uart_arsize   ),
            .s_axi_arburst  (uart_arburst  ),
            .s_axi_arvalid  (uart_arvalid  ),
            .s_axi_arready  (uart_arready  ),
            //r
            .s_axi_rid      (uart_rid      ),
            .s_axi_rdata    (uart_rdata    ),
            .s_axi_rresp    (uart_rresp    ),
            .s_axi_rlast    (uart_rlast    ),
            .s_axi_rvalid   (uart_rvalid   ),
            .s_axi_rready   (uart_rready   ),
            //aw
            .s_axi_awid     (uart_awid     ),
            .s_axi_awaddr   (uart_awaddr   ),
            .s_axi_awlen    (uart_awlen    ),
            .s_axi_awsize   (uart_awsize   ),
            .s_axi_awburst  (uart_awburst  ),
            .s_axi_awvalid  (uart_awvalid  ),
            .s_axi_awready  (uart_awready  ),
            //w
            .s_axi_wdata    (uart_wdata    ),
            .s_axi_wstrb    (uart_wstrb    ),
            .s_axi_wlast    (uart_wlast    ),
            .s_axi_wvalid   (uart_wvalid   ),
            .s_axi_wready   (uart_wready   ),
            //b
            .s_axi_bid      (uart_bid      ),
            .s_axi_bresp    (uart_bresp    ),
            .s_axi_bvalid   (uart_bvalid   ),
            .s_axi_bready   (uart_bready   )
        );
    assign uart_out = uart_wvalid & uart_wready;
    assign uart_char = uart_wdata[7:0];
    initial begin
        $readmemh("ram.mif", ram.mem);
        $readmemh("uart_fake.mif", uart_fake.mem);
        $readmemh("reg.mif", cpu.cpu_sram.regfile.registers);
    end
endmodule
