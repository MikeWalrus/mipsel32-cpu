module hazard_detect(
        input en,
        input reg_write_is_mem_EX,
        input mfc0_EX,
        input mfc0_MEM,

        input rs_data_ID_is_from_ex,
        input rt_data_ID_is_from_ex,
        input rs_data_ID_is_from_mem,
        input rt_data_ID_is_from_mem,
        output IF_ID_reg_stall
    );
    assign IF_ID_reg_stall = en &
           |{
               (reg_write_is_mem_EX|mfc0_EX)
               & (rs_data_ID_is_from_ex | rt_data_ID_is_from_ex),

               mfc0_MEM
               & (rs_data_ID_is_from_mem | rt_data_ID_is_from_mem)
           };
endmodule
