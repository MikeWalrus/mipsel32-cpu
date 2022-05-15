`timescale 1ns / 1ps

`define REPLACE_WRONG  cache_top.replace_wrong
`define CACHERES_WRONG  cache_top.cacheres_wrong
`define TEST_INDEX  cache_top.test_index
`define ROUND_FINISH cache_top.read_round_finish
module testbench #
(
        parameter NUM_WAY = 2,
        parameter BYTES_PER_LINE = 64,
        parameter NUM_LINE = 256 // must <= 256 if VIPT
)
();
    reg resetn;
    reg clk;

    initial
    begin
        $dumpvars();
        clk = 1'b0;
        resetn = 1'b0;
        #2000;
        resetn = 1'b1;
    end
    always #5 clk=~clk;

    parameter INDEX_WIDTH = $clog2(NUM_LINE);

    cache_top #(
                  .SIMULATION(1'b1),
                  .NUM_LINE(NUM_LINE),
                  .NUM_WAY(NUM_WAY),
                  .BYTES_PER_LINE(BYTES_PER_LINE)
              ) cache_top(
                  .resetn(resetn),
                  .clk(clk)
              );

    always @(posedge clk)
    begin
        if(`ROUND_FINISH) begin
            $display("index %x finished",`TEST_INDEX);
            if(`TEST_INDEX=={INDEX_WIDTH{1'b1}}) begin
                $display("=========================================================");
                $display("Test end!");
                $display("----PASS!!!");
                $finish;
            end
        end
        else if(`REPLACE_WRONG) begin
            $display("replace wrong at index %x",`TEST_INDEX);
            $display("=========================================================");
            $display("Test end!");
            $display("----FAIL!!!");
            $finish;
        end
        else if(`CACHERES_WRONG) begin
            $display("cacheres wrong at index %x",`TEST_INDEX);
            $display("=========================================================");
            $display("Test end!");
            $display("----FAIL!!!");
            $finish;
        end
    end

endmodule
