module pipeline_reg #
    (
        parameter WIDTH = 1
    )
    (
        input clk,
        input reset,
        input stall,
        input valid_in,
        output allow_in,
        input allow_out,
        output valid_out,
        input [WIDTH-1:0] in,
        output reg [WIDTH-1:0] out,
        output reg valid
    );
    assign valid_out = valid & ~stall;
    assign allow_in = ~valid | (~stall & allow_out);
    always @(posedge clk) begin
        if (reset)
            valid <= 0;
        else if (allow_in)
            valid <= valid_in;

        if (valid_in && allow_in)
            out <= in;
    end
endmodule
