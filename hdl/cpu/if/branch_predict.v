//The state's change is launched at ID, and finished at EX.
//The delay slot is impossible to be branch instruction and jump and link instruction.
//Think about the situation in different stage of branch and jump and link instruction.
//IF stage: search in branch_table for the branch predict result, delay slot in pre_IF ask for instruction.
//ID stage: launch the change signal of all branch units, deliver pc signal to pre_IF, the true result deliver to EX stage.
//EX stage: finish the change, flush IF if the branch predict error.
module branch_predict #(
	parameter WIDTH = 4,
	parameter LINE_NUM = 16,
	parameter ADDR_WIDTH = 32
)(
	input clk,
	input reset,
	// ID launch, EX finish
	input replace_en, // request_miss_ID & branch_or_jump
	input [ADDR_WIDTH-1:0] replace_pc, // pc_ID
	input [ADDR_WIDTH-1:0] replace_pc_target, // pc_target
	input static_branch_predict, // request_miss_ID & branch_or_jump & ~((pc_ID + 32'd8) == true_pc_target)
	// ID launch, EX finish
	input fresh_en, // ~request_miss_ID & branch_or_jump
	input [WIDTH-1:0] fresh_line_index, // request_line_index_IF -> fresh_line_index_ID
	input dynamic_branch_predict, // request_state_IF -> dynamic_branch_predict_ID
	// IF launch, IF finish
	input [ADDR_WIDTH-1:0] request_pc, // pc_IF
	output [WIDTH-1:0] request_line_index,
	output [ADDR_WIDTH-1:0] request_pc_target,
	output request_miss,
	output request_state
);
	//branch_valid
	wire [WIDTH-1:0] replace_line_invalid_index;
	wire [LINE_NUM-1:0] valid;
	wire all_valid;

	//plru
	wire [WIDTH-1:0] plru_line_index;

	//branch_replace_line
	wire [WIDTH-1:0] replace_line_index;

	branch_valid #(
		.WIDTH(WIDTH),
		.LINE_NUM(LINE_NUM)
	) branch_valid (
		.clk(clk),
		.reset(reset),
		.replace_en(replace_en),
		.replace_line_invalid_index(replace_line_invalid_index),
		.valid_out(valid),
		.all_valid(all_valid)
	);

	plru #(
		.WIDTH(WIDTH),
		.LINE_NUM(LINE_NUM)
	) plru (
		.clk(clk),
		.reset(reset),
		.replace_en(replace_en & all_valid),
		.fresh_en(fresh_en & all_valid),
		.fresh_line_index(fresh_line_index),
		.out(plru_line_index)
	);

	branch_replace_line #(
		.WIDTH(WIDTH)
	) branch_replace_line (
		.all_valid(all_valid),
		.replace_line_invalid_index(replace_line_invalid_index),
		.plru_line_index(plru_line_index),
		.replace_line_index(replace_line_index)
	);

	branch_table #(
		.WIDTH(WIDTH),
		.LINE_NUM(LINE_NUM),
		.ADDR_WIDTH(ADDR_WIDTH)
	) branch_table (
		.clk(clk),
		.reset(reset),
		// ID launch, EX finish
		.replace_en(replace_en),
		.replace_line_index(replace_line_index),
		.replace_pc(replace_pc),
		.replace_pc_target(replace_pc_target),
		// IF launch, IF finish
		.request_pc(request_pc),
		.valid(valid),
		.request_line_index(request_line_index),
		.request_pc_target(request_pc_target),
		.request_miss(request_miss)
	);

	branch_state_machine #(
		.LINE_NUM(LINE_NUM)
	) branch_state_machine (
		.clk(clk),
		.reset(reset),

		.replace_en(replace_en),
		.replace_line_index(replace_line_index),
		.static_branch_predict(static_branch_predict),

		.fresh_en(fresh_en),
		.fresh_line_index(fresh_line_index),
		.dynamic_branch_predict(dynamic_branch_predict),

		.request_line_index(request_line_index),
		.request_miss(request_miss),
		.request_state(request_state)
	);
endmodule
