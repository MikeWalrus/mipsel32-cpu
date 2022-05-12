module test();
    genvar i;
    wire [32:2] finished;
    for (i = 2; i <= 32; i = i + 1) begin :a
        testbench #(.WIDTH(i)) t(.finished(finished[i]));
    end
    initial
        $dumpvars();
    always @(*) begin
        if (&finished)
            $finish();
    end
endmodule

module testbench
    #(parameter WIDTH = 3)(
         output reg finished
     );

    reg clk;
    reg reset;
    integer seed = 0;
    integer period = 0;
    integer longest_period = 2 ** WIDTH - 1;
    wire [WIDTH-1:0] lfsr_out;

    initial begin
        $display("WIDTH=%d\ttaps: %b", WIDTH, lfsr.taps);
        finished = 0;
        clk = 1;
        reset = 1;
        #100
         seed[WIDTH-1:0] = lfsr_out;
        reset = 0;
    end
    always begin
        #10
         clk = ~clk;
    end

    wire en = 1;
    lfsr #(.WIDTH(WIDTH)) lfsr(
             .clk(clk),
             .reset(reset),
             .en(en),
             .out(lfsr_out)
         );

    initial begin
    end

    always @(posedge clk) begin
        if (!reset) begin
            period <= period + 1;
            if (lfsr_out == seed[WIDTH-1:0]) begin
                if (period > 0 & !finished) begin
                    $display("WIDTH:%d\nperiod: %d\nlongest_period: %d\n%s\n",
                             WIDTH, period, longest_period,
                             period == longest_period ? "PASS" : "FAIL");
                    finished <= 1;
                end
            end
        end
    end

endmodule
