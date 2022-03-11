module mem_write_data_gen(
        input [31:0] data,
        input write_b,
        input write_h,
        input write_w,
        input swl,
        input swr,
        input [1:0] byte_offset,
        output [31:0] mem_write_data
    );
    wire [31:0] b = {4{data[0+:8]}};
    wire [31:0] h = {2{data[0+:16]}};

    genvar i;
    for (i = 0; i < 4; i = i + 1) begin :l
        localparam len = i * 8 + 8;
        localparam shift_amount = 31 - (len - 1);
        wire [31:0] shifted = data >> shift_amount;
    end
    wire [31:0] swl_data [3:0];
    for (i = 0; i < 4; i = i + 1) begin
        assign swl_data[i] = l[i].shifted;
    end

    for (i = 0; i < 4; i = i + 1) begin :r
        localparam len = 32 - i * 8;
        localparam shift_amount = 31 - (len - 1);
        wire [31:0] shifted = data << shift_amount;
    end
    wire [31:0] swr_data [3:0];
    for (i = 0; i < 4; i = i + 1) begin
        assign swr_data[i] = r[i].shifted;
    end

    assign mem_write_data =
           ({32{write_b}} & b)
           | ({32{write_h}} & h)
           | ({32{write_w}} & data)
           | ({32{swl}} & swl_data[byte_offset])
           | ({32{swr}} & swr_data[byte_offset]);
endmodule
