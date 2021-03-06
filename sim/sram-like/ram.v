module ram #
    (
        parameter depth = 65536,
        parameter width = 32,
        parameter num_bytes = width/8
    )
    (
        input [$clog2(depth)-1:0] addr,
        input clk,
        input [width - 1:0] din,
        output reg [width - 1:0] dout,
        input en,
        input [width/8 - 1:0] we
    );

    reg [width - 1:0] ram_[depth - 1:0];

    genvar i;
    for (i = 0; i < num_bytes; i = i + 1) begin
        always @(posedge clk) begin
            if (we[i])
                ram_[addr][i*8 +: 8] <= din[i*8 +: 8];
        end
    end
    always @(posedge clk) begin
        if (en)
            dout <= ram_[addr];
    end
endmodule

module inst_ram #
    (
        parameter depth = 2 ** 18,
        parameter width = 32
    )
    (
        input [$clog2(depth)-1:0] addra,
        input clka,
        input [width - 1:0] dina,
        output [width - 1:0] douta,
        input ena,
        input [width/8 - 1:0] wea
    );
    ram #(.depth(depth), .width(width))
        ram(
            .addr(addra),
            .clk(clka),
            .din(dina),
            .dout(douta),
            .en(ena),
            .we(wea)
        );
endmodule

module data_ram #
    (
        parameter depth = 65536,
        parameter width = 32
    )
    (
        input [$clog2(depth)-1:0] addra,
        input clka,
        input [width - 1:0] dina,
        output [width - 1:0] douta,
        input ena,
        input [width/8 - 1:0] wea
    );
    ram #(.depth(depth), .width(width))
        ram(
            .addr(addra),
            .clk(clka),
            .din(dina),
            .dout(douta),
            .en(ena),
            .we(wea)
        );
endmodule
