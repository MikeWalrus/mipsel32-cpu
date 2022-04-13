module exception_multiple #
(
    parameter NUM = 2
)
(
    input exception_old,
    input [4:0] exccode_old,

    input [NUM-1:0] exceptions,
    input [5*NUM-1:0] exccodes,

    output exception_out,
    output [4:0] exccode_out
);
    genvar i;
    for (i = NUM - 1; i >= 0; i = i - 1) begin: g
        wire exception_h;
        wire [4:0] exccode_h;
        wire _exception_out;
        wire [4:0] _exccode_out;
        exception_combine exception_combine(
            .exception_h(exception_h),
            .exccode_h(exccode_h),
            .exception_l(exceptions[i]),
            .exccode_l(exccodes[i*5+4:i*5]),
            .exception_out(_exception_out),
            .exccode_out(_exccode_out)
        );
    end

    assign g[NUM - 1].exception_h = exception_old;
    assign g[NUM - 1].exccode_h = exccode_old;

    assign exception_out = g[0]._exception_out;
    assign exccode_out = g[0]._exccode_out;

    for (i = NUM - 2; i >= 0; i = i - 1) begin
        assign g[i].exception_h = g[i + 1]._exception_out;
        assign g[i].exccode_h = g[i + 1]._exccode_out;
    end
endmodule
