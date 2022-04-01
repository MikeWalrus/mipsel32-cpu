module data_sram_request(
        output data_sram_req,
        output data_sram_wr,
        output [1:0] data_sram_size,
        output [3:0] data_sram_wstrb,
        output [31:0] data_sram_addr,
        output [31:0] data_sram_wdata,
        input data_sram_addr_ok,

        input mem_en_EX,
        input mem_wen_EX,

        input [31:0] data,
        input [31:0] virt_addr,

        input ID_EX_reg_valid,
        input ID_EX_reg_allow_out,
        input exception_EX_MEM_WB,
        input mem_w_EX,
        input mem_h_EX,
        input mem_b_EX,
        input mem_hu_EX,
        input mem_bu_EX,
        input mem_wl_EX,
        input mem_wr_EX,

        output mem_addr_unaligned,
        output ID_EX_reg_stall_mem_not_ready,
        output [1:0] byte_offset_EX
    );
    assign data_sram_req = ID_EX_reg_valid
           & (mem_en_EX | mem_wen_EX)
           // avoid sending multiple requests when stalling:
           & ID_EX_reg_allow_out
           // avoid sending request when exceptions have happened:
           & ~exception_EX_MEM_WB;

    reg [2:0] wstrb_count;
    integer i;
    always @(*) begin
        wstrb_count = 0;
        for (i = 0; i < 4; i = i + 1) begin
            wstrb_count = wstrb_count + {2'b0, data_sram_wstrb[i]};
        end
    end

    reg [1:0] w_size;
    always @(*) begin
        case(wstrb_count)
            3'd1:
                w_size = 0;
            3'd2:
                w_size = 1;
            3'd3:
                w_size = 2;
            3'd4:
                w_size = 2;
            default:
                w_size = 2'bxx;
        endcase
    end

    assign data_sram_size =
           data_sram_wr ? w_size :
           ({2{mem_w_EX}} & 2'd2)
           | ({2{mem_h_EX}} & 2'd1)
           | ({2{mem_b_EX}} & 2'd0);
    assign data_sram_wr = mem_wen_EX;

    mem_wstrb_gen mem_wstrb_gen(
                      .byte_offset(byte_offset_EX),
                      .wen_1b(
                          &{mem_wen_EX,
                            ID_EX_reg_valid,
                            ~exception_EX_MEM_WB
                           }),
                      .write_b(mem_b_EX),
                      .write_h(mem_h_EX),
                      .write_w(mem_w_EX),
                      .swl(mem_wl_EX),
                      .swr(mem_wr_EX),
                      .wstrb(data_sram_wstrb)
                  );

    mem_write_data_gen mem_write_data_gen(
                           .data(data),
                           .write_b(mem_b_EX),
                           .write_h(mem_h_EX),
                           .write_w(mem_w_EX),
                           .swl(mem_wl_EX),
                           .swr(mem_wr_EX),
                           .byte_offset(byte_offset_EX),
                           .mem_write_data(data_sram_wdata)
                       );

    mem_addr_check mem_addr_check(
                       .w(mem_w_EX & ~mem_wl_EX & ~mem_wr_EX),
                       .h(mem_h_EX | mem_hu_EX),
                       .b(mem_b_EX | mem_bu_EX),
                       .byte_offset(byte_offset_EX),
                       .unaligned(mem_addr_unaligned)
                   );

    addr_trans addr_trans_data(
                   .virt_addr(virt_addr),
                   .phy_addr(data_sram_addr)
               );

    assign byte_offset_EX = data_sram_addr[1:0];

    assign ID_EX_reg_stall_mem_not_ready =
           ~data_sram_addr_ok & data_sram_req;
endmodule
