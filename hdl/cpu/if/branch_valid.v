//`include "../util/isolate_rightmost.v"
//`include "../util/mux_1h.v"
module branch_valid #(
	parameter WIDTH = 4,
	parameter LINE_NUM = 16
)(
	input clk,
	input reset,
	//replace is launched at ID stage, and finished at EX stage
	input replace_en,
	output [WIDTH-1:0] replace_line_invalid_index,
	output [LINE_NUM-1:0] valid_out,
	output all_valid
);
	reg [LINE_NUM-1:0] valid;
	assign valid_out = valid;
	wire [LINE_NUM-1:0] invalid = ~valid;
	assign all_valid = ~|invalid;

	wire [LINE_NUM-1:0] replace_line_invalid_select;
	isolate_rightmost #(.WIDTH(LINE_NUM))
		isolate_rightmost_invalid(
			.en(1'b1),
			.in(invalid),
			.out(replace_line_invalid_select)
		);
	genvar i;
	wire [WIDTH*LINE_NUM-1:0] replace_line_invalid_in;
	for (i = 0; i < LINE_NUM; i = i + 1) begin
		assign replace_line_invalid_in[(i+1)*WIDTH-1:i*WIDTH] = i[WIDTH-1:0];
	end

	mux_1h #(
		.num_port(LINE_NUM),
		.data_width(WIDTH)
	) replace_line_invalid_mux_1h (
		.select(replace_line_invalid_select),
		.in(replace_line_invalid_in),
		.out(replace_line_invalid_index)
	);

	integer j;
	always @(posedge clk) begin
		if (reset) begin
			for (j = 0; j < LINE_NUM; j = j + 1) 
				valid[j] <= 0;
		end
		else if (replace_en & ~all_valid) begin
			valid[replace_line_invalid_index] <= 1;
		end
	end
endmodule
