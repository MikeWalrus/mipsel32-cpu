module branch_replace_line #(
	parameter WIDTH = 4
)(
	input all_valid,
	input [WIDTH-1:0] replace_line_invalid_index,
	input [WIDTH-1:0] plru_line_index,
	output [WIDTH-1:0] replace_line_index
);
	assign replace_line_index = all_valid ? plru_line_index : replace_line_invalid_index;
endmodule
