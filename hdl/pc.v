module pc #
    (parameter pc_reset = 'hBFC0_0000)
    (
        input clk,
        input reset,
        input [31:0] next,
        output reg [31:0] out
    );
    always @(posedge clk) begin
        if (reset)
            out <= pc_reset - 4;
        else
            out <= next;
    end
endmodule
