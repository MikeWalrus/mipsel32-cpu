module pipeline_reg #
    (
        parameter WIDTH = 1,
        parameter RESET = 0,
        parameter RESET_VALUE = 0
    )
    (
        input clk,
        input reset,
        input stall,
        input flush,

        input valid_in,
        output allow_in,
        input allow_out,
        output valid_out,
        input [WIDTH-1:0] in,
        output reg [WIDTH-1:0] out,
        output reg valid
    );
    assign valid_out = valid & ~stall;
    assign allow_in = ~valid | (~stall & allow_out) | flush;
    always @(posedge clk) begin
        if (reset) begin
            valid <= 0;
            if (RESET) begin
                out <= RESET_VALUE;
            end
        end
        else if (allow_in)
            valid <= valid_in & ~flush;

        if (valid_in && allow_in)
            out <= in;
    end
endmodule
