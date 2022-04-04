module mux_1h #
    (
        parameter num_port = 3,
        parameter data_width = 32
    )
    (
        input [num_port-1:0] select,
        input [num_port*data_width-1:0] in,
        output [data_width-1:0] out
    );
    genvar i;
    for (i = 0; i < num_port; i = i + 1) begin: and_gates
        wire [data_width-1:0] and_result = {data_width{select[i]}} & in[(i+1)*data_width-1:i*data_width];
        wire [data_width-1:0] or_result;
    end
    assign and_gates[0].or_result = and_gates[0].and_result;
    for (i = 1; i < num_port; i = i + 1) begin: g2
        assign and_gates[i].or_result = and_gates[i].and_result | and_gates[i-1].or_result;
    end
    assign out = and_gates[num_port-1].or_result;
endmodule
