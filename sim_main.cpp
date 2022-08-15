#include "Vtb_top.h"
#include "verilated.h"
#include "verilatedos.h"
#include "verilated_vcd_c.h"

vluint64_t main_time = 0;

double sc_time_stamp()
{
    return main_time;
}

static inline void print_uart(Vtb_top *top)
{
    if (top->uart_out && top->clk)
        putc(top->uart_char, stdout);
}

int main(int argc, char** argv, char** env)
{
    assert(argc == 3);
    unsigned long int trace_pc = strtol(argv[1], NULL, 16);
    unsigned long int stop_pc = strtol(argv[2], NULL, 16);
    printf("trace_pc: %lx\n", trace_pc);
    printf("stop_pc: %lx\n", stop_pc);

    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;

    VerilatedContext* contextp = new VerilatedContext;
    contextp->traceEverOn(true);
    contextp->commandArgs(argc, argv);
    Vtb_top* top = new Vtb_top { contextp };
    top->resetn = 0;
    while (!contextp->gotFinish()) {
        if (main_time > 100) {
            break;
        }
        top->clk = (top->clk + 1) & 1;
        top->eval();
        print_uart(top);
        main_time++;
    }

    top->resetn = 1;
    while (!contextp->gotFinish()) {
        top->clk = (top->clk + 1) & 1;
        top->eval();
        print_uart(top);
        if (!(main_time % (1 << 20))) {
            printf("pc: %x\n", top->wb_pc);
        }
        main_time++;
        if (top->wb_pc == trace_pc) {
            break;
        }
    }
    printf("Start dumping waveform.\n");
    top->trace(tfp, 99);
    tfp->open("sim_dump.vcd");
    while (!contextp->gotFinish()) {
        top->clk = (top->clk + 1) & 1;
        top->eval();
        tfp->dump(contextp->time());
        print_uart(top);
        if (!(main_time % (1 << 20))) {
            printf("pc: %x\n", top->wb_pc);
        }
        if (top->wb_pc == stop_pc)
            break;
        main_time++;
    }

    tfp->close();
    top->final();
    delete top;
    delete contextp;
    return 0;
}
