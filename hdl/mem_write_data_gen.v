module mem_write_data_gen(
        input [31:0] data,
        input write_b,
        input write_h,
        input write_w,
        output [31:0] mem_write_data
    );
    wire [31:0] b = {4{data[0+:8]}};
    wire [31:0] h = {2{data[0+:16]}};
    assign mem_write_data =
           ({32{write_b}} & b) |
           ({32{write_h}} & h) |
           ({32{write_w}} & data);
endmodule
