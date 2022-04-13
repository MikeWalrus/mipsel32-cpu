cpu_dir := hdl/cpu
cpu_source := $(wildcard $(cpu_dir)/*.v) $(wildcard $(cpu_dir)/*/*.v)
soc_axi_source := $(wildcard hdl/soc/axi/*.v)

verilog-axi_source := $(addprefix \
	sim/verilog-axi/rtl/, axi_ram.v axi_crossbar.v \
	axi_crossbar_wr.v axi_crossbar_addr.v \
	axi_crossbar_rd.v arbiter.v axi_register_wr.v \
	axi_register_rd.v priority_encoder.v \
)

soc_axi_sim_source := $(wildcard sim/*.v) $(verilog-axi_source)

all: cpu_axi_sim

cpu_axi_sim: $(design_source) $(sim_source)
	iverilog -Wall -o $@ -Ihdl/include $(ARGS) -DIVERILOG \
		-DSIMULATION $(cpu_source) $(soc_axi_source) $(soc_axi_sim_source)

.INTERMEDIATE:
%_test: testbench/%_test.v
	iverilog -Wall $^ -o $@

div_test: $(cpu_dir)/ex/signed_to_abs.v $(cpu_dir)/ex/div.v
tlb_test: $(cpu_dir)/mmu/tlb.v testbench/tlb_top.v $(cpu_dir)/util/mux_1h.v

.PHONY:
run_%: %
	vvp $? -lxt2

clean:
	-rm cpu_sim dump.lx2
