module tlb #(
        parameter TLBNUM = 16
    ) (
        input clk,

        // search port 0
        input  [18:0]               s0_vpn2,
        input                       s0_odd_page,
        input  [7:0]                s0_asid,
        output                      s0_found,
        output [$clog2(TLBNUM)-1:0] s0_index,
        output [19:0]               s0_pfn,
        output [2:0]                s0_c,
        output                      s0_d,
        output                      s0_v,

        // search port 1
        input  [18:0]               s1_vpn2,
        input                       s1_odd_page,
        input  [7:0]                s1_asid,
        output                      s1_found,
        output [$clog2(TLBNUM)-1:0] s1_index,
        output [19:0]               s1_pfn,
        output [2:0]                s1_c,
        output                      s1_d,
        output                      s1_v,

        // write port
        input                       we, // write enable
        input  [$clog2(TLBNUM)-1:0] w_index,
        input  [18:0]               w_vpn2,
        input  [7:0]                w_asid,
        input                       w_g,
        input  [19:0]               w_pfn0,
        input  [2:0]                w_c0,
        input                       w_d0,
        input                       w_v0,
        input  [19:0]               w_pfn1,
        input  [2:0]                w_c1,
        input                       w_d1,
        input                       w_v1,

        // read port
        input  [$clog2(TLBNUM)-1:0] r_index,
        output [18:0]               r_vpn2,
        output [7:0]                r_asid,
        output                      r_g,
        output [19:0]               r_pfn0,
        output [2:0]                r_c0,
        output                      r_d0,
        output                      r_v0,
        output [19:0]               r_pfn1,
        output [2:0]                r_c1,
        output                      r_d1,
        output                      r_v1
    );

    // reg
    reg [18:0] tlb_vpn2 [TLBNUM-1:0];
    reg [7:0]  tlb_asid [TLBNUM-1:0];
    reg        tlb_g    [TLBNUM-1:0];
    reg [19:0] tlb_pfn0 [TLBNUM-1:0];
    reg [2:0]  tlb_c0   [TLBNUM-1:0];
    reg        tlb_d0   [TLBNUM-1:0];
    reg        tlb_v0   [TLBNUM-1:0];
    reg [19:0] tlb_pfn1 [TLBNUM-1:0];
    reg [2:0]  tlb_c1   [TLBNUM-1:0];
    reg        tlb_d1   [TLBNUM-1:0];
    reg        tlb_v1   [TLBNUM-1:0];

    // search
    wire [TLBNUM-1:0] s0_match, s1_match;
    genvar i;
    for (i = 0; i < TLBNUM; i = i + 1) begin
        assign s0_match[i] = (tlb_vpn2[i] == s0_vpn2) && ((tlb_asid[i] == s0_asid) || tlb_g[i]);
        assign s1_match[i] = (tlb_vpn2[i] == s1_vpn2) && ((tlb_asid[i] == s1_asid) || tlb_g[i]);
    end

    localparam mux_data_width = $clog2(TLBNUM) + 20 + 3 + 1 + 1; // s_index, s_pfn, s_c, s_d, s_v
    wire [mux_data_width*TLBNUM-1:0] mux_in_data0, mux_in_data1;

    for (i = 0; i < TLBNUM; i = i + 1) begin
        assign mux_in_data0[(i+1)*mux_data_width-1:i*mux_data_width] =
               ({({$clog2(TLBNUM){1}} & i), tlb_pfn0[i], tlb_c0[i], tlb_d0[i], tlb_v0[i]} & {mux_data_width{~s0_odd_page}}) |
               ({({$clog2(TLBNUM){1}} & i), tlb_pfn1[i], tlb_c1[i], tlb_d1[i], tlb_v1[i]} & {mux_data_width{s0_odd_page}});
        assign mux_in_data1[(i+1)*mux_data_width-1:i*mux_data_width] =
               ({({$clog2(TLBNUM){1}} & i), tlb_pfn0[i], tlb_c0[i], tlb_d0[i], tlb_v0[i]} & {mux_data_width{~s1_odd_page}}) |
               ({({$clog2(TLBNUM){1}} & i), tlb_pfn1[i], tlb_c1[i], tlb_d1[i], tlb_v1[i]} & {mux_data_width{s1_odd_page}});
    end

    wire [mux_data_width-1:0] mux_data_out0, mux_data_out1;
    mux_1h #
        (
            .num_port   (TLBNUM),
            .data_width (mux_data_width)
        )
        s0_mux
        (
            .select     (s0_match),
            .in         (mux_in_data0),
            .out        (mux_data_out0)
        );
    mux_1h #
        (
            .num_port   (TLBNUM),
            .data_width (mux_data_width)
        )
        s1_mux
        (
            .select     (s1_match),
            .in         (mux_in_data1),
            .out        (mux_data_out1)
        );

    assign {s0_index, s0_pfn, s0_c, s0_d, s0_v} = mux_data_out0;
    assign {s1_index, s1_pfn, s1_c, s1_d, s1_v} = mux_data_out1;

    assign s0_found = |s0_match;
    assign s1_found = |s1_match;

    // read

    reg [18:0] r_vpn2_reg;
    reg [7:0]  r_asid_reg;
    reg        r_g_reg;
    reg [19:0] r_pfn0_reg, r_pfn1_reg;
    reg [2:0]  r_c0_reg, r_c1_reg, r_d0_reg, r_d1_reg, r_v0_reg, r_v1_reg;

    always @(*) begin
        r_vpn2_reg <= tlb_vpn2[r_index];
        r_asid_reg <= tlb_asid[r_index];
        r_g_reg    <= tlb_g[r_index];
        r_pfn0_reg <= tlb_pfn0[r_index];
        r_c0_reg   <= tlb_c0[r_index];
        r_d0_reg   <= tlb_d0[r_index];
        r_v0_reg   <= tlb_v0[r_index];
        r_pfn1_reg <= tlb_pfn1[r_index];
        r_c1_reg   <= tlb_c1[r_index];
        r_d1_reg   <= tlb_d1[r_index];
        r_v1_reg   <= tlb_v1[r_index];
    end

    assign r_vpn2 = r_vpn2_reg;
    assign r_asid = r_asid_reg;
    assign r_g    = r_g_reg;
    assign r_pfn0 = r_pfn0_reg;
    assign r_c0   = r_c0_reg;
    assign r_d0   = r_d0_reg;
    assign r_v0   = r_v0_reg;
    assign r_pfn1 = r_pfn1_reg;
    assign r_c1   = r_c1_reg;
    assign r_d1   = r_d1_reg;
    assign r_v1   = r_v1_reg;


    // write
    always @(posedge clk) begin
        if (we) begin
            tlb_vpn2[w_index] <= w_vpn2;
            tlb_asid[w_index] <= w_asid;
            tlb_g[w_index]    <= w_g;
            tlb_pfn0[w_index] <= w_pfn0;
            tlb_c0[w_index]   <= w_c0;
            tlb_d0[w_index]   <= w_d0;
            tlb_v0[w_index]   <= w_v0;
            tlb_pfn1[w_index] <= w_pfn1;
            tlb_c1[w_index]   <= w_c1;
            tlb_d1[w_index]   <= w_d1;
            tlb_v1[w_index]   <= w_v1;
        end
    end

endmodule
