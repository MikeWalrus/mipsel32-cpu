design_source := $(wildcard hdl/*/*.v) $(wildcard hdl/*.v)

verilog-axi_source := $(wildcard sim/verilog-axi/rtl/*.v)
sim_source := $(wildcard sim/*.v) $(verilog-axi_source)

all: cpu_sim

cpu_sim: $(design_source) $(sim_source)
	iverilog -Wall -o $@ -Ihdl/include -DIVERILOG -DSIMULATION $(design_source) $(sim_source)

.PHONY:
run_sim: cpu_sim
	vvp ./cpu_sim -lxt2

.INTERMEDIATE:
%_test: testbench/%_test.v
	iverilog -Wall $^ -o $@

div_test: hdl/ex/signed_to_abs.v hdl/ex/div.v

.PHONY:
run_%_test: %_test
	vvp $? -lxt2

clean:
	-rm cpu_sim dump.lx2
