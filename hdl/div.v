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
        output [WIDTH-1:0] quotient,
        output [WIDTH-1:0] remainder,
        output complete
    );
    reg [WIDTH-1:0] quotient_u;
    reg [WIDTH-1:0] remainder_u;
    wire [WIDTH-1:0] dividend_abs;
    wire [WIDTH-1:0] divisor_abs;
    wire dividend_sign;
    wire divisor_sign;
    wire quotient_sign;
    wire remainder_sign;

    assign quotient_sign = dividend_sign ^ divisor_sign;
    assign remainder_sign = dividend_sign;

    wire [WIDTH-1:0] quotient_signed = quotient_sign ? -quotient_u : quotient_u;
    wire [WIDTH-1:0] remainder_signed = remainder_sign ? -remainder_u : remainder_u;

    assign quotient = is_signed ? quotient_signed : quotient_u;
    assign remainder = is_signed ? remainder_signed : remainder_u;

    signed_to_abs signed_to_abs_dividend(
                      .num(dividend),
                      .abs_value(dividend_abs),
                      .sign(dividend_sign)
                  );
    signed_to_abs signed_to_abs_divisor(
                      .num(divisor),
                      .abs_value(divisor_abs),
                      .sign(divisor_sign)
                  );

    wire [WIDTH-1:0] dividend_u;
    wire [WIDTH-1:0] divisor_u;
    assign dividend_u = is_signed ? dividend_abs : dividend;
    assign divisor_u = is_signed ? divisor_abs : divisor;

    reg [WIDTH-1:0] dividend_reg;
    reg [WIDTH:0] minuend;
    reg [COUNT_WIDTH-1:0] count;
    wire [COUNT_WIDTH-1:0] count_init = 0;

    wire [WIDTH:0] minuend_shifted;
    wire [WIDTH:0] minuend_next;
    wire [WIDTH-1:0] dividend_next;
    wire [WIDTH:0] difference;
    assign {minuend_shifted, dividend_next} = {minuend, dividend_reg} << 1;
    assign difference = minuend_shifted - divisor_u;
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
                dividend_reg <= dividend_u;
                minuend <= 0;
                quotient_u <= 0;
            end
            else begin
                minuend <= minuend_next;
                dividend_reg <= dividend_next;
                quotient_u[WIDTH - count] <= can_subtract;
            end

            if (count == WIDTH) begin
                remainder_u <= minuend_next[WIDTH-1:0];
            end
        end
    end

endmodule
