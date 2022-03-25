module pc #
    (parameter pc_reset = 'hBFC0_0000)
    (
        input clk,
        input reset,
        input wen,
        input [31:0] next,
        output reg [31:0] out
    );
    always @(posedge clk) begin
        if (reset)
            out <= pc_reset;
        else
            if (wen)
                out <= next;
    end
endmodule
