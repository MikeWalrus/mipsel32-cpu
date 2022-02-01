SRCS := $(wildcard *.v)
TEST_TARGET_DIR := test
TESTS := $(patsubst %.v, %_test, $(SRCS))

all: sim

sim: *.v
	iverilog -Wall -o sim -DSIMULATION *.v BRIDGE/bridge_1x2.v CONFREG/confreg.v

.PHONY:

run_sim: sim
	vvp ./sim -lxt2

# $(TEST_TARGET_DIR):
# 	mkdir $@

# $(TEST_TARGET_DIR)/%_test: %.v testbench/%_test.v $(TEST_TARGET_DIR) ./common.vh
# 	iverilog -Wall -I testbench $*.v testbench/$*_test.v -o $@

# %_test: $(TEST_TARGET_DIR)/%_test
# 	@! vvp $? | grep "FAILED"
