//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
//Date        : Thu Jul 14 17:09:46 2022
//Host        : oyster running 64-bit Arch Linux
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
    (DDR3_addr,
     DDR3_ba,
     DDR3_cas_n,
     DDR3_ck_n,
     DDR3_ck_p,
     DDR3_cke,
     DDR3_dm,
     DDR3_dq,
     DDR3_dqs_n,
     DDR3_dqs_p,
     DDR3_odt,
     DDR3_ras_n,
     DDR3_reset_n,
     DDR3_we_n,
     MDIO_mdc,
     MDIO_mdio_io,
     MII_col,
     MII_crs,
     MII_rst_n,
     MII_rx_clk,
     MII_rx_dv,
     MII_rx_er,
     MII_rxd,
     MII_tx_clk,
     MII_tx_en,
     MII_txd,
     SPI_CLK,
     SPI_CS,
     SPI_MISO,
     SPI_MOSI,
     /* UART_baudoutn, */
     /* UART_ctsn, */
     /* UART_dcdn, */
     /* UART_ddis, */
     /* UART_dsrn, */
     /* UART_dtrn, */
     /* UART_out1n, */
     /* UART_out2n, */
     /* UART_ri, */
     /* UART_rtsn, */
     UART_rxd,
     /* UART_rxrdyn, */
     UART_txd,
     /* UART_txrdyn, */
     clk,
     resetn);
    output [12:0]DDR3_addr;
    output [2:0]DDR3_ba;
    output DDR3_cas_n;
    output [0:0]DDR3_ck_n;
    output [0:0]DDR3_ck_p;
    output [0:0]DDR3_cke;
    output [1:0]DDR3_dm;
    inout [15:0]DDR3_dq;
    inout [1:0]DDR3_dqs_n;
    inout [1:0]DDR3_dqs_p;
    output [0:0]DDR3_odt;
    output DDR3_ras_n;
    output DDR3_reset_n;
    output DDR3_we_n;
    output MDIO_mdc;
    inout MDIO_mdio_io;
    input MII_col;
    input MII_crs;
    output MII_rst_n;
    input MII_rx_clk;
    input MII_rx_dv;
    input MII_rx_er;
    input [3:0]MII_rxd;
    input MII_tx_clk;
    output MII_tx_en;
    output [3:0]MII_txd;
    output SPI_CLK;
    output SPI_CS;
    inout SPI_MISO;
    inout SPI_MOSI;
    /* output UART_baudoutn; */
    /* input UART_ctsn; */
    /* input UART_dcdn; */
    /* output UART_ddis; */
    /* input UART_dsrn; */
    /* output UART_dtrn; */
    /* output UART_out1n; */
    /* output UART_out2n; */
    /* input UART_ri; */
    /* output UART_rtsn; */
    input UART_rxd;
    /* output UART_rxrdyn; */
    output UART_txd;
    /* output UART_txrdyn; */
    input clk;
    input resetn;

    wire [12:0]DDR3_addr;
    wire [2:0]DDR3_ba;
    wire DDR3_cas_n;
    wire [0:0]DDR3_ck_n;
    wire [0:0]DDR3_ck_p;
    wire [0:0]DDR3_cke;
    wire [1:0]DDR3_dm;
    wire [15:0]DDR3_dq;
    wire [1:0]DDR3_dqs_n;
    wire [1:0]DDR3_dqs_p;
    wire [0:0]DDR3_odt;
    wire DDR3_ras_n;
    wire DDR3_reset_n;
    wire DDR3_we_n;
    wire MDIO_mdc;
    wire MDIO_mdio_i;
    wire MDIO_mdio_io;
    wire MDIO_mdio_o;
    wire MDIO_mdio_t;
    wire MII_col;
    wire MII_crs;
    wire MII_rst_n;
    wire MII_rx_clk;
    wire MII_rx_dv;
    wire MII_rx_er;
    wire [3:0]MII_rxd;
    wire MII_tx_clk;
    wire MII_tx_en;
    wire [3:0]MII_txd;
    wire SPI_CLK;
    wire SPI_CS;
    wire SPI_MISO;
    wire SPI_MOSI;
    /* wire UART_baudoutn; */
    /* wire UART_ctsn; */
    /* wire UART_dcdn; */
    /* wire UART_ddis; */
    /* wire UART_dsrn; */
    /* wire UART_dtrn; */
    /* wire UART_out1n; */
    /* wire UART_out2n; */
    /* wire UART_ri; */
    /* wire UART_rtsn; */
    wire UART_rxd;
    /* wire UART_rxrdyn; */
    wire UART_txd;
    /* wire UART_txrdyn; */
    wire clk;
    wire resetn;
    wire [3:0]SPI_csn_o ;
    wire [3:0]SPI_csn_en;
    wire SPI_sck_o ;
    wire SPI_sdo_i ;
    wire SPI_sdo_o ;
    wire SPI_sdo_en;
    wire SPI_sdi_i ;
    wire SPI_sdi_o ;
    wire SPI_sdi_en;
    assign     SPI_CLK = SPI_sck_o;
    assign     SPI_CS  = ~SPI_csn_en[0] & SPI_csn_o[0];
    assign     SPI_MOSI = SPI_sdo_en ? 1'bz : SPI_sdo_o ;
    assign     SPI_MISO = SPI_sdi_en ? 1'bz : SPI_sdi_o ;
    assign     SPI_sdo_i = SPI_MOSI;
    assign     SPI_sdi_i = SPI_MISO;

    IOBUF MDIO_mdio_iobuf
          (.I(MDIO_mdio_o),
           .IO(MDIO_mdio_io),
           .O(MDIO_mdio_i),
           .T(MDIO_mdio_t));
    design_1 design_1_i
             (.DDR3_addr(DDR3_addr),
              .DDR3_ba(DDR3_ba),
              .DDR3_cas_n(DDR3_cas_n),
              .DDR3_ck_n(DDR3_ck_n),
              .DDR3_ck_p(DDR3_ck_p),
              .DDR3_cke(DDR3_cke),
              .DDR3_dm(DDR3_dm),
              .DDR3_dq(DDR3_dq),
              .DDR3_dqs_n(DDR3_dqs_n),
              .DDR3_dqs_p(DDR3_dqs_p),
              .DDR3_odt(DDR3_odt),
              .DDR3_ras_n(DDR3_ras_n),
              .DDR3_reset_n(DDR3_reset_n),
              .DDR3_we_n(DDR3_we_n),
              .MDIO_mdc(MDIO_mdc),
              .MDIO_mdio_i(MDIO_mdio_i),
              .MDIO_mdio_o(MDIO_mdio_o),
              .MDIO_mdio_t(MDIO_mdio_t),
              .MII_col(MII_col),
              .MII_crs(MII_crs),
              .MII_rst_n(MII_rst_n),
              .MII_rx_clk(MII_rx_clk),
              .MII_rx_dv(MII_rx_dv),
              .MII_rx_er(MII_rx_er),
              .MII_rxd(MII_rxd),
              .MII_tx_clk(MII_tx_clk),
              .MII_tx_en(MII_tx_en),
              .MII_txd(MII_txd),
              /* .UART_baudoutn(UART_baudoutn), */
              .UART_ctsn(1'b0),
              .UART_dcdn(1'b0),
              /* .UART_ddis(UART_ddis), */
              .UART_dsrn(1'b0),
              /* .UART_dtrn(UART_dtrn), */
              /* .UART_out1n(UART_out1n), */
              /* .UART_out2n(UART_out2n), */
              .UART_ri(1'b1),
              /* .UART_rtsn(UART_rtsn), */
              .UART_rxd(UART_rxd),
              /* .UART_rxrdyn(UART_rxrdyn), */
              .UART_txd(UART_txd),
              /* .UART_txrdyn(UART_txrdyn), */
              .SPI_sck_o(SPI_sck_o ) ,
              .SPI_sdo_i(SPI_sdo_i ) ,
              .SPI_sdo_o(SPI_sdo_o ) ,
              .SPI_sdo_en(SPI_sdo_en),
              .SPI_sdi_i(SPI_sdi_i ) ,
              .SPI_sdi_o(SPI_sdi_o ) ,
              .SPI_sdi_en(SPI_sdi_en),
              .SPI_csn_en(SPI_csn_en),
              .SPI_csn_o(SPI_csn_o),
              .clk(clk),
              .resetn(resetn));
endmodule
