`define INDEX 5'd0
`define RANDOM 5'd1
`define ENTRYLO0 5'd2
`define ENTRYLO1 5'd3
`define CONTEXT 5'd4
`define PAGEMASK 5'd5
`define WIRED 5'd6
`define BADVADDR 5'd8
`define COUNT 5'd9
`define ENTRYHI 5'd10
`define COMPARE 5'd11
`define STATUS 5'd12
`define CAUSE 5'd13
`define EPC 5'd14
`define EBASE 5'd15
`define CONFIG 5'd16
`define TAGLO 5'd28
`define TAGHI 5'd29

`define EXC_Int 5'h00
`define EXC_MOD 5'h01
`define EXC_TLBL 5'h02
`define EXC_TLBS 5'h03
`define EXC_AdEL 5'h04
`define EXC_AdES 5'h05
`define EXC_Sys 5'h08
`define EXC_Bp 5'h09
`define EXC_RI 5'h0a
`define EXC_CpU 5'h0b
`define EXC_Ov 5'h0c

`define ERET 5'h1f
`define REFETCH 5'h1e

`define CACHED 3'h3
`define UNCACHED 3'h2
