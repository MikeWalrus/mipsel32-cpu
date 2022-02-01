`include "common.vh"

module regfile_test;
    reg clk;
    reg [4:0] r_addr1;
    wire [31:0] r_data1;
    reg [4:0] r_addr2;
    wire [31:0] r_data2;
    reg w_enable;
    reg [4:0] w_addr;
    reg [31:0] w_data;

    task step;
        begin
            #5;
            clk = ~clk;
            clk = ~clk;
        end
    endtask

    task write_data(input [31:0] data, input [4:0] addr);
        begin
            w_enable = 1;
            w_data = data;
            w_addr = addr;
            step;
            w_enable = 0;
        end
    endtask

    regfile r(.clk(clk),
              .r_addr1(r_addr1),
              .r_addr2(r_addr2),
              .r_data1(r_data1),
              .r_data2(r_data2),
              .w_data(w_data),
              .w_addr(w_addr),
              .w_enable(w_enable)
             );

    initial begin
        clk = 0;
        w_enable = 0;

        for (integer i = 0; i < 32; i++) begin
            write_data(i, i);
            r_addr1 = i;
            step;
            `assert(r_data1, i, "");
        end
        for (integer i = 0; i < 32; i++) begin
            r_addr2 = i;
            step;
            `assert(r_data2, i, "");
        end
        write_data(0, 1);
        r_addr1 = 0;
        step;
        `assert(r_data1, 0, "$0 should always be 0");
    end
endmodule
