## Simulation

### Icarus Verilog

With sram-like interface:
```shell
make run_cpu_sram_sim
```

With AXI interface:
```shell
make run_cpu_axi_sim
```

### Verilator
```shell
make cpu_sram_verilate
./obj_dir/Vtb_top
```

or
```shell
make cpu_axi_verilate
./obj_dir/Vtb_top
```
