cpu_dir := hdl/cpu
cpu_source := $(wildcard $(cpu_dir)/*.v) $(wildcard $(cpu_dir)/*/*.v)

cache_dir := hdl/cache
cache_source := $(wildcard $(cache_dir)/*.v)

headers := hdl/include

verilog-axi_source := $(addprefix \
	sim/axi/verilog-axi/rtl/, axi_ram.v axi_crossbar.v \
	axi_crossbar_wr.v axi_crossbar_addr.v \
	axi_crossbar_rd.v arbiter.v axi_register_wr.v \
	axi_register_rd.v priority_encoder.v \
)

soc_axi_source := $(wildcard hdl/soc/axi/*.v)
soc_axi_sim_source := $(verilog-axi_source) $(wildcard sim/axi/*.v)

soc_sram_source := $(wildcard hdl/soc/sram-like/*.v)
soc_sram_sim_source := $(wildcard sim/sram-like/*.v)

all: cpu_axi_sim

.SECONDEXPANSION:
cpu_%_sim: $(cpu_source) $$(soc_$$*_source) $$(soc_$$*_sim_source) $(cache_source)
	iverilog -Wall -o $@ -I$(headers) $(ARGS) -D$* -DIVERILOG \
		-DSIMULATION $^

cpu_%_verilate: $(cpu_source) $$(soc_$$*_source) $$(soc_$$*_sim_source) $(cache_source)
	verilator --trace --CFLAGS -g -Wno-TIMESCALEMOD -Wno-STMTDLY -Wno-PINMISSING -Wno-INITIALDLY -Wno-CASEINCOMPLETE -Wno-LITENDIAN -Wno-WIDTH -Wno-IMPLICIT -D$* -DIVERILOG --top-module tb_top -I$(headers) $(ARGS) --cc --exe --build sim_main.cpp $^

		
.INTERMEDIATE:
%_test: testbench/%_test.v
	iverilog -DIVERILOG -Wall $^ -o $@

div_test: $(cpu_dir)/ex/signed_to_abs.v $(cpu_dir)/ex/div.v
tlb_test: $(cpu_dir)/mmu/tlb.v testbench/tlb_top.v $(cpu_dir)/util/mux_1h.v
cache_test: $(cache_source) $(cpu_dir)/util/mux.v $(cpu_dir)/util/mux_1h.v \
	$(cpu_dir)/util/bin_to_1h.v $(cpu_dir)/util/isolate_rightmost.v \
	testbench/cache_top.v
lfsr_test: $(cache_dir)/lfsr.v

.PHONY:
run_%: %
	vvp $? -lxt2

clean:
	-rm cpu_sram_sim cpu_axi_sim dump.lx2

install_axi_cpu:
ifndef TARGET_CPU_DIR
	$(error TARGET_CPU_DIR is not set)
endif
	-rm $(TARGET_CPU_DIR)/* -r
	cp --parents -r $(cpu_source) $(headers) $(cache_source) \
		./hdl/soc/axi/mycpu_top.v \
		$(TARGET_CPU_DIR)
ifdef NODEBUG
	find $(TARGET_CPU_DIR) -type f -name '*.v' \
		-exec sed -i 's/"TRUE"/"FALSE"/g' '{}' \;
endif
