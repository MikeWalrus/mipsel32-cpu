module mux #
    (
        parameter num_port = 3,
        parameter data_width = 32,

        parameter select_width = $clog2(num_port)
    )
    (
        input [select_width-1:0] select,
        input [num_port*data_width-1:0] in,
        output [data_width-1:0] out
    );
    wire [num_port-1:0] select_1h;
    bin_to_1h
        #(.OUTPUT_WIDTH(num_port)) bin_to_1h
        (
            .binary(select),
            .one_hot(select_1h)
        );
    mux_1h
        #(.num_port(num_port), .data_width(data_width)) mux_1h
        (
            .select(select_1h),
            .in(in),
            .out(out)
        );
endmodule
