module regfile #
    (
        parameter NUM_REG  = 32,
        parameter ADDR_WIDTH = $clog2(NUM_REG)
    )
    (
        input clk,
        input [ADDR_WIDTH-1:0] r_addr1,
        output [31:0] r_data1,
        input [ADDR_WIDTH-1:0] r_addr2,
        output [31:0] r_data2,
        input w_enable,
        input [ADDR_WIDTH-1:0] w_addr,
        input [31:0] w_data
    );
    reg [31:0] registers[NUM_REG-1:0];
    assign r_data1 = (r_addr1 == {ADDR_WIDTH{1'b0}}) ? 32'b0 : registers[r_addr1];
    assign r_data2 = (r_addr2 == {ADDR_WIDTH{1'b0}}) ? 32'b0 : registers[r_addr2];
    always @(posedge clk) begin
        if (w_enable)
            registers[w_addr] <= w_data;
    end
endmodule
