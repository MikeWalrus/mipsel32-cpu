// MikeWalrus, our super hero!!!
// plru worked only when branch line fullfill
// plru fresh only when the instruction on ID stage and is not stall, control by the stall signal in ID stage
// plru fresh operation: replace line and fresh line used recently
//`include "../util/mux_1h.v"
module plru #(
	parameter WIDTH = 4,
	parameter LINE_NUM = 16 
)(
	input clk,
	input reset,
	input replace_en,
	input fresh_en,
	input [WIDTH-1:0] fresh_line_index,
	output [WIDTH-1:0] out
);
// The state's change is launched at ID stage, and finished at EX stage.
	reg [WIDTH-1:0] plru_reg;
	wire [WIDTH-1:0] plru_reg_next;
	always @(posedge clk) begin
		if (reset)
			plru_reg <= {WIDTH{1'b0}};
		else if (replace_en | fresh_en) 
			plru_reg <= plru_reg_next;
	end

	assign out = plru_reg;

	reg [WIDTH-1:0] used_state[LINE_NUM-1:0];
	wire [WIDTH-1:0] next_used_state[LINE_NUM-1:0];

	genvar i;
	wire [WIDTH-1:0] xor_with_fresh_line[LINE_NUM-1:0];
	wire [WIDTH-1:0] lowbit_xor_with_fresh_line[LINE_NUM-1:0];
	for (i = 0; i < LINE_NUM; i = i + 1) begin
		assign xor_with_fresh_line[i] = used_state[i] ^ used_state[replace_en ? plru_reg : fresh_line_index];
		assign lowbit_xor_with_fresh_line[i] = xor_with_fresh_line[i] & (-xor_with_fresh_line[i]);
		assign next_used_state[i] = used_state[i] & (~lowbit_xor_with_fresh_line[i]) | (lowbit_xor_with_fresh_line[i] - 1);
	end

	generate
		genvar j;
		for (j = 0; j < LINE_NUM; j = j + 1) begin
			always @(posedge clk) begin
				if (reset)
					used_state[j] <= j[WIDTH-1:0];
				else if (fresh_en | replace_en) 
					used_state[j] <= next_used_state[j];
			end
		end
	endgenerate

	wire [LINE_NUM-1:0] plru_reg_next_select;
	wire [WIDTH*LINE_NUM-1:0] plru_reg_next_in;
	genvar k;
	for (k = 0; k < LINE_NUM; k = k + 1) begin
		assign plru_reg_next_select[k] = (next_used_state[k] == {WIDTH{1'b0}});
		assign plru_reg_next_in[(k+1)*WIDTH-1:k*WIDTH] = k[WIDTH-1:0];
	end
	mux_1h #(
		.num_port(LINE_NUM),
		.data_width(WIDTH)
	) plru_reg_next_mux_1h (
		.select(plru_reg_next_select),
		.in(plru_reg_next_in),
		.out(plru_reg_next)
	);

endmodule
