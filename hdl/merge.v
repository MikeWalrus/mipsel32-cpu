module merge #
    (
        parameter left = 1
    )
    (
        input [31:0] mem_word,
        input [31:0] reg_word,
        input [1:0] byte_addr,
        output [31:0] merged_word
    );
    genvar i;
    for (i = 0; i < 4; i = i + 1) begin :generate_block
        wire [31:0] merged;
        if (left) begin
            localparam len = i * 8 + 8;
            assign merged[31:32-len] = mem_word[len-1:0];
            if (31 - len >= 0)
                assign merged[31-len:0] = reg_word[31-len:0];
        end else begin
            localparam len = 32 - i * 8;
            assign merged[len-1:0] = mem_word[31:32-len];
            if (len < 32)
                assign merged[31:len] = reg_word[31:len];
        end
    end
    wire [31:0] merged_words [3:0];
    for (i = 0; i < 4; i = i + 1) begin
        assign merged_words[i] = generate_block[i].merged;
    end
    assign merged_word = merged_words[byte_addr];
endmodule
