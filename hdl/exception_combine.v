// Combines two exceptions.
// Make sure that exceptions of lower
// priority cannot overwrite exccode.

module exception_combine(
        input exception_h,
        input [4:0] exccode_h,

        input exception_l,
        input [4:0] exccode_l,

        output reg exception_out,
        output reg [4:0] exccode_out
    );
    always @(*) begin
        exception_out = exception_h;
        exccode_out = exccode_h;
        if (exception_l) begin
            exception_out = 1;
            if (exception_h)
                exccode_out = exccode_h;
            else
                exccode_out = exccode_l;
        end
    end
endmodule
