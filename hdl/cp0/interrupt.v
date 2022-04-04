module interrupt(
        input [7:0] cp0_cause_ip,
        input [7:0] cp0_status_im,
        input cp0_status_ie,
        input cp0_status_exl,
        output reg exc_interrupt
    );
    always @(*) begin
        exc_interrupt = 1'b0;
        if (cp0_status_ie & !cp0_status_exl) begin
            exc_interrupt = |(cp0_status_im & cp0_cause_ip);
        end
    end
endmodule
