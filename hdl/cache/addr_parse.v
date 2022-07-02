module addr_parse #
    (
        parameter BYTES_PER_LINE = 16,
        parameter NUM_LINE = 256,

        parameter OFFSET_WIDTH = $clog2(BYTES_PER_LINE),
        parameter INDEX_WIDTH = $clog2(NUM_LINE),
        parameter TAG_WIDTH = 32 - OFFSET_WIDTH - INDEX_WIDTH
    )
    (
        input [31:0] addr,
        output [INDEX_WIDTH-1:0] index,
        output [TAG_WIDTH-1:0] tag,
        output [OFFSET_WIDTH-1:0] offset
    );
    assign index = addr[(31-TAG_WIDTH)-:INDEX_WIDTH];
    assign tag = addr[31-:TAG_WIDTH];
    assign offset = addr[0+:OFFSET_WIDTH];
endmodule
