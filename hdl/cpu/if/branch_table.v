//`include "../util/mux_1h.v"
module branch_table #(
	parameter WIDTH = 4,
	parameter LINE_NUM = 16,
	parameter ADDR_WIDTH = 32
)(
	input clk,
	input reset,
	//ID launch, EX finish
	input replace_en,
	input [WIDTH-1:0] replace_line_index,
	input [ADDR_WIDTH-1:0] replace_pc,
	input [ADDR_WIDTH-1:0] replace_pc_target,
	//IF launch, IF finish
	input [ADDR_WIDTH-1:0] request_pc,
	input [LINE_NUM-1:0] valid,
	output [WIDTH-1:0] request_line_index,
	output [ADDR_WIDTH-1:0] request_pc_target,
	output request_miss
);
	reg [ADDR_WIDTH-1:0] pc[LINE_NUM-1:0];
	reg [ADDR_WIDTH-1:0] pc_target[LINE_NUM-1:0];
	integer i;
	always @(posedge clk) begin
		if (reset) begin
			for (i = 0; i < LINE_NUM; i = i + 1) begin
				pc[i] <= {ADDR_WIDTH{1'b0}};
				pc_target[i] <= {ADDR_WIDTH{1'b0}};
			end
		end
		else if (replace_en) begin
			pc[replace_line_index] <= replace_pc;
			pc_target[replace_line_index] <= replace_pc_target;
		end
	end

	genvar j;
	wire [LINE_NUM-1:0] request_line_index_select;
	wire [WIDTH*LINE_NUM-1:0] request_line_index_in;
	for (j = 0; j < LINE_NUM; j = j + 1) begin
		assign request_line_index_select[j] = (pc[j] == request_pc) & valid[j];
		assign request_line_index_in[(j+1)*WIDTH-1:j*WIDTH] = j[WIDTH-1:0];
	end
	mux_1h #(
		.num_port(LINE_NUM),
		.data_width(WIDTH)
	) request_line_index_mux_1h (
		.select(request_line_index_select),
		.in(request_line_index_in),
		.out(request_line_index)
	);
	assign request_miss = ~|request_line_index_select;

	assign request_pc_target = request_miss ? {request_pc + 32'd8} : pc_target[request_line_index];
endmodule
