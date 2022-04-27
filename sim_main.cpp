#include "Vtb_top.h"
#include "verilated.h"
#include "verilatedos.h"

vluint64_t main_time = 0;

double sc_time_stamp() {
    return main_time;
}

int main(int argc, char** argv, char** env)
{
    VerilatedContext* contextp = new VerilatedContext;
    contextp->traceEverOn(true);
    contextp->commandArgs(argc, argv);
    Vtb_top* top = new Vtb_top { contextp };
    top->resetn = 0;
    while (!contextp->gotFinish()) {
        if (main_time > 100) {
            top->resetn = 1;
        }
        top->clk = (top->clk + 1) & 1;
        top->eval();
        main_time++;
    }
    top->final();
    delete top;
    delete contextp;
    return 0;
}
