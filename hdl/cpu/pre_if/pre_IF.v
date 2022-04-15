`include "cp0.vh"
module pre_IF #
(
    parameter TLB = 1
)
(
        input clk,
        input reset,

        // sram-like
        output inst_sram_req,
        output inst_sram_wr,
        output [1:0] inst_sram_size,
        output [3:0] inst_sram_wstrb,
        output [31:0] inst_sram_addr,
        output [31:0] inst_sram_wdata,
        input inst_sram_addr_ok,
        input inst_sram_data_ok,

        // pipeline register: pre_IF
        input _pre_IF_reg_valid,
        input _pre_IF_reg_allow_out,
        output _pre_IF_reg_stall,
        input leaving_pre_IF,

        // pipeline register: pre_IF to IF
        input pre_IF_IF_reg_valid,
        input pre_IF_IF_reg_stall_wait_for_data,
        output pre_IF_IF_reg_stall_discard_instruction,

        // pipeline register: IF to ID
        input IF_ID_reg_valid_out,

        // exception-like events
        input exception_like_now,
        input exception_now_pre_IF,
        input eret_now_pre_IF,
        input refetch_now_pre_IF,

        input [31:0] cp0_epc,
        input [31:0] refetch_pc_pre_IF,

        output exception_pre_IF,
        output [4:0] exccode_pre_IF,

        // PC
        input next_pc_is_next,

        input [31:0] next_pc_without_exception,
        input [31:0] curr_pc_IF,
        output reg [31:0] curr_pc_pre_IF,

        // TLB
        output [18:0] vpn2,
        output odd_page,
        input [19:0] pfn
    );
    assign inst_sram_size = 2'd2;
    assign inst_sram_wstrb = 4'b1111;
    assign inst_sram_req =
           _pre_IF_reg_valid
           & _pre_IF_reg_allow_out
           & !exception_like_now
           & !exception_pre_IF;

    assign inst_sram_wr = 1'b0;
    addr_trans #(.TLB(TLB)) addr_trans_inst(
                   .virt_addr(curr_pc_pre_IF),
                   .phy_addr(inst_sram_addr),

                   .vpn2(vpn2),
                   .odd_page(odd_page),
                   .pfn(pfn)
               );

    // We misses the delay slot if:
    wire delay_slot_miss =
         ~next_pc_is_next & ~pre_IF_IF_reg_valid;

    reg [31:0] target;
    reg use_target;
    always @(posedge clk) begin
        if (reset) begin
            use_target <= 0;
        end
        if (IF_ID_reg_valid_out & !next_pc_is_next) begin
            target <= next_pc_without_exception;
            if (pre_IF_IF_reg_valid & leaving_pre_IF)
                use_target <= 0; // haven't missed the delay slot
            else
                use_target <= 1;
        end else begin
            if (use_target && !delay_slot_have_missed && leaving_pre_IF) begin
                use_target <= 0;
            end
        end
    end

    reg delay_slot_have_missed;
    always @(posedge clk) begin
        if (reset) begin
            delay_slot_have_missed <= 0;
        end else if (delay_slot_miss && !leaving_pre_IF) begin
            delay_slot_have_missed <= 1;
        end else if (delay_slot_have_missed && leaving_pre_IF) begin
            delay_slot_have_missed <= 0;
        end
    end

    wire should_discard_instruction =
         exception_like_now & (
             // the address is accepted in pre-IF
             (inst_sram_req & inst_sram_addr_ok)
             || // or
             // IF is waiting for data
             pre_IF_IF_reg_stall_wait_for_data
         );

    reg discard_instruction;
    always @(posedge clk) begin
        if (reset) begin
            discard_instruction <= 0;
        end begin
            if (should_discard_instruction) begin
                discard_instruction <= 1;
            end else if (inst_sram_data_ok) begin
                // If an unwanted instruction needs to be discarded,
                // it has been discarded.
                discard_instruction <= 0;
            end
        end
    end
    assign pre_IF_IF_reg_stall_discard_instruction = discard_instruction;

    always @(*) begin
        if (exception_now_pre_IF)
            curr_pc_pre_IF = 32'hBFC0_0380;
        else if (eret_now_pre_IF)
            curr_pc_pre_IF = cp0_epc;
        else if (refetch_now_pre_IF)
            curr_pc_pre_IF = refetch_pc_pre_IF;
        else if (delay_slot_miss || delay_slot_have_missed)
            // We've missed the delay slot, so we request for the instruction
            // of the delay slot in this cycle, and request for the
            // instruction of the target in the next cycle.
            curr_pc_pre_IF = curr_pc_IF + 4;
        else if (inst_sram_addr_ok && _pre_IF_reg_allow_out) begin
            if (use_target)
                curr_pc_pre_IF = target;
            else
                curr_pc_pre_IF = next_pc_without_exception;
        end else
            curr_pc_pre_IF = curr_pc_IF;
    end
    assign _pre_IF_reg_stall = inst_sram_req & ~inst_sram_addr_ok;

    wire inst_addr_error = (curr_pc_pre_IF[1:0] != 2'b00);
    exception_combine inst_addr_error_exception(
                          .exception_h(1'b0),
                          .exccode_h({5{1'bz}}),
                          .exception_l(inst_addr_error),
                          .exccode_l(`EXC_AdEL),
                          .exception_out(exception_pre_IF),
                          .exccode_out(exccode_pre_IF)
                      );
endmodule