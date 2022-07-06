module data_sram_request #
    (
        parameter TLB = 1
    )
    (
        output data_sram_req,
        output data_sram_cached,
        output data_sram_wr,
        output [1:0] data_sram_size,
        output [3:0] data_sram_wstrb,
        output [31:0] data_sram_addr,
        output [31:0] data_sram_wdata,
        input data_sram_addr_ok,

        output inst_cacheop,
        output inst_cacheop_index,
        output inst_cacheop_hit,
        output inst_cacheop_wb,
        output [31:0] inst_cacheop_addr,
        input inst_cacheop_ok1,

        output data_cacheop,
        output data_cacheop_index,
        output data_cacheop_hit,
        output data_cacheop_wb,
        output [31:0] data_cacheop_addr,
        input data_cacheop_ok1,

        input mem_ren_EX,
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
        output [1:0] byte_offset_EX,

        // TLB
        output [18:0] vpn2,
        output odd_page,
        input [19:0] pfn,
        input found,
        input v,
        input d,
        input [2:0] c,

        input cacheop_i,
        input cacheop_d,
        input cacheop_index,
        input cacheop_hit,
        input cacheop_wb,

        input [2:0] cp0_config_k0,

        output tlb_refill,
        output tlb_error,
        output tlb_mod
    );
    wire [31:0] phy_addr;
    assign data_sram_addr = phy_addr;

    wire req =
         (ID_EX_reg_valid
`ifdef sram
          // avoid sending multiple requests when stalling:
          & ID_EX_reg_allow_out
`endif
          // avoid sending request when exceptions have happened:
          & ~exception_EX_MEM_WB) ? 1 : 0;
    assign data_sram_req = req & (mem_ren_EX | mem_wen_EX);
    assign inst_cacheop = ID_EX_reg_valid & ~exception_EX_MEM_WB & cacheop_i;
    assign data_cacheop = ID_EX_reg_valid & ~exception_EX_MEM_WB & cacheop_d;

    assign inst_cacheop_hit = cacheop_hit;
    assign inst_cacheop_index = cacheop_index;
    assign inst_cacheop_wb = cacheop_wb;
    assign inst_cacheop_addr = phy_addr;
    assign data_cacheop_hit = cacheop_hit;
    assign data_cacheop_index = cacheop_index;
    assign data_cacheop_wb = cacheop_wb;
    assign data_cacheop_addr = phy_addr;

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

    wire virt_mapped;
    addr_trans #(.TLB(TLB)) addr_trans_data(
                   .virt_addr(virt_addr),
                   .phy_addr(phy_addr),
                   .tlb_mapped(virt_mapped),
                   .cached(data_sram_cached),

                   .vpn2(vpn2),
                   .odd_page(odd_page),
                   .pfn(pfn),
                   .c(c),
                   .cp0_config_k0(cp0_config_k0)
               );
    assign tlb_refill = virt_mapped & ~found;
    assign tlb_error = virt_mapped & (mem_ren_EX | mem_wen_EX) & ~(found & v);
    assign tlb_mod = virt_mapped & mem_wen_EX & (found & v & ~d);

    assign byte_offset_EX = data_sram_addr[1:0];

    assign ID_EX_reg_stall_mem_not_ready =
           |{
               ~data_sram_addr_ok & data_sram_req,
               ~inst_cacheop_ok1 & inst_cacheop,
               ~data_cacheop_ok1 & data_cacheop
           };
endmodule
