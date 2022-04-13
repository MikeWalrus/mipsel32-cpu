module forwarding(
        input [4:0] r1,

        input is_ID_EX_valid,
        input [4:0] reg_write_addr_EX,
        input reg_write_EX,

        input is_EX_MEM_valid,
        input [4:0] reg_write_addr_MEM,
        input reg_write_MEM,

        input is_MEM_WB_valid,
        input [4:0] reg_write_addr_WB,
        input reg_write_WB,

        output r1_data_ID_is_no_forward,
        output r1_data_ID_is_from_ex,
        output r1_data_ID_is_from_mem,
        output r1_data_ID_is_from_wb
    );
    assign r1_data_ID_is_from_ex = is_ID_EX_valid &
           reg_write_EX & (r1 == reg_write_addr_EX) & (r1 != 5'b0);
    assign r1_data_ID_is_from_mem = is_EX_MEM_valid &
           ~r1_data_ID_is_from_ex & reg_write_MEM & (r1 == reg_write_addr_MEM) & (r1 != 5'b0);
    assign r1_data_ID_is_from_wb = is_MEM_WB_valid &
           ~r1_data_ID_is_from_ex & ~r1_data_ID_is_from_mem & reg_write_WB & (r1 == reg_write_addr_WB) & (r1 != 5'b0);
    assign r1_data_ID_is_no_forward =
           ~r1_data_ID_is_from_wb
           & ~r1_data_ID_is_from_mem
           & ~r1_data_ID_is_from_ex;
endmodule
