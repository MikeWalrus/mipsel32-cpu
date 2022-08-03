// two situation:
// 1.It has been a branch line, it needs to be changed state after request.
// 2.It hasn't been a branch line, it needs to be fresh the branch line and set up a new state machine.
// state configuration:
// 2'00 2'01 pc+4
// 2'10 2'11 branch_target
// 2'00 -> 2'01 -> 2'10 -> 2'11
// 2'00 <- 2'01 <- 2'10 <- 2'11
module branch_state_machine #(
	parameter WIDTH = 4,
	parameter LINE_NUM = 16
)(
	input clk,
	input reset,
	//ID launch, EX finish
	input replace_en,
	input [WIDTH-1:0] replace_line_index,
	input static_branch_predict,
	//ID launch, EX finish
	input fresh_en,
	input [WIDTH-1:0] fresh_line_index,
	input dynamic_branch_predict,
	//IF launch, IF finish
	input [WIDTH-1:0] request_line_index,
	input request_miss,
	output request_state
);
	reg [1:0] state_machine[LINE_NUM-1:0];
	integer i;
	always @(posedge clk) begin
		if (reset) begin
			for (i = 0; i < LINE_NUM; i = i + 1) begin
				state_machine[i] <= 2'b01;
			end
		end
		else if (replace_en) begin
			state_machine[replace_line_index] <= static_branch_predict ? 2'b00 : 2'b10;
		end
		else if (fresh_en) begin
			// mux_1h operation hhh
			state_machine[fresh_line_index] <= 
				({2{state_machine[fresh_line_index] == 2'b00}} & (dynamic_branch_predict ? 2'b00 : 2'b01)) |	
				({2{state_machine[fresh_line_index] == 2'b01}} & (dynamic_branch_predict ? 2'b00 : 2'b10)) |
				({2{state_machine[fresh_line_index] == 2'b10}} & (dynamic_branch_predict ? 2'b11 : 2'b01)) |
				({2{state_machine[fresh_line_index] == 2'b11}} & (dynamic_branch_predict ? 2'b11 : 2'b10));
		end
	end

	assign request_state = ~request_miss & state_machine[request_line_index][1];
endmodule
