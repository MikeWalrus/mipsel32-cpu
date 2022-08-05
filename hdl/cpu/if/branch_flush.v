// data_ok signal
// data_ok -> pre_IF_IF_reg_valid
// data_ok before leaving_ID:
// leaving pre_IF_IF_
// data_ok in leaving_ID branch_flush
// data_ok after leaving_ID branch_flush
module branch_flush_unit (
	input clk,
	input reset,

	input leaving_pre_IF,
    input leaving_IF,
    input branch_discard,

	output branch_flush
);

	wire should_branch_flush = branch_discard;
	reg branch_flush_reg;
	always @(posedge clk) begin	
		if (reset) 
			branch_flush_reg <= 0;
		else if (should_branch_flush & leaving_IF)
			branch_flush_reg <= 0;
		else if (should_branch_flush & ~leaving_IF)
			branch_flush_reg <= 1;
		else if (branch_flush_reg & leaving_pre_IF)
			branch_flush_reg <= 0;
	end

	assign branch_flush = (should_branch_flush & leaving_IF) ? 1'b1 : branch_flush_reg;
endmodule

