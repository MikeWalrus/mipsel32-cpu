`define assert(signal, value, msg) \
        if (signal !== value) begin \
            $display("ASSERTION \33[31mFAILED\33[0m in %m: signal(%d) != value(%d), \"\33[31m%s\33[0m\"",signal, value, msg); \
            $finish; \
        end
