`include "cp0.vh"

module cp0(
        input clk,
        input reset,
        input [4:0] reg_num,
        input [1:0] sel,
        input [31:0] reg_in,

        input wen,
        input exception,
        input is_delay_slot,
        input [31:0] pc,
        input [5:0] interrupt,
        input [4:0] exccode,
        input [31:0] badvaddr_in,

        output reg [31:0] reg_out,
        output [31:0] epc_out,
        output [7:0] cause_ip_out,
        output [7:0] status_im_out,
        output status_ie_out,
        output status_exl_out,

        output reg exception_now,
        output reg eret_now
    );
    wire eret = exception & exccode == `ERET;
    wire status_bev = 1'b1;
    reg [7:0] status_im;
    assign status_im_out = status_im;
    reg status_exl;
    assign status_exl_out = status_exl;
    reg status_ie;
    assign status_ie_out = status_ie;
    wire [31:0] status =
         {
             {9{1'b0}},
             status_bev,
             {6{1'b0}},
             status_im,
             {6{1'b0}},
             status_exl,
             status_ie
         };

    always @(posedge clk) begin
        if (reset) begin
            status_exl <= 1'b0;
            status_ie <= 1'b0;
        end else if (eret) begin
            status_exl <= 1'b0;
        end else if (exception) begin
            status_exl <= 1'b1;
        end else if (reg_num == `STATUS) begin
            if (wen) begin
                status_ie <= reg_in[0];
                status_exl <= reg_in[1];
                status_im <= reg_in[15:8];
            end
        end
    end

    reg cause_bd;
    reg cause_ti;
    reg [7:0] cause_ip;
    assign cause_ip_out = cause_ip;
    reg [4:0] cause_exccode;
    wire [31:0] cause =
         {
             cause_bd,
             cause_ti,
             {14{1'b0}},
             cause_ip,
             1'b0,
             cause_exccode,
             {2{1'b0}}
         };

    always @(posedge clk) begin
        if (reset) begin
            cause_bd <= 1'b0;
            cause_ti <= 1'b0;
        end else if (exception) begin
            if (!status_exl)
                cause_bd <= is_delay_slot;
        end else if (wen && reg_num == `COMPARE)
            cause_ti <= 1'b0;
        else if (count == compare)
            cause_ti <= 1'b1;
    end

    always @(posedge clk) begin
        if (reset) begin
            cause_ip <= 8'd0;
        end else begin
            cause_ip[7] <= interrupt[5] | cause_ti;
            cause_ip[6:2] <= interrupt[4:0];
            if (wen && reg_num == `CAUSE) begin
                cause_ip[1:0] <= reg_in[9:8];
            end
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            cause_exccode <= 5'd0;
        end else if (exception & ~eret)
            cause_exccode <= exccode;
    end

    reg [31:0] epc;
    assign epc_out = epc;
    wire [31:0] epc_next = is_delay_slot ? pc - 32'd4 : pc;
    always @(posedge clk) begin
        if (exception & !status_exl & !eret) begin
            epc <= epc_next;
        end else if (wen && reg_num == `EPC)
            epc <= reg_in;
        else
            epc <= epc;
    end


    reg [31:0] badvaddr;
    always @(posedge clk) begin
        if (exception && (exccode == `EXC_AdEL || exccode == `EXC_AdES)) begin
            badvaddr <= badvaddr_in;
        end
    end


    reg [31:0] count;
    reg count_should_inc;

    always @(posedge clk) begin
        if (reset)
            count_should_inc <= 1'b1;
        else
            count_should_inc <= ~count_should_inc;
    end

    always @(posedge clk) begin
        if (reset) begin
            count_should_inc <= 1'b1;
            count <= 32'd0;
        end else if (wen && reg_num == `COUNT) begin
            count <= reg_in;
        end else if (count_should_inc)
            count <= count + 1;
    end


    reg [31:0] compare;
    always @(posedge clk) begin
        if (wen && reg_num == `COMPARE)
            compare <= reg_in;
    end

    always @(*) begin
        case (reg_num)
            `STATUS:
                reg_out = status;
            `CAUSE:
                reg_out = cause;
            `EPC:
                reg_out = epc;
            `BADVADDR:
                reg_out = badvaddr;
            default:
                reg_out = 0;
        endcase
    end

    always @(*) begin
        exception_now = 0;
        eret_now = 0;
        if (exception & ~status_exl) begin
            exception_now = 1;
        end
        if (eret) begin
            eret_now = 1;
        end
    end

endmodule
