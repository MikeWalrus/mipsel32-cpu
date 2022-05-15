module bram
    #(
         parameter DEPTH = 65536,
         parameter WIDTH = 32,
         parameter WRITE_BYTE = 0,

         parameter WE_WIDTH = WRITE_BYTE ? WIDTH/8 : 1
     )
     (
         input [$clog2(DEPTH)-1:0] addr,
         input clk,
         input [WIDTH-1:0] din,
         output [WIDTH-1:0] dout,
         input [WE_WIDTH-1:0] we
     );
`ifndef IVERILOG
    xpm_memory_spram #(
                         .ADDR_WIDTH_A($clog2(DEPTH)),  // DECIMAL
                         .BYTE_WRITE_WIDTH_A(WRITE_BYTE ? 8 : WIDTH), // DECIMAL
                         .MEMORY_INIT_FILE("none"),     // String
                         .MEMORY_INIT_PARAM("0"),       // String
                         .MEMORY_PRIMITIVE("block"),    // String
                         .MEMORY_SIZE(DEPTH * WIDTH),   // DECIMAL
                         .READ_DATA_WIDTH_A(WIDTH),     // DECIMAL
                         .READ_LATENCY_A(1),            // DECIMAL
                         .READ_RESET_VALUE_A("0"),      // String
                         .RST_MODE_A("SYNC"),           // String
                         .SIM_ASSERT_CHK(0),            // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
                         .USE_MEM_INIT(1),              // DECIMAL
                         .WRITE_DATA_WIDTH_A(WIDTH),    // DECIMAL
                         .WRITE_MODE_A("read_first")    // String
                     )
                     xpm_memory_spram_inst (
                         .douta(dout),                   // READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
                         .addra(addr),                   // ADDR_WIDTH_A-bit input: Address for port A write and read operations.
                         .clka(clk),                     // 1-bit input: Clock signal for port A.
                         .dina(din),                     // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
                         .ena(1),                        // 1-bit input: Memory enable signal for port A. Must be high on clock
                         // cycles when read or write operations are initiated. Pipelined
                         // internally.
                         .wea(we)                        // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector
                         // for port A input data port dina. 1 bit wide when word-wide writes are
                         // used. In byte-wide write configurations, each bit controls the
                         // writing one byte of dina to address addra. For example, to
                         // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A
                         // is 32, wea would be 4'b0010.

                     );
`else
    reg [WIDTH - 1:0] ram_[DEPTH - 1:0];
    reg [WIDTH - 1:0] dout_latch;
    always @(posedge clk) begin
        dout_latch <= ram_[addr];
    end
    assign dout = dout_latch;

    integer j;
    initial begin
        for (j = 0; j < DEPTH; j = j + 1) begin
            ram_[j] = 0;
        end
    end

    localparam num_bytes = WIDTH / 8;
    generate
        genvar i;
        if (WRITE_BYTE) begin
            for (i = 0; i < num_bytes; i = i + 1) begin
                always @(posedge clk) begin
                    if (we[i])
                        ram_[addr][i*8+7:i*8] <= din[i*8+7:i*8];
                end
            end
        end else begin
            always @(posedge clk)
                if (we)
                    ram_[addr] <= din;
        end
    endgenerate
`endif
endmodule
