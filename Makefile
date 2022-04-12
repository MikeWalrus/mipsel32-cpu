design_source := $(wildcard hdl/*/*.v) $(wildcard hdl/*.v)
verilog-axi_source := $(addprefix \
	sim/verilog-axi/rtl/, axi_ram.v axi_crossbar.v \
	axi_crossbar_wr.v axi_crossbar_addr.v \
	axi_crossbar_rd.v arbiter.v axi_register_wr.v \
	axi_register_rd.v priority_encoder.v \
)
sim_source := $(wildcard sim/*.v) $(verilog-axi_source)

all: cpu_sim

cpu_sim: $(design_source) $(sim_source)
	iverilog -Wall -o $@ -Ihdl/include $(ARGS) -DIVERILOG \
		-DSIMULATION $(design_source) $(sim_source)

.PHONY:
run_sim: cpu_sim
	vvp ./cpu_sim -lxt2

.INTERMEDIATE:
%_test: testbench/%_test.v
	iverilog -Wall $^ -o $@

div_test: hdl/ex/signed_to_abs.v hdl/ex/div.v
tlb_test: hdl/mmu/tlb.v testbench/tlb_top.v hdl/util/mux_1h.v

.PHONY:
run_%_test: %_test
	vvp $? -lxt2

clean:
	-rm cpu_sim dump.lx2
