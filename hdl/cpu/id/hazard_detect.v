module hazard_detect(
        input en,

        input reg_write_is_mem_EX,
        input reg_write_is_mem_MEM,
        input mem_wait_for_data,
        input mfc0_EX,
        input mfc0_MEM,
        input is_result_product_EX,

        input rs_data_ID_is_from_ex,
        input rt_data_ID_is_from_ex,
        input rs_data_ID_is_from_mem,
        input rt_data_ID_is_from_mem,
        output IF_ID_reg_stall
    );
    assign IF_ID_reg_stall = en &
           |{
               (reg_write_is_mem_EX | mfc0_EX | is_result_product_EX)
               & (rs_data_ID_is_from_ex | rt_data_ID_is_from_ex),

               (mfc0_MEM | (reg_write_is_mem_MEM & mem_wait_for_data))
               & (rs_data_ID_is_from_mem | rt_data_ID_is_from_mem)
           };
endmodule
