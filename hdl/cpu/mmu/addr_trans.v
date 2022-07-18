`include "cp0.vh"

module addr_trans #
    (
        parameter TLB = 1
    )
    (
        input [31:0] virt_addr,
        output [31:0] phy_addr,
        output tlb_mapped,
        (* MARK_DEBUG = "FALSE" *)output cached,

        // TLB
        output [18:0] vpn2,
        output odd_page,
        input [19:0] pfn,
        input [2:0] c,
        (* MARK_DEBUG = "FALSE" *)input [2:0] cp0_config_k0
    );
    // localparam virt_kuseg_start = 32'h0000_0000;
    localparam virt_kseg0_start = 32'h8000_0000;
    localparam virt_kseg1_start = 32'hA000_0000;
    localparam virt_kseg2_start = 32'hC000_0000;
    // localparam virt_kseg3_start = 32'hE000_0000;

    // localparam phy_kuseg_start = virt_kuseg_start;
    localparam phy_kseg0_start = 32'h0000_0000;
    localparam phy_kseg1_start = 32'h0000_0000;
    // localparam phy_kseg2_start = virt_kseg2_start;
    // localparam phy_kseg3_start = virt_kseg3_start;

    localparam [31:0] offset_kseg0 = phy_kseg0_start - virt_kseg0_start;
    localparam [31:0] offset_kseg1 = phy_kseg1_start - virt_kseg1_start;

    wire kseg0 =
         virt_addr >= virt_kseg0_start && virt_addr < virt_kseg1_start;
    wire kseg1 =
         virt_addr >= virt_kseg1_start && virt_addr < virt_kseg2_start;
    wire mapped = ~kseg0 & ~kseg1;
    wire [31:0] mapped_addr;

    if (!TLB) begin
        assign tlb_mapped = 0;
        assign mapped_addr = virt_addr;
        mux_1h #(.num_port(3), .data_width(1))
               cached_mux(
                   .select({kseg0, kseg1, mapped}),
                   .in(
                       {
                           cp0_config_k0 == `CACHED,
                           1'b0,
                           1'b0 // NOTE: not sure about this
                       }),
                   .out(cached)
               );
    end else begin
        assign tlb_mapped = mapped;
        assign {vpn2, odd_page} = virt_addr[31-:20];
        assign mapped_addr = {pfn, virt_addr[0+:12]};
        mux_1h #(.num_port(3), .data_width(1))
               cached_mux(
                   .select({kseg0, kseg1, mapped}),
                   .in(
                       {
                           cp0_config_k0 == `CACHED,
                           1'b0,
                           c == `CACHED
                       }),
                   .out(cached)
               );
    end

    mux_1h #(.num_port(3))
           phy_addr_mux(
               .select({kseg0, kseg1, mapped}),
               .in(
                   {
                       virt_addr + offset_kseg0,
                       virt_addr + offset_kseg1,
                       mapped_addr
                   }),
               .out(phy_addr)
           );
endmodule
