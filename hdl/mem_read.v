module mem_read(
        input [31:0] data_sram_rdata,
        input read_w,
        input read_b,
        input read_bu,
        input read_h,
        input read_hu,
        input [1:0] byte_offset,
        output [31:0] mem_read_data
    );
    wire [31:0] mem_read_word = data_sram_rdata;
    wire [31:0] b_extended;

    wire [7:0] bytes [3:0];
    genvar i;
    for (i = 0; i < 4; i = i + 1) begin
        assign bytes[i] = data_sram_rdata[i*8+7:i*8];
    end

    wire [15:0] halfwords [1:0];
    for (i = 0; i < 2; i = i + 1) begin
        assign halfwords[i] = data_sram_rdata[i*16+15:i*16];
    end

    wire [7:0] b = bytes[byte_offset];
    wire [15:0] h = halfwords[byte_offset[1]];

    extend #(.in_width(8), .sign_extend(1)) b_to_w(
               .in(b),
               .out(b_extended)
           );
    wire [31:0] h_extended;
    extend #(.in_width(16), .sign_extend(1)) h_to_w(
               .in(h),
               .out(h_extended)
           );
    wire [31:0] b_extended_u;
    extend #(.in_width(8), .sign_extend(0)) bu_to_w(
               .in(b),
               .out(b_extended_u)
           );
    wire [31:0] h_extended_u;
    extend #(.in_width(16), .sign_extend(0)) hu_to_w(
               .in(h),
               .out(h_extended_u)
           );

    mux_1h #(.num_port(5)) data_sram_read_mux (
               .select(
                   {
                       read_w,
                       read_b,
                       read_bu,
                       read_h,
                       read_hu
                   }),
               .in(
                   {
                       mem_read_word,
                       b_extended,
                       b_extended_u,
                       h_extended,
                       h_extended_u
                   }
               ),
               .out(mem_read_data)
           );
endmodule
