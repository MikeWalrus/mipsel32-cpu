module mem_addr_check(
        input w,
        input h,
        input b,
        input [1:0] byte_offset,
        output unaligned
    );
    wire word_aligned = byte_offset[1:0] == 2'b0;
    wire halfword_aligned = byte_offset[0] == 1'b0;
    wire byte_aligned = 1'b1;
    assign unaligned =
           |{
               w & ~word_aligned,
               h & ~halfword_aligned,
               b & ~byte_aligned
           };
endmodule
