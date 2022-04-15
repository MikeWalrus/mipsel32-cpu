`include "cp0.vh"

module cp0 #
    (
        parameter TLBNUM = 16,
        parameter TLBNUM_WIDTH = $clog2(TLBNUM)
    )
    (
        input clk,
        input reset,
        input [4:0] reg_num,
        input [1:0] sel,
        input [31:0] reg_in,

        input wen,
        input exception_like,
        input is_delay_slot,
        input [31:0] pc,
        input [5:0] interrupt,
        input [4:0] exccode,
        input [31:0] badvaddr_in,
        input tlbp,
        input [TLBNUM_WIDTH:0] tlbp_result,
        input tlbr,

        output reg [31:0] reg_out,

        output reg [31:0] epc,
        output reg [7:0] cause_ip,
        output reg [7:0] status_im,
        output reg status_ie,
        output reg status_exl,
        output reg [18:0] entry_hi_vpn2,
        output reg [7:0] entry_hi_asid,

        output reg exception_now,
        output eret_now,
        output refetch_now,

        // TLB write port
        output  [$clog2(TLBNUM)-1:0] w_index,
        output  [18:0]               w_vpn2,
        output  [7:0]                w_asid,
        output                       w_g,
        output  [19:0]               w_pfn0,
        output  [2:0]                w_c0,
        output                       w_d0,
        output                       w_v0,
        output  [19:0]               w_pfn1,
        output  [2:0]                w_c1,
        output                       w_d1,
        output                       w_v1,
        // TLB read port
        output  [$clog2(TLBNUM)-1:0] r_index,
        input  [18:0]                r_vpn2,
        input  [7:0]                 r_asid,
        input                        r_g,
        input  [19:0]                r_pfn0,
        input  [2:0]                 r_c0,
        input                        r_d0,
        input                        r_v0,
        input  [19:0]                r_pfn1,
        input  [2:0]                 r_c1,
        input                        r_d1,
        input                        r_v1
    );
    wire eret = exception_like & exccode == `ERET;
    wire refetch = exception_like & exccode == `REFETCH;
    wire exception = exception_like & ~eret & ~refetch;
    wire status_bev = 1'b1;
    // reg [7:0] status_im;
    // reg status_exl;
    // reg status_ie;
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
    // reg [7:0] cause_ip;
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

    reg [31:0] count;
    reg [31:0] compare;

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
        end else if (exception)
            cause_exccode <= exccode;
    end

    // reg [31:0] epc;
    wire [31:0] epc_next = is_delay_slot ? pc - 32'd4 : pc;
    always @(posedge clk) begin
        if (exception & !status_exl) begin
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

    reg count_should_inc;

    always @(posedge clk) begin
        if (reset)
            count_should_inc <= 1'b1;
        else
            count_should_inc <= ~count_should_inc;
    end

    always @(posedge clk) begin
        if (reset) begin
            count <= 32'd0;
        end else if (wen && reg_num == `COUNT) begin
            count <= reg_in;
        end else if (count_should_inc)
            count <= count + 1;
    end

    always @(posedge clk) begin
        if (wen && reg_num == `COMPARE)
            compare <= reg_in;
    end

    reg index_p;
    reg [TLBNUM_WIDTH-1:0] index_index;
    wire [31:0] index = {index_p, {32-1-TLBNUM_WIDTH{1'b0}}, index_index};

    always @(posedge clk) begin
        if (reset) begin
            index_p <= 0;
        end else if (tlbp) begin
            index_p <= tlbp_result[TLBNUM_WIDTH];
            index_index <= tlbp_result[TLBNUM_WIDTH-1:0];
        end else if (wen && reg_num == `INDEX) begin
            index_index <= reg_in[TLBNUM_WIDTH-1:0];
        end
    end

    reg [19:0] entry_lo_pfn [1:0];
    reg [2:0] entry_lo_c [1:0];
    reg entry_lo_d [1:0];
    reg entry_lo_v [1:0];
    reg entry_lo_g [1:0];
    wire [31:0] entry_lo [1:0];

    wire [19:0] r_pfn [1:0];
    wire [2:0] r_c [1:0];
    wire r_d [1:0];
    wire r_v [1:0];

    assign r_pfn[0] = r_pfn0;
    assign r_pfn[1] = r_pfn1;
    assign r_c[0] = r_c0;
    assign r_c[1] = r_c1;
    assign r_d[0] = r_d0;
    assign r_d[1] = r_d1;
    assign r_v[0] = r_v0;
    assign r_v[1] = r_v1;

    genvar i;
    for (i = 0; i < 2; i = i + 1) begin
        assign entry_lo[i] =
               {
                   6'b0,
                   entry_lo_pfn[i],
                   entry_lo_c[i],
                   entry_lo_d[i],
                   entry_lo_v[i],
                   entry_lo_g[i]
               };
        always @(posedge clk) begin
            if (tlbr) begin
                entry_lo_pfn[i] <= r_pfn[i];
                entry_lo_c[i] <= r_c[i];
                entry_lo_d[i] <= r_d[i];
                entry_lo_v[i] <= r_v[i];
                entry_lo_g[i] <= r_g;
            end else if (wen && reg_num == `ENTRYLO0+i[4:0]) begin
                {
                    entry_lo_pfn[i],
                    entry_lo_c[i],
                    entry_lo_d[i],
                    entry_lo_v[i],
                    entry_lo_g[i]
                } <= reg_in[25:0];
            end
        end
    end

    // reg [18:0] entry_hi_vpn2;
    // reg [7:0] entry_hi_asid;
    wire [31:0] entry_hi = {entry_hi_vpn2, 5'b0, entry_hi_asid};
    always @(posedge clk) begin
        if (tlbr) begin
            entry_hi_vpn2 <= r_vpn2;
            entry_hi_asid <= r_asid;
        end else if (wen & reg_num == `ENTRYHI) begin
            entry_hi_vpn2 <= reg_in[31:13];
            entry_hi_asid <= reg_in[7:0];
        end
    end

    assign w_index = index_index;
    assign w_vpn2 = entry_hi_vpn2;
    assign w_asid = entry_hi_asid;
    assign w_g = entry_lo_g[0] & entry_lo_g[1];
    assign w_pfn0 = entry_lo_pfn[0];
    assign w_c0 = entry_lo_c[0];
    assign w_d0 = entry_lo_d[0];
    assign w_v0 = entry_lo_v[0];
    assign w_pfn1 = entry_lo_pfn[1];
    assign w_c1 = entry_lo_c[1];
    assign w_d1 = entry_lo_d[1];
    assign w_v1 = entry_lo_v[1];

    assign r_index = index_index;

    always @(*) begin
        case (reg_num)
            `INDEX:
                reg_out = index;
            `ENTRYLO0:
                reg_out = entry_lo[0];
            `ENTRYLO1:
                reg_out = entry_lo[1];
            `ENTRYHI:
                reg_out = entry_hi;
            `STATUS:
                reg_out = status;
            `CAUSE:
                reg_out = cause;
            `EPC:
                reg_out = epc;
            `BADVADDR:
                reg_out = badvaddr;
            `COUNT:
                reg_out = count;
            default:
                reg_out = 0;
        endcase
    end

    always @(*) begin
        exception_now = 0;
        if (exception & ~status_exl) begin
            exception_now = 1;
        end
    end
    assign eret_now = eret;
    assign refetch_now = refetch;
endmodule