module addr_trans(
        input [31:0] virt_addr,
        output reg [31:0] phy_addr
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

    localparam offset_kseg0 = phy_kseg0_start - virt_kseg0_start;
    localparam offset_kseg1 = phy_kseg1_start - virt_kseg1_start;

    always @(virt_addr) begin
        if (virt_addr >= virt_kseg0_start) begin
            if (virt_addr < virt_kseg1_start)
                phy_addr = virt_addr + offset_kseg0;
            else if (virt_addr < virt_kseg2_start)
                phy_addr = virt_addr + offset_kseg1;
            else
                phy_addr = virt_addr;
        end
        else
            phy_addr = virt_addr;
    end
endmodule
