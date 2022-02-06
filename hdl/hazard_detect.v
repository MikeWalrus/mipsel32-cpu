module hazard_detect(
        input reg_write_is_mem_EX,
        input rs_data_ID_is_from_ex,
        input rt_data_ID_is_from_ex,
        output IF_ID_reg_stall
    );
    assign IF_ID_reg_stall = reg_write_is_mem_EX
           & (rs_data_ID_is_from_ex | rt_data_ID_is_from_ex);
endmodule
