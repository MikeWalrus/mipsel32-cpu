SRCS := $(wildcard *.v)
TEST_TARGET_DIR := test
TESTS := $(patsubst %.v, %_test, $(SRCS))

all: sim

sim: *.v
	iverilog -Wall -o sim -DIVERILOG -DSIMULATION *.v BRIDGE/bridge_1x2.v CONFREG/confreg.v

.PHONY:

run_sim: sim
	vvp ./sim -lxt2

$(TEST_TARGET_DIR):
	mkdir $@

.INTERMEDIATE:
$(TEST_TARGET_DIR)/%_test: %.v testbench/%_test.v $(TEST_TARGET_DIR) ./common.vh
	iverilog -Wall $^ -o $@

$(TEST_TARGET_DIR)/div_test: signed_to_abs.v

.PHONY:
%_test: $(TEST_TARGET_DIR)/%_test
	vvp $? -lxt2
