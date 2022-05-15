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

    // Isolate the rightmost bit
    // http://fpgacpu.ca/fpga/Bitmask_Isolate_Rightmost_1_Bit.html
    wire [NUM_WAY-1:0] replace_way_invalid = invalid_way & -invalid_way;

    // Use an LFSR with more bits than needed to get the distribution more even.
    localparam LFSR_WIDTH = $clog2(NUM_WAY) + 2;

    wire [NUM_WAY-1:0] random_replace_way;
    // verilator lint_off UNUSED
    wire [LFSR_WIDTH-1:0] lfsr_out;
    // verilator lint_on UNUSED
    lfsr #(.WIDTH(LFSR_WIDTH)) lfsr(
             .clk(clk),
             .reset(reset),
             .en(en & no_invalid_ways),
             .out(lfsr_out)
         );
    bin_to_1h #(.OUTPUT_WIDTH(NUM_WAY)) replace_way_bin_to_1h(
                  .binary(lfsr_out[$clog2(NUM_WAY)-1:0]),
                  .one_hot(random_replace_way)
              );
    assign replace_way = no_invalid_ways ?
           random_replace_way : replace_way_invalid;
endmodule
