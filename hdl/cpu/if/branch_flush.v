// old
// pre_IF(AC) IF(delay slot) ID(branch)
// next state:
// pre_IF(AC) IF(delay slot) ID(branch):
//		no special thing
// pre_IF(AC) IF(delay slot) EX(branch):
//		target fresh
//		use_target = 1
// pre_IF(AC) ID(delay slot) EX(branch):
//		target fresh
//		use_target = 1
//     IF(AC) ID(delay slot) EX(branch):
//		target fresh
//		use_target = 0
// pre_IF(delay slot) ID(branch)
// delay slot miss!
// next state:
// pre_IF(delay slot) ID(branch)
// 		delay slot have miss = 1
// 		target and use_target not change
// pre_IF(delay slot) EX(branch)
// 		delay slot have miss = 1
// 		target fresh
//		use_target = 1
// pre_IF(AC) IF(delay slot) ID(branch)
// 		delay slot have miss = 0
//		target and use_target not change
// pre_IF(AC) IF(delay slot) EX(branch)
// 		delay slot have miss = 0
//		target fresh
//		use_target = 1
// new
// pre_IF(WA) IF(delay slot) ID(branch)
// next state:
// pre_IF(WA) IF(delay slot) ID(branch): no problem
//		no special thing
// pre_IF(WA) IF(delay slot) EX(branch): big problem
//		target fresh
//		use_target = 1
//		discard the instruction
//		the target use need to be changed!
// pre_IF(WA) ID(delay slot) EX(branch): big problem
//		target fresh
//		use_target = 1
//		discard the instruction
//		the target use need to be changed!
//     IF(WA) ID(delay slot) EX(branch): big problem
//		target fresh
//		use_target = 0
//		flush the instruction
// pre_IF(AC) IF(delay slot) ID(branch)
// next state:
// pre_IF(AC) IF(delay slot) ID(branch): no problem
//		no special thing
// pre_IF(AC) IF(delay slot) EX(branch): no problem
//		target fresh
//		use_target = 1
// pre_IF(AC) ID(delay slot) EX(branch): no problem
//		target fresh
//		use_target = 1
//     IF(AC) ID(delay slot) EX(branch): no problem
//		target fresh
//		use_target = 0
// pre_IF(delay slot) ID(branch)
// delay slot miss!
// next state:
// pre_IF(delay slot) ID(branch): no problem
// 		delay slot have miss = 1
// 		target and use_target not change
// pre_IF(delay slot) EX(branch): no problem
// 		delay slot have miss = 1
// 		target fresh
//		use_target = 1
// pre_IF(AC/WA) IF(delay slot) ID(branch): towards situation 1
// 		delay slot have miss = 0
//		target and use_target not change
// pre_IF(WA) IF(delay slot) EX(branch): big problem
//		delay slot have miss = 0
//		target fresh
//		use_target = 1
// pre_IF(AC) IF(delay slot) EX(branch): no problem
// 		delay slot have miss = 0
//		target fresh
//		use_target = 1

module branch_flush_unit(
	input leaving_pre_IF,
	input leaving_IF,
	input leaving_ID,
	input branch_predict_fail,

	output branch_flush
);
	assign branch_flush = leaving_pre_IF & leaving_IF & leaving_ID & branch_predict_fail;
endmodule
