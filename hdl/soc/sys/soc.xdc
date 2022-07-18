#clock, resetn
set_property -dict {PACKAGE_PIN AC19 IOSTANDARD LVCMOS33} [get_ports clk]
set_property -dict {PACKAGE_PIN Y3 IOSTANDARD LVCMOS33} [get_ports resetn]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets clk]
create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]

#LED
#set_property PACKAGE_PIN K23 [get_ports {led[0]}]
#set_property PACKAGE_PIN J21 [get_ports {led[1]}]
#set_property PACKAGE_PIN H23 [get_ports {led[2]}]
#set_property PACKAGE_PIN J19 [get_ports {led[3]}]
#set_property PACKAGE_PIN G9 [get_ports {led[4]}]
#set_property PACKAGE_PIN J26 [get_ports {led[5]}]
#set_property PACKAGE_PIN J23 [get_ports {led[6]}]
#set_property PACKAGE_PIN J8 [get_ports {led[7]}]
#set_property PACKAGE_PIN H8 [get_ports {led[8]}]
#set_property PACKAGE_PIN G8 [get_ports {led[9]}]
#set_property PACKAGE_PIN F7 [get_ports {led[10]}]
#set_property PACKAGE_PIN A4 [get_ports {led[11]}]
#set_property PACKAGE_PIN A5 [get_ports {led[12]}]
#set_property PACKAGE_PIN A3 [get_ports {led[13]}]
#set_property PACKAGE_PIN D5 [get_ports {led[14]}]
#set_property PACKAGE_PIN H7 [get_ports {led[15]}]

#led_rg 0/1
#set_property PACKAGE_PIN G7 [get_ports {led_rg0[0]}]
#set_property PACKAGE_PIN F8 [get_ports {led_rg0[1]}]
#set_property PACKAGE_PIN B5 [get_ports {led_rg1[0]}]
#set_property PACKAGE_PIN D6 [get_ports {led_rg1[1]}]

#NUM
#set_property PACKAGE_PIN D3 [get_ports {num_csn[7]}]
#set_property PACKAGE_PIN D25 [get_ports {num_csn[6]}]
#set_property PACKAGE_PIN D26 [get_ports {num_csn[5]}]
#set_property PACKAGE_PIN E25 [get_ports {num_csn[4]}]
#set_property PACKAGE_PIN E26 [get_ports {num_csn[3]}]
#set_property PACKAGE_PIN G25 [get_ports {num_csn[2]}]
#set_property PACKAGE_PIN G26 [get_ports {num_csn[1]}]
#set_property PACKAGE_PIN H26 [get_ports {num_csn[0]}]
#
#set_property PACKAGE_PIN C3 [get_ports {num_a_g[0]}]
#set_property PACKAGE_PIN E6 [get_ports {num_a_g[1]}]
#set_property PACKAGE_PIN B2 [get_ports {num_a_g[2]}]
#set_property PACKAGE_PIN B4 [get_ports {num_a_g[3]}]
#set_property PACKAGE_PIN E5 [get_ports {num_a_g[4]}]
#set_property PACKAGE_PIN D4 [get_ports {num_a_g[5]}]
#set_property PACKAGE_PIN A2 [get_ports {num_a_g[6]}]
#set_property PACKAGE_PIN C4 :DP

#switch
#set_property PACKAGE_PIN AC21 [get_ports {switch[7]}]
#set_property PACKAGE_PIN AD24 [get_ports {switch[6]}]
#set_property PACKAGE_PIN AC22 [get_ports {switch[5]}]
#set_property PACKAGE_PIN AC23 [get_ports {switch[4]}]
#set_property PACKAGE_PIN AB6 [get_ports {switch[3]}]
#set_property PACKAGE_PIN W6 [get_ports {switch[2]}]
#set_property PACKAGE_PIN AA7 [get_ports {switch[1]}]
#set_property PACKAGE_PIN Y6 [get_ports {switch[0]}]

#btn_key
#set_property PACKAGE_PIN V8 [get_ports {btn_key_col[0]}]
#set_property PACKAGE_PIN V9 [get_ports {btn_key_col[1]}]
#set_property PACKAGE_PIN Y8 [get_ports {btn_key_col[2]}]
#set_property PACKAGE_PIN V7 [get_ports {btn_key_col[3]}]
#set_property PACKAGE_PIN U7 [get_ports {btn_key_row[0]}]
#set_property PACKAGE_PIN W8 [get_ports {btn_key_row[1]}]
#set_property PACKAGE_PIN Y7 [get_ports {btn_key_row[2]}]
#set_property PACKAGE_PIN AA8 [get_ports {btn_key_row[3]}]

#btn_step
#set_property PACKAGE_PIN Y5 [get_ports {btn_step[0]}]
#set_property PACKAGE_PIN V6 [get_ports {btn_step[1]}]

#SPI flash
set_property PACKAGE_PIN P20 [get_ports SPI_CLK]
set_property PACKAGE_PIN R20 [get_ports SPI_CS]
set_property PACKAGE_PIN P19 [get_ports SPI_MISO]
set_property PACKAGE_PIN N18 [get_ports SPI_MOSI]

#mac phy connect
set_property -dict {PACKAGE_PIN AB21 IOSTANDARD LVCMOS33} [get_ports MII_tx_clk]
set_property -dict {PACKAGE_PIN AA19 IOSTANDARD LVCMOS33} [get_ports MII_rx_clk]
set_property -dict {PACKAGE_PIN AA15 IOSTANDARD LVCMOS33} [get_ports MII_tx_en]
set_property -dict {PACKAGE_PIN AF18 IOSTANDARD LVCMOS33} [get_ports {MII_txd[0]}]
set_property -dict {PACKAGE_PIN AE18 IOSTANDARD LVCMOS33} [get_ports {MII_txd[1]}]
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS33} [get_ports {MII_txd[2]}]
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports {MII_txd[3]}]
set_property -dict {PACKAGE_PIN AB20 IOSTANDARD LVCMOS33} [get_ports MII_tx_er]
set_property -dict {PACKAGE_PIN AE22 IOSTANDARD LVCMOS33} [get_ports MII_rx_dv]
set_property -dict {PACKAGE_PIN V1 IOSTANDARD LVCMOS33} [get_ports {MII_rxd[0]}]
set_property -dict {PACKAGE_PIN V4 IOSTANDARD LVCMOS33} [get_ports {MII_rxd[1]}]
set_property -dict {PACKAGE_PIN V2 IOSTANDARD LVCMOS33} [get_ports {MII_rxd[2]}]
set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS33} [get_ports {MII_rxd[3]}]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports MII_rx_er]
set_property -dict {PACKAGE_PIN Y15 IOSTANDARD LVCMOS33} [get_ports MII_col]
set_property -dict {PACKAGE_PIN AF20 IOSTANDARD LVCMOS33} [get_ports MII_crs]
set_property -dict {PACKAGE_PIN AE26 IOSTANDARD LVCMOS33} [get_ports MII_rst_n]
set_property -dict {PACKAGE_PIN W3 IOSTANDARD LVCMOS33} [get_ports MDIO_mdc]
set_property -dict {PACKAGE_PIN W1 IOSTANDARD LVCMOS33} [get_ports MDIO_mdio_io]

#uart
set_property PACKAGE_PIN F23 [get_ports UART_rxd]
set_property IOSTANDARD LVCMOS33 [get_ports UART_rxd]
set_property PACKAGE_PIN H19 [get_ports UART_txd]
set_property IOSTANDARD LVCMOS33 [get_ports UART_txd]

#nand flash
#set_property PACKAGE_PIN V19 [get_ports NAND_CLE]
#set_property PACKAGE_PIN W20 [get_ports NAND_ALE]
#set_property PACKAGE_PIN AA25 [get_ports NAND_RDY]
#set_property PACKAGE_PIN AA24 [get_ports NAND_RD]
#set_property PACKAGE_PIN AB24 [get_ports NAND_CE]
#set_property PACKAGE_PIN AA22 [get_ports NAND_WR]
#set_property PACKAGE_PIN W19 [get_ports {NAND_DATA[7]}]
#set_property PACKAGE_PIN Y20 [get_ports {NAND_DATA[6]}]
#set_property PACKAGE_PIN Y21 [get_ports {NAND_DATA[5]}]
#set_property PACKAGE_PIN V18 [get_ports {NAND_DATA[4]}]
#set_property PACKAGE_PIN U19 [get_ports {NAND_DATA[3]}]
#set_property PACKAGE_PIN U20 [get_ports {NAND_DATA[2]}]
#set_property PACKAGE_PIN W21 [get_ports {NAND_DATA[1]}]
#set_property PACKAGE_PIN AC24 [get_ports {NAND_DATA[0]}]

#ejtag
#set_property PACKAGE_PIN J18 [get_ports EJTAG_TRST]
#set_property PACKAGE_PIN K18 [get_ports EJTAG_TCK]
#set_property PACKAGE_PIN K20 [get_ports EJTAG_TDI]
#set_property PACKAGE_PIN K22 [get_ports EJTAG_TMS]
#set_property PACKAGE_PIN K21 [get_ports EJTAG_TDO]


#set_property IOSTANDARD LVCMOS33 [get_ports clk]
#set_property IOSTANDARD LVCMOS33 [get_ports resetn]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led_rg0[*]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led_rg1[*]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {num_a_g[*]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {num_csn[*]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {switch[*]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {btn_key_col[*]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {btn_key_row[*]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {btn_step[*]}]

set_property IOSTANDARD LVCMOS33 [get_ports SPI_MOSI]
set_property IOSTANDARD LVCMOS33 [get_ports SPI_MISO]
set_property IOSTANDARD LVCMOS33 [get_ports SPI_CS]
set_property IOSTANDARD LVCMOS33 [get_ports SPI_CLK]

#set_property IOSTANDARD LVCMOS33 [get_ports {mrxd_0[*]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {mtxd_0[*]}]
#set_property IOSTANDARD LVCMOS33 [get_ports phy_rstn]
#set_property IOSTANDARD LVCMOS33 [get_ports mtxerr_0]
#set_property IOSTANDARD LVCMOS33 [get_ports mtxen_0]
#set_property IOSTANDARD LVCMOS33 [get_ports mtxclk_0]
#set_property IOSTANDARD LVCMOS33 [get_ports mrxerr_0]
#set_property IOSTANDARD LVCMOS33 [get_ports mcoll_0]
#set_property IOSTANDARD LVCMOS33 [get_ports mcrs_0]
#set_property IOSTANDARD LVCMOS33 [get_ports mdc_0]
#set_property IOSTANDARD LVCMOS33 [get_ports mdio_0]
#set_property IOSTANDARD LVCMOS33 [get_ports mrxclk_0]
#set_property IOSTANDARD LVCMOS33 [get_ports mrxdv_0]

#set_property IOSTANDARD LVCMOS33 [get_ports NAND_CLE]
#set_property IOSTANDARD LVCMOS33 [get_ports NAND_ALE]
#set_property IOSTANDARD LVCMOS33 [get_ports NAND_RDY]
#set_property IOSTANDARD LVCMOS33 [get_ports NAND_RD]
#set_property IOSTANDARD LVCMOS33 [get_ports NAND_CE]
#set_property IOSTANDARD LVCMOS33 [get_ports NAND_WR]
#set_property IOSTANDARD LVCMOS33 [get_ports {NAND_DATA[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {NAND_DATA[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {NAND_DATA[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {NAND_DATA[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {NAND_DATA[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {NAND_DATA[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {NAND_DATA[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {NAND_DATA[0]}]

#set_property IOSTANDARD LVCMOS33 [get_ports EJTAG_TRST]
#set_property IOSTANDARD LVCMOS33 [get_ports EJTAG_TCK]
#set_property IOSTANDARD LVCMOS33 [get_ports EJTAG_TDI]
#set_property IOSTANDARD LVCMOS33 [get_ports EJTAG_TMS]
#set_property IOSTANDARD LVCMOS33 [get_ports EJTAG_TDO]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets EJTAG_TCK_IBUF]

#create_clock -period 40.000 -name mrxclk_0 -waveform {0.000 20.000} [get_ports mrxclk_0]
#create_clock -period 40.000 -name mtxclk_0 -waveform {0.000 20.000} [get_ports mtxclk_0]

#set_false_path -from [get_clocks clk_pll_i] -to [get_clocks clk_out1_clk_pll_33]
#set_false_path -from [get_clocks mrxclk_0] -to [get_clocks clk_out1_clk_pll_33]
#set_false_path -from [get_clocks mtxclk_0] -to [get_clocks clk_out1_clk_pll_33]
#set_false_path -from [get_clocks clk_out1_clk_pll_33] -to [get_clocks mrxclk_0]
#set_false_path -from [get_clocks clk_out1_clk_pll_33] -to [get_clocks mrxclk_0]
#set_false_path -from [get_clocks clk_out1_clk_pll_33] -to [get_clocks mtxclk_0]
#set_false_path -from [get_clocks clk_out1_clk_pll_33] -to [get_clocks mtxclk_0]


set_property MARK_DEBUG true [get_nets design_1_i/SPI_MISO]
set_property MARK_DEBUG true [get_nets design_1_i/SPI_MOSI]

connect_debug_port u_ila_2/probe0 [get_nets [list design_1_i/spi_flash_ctrl_0_SPI_CLK]]
connect_debug_port u_ila_2/probe1 [get_nets [list design_1_i/spi_flash_ctrl_0_SPI_CS]]
connect_debug_port u_ila_2/probe2 [get_nets [list design_1_i/SPI_MISO]]
connect_debug_port u_ila_2/probe3 [get_nets [list design_1_i/SPI_MOSI]]

connect_debug_port u_ila_1/probe0 [get_nets [list design_1_i/M03_ARESETN_1]]


create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list design_1_i/clk_wiz/inst/cpu_clk]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 32 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {design_1_i/CPU/inst/cpu_sram/data_sram_addr[0]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[1]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[2]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[3]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[4]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[5]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[6]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[7]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[8]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[9]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[10]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[11]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[12]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[13]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[14]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[15]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[16]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[17]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[18]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[19]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[20]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[21]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[22]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[23]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[24]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[25]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[26]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[27]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[28]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[29]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[30]} {design_1_i/CPU/inst/cpu_sram/data_sram_addr[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 32 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[0]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[1]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[2]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[3]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[4]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[5]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[6]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[7]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[8]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[9]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[10]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[11]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[12]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[13]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[14]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[15]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[16]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[17]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[18]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[19]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[20]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[21]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[22]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[23]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[24]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[25]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[26]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[27]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[28]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[29]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[30]} {design_1_i/CPU/inst/cpu_sram/curr_pc_pre_IF[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 4 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wen[0]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wen[1]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wen[2]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wen[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 32 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[0]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[1]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[2]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[3]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[4]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[5]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[6]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[7]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[8]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[9]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[10]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[11]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[12]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[13]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[14]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[15]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[16]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[17]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[18]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[19]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[20]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[21]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[22]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[23]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[24]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[25]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[26]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[27]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[28]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[29]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[30]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wdata[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 32 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[0]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[1]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[2]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[3]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[4]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[5]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[6]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[7]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[8]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[9]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[10]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[11]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[12]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[13]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[14]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[15]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[16]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[17]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[18]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[19]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[20]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[21]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[22]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[23]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[24]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[25]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[26]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[27]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[28]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[29]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[30]} {design_1_i/CPU/inst/cpu_sram/curr_pc_WB[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 32 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {design_1_i/CPU/inst/cpu_sram/instruction_ID[0]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[1]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[2]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[3]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[4]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[5]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[6]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[7]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[8]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[9]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[10]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[11]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[12]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[13]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[14]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[15]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[16]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[17]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[18]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[19]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[20]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[21]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[22]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[23]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[24]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[25]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[26]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[27]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[28]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[29]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[30]} {design_1_i/CPU/inst/cpu_sram/instruction_ID[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 3 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {design_1_i/CPU/inst/cpu_sram/data_sram_request/addr_trans_data/cp0_config_k0[0]} {design_1_i/CPU/inst/cpu_sram/data_sram_request/addr_trans_data/cp0_config_k0[1]} {design_1_i/CPU/inst/cpu_sram/data_sram_request/addr_trans_data/cp0_config_k0[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 5 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wnum[0]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wnum[1]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wnum[2]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wnum[3]} {design_1_i/CPU/inst/cpu_sram/debug_wb_rf_wnum[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 32 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[0]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[1]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[2]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[3]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[4]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[5]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[6]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[7]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[8]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[9]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[10]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[11]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[12]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[13]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[14]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[15]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[16]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[17]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[18]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[19]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[20]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[21]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[22]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[23]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[24]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[25]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[26]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[27]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[28]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[29]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[30]} {design_1_i/CPU/inst/cpu_sram/curr_pc_MEM[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 4 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/wstrb[0]} {design_1_i/CPU/inst/sram_to_axi/wstrb[1]} {design_1_i/CPU/inst/sram_to_axi/wstrb[2]} {design_1_i/CPU/inst/sram_to_axi/wstrb[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 4 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/arcache[0]} {design_1_i/CPU/inst/sram_to_axi/arcache[1]} {design_1_i/CPU/inst/sram_to_axi/arcache[2]} {design_1_i/CPU/inst/sram_to_axi/arcache[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 8 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/arlen[0]} {design_1_i/CPU/inst/sram_to_axi/arlen[1]} {design_1_i/CPU/inst/sram_to_axi/arlen[2]} {design_1_i/CPU/inst/sram_to_axi/arlen[3]} {design_1_i/CPU/inst/sram_to_axi/arlen[4]} {design_1_i/CPU/inst/sram_to_axi/arlen[5]} {design_1_i/CPU/inst/sram_to_axi/arlen[6]} {design_1_i/CPU/inst/sram_to_axi/arlen[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 2 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/awburst[0]} {design_1_i/CPU/inst/sram_to_axi/awburst[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 32 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/araddr[0]} {design_1_i/CPU/inst/sram_to_axi/araddr[1]} {design_1_i/CPU/inst/sram_to_axi/araddr[2]} {design_1_i/CPU/inst/sram_to_axi/araddr[3]} {design_1_i/CPU/inst/sram_to_axi/araddr[4]} {design_1_i/CPU/inst/sram_to_axi/araddr[5]} {design_1_i/CPU/inst/sram_to_axi/araddr[6]} {design_1_i/CPU/inst/sram_to_axi/araddr[7]} {design_1_i/CPU/inst/sram_to_axi/araddr[8]} {design_1_i/CPU/inst/sram_to_axi/araddr[9]} {design_1_i/CPU/inst/sram_to_axi/araddr[10]} {design_1_i/CPU/inst/sram_to_axi/araddr[11]} {design_1_i/CPU/inst/sram_to_axi/araddr[12]} {design_1_i/CPU/inst/sram_to_axi/araddr[13]} {design_1_i/CPU/inst/sram_to_axi/araddr[14]} {design_1_i/CPU/inst/sram_to_axi/araddr[15]} {design_1_i/CPU/inst/sram_to_axi/araddr[16]} {design_1_i/CPU/inst/sram_to_axi/araddr[17]} {design_1_i/CPU/inst/sram_to_axi/araddr[18]} {design_1_i/CPU/inst/sram_to_axi/araddr[19]} {design_1_i/CPU/inst/sram_to_axi/araddr[20]} {design_1_i/CPU/inst/sram_to_axi/araddr[21]} {design_1_i/CPU/inst/sram_to_axi/araddr[22]} {design_1_i/CPU/inst/sram_to_axi/araddr[23]} {design_1_i/CPU/inst/sram_to_axi/araddr[24]} {design_1_i/CPU/inst/sram_to_axi/araddr[25]} {design_1_i/CPU/inst/sram_to_axi/araddr[26]} {design_1_i/CPU/inst/sram_to_axi/araddr[27]} {design_1_i/CPU/inst/sram_to_axi/araddr[28]} {design_1_i/CPU/inst/sram_to_axi/araddr[29]} {design_1_i/CPU/inst/sram_to_axi/araddr[30]} {design_1_i/CPU/inst/sram_to_axi/araddr[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 4 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/arid[0]} {design_1_i/CPU/inst/sram_to_axi/arid[1]} {design_1_i/CPU/inst/sram_to_axi/arid[2]} {design_1_i/CPU/inst/sram_to_axi/arid[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 2 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/arburst[0]} {design_1_i/CPU/inst/sram_to_axi/arburst[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 8 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/awlen[0]} {design_1_i/CPU/inst/sram_to_axi/awlen[1]} {design_1_i/CPU/inst/sram_to_axi/awlen[2]} {design_1_i/CPU/inst/sram_to_axi/awlen[3]} {design_1_i/CPU/inst/sram_to_axi/awlen[4]} {design_1_i/CPU/inst/sram_to_axi/awlen[5]} {design_1_i/CPU/inst/sram_to_axi/awlen[6]} {design_1_i/CPU/inst/sram_to_axi/awlen[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 3 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/arsize[0]} {design_1_i/CPU/inst/sram_to_axi/arsize[1]} {design_1_i/CPU/inst/sram_to_axi/arsize[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 32 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/awaddr[0]} {design_1_i/CPU/inst/sram_to_axi/awaddr[1]} {design_1_i/CPU/inst/sram_to_axi/awaddr[2]} {design_1_i/CPU/inst/sram_to_axi/awaddr[3]} {design_1_i/CPU/inst/sram_to_axi/awaddr[4]} {design_1_i/CPU/inst/sram_to_axi/awaddr[5]} {design_1_i/CPU/inst/sram_to_axi/awaddr[6]} {design_1_i/CPU/inst/sram_to_axi/awaddr[7]} {design_1_i/CPU/inst/sram_to_axi/awaddr[8]} {design_1_i/CPU/inst/sram_to_axi/awaddr[9]} {design_1_i/CPU/inst/sram_to_axi/awaddr[10]} {design_1_i/CPU/inst/sram_to_axi/awaddr[11]} {design_1_i/CPU/inst/sram_to_axi/awaddr[12]} {design_1_i/CPU/inst/sram_to_axi/awaddr[13]} {design_1_i/CPU/inst/sram_to_axi/awaddr[14]} {design_1_i/CPU/inst/sram_to_axi/awaddr[15]} {design_1_i/CPU/inst/sram_to_axi/awaddr[16]} {design_1_i/CPU/inst/sram_to_axi/awaddr[17]} {design_1_i/CPU/inst/sram_to_axi/awaddr[18]} {design_1_i/CPU/inst/sram_to_axi/awaddr[19]} {design_1_i/CPU/inst/sram_to_axi/awaddr[20]} {design_1_i/CPU/inst/sram_to_axi/awaddr[21]} {design_1_i/CPU/inst/sram_to_axi/awaddr[22]} {design_1_i/CPU/inst/sram_to_axi/awaddr[23]} {design_1_i/CPU/inst/sram_to_axi/awaddr[24]} {design_1_i/CPU/inst/sram_to_axi/awaddr[25]} {design_1_i/CPU/inst/sram_to_axi/awaddr[26]} {design_1_i/CPU/inst/sram_to_axi/awaddr[27]} {design_1_i/CPU/inst/sram_to_axi/awaddr[28]} {design_1_i/CPU/inst/sram_to_axi/awaddr[29]} {design_1_i/CPU/inst/sram_to_axi/awaddr[30]} {design_1_i/CPU/inst/sram_to_axi/awaddr[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 3 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/arprot[0]} {design_1_i/CPU/inst/sram_to_axi/arprot[1]} {design_1_i/CPU/inst/sram_to_axi/arprot[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 4 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/bid[0]} {design_1_i/CPU/inst/sram_to_axi/bid[1]} {design_1_i/CPU/inst/sram_to_axi/bid[2]} {design_1_i/CPU/inst/sram_to_axi/bid[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 3 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/awsize[0]} {design_1_i/CPU/inst/sram_to_axi/awsize[1]} {design_1_i/CPU/inst/sram_to_axi/awsize[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 3 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/awprot[0]} {design_1_i/CPU/inst/sram_to_axi/awprot[1]} {design_1_i/CPU/inst/sram_to_axi/awprot[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 2 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/bresp[0]} {design_1_i/CPU/inst/sram_to_axi/bresp[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 4 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/awid[0]} {design_1_i/CPU/inst/sram_to_axi/awid[1]} {design_1_i/CPU/inst/sram_to_axi/awid[2]} {design_1_i/CPU/inst/sram_to_axi/awid[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 4 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/awcache[0]} {design_1_i/CPU/inst/sram_to_axi/awcache[1]} {design_1_i/CPU/inst/sram_to_axi/awcache[2]} {design_1_i/CPU/inst/sram_to_axi/awcache[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 32 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/wdata[0]} {design_1_i/CPU/inst/sram_to_axi/wdata[1]} {design_1_i/CPU/inst/sram_to_axi/wdata[2]} {design_1_i/CPU/inst/sram_to_axi/wdata[3]} {design_1_i/CPU/inst/sram_to_axi/wdata[4]} {design_1_i/CPU/inst/sram_to_axi/wdata[5]} {design_1_i/CPU/inst/sram_to_axi/wdata[6]} {design_1_i/CPU/inst/sram_to_axi/wdata[7]} {design_1_i/CPU/inst/sram_to_axi/wdata[8]} {design_1_i/CPU/inst/sram_to_axi/wdata[9]} {design_1_i/CPU/inst/sram_to_axi/wdata[10]} {design_1_i/CPU/inst/sram_to_axi/wdata[11]} {design_1_i/CPU/inst/sram_to_axi/wdata[12]} {design_1_i/CPU/inst/sram_to_axi/wdata[13]} {design_1_i/CPU/inst/sram_to_axi/wdata[14]} {design_1_i/CPU/inst/sram_to_axi/wdata[15]} {design_1_i/CPU/inst/sram_to_axi/wdata[16]} {design_1_i/CPU/inst/sram_to_axi/wdata[17]} {design_1_i/CPU/inst/sram_to_axi/wdata[18]} {design_1_i/CPU/inst/sram_to_axi/wdata[19]} {design_1_i/CPU/inst/sram_to_axi/wdata[20]} {design_1_i/CPU/inst/sram_to_axi/wdata[21]} {design_1_i/CPU/inst/sram_to_axi/wdata[22]} {design_1_i/CPU/inst/sram_to_axi/wdata[23]} {design_1_i/CPU/inst/sram_to_axi/wdata[24]} {design_1_i/CPU/inst/sram_to_axi/wdata[25]} {design_1_i/CPU/inst/sram_to_axi/wdata[26]} {design_1_i/CPU/inst/sram_to_axi/wdata[27]} {design_1_i/CPU/inst/sram_to_axi/wdata[28]} {design_1_i/CPU/inst/sram_to_axi/wdata[29]} {design_1_i/CPU/inst/sram_to_axi/wdata[30]} {design_1_i/CPU/inst/sram_to_axi/wdata[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
set_property port_width 32 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/i_rdata[0]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[1]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[2]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[3]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[4]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[5]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[6]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[7]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[8]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[9]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[10]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[11]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[12]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[13]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[14]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[15]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[16]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[17]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[18]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[19]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[20]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[21]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[22]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[23]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[24]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[25]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[26]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[27]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[28]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[29]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[30]} {design_1_i/CPU/inst/sram_to_axi/i_rdata[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe28]
set_property port_width 2 [get_debug_ports u_ila_0/probe28]
connect_debug_port u_ila_0/probe28 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/d_size[0]} {design_1_i/CPU/inst/sram_to_axi/d_size[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe29]
set_property port_width 32 [get_debug_ports u_ila_0/probe29]
connect_debug_port u_ila_0/probe29 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/d_rdata[0]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[1]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[2]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[3]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[4]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[5]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[6]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[7]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[8]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[9]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[10]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[11]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[12]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[13]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[14]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[15]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[16]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[17]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[18]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[19]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[20]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[21]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[22]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[23]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[24]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[25]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[26]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[27]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[28]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[29]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[30]} {design_1_i/CPU/inst/sram_to_axi/d_rdata[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe30]
set_property port_width 4 [get_debug_ports u_ila_0/probe30]
connect_debug_port u_ila_0/probe30 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/d_wstrb[0]} {design_1_i/CPU/inst/sram_to_axi/d_wstrb[1]} {design_1_i/CPU/inst/sram_to_axi/d_wstrb[2]} {design_1_i/CPU/inst/sram_to_axi/d_wstrb[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe31]
set_property port_width 32 [get_debug_ports u_ila_0/probe31]
connect_debug_port u_ila_0/probe31 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/d_wdata[0]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[1]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[2]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[3]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[4]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[5]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[6]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[7]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[8]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[9]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[10]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[11]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[12]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[13]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[14]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[15]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[16]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[17]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[18]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[19]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[20]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[21]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[22]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[23]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[24]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[25]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[26]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[27]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[28]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[29]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[30]} {design_1_i/CPU/inst/sram_to_axi/d_wdata[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe32]
set_property port_width 32 [get_debug_ports u_ila_0/probe32]
connect_debug_port u_ila_0/probe32 [get_nets [list {design_1_i/CPU/inst/sram_to_axi/i_addr[0]} {design_1_i/CPU/inst/sram_to_axi/i_addr[1]} {design_1_i/CPU/inst/sram_to_axi/i_addr[2]} {design_1_i/CPU/inst/sram_to_axi/i_addr[3]} {design_1_i/CPU/inst/sram_to_axi/i_addr[4]} {design_1_i/CPU/inst/sram_to_axi/i_addr[5]} {design_1_i/CPU/inst/sram_to_axi/i_addr[6]} {design_1_i/CPU/inst/sram_to_axi/i_addr[7]} {design_1_i/CPU/inst/sram_to_axi/i_addr[8]} {design_1_i/CPU/inst/sram_to_axi/i_addr[9]} {design_1_i/CPU/inst/sram_to_axi/i_addr[10]} {design_1_i/CPU/inst/sram_to_axi/i_addr[11]} {design_1_i/CPU/inst/sram_to_axi/i_addr[12]} {design_1_i/CPU/inst/sram_to_axi/i_addr[13]} {design_1_i/CPU/inst/sram_to_axi/i_addr[14]} {design_1_i/CPU/inst/sram_to_axi/i_addr[15]} {design_1_i/CPU/inst/sram_to_axi/i_addr[16]} {design_1_i/CPU/inst/sram_to_axi/i_addr[17]} {design_1_i/CPU/inst/sram_to_axi/i_addr[18]} {design_1_i/CPU/inst/sram_to_axi/i_addr[19]} {design_1_i/CPU/inst/sram_to_axi/i_addr[20]} {design_1_i/CPU/inst/sram_to_axi/i_addr[21]} {design_1_i/CPU/inst/sram_to_axi/i_addr[22]} {design_1_i/CPU/inst/sram_to_axi/i_addr[23]} {design_1_i/CPU/inst/sram_to_axi/i_addr[24]} {design_1_i/CPU/inst/sram_to_axi/i_addr[25]} {design_1_i/CPU/inst/sram_to_axi/i_addr[26]} {design_1_i/CPU/inst/sram_to_axi/i_addr[27]} {design_1_i/CPU/inst/sram_to_axi/i_addr[28]} {design_1_i/CPU/inst/sram_to_axi/i_addr[29]} {design_1_i/CPU/inst/sram_to_axi/i_addr[30]} {design_1_i/CPU/inst/sram_to_axi/i_addr[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe33]
set_property port_width 32 [get_debug_ports u_ila_0/probe33]
connect_debug_port u_ila_0/probe33 [get_nets [list {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[0]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[1]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[2]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[3]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[4]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[5]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[6]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[7]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[8]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[9]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[10]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[11]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[12]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[13]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[14]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[15]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[16]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[17]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[18]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[19]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[20]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[21]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[22]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[23]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[24]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[25]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[26]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[27]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[28]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[29]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[30]} {design_1_i/CPU/inst/cpu_sram/curr_pc_IF[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe34]
set_property port_width 32 [get_debug_ports u_ila_0/probe34]
connect_debug_port u_ila_0/probe34 [get_nets [list {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[0]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[1]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[2]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[3]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[4]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[5]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[6]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[7]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[8]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[9]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[10]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[11]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[12]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[13]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[14]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[15]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[16]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[17]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[18]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[19]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[20]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[21]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[22]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[23]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[24]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[25]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[26]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[27]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[28]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[29]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[30]} {design_1_i/CPU/inst/cpu_sram/curr_pc_EX[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe35]
set_property port_width 32 [get_debug_ports u_ila_0/probe35]
connect_debug_port u_ila_0/probe35 [get_nets [list {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[0]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[1]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[2]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[3]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[4]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[5]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[6]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[7]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[8]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[9]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[10]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[11]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[12]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[13]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[14]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[15]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[16]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[17]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[18]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[19]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[20]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[21]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[22]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[23]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[24]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[25]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[26]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[27]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[28]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[29]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[30]} {design_1_i/CPU/inst/cpu_sram/curr_pc_ID[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe36]
set_property port_width 1 [get_debug_ports u_ila_0/probe36]
connect_debug_port u_ila_0/probe36 [get_nets [list design_1_i/ARESETN_1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe37]
set_property port_width 1 [get_debug_ports u_ila_0/probe37]
connect_debug_port u_ila_0/probe37 [get_nets [list design_1_i/CPU/inst/sram_to_axi/arready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe38]
set_property port_width 1 [get_debug_ports u_ila_0/probe38]
connect_debug_port u_ila_0/probe38 [get_nets [list design_1_i/CPU/inst/sram_to_axi/arvalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe39]
set_property port_width 1 [get_debug_ports u_ila_0/probe39]
connect_debug_port u_ila_0/probe39 [get_nets [list design_1_i/CPU/inst/sram_to_axi/awready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe40]
set_property port_width 1 [get_debug_ports u_ila_0/probe40]
connect_debug_port u_ila_0/probe40 [get_nets [list design_1_i/CPU/inst/sram_to_axi/awvalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe41]
set_property port_width 1 [get_debug_ports u_ila_0/probe41]
connect_debug_port u_ila_0/probe41 [get_nets [list design_1_i/CPU/inst/sram_to_axi/bready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe42]
set_property port_width 1 [get_debug_ports u_ila_0/probe42]
connect_debug_port u_ila_0/probe42 [get_nets [list design_1_i/CPU/inst/sram_to_axi/bvalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe43]
set_property port_width 1 [get_debug_ports u_ila_0/probe43]
connect_debug_port u_ila_0/probe43 [get_nets [list design_1_i/CPU/inst/cpu_sram/pre_IF/addr_trans_inst/cached]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe44]
set_property port_width 1 [get_debug_ports u_ila_0/probe44]
connect_debug_port u_ila_0/probe44 [get_nets [list design_1_i/CPU/inst/sram_to_axi/d_addr_ok]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe45]
set_property port_width 1 [get_debug_ports u_ila_0/probe45]
connect_debug_port u_ila_0/probe45 [get_nets [list design_1_i/CPU/inst/sram_to_axi/d_cacheop]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe46]
set_property port_width 1 [get_debug_ports u_ila_0/probe46]
connect_debug_port u_ila_0/probe46 [get_nets [list design_1_i/CPU/inst/sram_to_axi/d_cacheop_hit]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe47]
set_property port_width 1 [get_debug_ports u_ila_0/probe47]
connect_debug_port u_ila_0/probe47 [get_nets [list design_1_i/CPU/inst/sram_to_axi/d_cacheop_index]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe48]
set_property port_width 1 [get_debug_ports u_ila_0/probe48]
connect_debug_port u_ila_0/probe48 [get_nets [list design_1_i/CPU/inst/sram_to_axi/d_cacheop_ok1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe49]
set_property port_width 1 [get_debug_ports u_ila_0/probe49]
connect_debug_port u_ila_0/probe49 [get_nets [list design_1_i/CPU/inst/sram_to_axi/d_cacheop_ok2]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe50]
set_property port_width 1 [get_debug_ports u_ila_0/probe50]
connect_debug_port u_ila_0/probe50 [get_nets [list design_1_i/CPU/inst/sram_to_axi/d_cacheop_wb]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe51]
set_property port_width 1 [get_debug_ports u_ila_0/probe51]
connect_debug_port u_ila_0/probe51 [get_nets [list design_1_i/CPU/inst/sram_to_axi/d_data_ok]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe52]
set_property port_width 1 [get_debug_ports u_ila_0/probe52]
connect_debug_port u_ila_0/probe52 [get_nets [list design_1_i/CPU/inst/sram_to_axi/d_uncached]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe53]
set_property port_width 1 [get_debug_ports u_ila_0/probe53]
connect_debug_port u_ila_0/probe53 [get_nets [list design_1_i/CPU/inst/sram_to_axi/d_wr]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe54]
set_property port_width 1 [get_debug_ports u_ila_0/probe54]
connect_debug_port u_ila_0/probe54 [get_nets [list design_1_i/CPU/inst/cpu_sram/data_sram_cached]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe55]
set_property port_width 1 [get_debug_ports u_ila_0/probe55]
connect_debug_port u_ila_0/probe55 [get_nets [list design_1_i/CPU/inst/cpu_sram/data_sram_req]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe56]
set_property port_width 1 [get_debug_ports u_ila_0/probe56]
connect_debug_port u_ila_0/probe56 [get_nets [list design_1_i/CPU/inst/sram_to_axi/i_addr_ok]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe57]
set_property port_width 1 [get_debug_ports u_ila_0/probe57]
connect_debug_port u_ila_0/probe57 [get_nets [list design_1_i/CPU/inst/sram_to_axi/i_cacheop]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe58]
set_property port_width 1 [get_debug_ports u_ila_0/probe58]
connect_debug_port u_ila_0/probe58 [get_nets [list design_1_i/CPU/inst/sram_to_axi/i_cacheop_ok1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe59]
set_property port_width 1 [get_debug_ports u_ila_0/probe59]
connect_debug_port u_ila_0/probe59 [get_nets [list design_1_i/CPU/inst/sram_to_axi/i_cacheop_ok2]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe60]
set_property port_width 1 [get_debug_ports u_ila_0/probe60]
connect_debug_port u_ila_0/probe60 [get_nets [list design_1_i/CPU/inst/sram_to_axi/i_data_ok]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe61]
set_property port_width 1 [get_debug_ports u_ila_0/probe61]
connect_debug_port u_ila_0/probe61 [get_nets [list design_1_i/CPU/inst/sram_to_axi/i_req]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe62]
set_property port_width 1 [get_debug_ports u_ila_0/probe62]
connect_debug_port u_ila_0/probe62 [get_nets [list design_1_i/CPU/inst/sram_to_axi/i_uncached]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe63]
set_property port_width 1 [get_debug_ports u_ila_0/probe63]
connect_debug_port u_ila_0/probe63 [get_nets [list design_1_i/CPU/inst/sram_to_axi/rlast]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe64]
set_property port_width 1 [get_debug_ports u_ila_0/probe64]
connect_debug_port u_ila_0/probe64 [get_nets [list design_1_i/CPU/inst/sram_to_axi/rready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe65]
set_property port_width 1 [get_debug_ports u_ila_0/probe65]
connect_debug_port u_ila_0/probe65 [get_nets [list design_1_i/rst_clk_wiz_100M_mb_reset]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe66]
set_property port_width 1 [get_debug_ports u_ila_0/probe66]
connect_debug_port u_ila_0/probe66 [get_nets [list design_1_i/rst_clk_wiz_100M_peripheral_aresetn]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe67]
set_property port_width 1 [get_debug_ports u_ila_0/probe67]
connect_debug_port u_ila_0/probe67 [get_nets [list design_1_i/CPU/inst/sram_to_axi/rvalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe68]
set_property port_width 1 [get_debug_ports u_ila_0/probe68]
connect_debug_port u_ila_0/probe68 [get_nets [list design_1_i/CPU/inst/sram_to_axi/wlast]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe69]
set_property port_width 1 [get_debug_ports u_ila_0/probe69]
connect_debug_port u_ila_0/probe69 [get_nets [list design_1_i/CPU/inst/sram_to_axi/wready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe70]
set_property port_width 1 [get_debug_ports u_ila_0/probe70]
connect_debug_port u_ila_0/probe70 [get_nets [list design_1_i/CPU/inst/sram_to_axi/wvalid]]
create_debug_core u_ila_1 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_1]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_1]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_1]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_1]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_1]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_1]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_1]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_1]
set_property port_width 1 [get_debug_ports u_ila_1/clk]
connect_debug_port u_ila_1/clk [get_nets [list design_1_i/ddr3_controller/u_design_1_mig_7series_0_0_mig/u_ddr3_infrastructure/CLK]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe0]
set_property port_width 1 [get_debug_ports u_ila_1/probe0]
connect_debug_port u_ila_1/probe0 [get_nets [list design_1_i/ddr3_controller_init_calib_complete]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe1]
set_property port_width 1 [get_debug_ports u_ila_1/probe1]
connect_debug_port u_ila_1/probe1 [get_nets [list design_1_i/proc_sys_reset_0_peripheral_aresetn]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_1_CLK]
