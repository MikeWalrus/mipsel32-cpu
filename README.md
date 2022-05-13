## Simulation
Make sure the memory initialisation files `inst_ram.mif` and `data_ram.mif` are in the top directory, preferably by creating a symbolic link.

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

### FLAGS
To disable trace comparision, invoke `make` with `ARGS=-DNOTRACE`. e.g.:

```shell
make ARGS=-DNOTRACE cpu_sram_verilate
./obj_dir/Vtb_top
```

