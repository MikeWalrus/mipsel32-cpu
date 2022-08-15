`include "cp0.vh"

module cp0 #
    (
        // TLB
        parameter TLBNUM = 16,
        parameter TLBNUM_WIDTH = $clog2(TLBNUM),

        // Cache
        parameter I_NUM_WAY = 2,
        // BYTES_PER_LINE * NUM_LINE must <= 4096
        parameter I_BYTES_PER_LINE = 32,
        parameter I_NUM_LINE = 128,
        parameter D_NUM_WAY = 2,
        // BYTES_PER_LINE * NUM_LINE must <= 4096
        parameter D_BYTES_PER_LINE = 16,
        parameter D_NUM_LINE = 256,

        parameter CONFIG_K0 = `CACHED,
        parameter PRID = 32'h7000
    )
    (
        input clk,
        input reset,
        input [4:0] reg_num,
        input [2:0] sel,
        input [31:0] reg_in,

        // From WB
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
        input tlbwr,
        input [18:0] tlb_error_vpn2,
        input tlb_refill,

        // To WB
        output reg [31:0] reg_out,

        output reg [7:0] cause_ip,
        output reg [7:0] status_im,
        output reg status_ie,
        output reg status_exl,
        output reg [18:0] entry_hi_vpn2,
        output reg [7:0] entry_hi_asid,
        output reg [2:0] config_k0,

        // To pre-IF
        output exception_like_now,
        output [31:0] exception_like_now_pc,

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
    wire exception = exception_like & ~eret;
    wire exc_tlb_refill = exception & tlb_refill;
    wire exc_int = exception & exccode == `EXC_Int;
    wire exc = exception & ~exc_tlb_refill & ~exc_int;

    localparam [0:0] config_m = 1'b1;
    localparam [0:0] config_be = 1'b0;
    localparam [1:0] config_at = 2'b0;
    localparam [2:0] config_ar = 3'b0;
    localparam [2:0] config_mt = 3'b1;
    // reg [2:0] config_k0;
    always @(posedge clk) begin
        if (reset)
            config_k0 <= CONFIG_K0;
        else if (reg_num == `CONFIG && sel == 0) begin
            if (wen)
                config_k0 <= reg_in[2:0];
        end
    end
    wire [31:0] config_ = {
             config_m,
             15'b0,
             config_be,
             config_at,
             config_ar,
             config_mt,
             4'b0,
             config_k0
         };

    localparam [2:0] tmp_is = $clog2(I_NUM_LINE);
    localparam [2:0] tmp_il = $clog2(I_BYTES_PER_LINE);
    localparam [2:0] tmp_ds = $clog2(D_NUM_LINE);
    localparam [2:0] tmp_dl = $clog2(D_BYTES_PER_LINE);

    localparam [0:0] config1_m = 1'b1;
    localparam [5:0] config1_mmu_size_1 = TLBNUM[5:0] - 6'b1;
    localparam [2:0] config1_is = tmp_is - 3'h6;
    localparam [2:0] config1_il = tmp_il - 3'h1;
    localparam [2:0] config1_ia = I_NUM_WAY - 1;
    localparam [2:0] config1_ds = tmp_ds - 3'h6;
    localparam [2:0] config1_dl = tmp_dl - 3'h1;
    localparam [2:0] config1_da = D_NUM_WAY - 1;
    localparam [0:0] config1_c2 = 0;
    localparam [0:0] config1_md = 0;
    localparam [0:0] config1_pc = 0;
    localparam [0:0] config1_wr = 0;
    localparam [0:0] config1_ca = 0;
    localparam [0:0] config1_ep = 0;
    localparam [0:0] config1_fp = 0;
    wire [31:0] config1 = {
             config1_m,
             config1_mmu_size_1,
             config1_is,
             config1_il,
             config1_ia,
             config1_ds,
             config1_dl,
             config1_da,
             config1_c2,
             config1_md,
             config1_pc,
             config1_wr,
             config1_ca,
             config1_ep,
             config1_fp
         };

    wire [31:0] config_012345;
    mux #(.num_port(6), .data_width(32)) config_mux(
            .select(sel),
            .in({
                    32'b0,
                    32'b0,
                    32'b0,
                    32'b0,
                    config1,
                    config_
                }),
            .out(config_012345)
        );

    parameter [2:0] status_cu321 = 3'b000;
    reg status_cu0;
    reg status_bev;
    reg status_um;
    // reg [7:0] status_im;
    // reg status_exl;
    // reg status_ie;
    (* MARK_DEBUG = "TRUE" *)wire [31:0] status =
    {
        status_cu321,
        status_cu0,
        {5{1'b0}},
        status_bev,
        {6{1'b0}},
        status_im,
        {3{1'b0}},
        status_um,
        1'b0,
        1'b0,
        status_exl,
        status_ie
    };

    always @(posedge clk) begin
        if (reset) begin
            status_exl <= 1'b0;
            status_ie <= 1'b0;
            status_bev <= 1'b1;
            status_um <= 1'b0;
            status_cu0 <= 1'b1;
        end else if (eret) begin
            status_exl <= 1'b0;
        end else if (exception) begin
            status_exl <= 1'b1;
        end else if (reg_num == `STATUS) begin
            if (wen) begin
                status_ie <= reg_in[0];
                status_exl <= reg_in[1];
                status_um <= reg_in[4];
                status_im <= reg_in[15:8];
                status_bev <= reg_in[22];
                status_cu0 <= reg_in[28];
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

    reg [31:0] epc;
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
        if (exception && |{
                    exccode == `EXC_AdEL,
                    exccode == `EXC_AdES,
                    exccode == `EXC_TLBL,
                    exccode == `EXC_TLBS,
                    exccode == `EXC_MOD,
                    tlb_refill
                }) begin
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
        if (exception & (
                    exccode == `EXC_TLBL
                    | exccode == `EXC_TLBS
                    | exccode == `EXC_MOD)) begin
            entry_hi_vpn2 <= tlb_error_vpn2;
        end else if (tlbr) begin
            entry_hi_vpn2 <= r_vpn2;
            entry_hi_asid <= r_asid;
        end else if (wen & reg_num == `ENTRYHI) begin
            entry_hi_vpn2 <= reg_in[31:13];
            entry_hi_asid <= reg_in[7:0];
        end
    end

    reg [TLBNUM_WIDTH-1:0] wired_wired;
    wire [31:0] wired = {{(32-TLBNUM_WIDTH){1'b0}}, wired_wired};
    always @(posedge clk) begin
        if (reset) begin
            wired_wired <= 0;
        end else if (reg_num == `WIRED) begin
            if (wen) begin
                wired_wired <= reg_in[TLBNUM_WIDTH-1:0];
            end
        end
    end

    reg [TLBNUM_WIDTH-1:0] random_random;
    wire [31:0] random = {{(32-TLBNUM_WIDTH){1'b0}}, random_random};
    always @(posedge clk) begin
        if (reset) begin
            random_random <= {TLBNUM_WIDTH{1'b1}};
        end else begin
            if (reg_num == `WIRED && wen) begin
                random_random <= reg_in[TLBNUM_WIDTH-1:0];
            end else begin
                if (random_random == {TLBNUM_WIDTH{1'b1}})
                    random_random <= wired_wired;
                else
                    random_random <= random_random + 1;
            end
        end
    end

    reg [8:0] context_ptebase;
    reg [18:0] context_badvpn2;
    (* MARK_DEBUG = "TRUE" *)wire [31:0] context_ = {context_ptebase, context_badvpn2, 4'b0};

    always @(posedge clk) begin
        if (exception & (
                    exccode == `EXC_TLBL
                    | exccode == `EXC_TLBS
                    | exccode == `EXC_MOD
                    | tlb_refill)) begin
            context_badvpn2 <= tlb_error_vpn2;
        end else begin
            if (reg_num == `CONTEXT && wen) begin
                context_ptebase <= reg_in[31:23];
            end
        end
    end

    assign w_index = tlbwr ? random_random : index_index;
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
            `RANDOM:
                reg_out = random;
            `ENTRYLO0:
                reg_out = entry_lo[0];
            `ENTRYLO1:
                reg_out = entry_lo[1];
            `CONTEXT:
                reg_out = context_;
            `PAGEMASK:
                reg_out = 0;
            `WIRED:
                reg_out = wired;
            `ENTRYHI:
                reg_out = entry_hi;
            `STATUS:
                reg_out = status;
            `CAUSE:
                reg_out = cause;
            `EPC:
                reg_out = epc;
            15:
                reg_out = (sel == 0) ? PRID : 0;
            `BADVADDR:
                reg_out = badvaddr;
            `COUNT:
                reg_out = count;
            `CONFIG:
                reg_out = config_012345;
            default:
                reg_out = 0;
        endcase
    end

    reg exception_now;
    wire eret_now = eret;
    assign exception_like_now = exception_now | eret_now;
    always @(*) begin
        exception_now = 0;
        if (exception & ~status_exl) begin
            exception_now = 1;
        end
    end
    mux_1h #(.num_port(3), .data_width(32))
           exception_pc_mux(
               .select({
                           eret,
                           exc_tlb_refill,
                           exc_int | exc
                       }),
               .in({
                       epc,
                       status_bev ? {
                           32'hBFC0_0200,
                           32'hBFC0_0380
                       } : {
                           32'h8000_0000,
                           32'h8000_0180
                       }
                   }),
               .out(exception_like_now_pc)
           );
endmodule
