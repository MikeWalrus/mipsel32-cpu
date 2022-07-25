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
        output inst_sram_cached,
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
        input exception_like_now_pre_IF,
        input [31:0] exception_like_now_pc_pre_IF,

        output exception_pre_IF,
        output [4:0] exccode_pre_IF,
        output tlb_refill,

        // PC
        input next_pc_is_next,

        input [31:0] next_pc_without_exception,
        input [31:0] curr_pc_IF,
        output reg [31:0] curr_pc_pre_IF,

        // TLB
        output [18:0] vpn2,
        output odd_page,
        input [19:0] pfn,
        input found,
        input v,
        input [2:0] c,

        input [2:0] cp0_config_k0
    );
    assign inst_sram_size = 2'd2;
    assign inst_sram_wstrb = 4'b1111;
    assign inst_sram_req =
           _pre_IF_reg_valid
           & _pre_IF_reg_allow_out
           & !exception_like_now
           & !exception_pre_IF;

    assign inst_sram_wr = 1'b0;
    wire virt_mapped;
    reg [31:0] curr_pc_pre_IF_req;
    addr_trans #(.TLB(TLB)) addr_trans_inst(
                   .virt_addr(curr_pc_pre_IF_req),
                   .phy_addr(inst_sram_addr),
                   .tlb_mapped(virt_mapped),
                   .cached(inst_sram_cached),

                   .vpn2(vpn2),
                   .odd_page(odd_page),
                   .pfn(pfn),
                   .c(c),
                   .cp0_config_k0(cp0_config_k0)
               );

    // We misses the delay slot if:
    wire delay_slot_miss =
         ~next_pc_is_next & ~pre_IF_IF_reg_valid;
    reg delay_slot_have_missed;

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

    wire inst_addr_error = (curr_pc_pre_IF_req[1:0] != 2'b00);
    wire inst_tlb_error = virt_mapped & ~(found & v);
    assign tlb_refill = virt_mapped & ~inst_addr_error & ~found;

    always @(*) begin
        // curr_pc_pre_IF_req: the address we request this cycle
        if (exception_like_now_pre_IF) begin
            curr_pc_pre_IF_req = exception_like_now_pc_pre_IF;
        end
        else if (delay_slot_miss || delay_slot_have_missed)
            // We've missed the delay slot, so we request for the instruction
            // of the delay slot in this cycle, and request for the
            // instruction of the target in the next cycle.
            curr_pc_pre_IF_req = curr_pc_IF + 4;
        else if (use_target)
            curr_pc_pre_IF_req = target;
        else
            curr_pc_pre_IF_req = next_pc_without_exception;
    end

    always @(*) begin
        // curr_pc_pre_IF: the address we probably should request the next cycle
        if ((inst_sram_addr_ok && _pre_IF_reg_allow_out)
                || exception_like_now_pre_IF
                || inst_addr_error || inst_tlb_error)
            curr_pc_pre_IF = curr_pc_pre_IF_req;
        else
            curr_pc_pre_IF = curr_pc_IF;
    end
    assign _pre_IF_reg_stall = inst_sram_req & ~inst_sram_addr_ok;

    exception_multiple #(.NUM(2)) pre_IF_exceptions(
                           .exception_old(1'b0),
                           .exccode_old({5{1'bz}}),
                           .exceptions(
                               {
                                   inst_addr_error,
                                   inst_tlb_error
                               }
                           ),
                           .exccodes(
                               {
                                   `EXC_AdEL,
                                   `EXC_TLBL
                               }
                           ),
                           .exception_out(exception_pre_IF),
                           .exccode_out(exccode_pre_IF)
                       );
endmodule
