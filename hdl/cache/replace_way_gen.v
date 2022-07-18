module replace_way_gen # (parameter NUM_WAY = 2)
    (
        input clk,
        input reset,
        input en,
        input [NUM_WAY-1:0] v_ways,
        output [NUM_WAY-1:0] replace_way
    );
    wire [NUM_WAY-1:0] invalid_way = ~v_ways;
    wire no_invalid_ways = ~|invalid_way;

    wire [NUM_WAY-1:0] replace_way_invalid;
    isolate_rightmost #(.WIDTH(NUM_WAY))
                      isolate_rightmost(
                          .en(1'b1),
                          .in(invalid_way),
                          .out(replace_way_invalid)
                      );

    // Use an LFSR with more bits than needed to get the distribution more even.
    localparam LFSR_WIDTH = $clog2(NUM_WAY) + 2;

    wire [NUM_WAY-1:0] random_replace_way;
    // verilator lint_off UNUSED
    wire [LFSR_WIDTH-1:0] lfsr_out;
    // verilator lint_on UNUSED
    lfsr #(.WIDTH(LFSR_WIDTH)) lfsr(
             .clk(clk),
             .reset(reset),
             .seed({LFSR_WIDTH{1'b1}}),
             .en(en & no_invalid_ways),
             .out(lfsr_out)
         );
    if (NUM_WAY == 1) begin
        assign random_replace_way = 0;
    end else begin
        bin_to_1h #(.OUTPUT_WIDTH(NUM_WAY)) replace_way_bin_to_1h(
                      .binary(lfsr_out[$clog2(NUM_WAY)-1:0]),
                      .one_hot(random_replace_way)
                  );
    end
    assign replace_way = no_invalid_ways ?
           random_replace_way : replace_way_invalid;
endmodule
