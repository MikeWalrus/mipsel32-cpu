module isolate_rightmost #
    (
        parameter WIDTH = 2
    )
    (
        input en,
        input [WIDTH-1:0] in,
        output [WIDTH-1:0] out
    );
    // Isolate the rightmost bit
    // http://fpgacpu.ca/fpga/Bitmask_Isolate_Rightmost_1_Bit.html
    assign out = in & -in & {WIDTH{en}};
endmodule
