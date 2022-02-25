module div #
    (
        parameter WIDTH = 32,
        parameter COUNT_WIDTH = $clog2(WIDTH + 1)
    )
    (
        input clk,
        input reset,
        input en,
        input is_signed,
        input [WIDTH-1:0] dividend,
        input [WIDTH-1:0] divisor,
        output reg [WIDTH-1:0] quotient,
        output reg [WIDTH-1:0] remainder,
        output complete
    );
    reg [WIDTH-1:0] dividend_reg;
    reg [WIDTH:0] minuend;
    reg [COUNT_WIDTH-1:0] count;
    wire [COUNT_WIDTH-1:0] count_init = 0;

    wire [WIDTH:0] minuend_shifted;
    wire [WIDTH:0] minuend_next;
    wire [WIDTH-1:0] dividend_next;
    wire [WIDTH:0] difference;
    assign {minuend_shifted, dividend_next} = {minuend, dividend_reg} << 1;
    assign difference = minuend_shifted - divisor;
    wire can_subtract = ~difference[WIDTH];
    assign minuend_next = can_subtract ? difference : minuend_shifted;

    assign complete = count == WIDTH + 1;

    always @(posedge clk) begin
        if (!reset && en) begin
            count <= count + 1;
        end
        else begin
            count <= count_init;
        end
    end

    always @(posedge clk) begin
        if (!reset && en) begin
            if (count == count_init) begin
                dividend_reg <= dividend;
                minuend <= 0;
                quotient <= 0;
            end
            else begin
                minuend <= minuend_next;
                dividend_reg <= dividend_next;
                quotient[WIDTH - count] <= can_subtract;
            end

            if (count == WIDTH) begin
                remainder <= minuend_next[WIDTH-1:0];
            end
        end
    end

endmodule
