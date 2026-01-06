//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.2 (lin64) Build 3671981 Fri Oct 14 04:59:54 MDT 2022
//Date        : Fri Nov 28 15:47:12 2025
//Host        : claudio-z790prors running 64-bit Ubuntu 22.04.5 LTS
//Command     : generate_target top_block.bd
//Design      : top_block
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module Const_wrapper_imp_OSYF0A
   (BX_SYNC_TRG_N,
    BX_SYNC_TRG_P,
    HBTRG_N,
    HBTRG_P,
    HRSTB_N,
    HRSTB_P);
  output [0:0]BX_SYNC_TRG_N;
  output [0:0]BX_SYNC_TRG_P;
  output [0:0]HBTRG_N;
  output [0:0]HBTRG_P;
  output [3:0]HRSTB_N;
  output [3:0]HRSTB_P;

  wire [3:0]HRSTB_wrapper_HRSTB_N;
  wire [3:0]HRSTB_wrapper_HRSTB_P;
  wire OBUFDS_CONST_0_O;
  wire OBUFDS_CONST_0_OB;
  wire OBUFDS_CONST_1_O;
  wire OBUFDS_CONST_1_OB;
  wire [0:0]clk_wiz_2_clk_out1;

  assign BX_SYNC_TRG_N[0] = OBUFDS_CONST_0_OB;
  assign BX_SYNC_TRG_P[0] = OBUFDS_CONST_0_O;
  assign HBTRG_N[0] = OBUFDS_CONST_1_OB;
  assign HBTRG_P[0] = OBUFDS_CONST_1_O;
  assign HRSTB_N[3:0] = HRSTB_wrapper_HRSTB_N;
  assign HRSTB_P[3:0] = HRSTB_wrapper_HRSTB_P;
  HRSTB_wrapper_imp_GWJ9FB HRSTB_wrapper
       (.HRSTB_N(HRSTB_wrapper_HRSTB_N),
        .HRSTB_P(HRSTB_wrapper_HRSTB_P),
        .In2(clk_wiz_2_clk_out1));
  top_block_OBUFDS_CONST_0_0 OBUFDS_CONST_0
       (.I(clk_wiz_2_clk_out1),
        .O(OBUFDS_CONST_0_O),
        .OB(OBUFDS_CONST_0_OB));
  top_block_OBUFDS_CONST_0_1 OBUFDS_CONST_1
       (.I(clk_wiz_2_clk_out1),
        .O(OBUFDS_CONST_1_O),
        .OB(OBUFDS_CONST_1_OB));
  top_block_xlconstant_1_4 xlconstant_1
       (.dout(clk_wiz_2_clk_out1));
endmodule

module FIFO_logic_imp_1EKWP1E
   (clk,
    clk1,
    clk125MHz,
    data_in,
    data_in1,
    data_in2,
    data_in3,
    en,
    fifos_empty,
    fifos_out,
    mem_full,
    mem_full1,
    mem_full2,
    mem_full3,
    read_en,
    read_en1,
    read_en2,
    read_en3,
    reset,
    reset1,
    reset2,
    reset3,
    select_ext,
    write_en,
    write_en1,
    write_en2,
    write_en3);
  input clk;
  input clk1;
  input clk125MHz;
  input [327:0]data_in;
  input [327:0]data_in1;
  input [327:0]data_in2;
  input [327:0]data_in3;
  input en;
  output [3:0]fifos_empty;
  output [1503:0]fifos_out;
  output mem_full;
  output mem_full1;
  output mem_full2;
  output mem_full3;
  input read_en;
  input read_en1;
  input read_en2;
  input read_en3;
  input reset;
  input reset1;
  input reset2;
  input reset3;
  input select_ext;
  input write_en;
  input write_en1;
  input write_en2;
  input write_en3;

  wire [47:0]c_counter_binary_0_Q;
  wire [47:0]c_counter_binary_0_Q1;
  wire [47:0]c_counter_binary_1_Q;
  wire clk1_1;
  wire clk1_2;
  wire clk_1;
  wire [3:0]cs_appunit_fifo_out_0_fifos_empty;
  wire [1503:0]cs_appunit_fifo_out_0_fifos_out;
  wire [0:0]cs_ccd_dflop_0_out;
  wire [47:0]cs_ccd_dflop_1_dout;
  wire cs_fifo_slicer_0_request_fifo_0;
  wire cs_fifo_slicer_0_request_fifo_1;
  wire cs_fifo_slicer_0_request_fifo_2;
  wire cs_fifo_slicer_0_request_fifo_3;
  wire cs_fifo_slicer_0_reset_fifo_0;
  wire cs_fifo_slicer_0_reset_fifo_1;
  wire cs_fifo_slicer_0_reset_fifo_2;
  wire cs_fifo_slicer_0_reset_fifo_3;
  wire cs_fifo_slicer_0_wr_en_0;
  wire cs_fifo_slicer_0_wr_en_1;
  wire cs_fifo_slicer_0_wr_en_2;
  wire cs_fifo_slicer_0_wr_en_3;
  wire [327:0]data_in1_1;
  wire [327:0]data_in2_1;
  wire [327:0]data_in3_1;
  wire [327:0]data_in_1;
  wire en_1;
  wire [375:0]fifo_generator_0_dout;
  wire fifo_generator_0_empty;
  wire fifo_generator_0_full;
  wire [375:0]fifo_generator_1_dout;
  wire fifo_generator_1_empty;
  wire fifo_generator_1_full;
  wire [375:0]fifo_generator_2_dout;
  wire fifo_generator_2_empty;
  wire fifo_generator_2_full;
  wire [375:0]fifo_generator_3_dout;
  wire fifo_generator_3_empty;
  wire fifo_generator_3_full;
  wire select_ext_1;
  wire [0:0]util_vector_logic_1_Res;
  wire [375:0]xlconcat_1_dout;
  wire [375:0]xlconcat_3_dout;
  wire [375:0]xlconcat_4_dout;
  wire [375:0]xlconcat_5_dout;

  assign clk1_1 = clk125MHz;
  assign clk1_2 = clk1;
  assign clk_1 = clk;
  assign cs_fifo_slicer_0_request_fifo_0 = read_en3;
  assign cs_fifo_slicer_0_request_fifo_1 = read_en1;
  assign cs_fifo_slicer_0_request_fifo_2 = read_en2;
  assign cs_fifo_slicer_0_request_fifo_3 = read_en;
  assign cs_fifo_slicer_0_reset_fifo_0 = reset3;
  assign cs_fifo_slicer_0_reset_fifo_1 = reset1;
  assign cs_fifo_slicer_0_reset_fifo_2 = reset2;
  assign cs_fifo_slicer_0_reset_fifo_3 = reset;
  assign cs_fifo_slicer_0_wr_en_0 = write_en3;
  assign cs_fifo_slicer_0_wr_en_1 = write_en1;
  assign cs_fifo_slicer_0_wr_en_2 = write_en2;
  assign cs_fifo_slicer_0_wr_en_3 = write_en;
  assign data_in1_1 = data_in1[327:0];
  assign data_in2_1 = data_in2[327:0];
  assign data_in3_1 = data_in3[327:0];
  assign data_in_1 = data_in[327:0];
  assign en_1 = en;
  assign fifos_empty[3:0] = cs_appunit_fifo_out_0_fifos_empty;
  assign fifos_out[1503:0] = cs_appunit_fifo_out_0_fifos_out;
  assign mem_full = fifo_generator_3_full;
  assign mem_full1 = fifo_generator_1_full;
  assign mem_full2 = fifo_generator_2_full;
  assign mem_full3 = fifo_generator_0_full;
  assign select_ext_1 = select_ext;
  top_block_c_counter_binary_0_0 c_counter_binary_0
       (.CLK(clk_1),
        .Q(c_counter_binary_0_Q1),
        .SCLR(util_vector_logic_1_Res));
  top_block_c_counter_binary_0_1 c_counter_binary_1
       (.CLK(clk1_2),
        .Q(c_counter_binary_1_Q),
        .SCLR(cs_ccd_dflop_0_out));
  top_block_cs_appunit_fifo_out_0_0 cs_appunit_fifo_out_0
       (.bus_0(fifo_generator_0_dout),
        .bus_1(fifo_generator_1_dout),
        .bus_2(fifo_generator_2_dout),
        .bus_3(fifo_generator_3_dout),
        .empty_0(fifo_generator_0_empty),
        .empty_1(fifo_generator_1_empty),
        .empty_2(fifo_generator_2_empty),
        .empty_3(fifo_generator_3_empty),
        .fifos_empty(cs_appunit_fifo_out_0_fifos_empty),
        .fifos_out(cs_appunit_fifo_out_0_fifos_out));
  top_block_cs_ccd_dflop_0_0 cs_ccd_dflop_0
       (.clk(clk1_2),
        .d(util_vector_logic_1_Res),
        .dout(cs_ccd_dflop_0_out));
  top_block_cs_ccd_dflop_0_2 cs_ccd_dflop_1
       (.clk(clk_1),
        .d(c_counter_binary_1_Q),
        .dout(cs_ccd_dflop_1_dout));
  top_block_cs_clk_sel_0_0 cs_clk_sel_0
       (.clk(clk_1),
        .count(c_counter_binary_0_Q),
        .ext_cnt(cs_ccd_dflop_1_dout),
        .int_cnt(c_counter_binary_0_Q1),
        .select_ext(select_ext_1));
  top_block_fifo_generator_0_0 fifo_generator_0
       (.din(xlconcat_1_dout),
        .dout(fifo_generator_0_dout),
        .empty(fifo_generator_0_empty),
        .full(fifo_generator_0_full),
        .rd_clk(clk1_1),
        .rd_en(cs_fifo_slicer_0_request_fifo_0),
        .srst(cs_fifo_slicer_0_reset_fifo_0),
        .wr_clk(clk_1),
        .wr_en(cs_fifo_slicer_0_wr_en_0));
  top_block_fifo_generator_0_1 fifo_generator_1
       (.din(xlconcat_5_dout),
        .dout(fifo_generator_1_dout),
        .empty(fifo_generator_1_empty),
        .full(fifo_generator_1_full),
        .rd_clk(clk1_1),
        .rd_en(cs_fifo_slicer_0_request_fifo_1),
        .srst(cs_fifo_slicer_0_reset_fifo_1),
        .wr_clk(clk_1),
        .wr_en(cs_fifo_slicer_0_wr_en_1));
  top_block_fifo_generator_1_0 fifo_generator_2
       (.din(xlconcat_3_dout),
        .dout(fifo_generator_2_dout),
        .empty(fifo_generator_2_empty),
        .full(fifo_generator_2_full),
        .rd_clk(clk1_1),
        .rd_en(cs_fifo_slicer_0_request_fifo_2),
        .srst(cs_fifo_slicer_0_reset_fifo_2),
        .wr_clk(clk_1),
        .wr_en(cs_fifo_slicer_0_wr_en_2));
  top_block_fifo_generator_2_0 fifo_generator_3
       (.din(xlconcat_4_dout),
        .dout(fifo_generator_3_dout),
        .empty(fifo_generator_3_empty),
        .full(fifo_generator_3_full),
        .rd_clk(clk1_1),
        .rd_en(cs_fifo_slicer_0_request_fifo_3),
        .srst(cs_fifo_slicer_0_reset_fifo_3),
        .wr_clk(clk_1),
        .wr_en(cs_fifo_slicer_0_wr_en_3));
  top_block_util_vector_logic_1_4 util_vector_logic_1
       (.Op1(en_1),
        .Res(util_vector_logic_1_Res));
  top_block_xlconcat_1_0 xlconcat_1
       (.In0(data_in3_1),
        .In1(c_counter_binary_0_Q),
        .dout(xlconcat_1_dout));
  top_block_xlconcat_1_3 xlconcat_3
       (.In0(data_in2_1),
        .In1(c_counter_binary_0_Q),
        .dout(xlconcat_3_dout));
  top_block_xlconcat_1_4 xlconcat_4
       (.In0(data_in_1),
        .In1(c_counter_binary_0_Q),
        .dout(xlconcat_4_dout));
  top_block_xlconcat_2_2 xlconcat_5
       (.In0(data_in1_1),
        .In1(c_counter_binary_0_Q),
        .dout(xlconcat_5_dout));
endmodule

module GPIO_Slicer_imp_IQC7PQ
   (Dout,
    Dout1,
    GPION,
    GPION_W7,
    GPIOP,
    GPIOP_W7);
  output [0:0]Dout;
  output [0:0]Dout1;
  input [7:0]GPION;
  output [6:0]GPION_W7;
  input [7:0]GPIOP;
  output [6:0]GPIOP_W7;

  wire [7:0]GPION_1;
  wire [7:0]GPIOP_1;
  wire [0:0]xlslice_0_Dout;
  wire [6:0]xlslice_1_Dout;
  wire [0:0]xlslice_2_Dout;
  wire [6:0]xlslice_3_Dout;

  assign Dout[0] = xlslice_0_Dout;
  assign Dout1[0] = xlslice_2_Dout;
  assign GPION_1 = GPION[7:0];
  assign GPION_W7[6:0] = xlslice_1_Dout;
  assign GPIOP_1 = GPIOP[7:0];
  assign GPIOP_W7[6:0] = xlslice_3_Dout;
  top_block_xlslice_0_1 xlslice_0
       (.Din(GPION_1),
        .Dout(xlslice_0_Dout));
  top_block_xlslice_0_2 xlslice_1
       (.Din(GPION_1),
        .Dout(xlslice_1_Dout));
  top_block_xlslice_0_3 xlslice_2
       (.Din(GPIOP_1),
        .Dout(xlslice_2_Dout));
  top_block_xlslice_1_0 xlslice_3
       (.Din(GPIOP_1),
        .Dout(xlslice_3_Dout));
endmodule

module HRSTB_wrapper_imp_GWJ9FB
   (HRSTB_N,
    HRSTB_P,
    In2);
  output [3:0]HRSTB_N;
  output [3:0]HRSTB_P;
  input [0:0]In2;

  wire [0:0]In2_1;
  wire [3:0]OBUFDS_TRG_0_O;
  wire [3:0]OBUFDS_TRG_0_OB;
  wire [0:0]util_vector_logic_1_Res;
  wire [3:0]xlconcat_2_dout;

  assign HRSTB_N[3:0] = OBUFDS_TRG_0_OB;
  assign HRSTB_P[3:0] = OBUFDS_TRG_0_O;
  assign In2_1 = In2[0];
  top_block_OBUFDS_TRG_0_1 OBUFDS_TRG_0
       (.I(xlconcat_2_dout),
        .O(OBUFDS_TRG_0_O),
        .OB(OBUFDS_TRG_0_OB));
  top_block_util_vector_logic_1_3 util_vector_logic_1
       (.Op1(In2_1),
        .Res(util_vector_logic_1_Res));
  top_block_xlconcat_2_1 xlconcat_2
       (.In0(util_vector_logic_1_Res),
        .In1(In2_1),
        .In2(In2_1),
        .In3(In2_1),
        .dout(xlconcat_2_dout));
endmodule

module SAMPA_I2C_wrapper_imp_VOP84W
   (S_I2C_SCL,
    S_I2C_SDA,
    m00_axi1_araddr,
    m00_axi1_arprot,
    m00_axi1_arready,
    m00_axi1_arvalid,
    m00_axi1_awaddr,
    m00_axi1_awprot,
    m00_axi1_awready,
    m00_axi1_awvalid,
    m00_axi1_bready,
    m00_axi1_bresp,
    m00_axi1_bvalid,
    m00_axi1_rdata,
    m00_axi1_rready,
    m00_axi1_rresp,
    m00_axi1_rvalid,
    m00_axi1_wdata,
    m00_axi1_wready,
    m00_axi1_wstrb,
    m00_axi1_wvalid,
    m00_axi_aclk,
    m00_axi_araddr,
    m00_axi_aresetn,
    m00_axi_arprot,
    m00_axi_arready,
    m00_axi_arvalid,
    m00_axi_awaddr,
    m00_axi_awprot,
    m00_axi_awready,
    m00_axi_awvalid,
    m00_axi_bready,
    m00_axi_bresp,
    m00_axi_bvalid,
    m00_axi_rdata,
    m00_axi_rready,
    m00_axi_rresp,
    m00_axi_rvalid,
    m00_axi_wdata,
    m00_axi_wready,
    m00_axi_wstrb,
    m00_axi_wvalid,
    s_axi_aclk);
  inout S_I2C_SCL;
  inout S_I2C_SDA;
  output [31:0]m00_axi1_araddr;
  output [2:0]m00_axi1_arprot;
  input [0:0]m00_axi1_arready;
  output [0:0]m00_axi1_arvalid;
  output [31:0]m00_axi1_awaddr;
  output [2:0]m00_axi1_awprot;
  input [0:0]m00_axi1_awready;
  output [0:0]m00_axi1_awvalid;
  output [0:0]m00_axi1_bready;
  input [1:0]m00_axi1_bresp;
  input [0:0]m00_axi1_bvalid;
  input [31:0]m00_axi1_rdata;
  output [0:0]m00_axi1_rready;
  input [1:0]m00_axi1_rresp;
  input [0:0]m00_axi1_rvalid;
  output [31:0]m00_axi1_wdata;
  input [0:0]m00_axi1_wready;
  output [3:0]m00_axi1_wstrb;
  output [0:0]m00_axi1_wvalid;
  input m00_axi_aclk;
  output [31:0]m00_axi_araddr;
  input m00_axi_aresetn;
  output [2:0]m00_axi_arprot;
  input [0:0]m00_axi_arready;
  output [0:0]m00_axi_arvalid;
  output [31:0]m00_axi_awaddr;
  output [2:0]m00_axi_awprot;
  input [0:0]m00_axi_awready;
  output [0:0]m00_axi_awvalid;
  output [0:0]m00_axi_bready;
  input [1:0]m00_axi_bresp;
  input [0:0]m00_axi_bvalid;
  input [31:0]m00_axi_rdata;
  output [0:0]m00_axi_rready;
  input [1:0]m00_axi_rresp;
  input [0:0]m00_axi_rvalid;
  output [31:0]m00_axi_wdata;
  input [0:0]m00_axi_wready;
  output [3:0]m00_axi_wstrb;
  output [0:0]m00_axi_wvalid;
  input s_axi_aclk;

  wire [31:0]Conn1_ARADDR;
  wire [2:0]Conn1_ARPROT;
  wire [0:0]Conn1_ARREADY;
  wire Conn1_ARVALID;
  wire [31:0]Conn1_AWADDR;
  wire [2:0]Conn1_AWPROT;
  wire [0:0]Conn1_AWREADY;
  wire Conn1_AWVALID;
  wire Conn1_BREADY;
  wire [1:0]Conn1_BRESP;
  wire [0:0]Conn1_BVALID;
  wire [31:0]Conn1_RDATA;
  wire Conn1_RREADY;
  wire [1:0]Conn1_RRESP;
  wire [0:0]Conn1_RVALID;
  wire [31:0]Conn1_WDATA;
  wire [0:0]Conn1_WREADY;
  wire [3:0]Conn1_WSTRB;
  wire Conn1_WVALID;
  wire [31:0]I2C_Controller_v1_0_0_m01_axi_ARADDR;
  wire I2C_Controller_v1_0_0_m01_axi_ARREADY;
  wire I2C_Controller_v1_0_0_m01_axi_ARVALID;
  wire [31:0]I2C_Controller_v1_0_0_m01_axi_AWADDR;
  wire I2C_Controller_v1_0_0_m01_axi_AWREADY;
  wire I2C_Controller_v1_0_0_m01_axi_AWVALID;
  wire I2C_Controller_v1_0_0_m01_axi_BREADY;
  wire [1:0]I2C_Controller_v1_0_0_m01_axi_BRESP;
  wire I2C_Controller_v1_0_0_m01_axi_BVALID;
  wire [31:0]I2C_Controller_v1_0_0_m01_axi_RDATA;
  wire I2C_Controller_v1_0_0_m01_axi_RREADY;
  wire [1:0]I2C_Controller_v1_0_0_m01_axi_RRESP;
  wire I2C_Controller_v1_0_0_m01_axi_RVALID;
  wire [31:0]I2C_Controller_v1_0_0_m01_axi_WDATA;
  wire I2C_Controller_v1_0_0_m01_axi_WREADY;
  wire [3:0]I2C_Controller_v1_0_0_m01_axi_WSTRB;
  wire I2C_Controller_v1_0_0_m01_axi_WVALID;
  wire Net;
  wire Net1;
  wire axi_iic_0_scl_o;
  wire axi_iic_0_scl_t;
  wire axi_iic_0_sda_o;
  wire axi_iic_0_sda_t;
  wire init_i2c_v1_0_0_init_i2c_rd;
  wire init_i2c_v1_0_0_init_i2c_wr;
  wire [31:0]init_i2c_v1_0_0_m00_axi_ARADDR;
  wire [2:0]init_i2c_v1_0_0_m00_axi_ARPROT;
  wire [0:0]init_i2c_v1_0_0_m00_axi_ARREADY;
  wire init_i2c_v1_0_0_m00_axi_ARVALID;
  wire [31:0]init_i2c_v1_0_0_m00_axi_AWADDR;
  wire [2:0]init_i2c_v1_0_0_m00_axi_AWPROT;
  wire [0:0]init_i2c_v1_0_0_m00_axi_AWREADY;
  wire init_i2c_v1_0_0_m00_axi_AWVALID;
  wire init_i2c_v1_0_0_m00_axi_BREADY;
  wire [1:0]init_i2c_v1_0_0_m00_axi_BRESP;
  wire [0:0]init_i2c_v1_0_0_m00_axi_BVALID;
  wire [31:0]init_i2c_v1_0_0_m00_axi_RDATA;
  wire init_i2c_v1_0_0_m00_axi_RREADY;
  wire [1:0]init_i2c_v1_0_0_m00_axi_RRESP;
  wire [0:0]init_i2c_v1_0_0_m00_axi_RVALID;
  wire [31:0]init_i2c_v1_0_0_m00_axi_WDATA;
  wire [0:0]init_i2c_v1_0_0_m00_axi_WREADY;
  wire [3:0]init_i2c_v1_0_0_m00_axi_WSTRB;
  wire init_i2c_v1_0_0_m00_axi_WVALID;
  wire iobuf_vhdl_0_o;
  wire iobuf_vhdl_1_o;
  wire m00_axi_aclk_1;
  wire m00_axi_aresetn_1;
  wire s_axi_aclk_1;

  assign Conn1_ARREADY = m00_axi_arready[0];
  assign Conn1_AWREADY = m00_axi_awready[0];
  assign Conn1_BRESP = m00_axi_bresp[1:0];
  assign Conn1_BVALID = m00_axi_bvalid[0];
  assign Conn1_RDATA = m00_axi_rdata[31:0];
  assign Conn1_RRESP = m00_axi_rresp[1:0];
  assign Conn1_RVALID = m00_axi_rvalid[0];
  assign Conn1_WREADY = m00_axi_wready[0];
  assign init_i2c_v1_0_0_m00_axi_ARREADY = m00_axi1_arready[0];
  assign init_i2c_v1_0_0_m00_axi_AWREADY = m00_axi1_awready[0];
  assign init_i2c_v1_0_0_m00_axi_BRESP = m00_axi1_bresp[1:0];
  assign init_i2c_v1_0_0_m00_axi_BVALID = m00_axi1_bvalid[0];
  assign init_i2c_v1_0_0_m00_axi_RDATA = m00_axi1_rdata[31:0];
  assign init_i2c_v1_0_0_m00_axi_RRESP = m00_axi1_rresp[1:0];
  assign init_i2c_v1_0_0_m00_axi_RVALID = m00_axi1_rvalid[0];
  assign init_i2c_v1_0_0_m00_axi_WREADY = m00_axi1_wready[0];
  assign m00_axi1_araddr[31:0] = init_i2c_v1_0_0_m00_axi_ARADDR;
  assign m00_axi1_arprot[2:0] = init_i2c_v1_0_0_m00_axi_ARPROT;
  assign m00_axi1_arvalid[0] = init_i2c_v1_0_0_m00_axi_ARVALID;
  assign m00_axi1_awaddr[31:0] = init_i2c_v1_0_0_m00_axi_AWADDR;
  assign m00_axi1_awprot[2:0] = init_i2c_v1_0_0_m00_axi_AWPROT;
  assign m00_axi1_awvalid[0] = init_i2c_v1_0_0_m00_axi_AWVALID;
  assign m00_axi1_bready[0] = init_i2c_v1_0_0_m00_axi_BREADY;
  assign m00_axi1_rready[0] = init_i2c_v1_0_0_m00_axi_RREADY;
  assign m00_axi1_wdata[31:0] = init_i2c_v1_0_0_m00_axi_WDATA;
  assign m00_axi1_wstrb[3:0] = init_i2c_v1_0_0_m00_axi_WSTRB;
  assign m00_axi1_wvalid[0] = init_i2c_v1_0_0_m00_axi_WVALID;
  assign m00_axi_aclk_1 = m00_axi_aclk;
  assign m00_axi_araddr[31:0] = Conn1_ARADDR;
  assign m00_axi_aresetn_1 = m00_axi_aresetn;
  assign m00_axi_arprot[2:0] = Conn1_ARPROT;
  assign m00_axi_arvalid[0] = Conn1_ARVALID;
  assign m00_axi_awaddr[31:0] = Conn1_AWADDR;
  assign m00_axi_awprot[2:0] = Conn1_AWPROT;
  assign m00_axi_awvalid[0] = Conn1_AWVALID;
  assign m00_axi_bready[0] = Conn1_BREADY;
  assign m00_axi_rready[0] = Conn1_RREADY;
  assign m00_axi_wdata[31:0] = Conn1_WDATA;
  assign m00_axi_wstrb[3:0] = Conn1_WSTRB;
  assign m00_axi_wvalid[0] = Conn1_WVALID;
  assign s_axi_aclk_1 = s_axi_aclk;
  top_block_I2C_Controller_v1_0_0_1 I2C_Controller_v1_0_0
       (.m00_axi_aclk(m00_axi_aclk_1),
        .m00_axi_araddr(Conn1_ARADDR),
        .m00_axi_aresetn(m00_axi_aresetn_1),
        .m00_axi_arprot(Conn1_ARPROT),
        .m00_axi_arready(Conn1_ARREADY),
        .m00_axi_arvalid(Conn1_ARVALID),
        .m00_axi_awaddr(Conn1_AWADDR),
        .m00_axi_awprot(Conn1_AWPROT),
        .m00_axi_awready(Conn1_AWREADY),
        .m00_axi_awvalid(Conn1_AWVALID),
        .m00_axi_bready(Conn1_BREADY),
        .m00_axi_bresp(Conn1_BRESP),
        .m00_axi_bvalid(Conn1_BVALID),
        .m00_axi_init_axi_txn(1'b0),
        .m00_axi_rdata(Conn1_RDATA),
        .m00_axi_rready(Conn1_RREADY),
        .m00_axi_rresp(Conn1_RRESP),
        .m00_axi_rvalid(Conn1_RVALID),
        .m00_axi_wdata(Conn1_WDATA),
        .m00_axi_wready(Conn1_WREADY),
        .m00_axi_wstrb(Conn1_WSTRB),
        .m00_axi_wvalid(Conn1_WVALID),
        .m01_axi_aclk(s_axi_aclk_1),
        .m01_axi_araddr(I2C_Controller_v1_0_0_m01_axi_ARADDR),
        .m01_axi_aresetn(m00_axi_aresetn_1),
        .m01_axi_arready(I2C_Controller_v1_0_0_m01_axi_ARREADY),
        .m01_axi_arvalid(I2C_Controller_v1_0_0_m01_axi_ARVALID),
        .m01_axi_awaddr(I2C_Controller_v1_0_0_m01_axi_AWADDR),
        .m01_axi_awready(I2C_Controller_v1_0_0_m01_axi_AWREADY),
        .m01_axi_awvalid(I2C_Controller_v1_0_0_m01_axi_AWVALID),
        .m01_axi_bready(I2C_Controller_v1_0_0_m01_axi_BREADY),
        .m01_axi_bresp(I2C_Controller_v1_0_0_m01_axi_BRESP),
        .m01_axi_bvalid(I2C_Controller_v1_0_0_m01_axi_BVALID),
        .m01_axi_init_axi_txn(1'b0),
        .m01_axi_rdata(I2C_Controller_v1_0_0_m01_axi_RDATA),
        .m01_axi_rready(I2C_Controller_v1_0_0_m01_axi_RREADY),
        .m01_axi_rresp(I2C_Controller_v1_0_0_m01_axi_RRESP),
        .m01_axi_rvalid(I2C_Controller_v1_0_0_m01_axi_RVALID),
        .m01_axi_wdata(I2C_Controller_v1_0_0_m01_axi_WDATA),
        .m01_axi_wready(I2C_Controller_v1_0_0_m01_axi_WREADY),
        .m01_axi_wstrb(I2C_Controller_v1_0_0_m01_axi_WSTRB),
        .m01_axi_wvalid(I2C_Controller_v1_0_0_m01_axi_WVALID),
        .start_i2c_read(init_i2c_v1_0_0_init_i2c_rd),
        .start_i2c_write(init_i2c_v1_0_0_init_i2c_wr));
  top_block_axi_iic_0_0 axi_iic_0
       (.s_axi_aclk(s_axi_aclk_1),
        .s_axi_araddr(I2C_Controller_v1_0_0_m01_axi_ARADDR[8:0]),
        .s_axi_aresetn(m00_axi_aresetn_1),
        .s_axi_arready(I2C_Controller_v1_0_0_m01_axi_ARREADY),
        .s_axi_arvalid(I2C_Controller_v1_0_0_m01_axi_ARVALID),
        .s_axi_awaddr(I2C_Controller_v1_0_0_m01_axi_AWADDR[8:0]),
        .s_axi_awready(I2C_Controller_v1_0_0_m01_axi_AWREADY),
        .s_axi_awvalid(I2C_Controller_v1_0_0_m01_axi_AWVALID),
        .s_axi_bready(I2C_Controller_v1_0_0_m01_axi_BREADY),
        .s_axi_bresp(I2C_Controller_v1_0_0_m01_axi_BRESP),
        .s_axi_bvalid(I2C_Controller_v1_0_0_m01_axi_BVALID),
        .s_axi_rdata(I2C_Controller_v1_0_0_m01_axi_RDATA),
        .s_axi_rready(I2C_Controller_v1_0_0_m01_axi_RREADY),
        .s_axi_rresp(I2C_Controller_v1_0_0_m01_axi_RRESP),
        .s_axi_rvalid(I2C_Controller_v1_0_0_m01_axi_RVALID),
        .s_axi_wdata(I2C_Controller_v1_0_0_m01_axi_WDATA),
        .s_axi_wready(I2C_Controller_v1_0_0_m01_axi_WREADY),
        .s_axi_wstrb(I2C_Controller_v1_0_0_m01_axi_WSTRB),
        .s_axi_wvalid(I2C_Controller_v1_0_0_m01_axi_WVALID),
        .scl_i(iobuf_vhdl_0_o),
        .scl_o(axi_iic_0_scl_o),
        .scl_t(axi_iic_0_scl_t),
        .sda_i(iobuf_vhdl_1_o),
        .sda_o(axi_iic_0_sda_o),
        .sda_t(axi_iic_0_sda_t));
  top_block_init_i2c_v1_0_0_0 init_i2c_v1_0_0
       (.init_i2c_rd(init_i2c_v1_0_0_init_i2c_rd),
        .init_i2c_wr(init_i2c_v1_0_0_init_i2c_wr),
        .m00_axi_aclk(m00_axi_aclk_1),
        .m00_axi_araddr(init_i2c_v1_0_0_m00_axi_ARADDR),
        .m00_axi_aresetn(m00_axi_aresetn_1),
        .m00_axi_arprot(init_i2c_v1_0_0_m00_axi_ARPROT),
        .m00_axi_arready(init_i2c_v1_0_0_m00_axi_ARREADY),
        .m00_axi_arvalid(init_i2c_v1_0_0_m00_axi_ARVALID),
        .m00_axi_awaddr(init_i2c_v1_0_0_m00_axi_AWADDR),
        .m00_axi_awprot(init_i2c_v1_0_0_m00_axi_AWPROT),
        .m00_axi_awready(init_i2c_v1_0_0_m00_axi_AWREADY),
        .m00_axi_awvalid(init_i2c_v1_0_0_m00_axi_AWVALID),
        .m00_axi_bready(init_i2c_v1_0_0_m00_axi_BREADY),
        .m00_axi_bresp(init_i2c_v1_0_0_m00_axi_BRESP),
        .m00_axi_bvalid(init_i2c_v1_0_0_m00_axi_BVALID),
        .m00_axi_init_axi_txn(1'b0),
        .m00_axi_rdata(init_i2c_v1_0_0_m00_axi_RDATA),
        .m00_axi_rready(init_i2c_v1_0_0_m00_axi_RREADY),
        .m00_axi_rresp(init_i2c_v1_0_0_m00_axi_RRESP),
        .m00_axi_rvalid(init_i2c_v1_0_0_m00_axi_RVALID),
        .m00_axi_wdata(init_i2c_v1_0_0_m00_axi_WDATA),
        .m00_axi_wready(init_i2c_v1_0_0_m00_axi_WREADY),
        .m00_axi_wstrb(init_i2c_v1_0_0_m00_axi_WSTRB),
        .m00_axi_wvalid(init_i2c_v1_0_0_m00_axi_WVALID));
  top_block_iobuf_vhdl_0_0 iobuf_vhdl_0
       (.i(axi_iic_0_scl_o),
        .io(S_I2C_SCL),
        .o(iobuf_vhdl_0_o),
        .t(axi_iic_0_scl_t));
  top_block_iobuf_vhdl_1_0 iobuf_vhdl_1
       (.i(axi_iic_0_sda_o),
        .io(S_I2C_SDA),
        .o(iobuf_vhdl_1_o),
        .t(axi_iic_0_sda_t));
endmodule

module SO_receiver_imp_J5HCEK
   (IBUF_OUT0,
    IBUF_OUT1,
    IBUF_OUT2,
    IBUF_OUT3,
    SO0N,
    SO0P,
    SO1N,
    SO1P,
    SO2N,
    SO2P,
    SO3N,
    SO3P,
    areset,
    areset_ref,
    areset_ref2,
    clk,
    idelay_refclk,
    idelay_refclk2,
    m00_axi_aclk,
    m00_axi_araddr,
    m00_axi_aresetn,
    m00_axi_arprot,
    m00_axi_arready,
    m00_axi_arvalid,
    m00_axi_awaddr,
    m00_axi_awprot,
    m00_axi_awready,
    m00_axi_awvalid,
    m00_axi_bready,
    m00_axi_bresp,
    m00_axi_bvalid,
    m00_axi_rdata,
    m00_axi_rready,
    m00_axi_rresp,
    m00_axi_rvalid,
    m00_axi_wdata,
    m00_axi_wready,
    m00_axi_wstrb,
    m00_axi_wvalid,
    ready,
    trg);
  output [10:0]IBUF_OUT0;
  output [10:0]IBUF_OUT1;
  output [10:0]IBUF_OUT2;
  output [10:0]IBUF_OUT3;
  input [10:0]SO0N;
  input [10:0]SO0P;
  input [10:0]SO1N;
  input [10:0]SO1P;
  input [10:0]SO2N;
  input [10:0]SO2P;
  input [10:0]SO3N;
  input [10:0]SO3P;
  input areset;
  input areset_ref;
  input [0:0]areset_ref2;
  input clk;
  input idelay_refclk;
  input idelay_refclk2;
  input m00_axi_aclk;
  output [31:0]m00_axi_araddr;
  input m00_axi_aresetn;
  output [2:0]m00_axi_arprot;
  input [0:0]m00_axi_arready;
  output [0:0]m00_axi_arvalid;
  output [31:0]m00_axi_awaddr;
  output [2:0]m00_axi_awprot;
  input [0:0]m00_axi_awready;
  output [0:0]m00_axi_awvalid;
  output [0:0]m00_axi_bready;
  input [1:0]m00_axi_bresp;
  input [0:0]m00_axi_bvalid;
  input [31:0]m00_axi_rdata;
  output [0:0]m00_axi_rready;
  input [1:0]m00_axi_rresp;
  input [0:0]m00_axi_rvalid;
  output [31:0]m00_axi_wdata;
  input [0:0]m00_axi_wready;
  output [3:0]m00_axi_wstrb;
  output [0:0]m00_axi_wvalid;
  output ready;
  output trg;

  wire [10:0]SO0N_1;
  wire [10:0]SO0P_1;
  wire [10:0]SO1N_1;
  wire [10:0]SO1P_1;
  wire [10:0]SO2N_1;
  wire [10:0]SO2P_1;
  wire [10:0]SO3N_1;
  wire [10:0]SO3P_1;
  wire areset_1;
  wire [0:0]areset_ref2_1;
  wire areset_ref_1;
  wire clk_1;
  wire delay_adjust_init_v1_0_init_adjust;
  wire [31:0]delay_adjust_init_v1_0_m00_axi_ARADDR;
  wire [2:0]delay_adjust_init_v1_0_m00_axi_ARPROT;
  wire [0:0]delay_adjust_init_v1_0_m00_axi_ARREADY;
  wire delay_adjust_init_v1_0_m00_axi_ARVALID;
  wire [31:0]delay_adjust_init_v1_0_m00_axi_AWADDR;
  wire [2:0]delay_adjust_init_v1_0_m00_axi_AWPROT;
  wire [0:0]delay_adjust_init_v1_0_m00_axi_AWREADY;
  wire delay_adjust_init_v1_0_m00_axi_AWVALID;
  wire delay_adjust_init_v1_0_m00_axi_BREADY;
  wire [1:0]delay_adjust_init_v1_0_m00_axi_BRESP;
  wire [0:0]delay_adjust_init_v1_0_m00_axi_BVALID;
  wire [31:0]delay_adjust_init_v1_0_m00_axi_RDATA;
  wire delay_adjust_init_v1_0_m00_axi_RREADY;
  wire [1:0]delay_adjust_init_v1_0_m00_axi_RRESP;
  wire [0:0]delay_adjust_init_v1_0_m00_axi_RVALID;
  wire [31:0]delay_adjust_init_v1_0_m00_axi_WDATA;
  wire [0:0]delay_adjust_init_v1_0_m00_axi_WREADY;
  wire [3:0]delay_adjust_init_v1_0_m00_axi_WSTRB;
  wire delay_adjust_init_v1_0_m00_axi_WVALID;
  wire idelay_refclk2_1;
  wire idelay_refclk_1;
  wire [10:0]idelay_top_v2_0_SO0_out;
  wire [10:0]idelay_top_v2_0_SO1_out;
  wire [10:0]idelay_top_v2_0_SO2_out;
  wire [10:0]idelay_top_v2_0_SO3_out;
  wire idelay_top_v2_0_ready;
  wire idelay_top_v2_0_trg;
  wire m00_axi_aclk_1;
  wire m00_axi_aresetn_1;

  assign IBUF_OUT0[10:0] = idelay_top_v2_0_SO0_out;
  assign IBUF_OUT1[10:0] = idelay_top_v2_0_SO1_out;
  assign IBUF_OUT2[10:0] = idelay_top_v2_0_SO2_out;
  assign IBUF_OUT3[10:0] = idelay_top_v2_0_SO3_out;
  assign SO0N_1 = SO0N[10:0];
  assign SO0P_1 = SO0P[10:0];
  assign SO1N_1 = SO1N[10:0];
  assign SO1P_1 = SO1P[10:0];
  assign SO2N_1 = SO2N[10:0];
  assign SO2P_1 = SO2P[10:0];
  assign SO3N_1 = SO3N[10:0];
  assign SO3P_1 = SO3P[10:0];
  assign areset_1 = areset;
  assign areset_ref2_1 = areset_ref2[0];
  assign areset_ref_1 = areset_ref;
  assign clk_1 = clk;
  assign delay_adjust_init_v1_0_m00_axi_ARREADY = m00_axi_arready[0];
  assign delay_adjust_init_v1_0_m00_axi_AWREADY = m00_axi_awready[0];
  assign delay_adjust_init_v1_0_m00_axi_BRESP = m00_axi_bresp[1:0];
  assign delay_adjust_init_v1_0_m00_axi_BVALID = m00_axi_bvalid[0];
  assign delay_adjust_init_v1_0_m00_axi_RDATA = m00_axi_rdata[31:0];
  assign delay_adjust_init_v1_0_m00_axi_RRESP = m00_axi_rresp[1:0];
  assign delay_adjust_init_v1_0_m00_axi_RVALID = m00_axi_rvalid[0];
  assign delay_adjust_init_v1_0_m00_axi_WREADY = m00_axi_wready[0];
  assign idelay_refclk2_1 = idelay_refclk2;
  assign idelay_refclk_1 = idelay_refclk;
  assign m00_axi_aclk_1 = m00_axi_aclk;
  assign m00_axi_araddr[31:0] = delay_adjust_init_v1_0_m00_axi_ARADDR;
  assign m00_axi_aresetn_1 = m00_axi_aresetn;
  assign m00_axi_arprot[2:0] = delay_adjust_init_v1_0_m00_axi_ARPROT;
  assign m00_axi_arvalid[0] = delay_adjust_init_v1_0_m00_axi_ARVALID;
  assign m00_axi_awaddr[31:0] = delay_adjust_init_v1_0_m00_axi_AWADDR;
  assign m00_axi_awprot[2:0] = delay_adjust_init_v1_0_m00_axi_AWPROT;
  assign m00_axi_awvalid[0] = delay_adjust_init_v1_0_m00_axi_AWVALID;
  assign m00_axi_bready[0] = delay_adjust_init_v1_0_m00_axi_BREADY;
  assign m00_axi_rready[0] = delay_adjust_init_v1_0_m00_axi_RREADY;
  assign m00_axi_wdata[31:0] = delay_adjust_init_v1_0_m00_axi_WDATA;
  assign m00_axi_wstrb[3:0] = delay_adjust_init_v1_0_m00_axi_WSTRB;
  assign m00_axi_wvalid[0] = delay_adjust_init_v1_0_m00_axi_WVALID;
  assign ready = idelay_top_v2_0_ready;
  assign trg = idelay_top_v2_0_trg;
  top_block_delay_adjust_init_v1_0_0 delay_adjust_init_v1_0
       (.init_adjust(delay_adjust_init_v1_0_init_adjust),
        .m00_axi_aclk(m00_axi_aclk_1),
        .m00_axi_araddr(delay_adjust_init_v1_0_m00_axi_ARADDR),
        .m00_axi_aresetn(m00_axi_aresetn_1),
        .m00_axi_arprot(delay_adjust_init_v1_0_m00_axi_ARPROT),
        .m00_axi_arready(delay_adjust_init_v1_0_m00_axi_ARREADY),
        .m00_axi_arvalid(delay_adjust_init_v1_0_m00_axi_ARVALID),
        .m00_axi_awaddr(delay_adjust_init_v1_0_m00_axi_AWADDR),
        .m00_axi_awprot(delay_adjust_init_v1_0_m00_axi_AWPROT),
        .m00_axi_awready(delay_adjust_init_v1_0_m00_axi_AWREADY),
        .m00_axi_awvalid(delay_adjust_init_v1_0_m00_axi_AWVALID),
        .m00_axi_bready(delay_adjust_init_v1_0_m00_axi_BREADY),
        .m00_axi_bresp(delay_adjust_init_v1_0_m00_axi_BRESP),
        .m00_axi_bvalid(delay_adjust_init_v1_0_m00_axi_BVALID),
        .m00_axi_init_axi_txn(1'b0),
        .m00_axi_rdata(delay_adjust_init_v1_0_m00_axi_RDATA),
        .m00_axi_rready(delay_adjust_init_v1_0_m00_axi_RREADY),
        .m00_axi_rresp(delay_adjust_init_v1_0_m00_axi_RRESP),
        .m00_axi_rvalid(delay_adjust_init_v1_0_m00_axi_RVALID),
        .m00_axi_wdata(delay_adjust_init_v1_0_m00_axi_WDATA),
        .m00_axi_wready(delay_adjust_init_v1_0_m00_axi_WREADY),
        .m00_axi_wstrb(delay_adjust_init_v1_0_m00_axi_WSTRB),
        .m00_axi_wvalid(delay_adjust_init_v1_0_m00_axi_WVALID));
  top_block_idelay_top_v2_0_0 idelay_top_v2_0
       (.SO0_n(SO0N_1),
        .SO0_out(idelay_top_v2_0_SO0_out),
        .SO0_p(SO0P_1),
        .SO1_n(SO1N_1),
        .SO1_out(idelay_top_v2_0_SO1_out),
        .SO1_p(SO1P_1),
        .SO2_n(SO2N_1),
        .SO2_out(idelay_top_v2_0_SO2_out),
        .SO2_p(SO2P_1),
        .SO3_n(SO3N_1),
        .SO3_out(idelay_top_v2_0_SO3_out),
        .SO3_p(SO3P_1),
        .S_AXI_ARADDR({1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_ARVALID(1'b0),
        .S_AXI_RREADY(1'b0),
        .areset(areset_1),
        .areset_ref(areset_ref_1),
        .areset_ref2(areset_ref2_1),
        .clk(clk_1),
        .idelay_refclk(idelay_refclk_1),
        .idelay_refclk2(idelay_refclk2_1),
        .init(delay_adjust_init_v1_0_init_adjust),
        .ready(idelay_top_v2_0_ready),
        .trg_en(idelay_top_v2_0_trg));
endmodule

module appUnit_imp_1BHH9Z2
   (Din,
    M_AXIS_data_tdata,
    M_AXIS_data_tready,
    M_AXIS_data_tvalid,
    SO0,
    SO1,
    SO2,
    SO3,
    clk,
    clk1,
    clk125MHz,
    clk_enable_1MHz,
    clk_enable_1kHz,
    en,
    event_reset,
    internal_enabled,
    n_samples,
    pretrigger_select,
    s_axis_aresetn_0,
    select_ext,
    threshold,
    user_clk);
  input [6:0]Din;
  output [31:0]M_AXIS_data_tdata;
  input M_AXIS_data_tready;
  output M_AXIS_data_tvalid;
  input [10:0]SO0;
  input [10:0]SO1;
  input [10:0]SO2;
  input [10:0]SO3;
  input clk;
  input clk1;
  input clk125MHz;
  input clk_enable_1MHz;
  input clk_enable_1kHz;
  input en;
  input event_reset;
  input internal_enabled;
  input [7:0]n_samples;
  input [1:0]pretrigger_select;
  input s_axis_aresetn_0;
  input select_ext;
  input [9:0]threshold;
  input user_clk;

  wire [6:0]Din_1;
  wire [1503:0]FIFO_logic_fifos_out;
  wire asyncfifo_0_mem_full;
  wire asyncfifo_1_mem_full;
  wire asyncfifo_2_mem_full;
  wire asyncfifo_3_mem_full;
  wire [31:0]axis_data_fifo_0_M_AXIS_TDATA;
  wire axis_data_fifo_0_M_AXIS_TREADY;
  wire axis_data_fifo_0_M_AXIS_TVALID;
  wire axis_data_fifo_0_prog_full;
  wire clk1_1;
  wire clk1_2;
  wire clk_1;
  wire clk_enable_1MHz_1;
  wire clk_enable_1kHz_1;
  wire [3:0]cs_appunit_fifo_out_0_fifos_empty;
  wire [39:0]cs_appunit_merge_0_SOs;
  wire [3:0]cs_appunit_merge_0_fulls;
  wire [1311:0]cs_das_rx_0_buses;
  wire [3:0]cs_das_rx_0_reset_fifos;
  wire [3:0]cs_das_rx_0_wr_ens;
  wire [1:0]cs_data_processor_0_bus_sel;
  wire [47:0]cs_data_processor_0_counter;
  wire [319:0]cs_data_processor_0_data_out;
  wire [3:0]cs_data_processor_0_fifo_req;
  wire cs_data_processor_0_last_data;
  wire [7:0]cs_data_processor_0_sample;
  wire cs_data_processor_0_valid;
  wire cs_event_builder_0_busy;
  wire cs_event_builder_0_data_ack_reg;
  wire [31:0]cs_event_builder_0_event_word;
  wire cs_event_builder_0_event_write;
  wire [327:0]cs_fifo_slicer_0_bus_0;
  wire [327:0]cs_fifo_slicer_0_bus_1;
  wire [327:0]cs_fifo_slicer_0_bus_2;
  wire [327:0]cs_fifo_slicer_0_bus_3;
  wire [0:0]cs_fifo_slicer_0_request_fifo_0;
  wire [0:0]cs_fifo_slicer_0_request_fifo_1;
  wire [0:0]cs_fifo_slicer_0_request_fifo_2;
  wire [0:0]cs_fifo_slicer_0_request_fifo_3;
  wire [0:0]cs_fifo_slicer_0_reset_fifo_0;
  wire [0:0]cs_fifo_slicer_0_reset_fifo_1;
  wire [0:0]cs_fifo_slicer_0_reset_fifo_2;
  wire [0:0]cs_fifo_slicer_0_reset_fifo_3;
  wire [0:0]cs_fifo_slicer_0_wr_en_0;
  wire [0:0]cs_fifo_slicer_0_wr_en_1;
  wire [0:0]cs_fifo_slicer_0_wr_en_2;
  wire [0:0]cs_fifo_slicer_0_wr_en_3;
  wire data_sender_v1_0_0_busy;
  wire [31:0]data_sender_v1_0_0_s_axis_TDATA;
  wire data_sender_v1_0_0_s_axis_TREADY;
  wire data_sender_v1_0_0_s_axis_TVALID;
  wire en_1;
  wire event_reset_1;
  wire internal_enabled_1;
  wire [7:0]n_samples_1;
  wire [1:0]pretrigger_select_1;
  wire [10:0]probe_in0_1;
  wire [10:0]probe_in1_1;
  wire [10:0]probe_in2_1;
  wire [10:0]probe_in3_1;
  wire s_axis_aresetn_0_1;
  wire select_ext_1;
  wire [9:0]threshold_1;
  wire [39:0]threshold_comparator_0_delayed_signals;
  wire [3:0]threshold_comparator_0_triggered;
  wire trigger_manager_0_trg;
  wire util_reduced_logic_0_Res;
  wire [4:0]xlconcat_0_dout;
  wire [0:0]xlslice_0_Dout;

  assign Din_1 = Din[6:0];
  assign M_AXIS_data_tdata[31:0] = axis_data_fifo_0_M_AXIS_TDATA;
  assign M_AXIS_data_tvalid = axis_data_fifo_0_M_AXIS_TVALID;
  assign axis_data_fifo_0_M_AXIS_TREADY = M_AXIS_data_tready;
  assign clk1_1 = clk125MHz;
  assign clk1_2 = clk1;
  assign clk_1 = clk;
  assign clk_enable_1MHz_1 = clk_enable_1MHz;
  assign clk_enable_1kHz_1 = clk_enable_1kHz;
  assign en_1 = en;
  assign event_reset_1 = event_reset;
  assign internal_enabled_1 = internal_enabled;
  assign n_samples_1 = n_samples[7:0];
  assign pretrigger_select_1 = pretrigger_select[1:0];
  assign probe_in0_1 = SO0[10:0];
  assign probe_in1_1 = SO1[10:0];
  assign probe_in2_1 = SO2[10:0];
  assign probe_in3_1 = SO3[10:0];
  assign s_axis_aresetn_0_1 = s_axis_aresetn_0;
  assign select_ext_1 = select_ext;
  assign threshold_1 = threshold[9:0];
  FIFO_logic_imp_1EKWP1E FIFO_logic
       (.clk(clk_1),
        .clk1(clk1_2),
        .clk125MHz(clk1_1),
        .data_in(cs_fifo_slicer_0_bus_3),
        .data_in1(cs_fifo_slicer_0_bus_1),
        .data_in2(cs_fifo_slicer_0_bus_2),
        .data_in3(cs_fifo_slicer_0_bus_0),
        .en(en_1),
        .fifos_empty(cs_appunit_fifo_out_0_fifos_empty),
        .fifos_out(FIFO_logic_fifos_out),
        .mem_full(asyncfifo_3_mem_full),
        .mem_full1(asyncfifo_1_mem_full),
        .mem_full2(asyncfifo_2_mem_full),
        .mem_full3(asyncfifo_0_mem_full),
        .read_en(cs_fifo_slicer_0_request_fifo_3),
        .read_en1(cs_fifo_slicer_0_request_fifo_1),
        .read_en2(cs_fifo_slicer_0_request_fifo_2),
        .read_en3(cs_fifo_slicer_0_request_fifo_0),
        .reset(cs_fifo_slicer_0_reset_fifo_3),
        .reset1(cs_fifo_slicer_0_reset_fifo_1),
        .reset2(cs_fifo_slicer_0_reset_fifo_2),
        .reset3(cs_fifo_slicer_0_reset_fifo_0),
        .select_ext(select_ext_1),
        .write_en(cs_fifo_slicer_0_wr_en_3),
        .write_en1(cs_fifo_slicer_0_wr_en_1),
        .write_en2(cs_fifo_slicer_0_wr_en_2),
        .write_en3(cs_fifo_slicer_0_wr_en_0));
  top_block_axis_data_fifo_0_0 axis_data_fifo_0
       (.m_axis_tdata(axis_data_fifo_0_M_AXIS_TDATA),
        .m_axis_tready(axis_data_fifo_0_M_AXIS_TREADY),
        .m_axis_tvalid(axis_data_fifo_0_M_AXIS_TVALID),
        .prog_full(axis_data_fifo_0_prog_full),
        .s_axis_aclk(clk1_1),
        .s_axis_aresetn(s_axis_aresetn_0_1),
        .s_axis_tdata(data_sender_v1_0_0_s_axis_TDATA),
        .s_axis_tready(data_sender_v1_0_0_s_axis_TREADY),
        .s_axis_tvalid(data_sender_v1_0_0_s_axis_TVALID));
  top_block_cs_appunit_merge_0_0 cs_appunit_merge_0
       (.SO_0(probe_in0_1),
        .SO_1(probe_in1_1),
        .SO_2(probe_in2_1),
        .SO_3(probe_in3_1),
        .SOs(cs_appunit_merge_0_SOs),
        .full_0(asyncfifo_0_mem_full),
        .full_1(asyncfifo_1_mem_full),
        .full_2(asyncfifo_2_mem_full),
        .full_3(asyncfifo_3_mem_full),
        .fulls(cs_appunit_merge_0_fulls));
  top_block_cs_das_rx_0_0 cs_das_rx_0
       (.SOs(threshold_comparator_0_delayed_signals),
        .buses(cs_das_rx_0_buses),
        .clk_SO(clk_1),
        .en(en_1),
        .fifo_full(cs_appunit_merge_0_fulls),
        .n_samples(n_samples_1),
        .reset_fifos(cs_das_rx_0_reset_fifos),
        .trg(util_reduced_logic_0_Res),
        .wr_ens(cs_das_rx_0_wr_ens));
  top_block_cs_data_processor_0_0 cs_data_processor_0
       (.ack(cs_event_builder_0_data_ack_reg),
        .bus_sel(cs_data_processor_0_bus_sel),
        .busy_i(cs_event_builder_0_busy),
        .clk(clk1_1),
        .counter(cs_data_processor_0_counter),
        .data_out(cs_data_processor_0_data_out),
        .event_reset(event_reset_1),
        .fifo_data_i(FIFO_logic_fifos_out),
        .fifo_empty(cs_appunit_fifo_out_0_fifos_empty),
        .fifo_req(cs_data_processor_0_fifo_req),
        .last_data(cs_data_processor_0_last_data),
        .sample(cs_data_processor_0_sample),
        .valid(cs_data_processor_0_valid));
  top_block_cs_event_builder_0_0 cs_event_builder_0
       (.bus_sel(cs_data_processor_0_bus_sel),
        .busy(cs_event_builder_0_busy),
        .busy_i(data_sender_v1_0_0_busy),
        .clk(clk1_1),
        .counter(cs_data_processor_0_counter),
        .data(cs_data_processor_0_data_out),
        .data_ack_reg(cs_event_builder_0_data_ack_reg),
        .event_reset(event_reset_1),
        .event_word(cs_event_builder_0_event_word),
        .event_write(cs_event_builder_0_event_write),
        .last_data(cs_data_processor_0_last_data),
        .sample_n(cs_data_processor_0_sample),
        .valid(cs_data_processor_0_valid));
  top_block_cs_fifo_slicer_0_0 cs_fifo_slicer_0
       (.bus_0(cs_fifo_slicer_0_bus_0),
        .bus_1(cs_fifo_slicer_0_bus_1),
        .bus_2(cs_fifo_slicer_0_bus_2),
        .bus_3(cs_fifo_slicer_0_bus_3),
        .buses(cs_das_rx_0_buses),
        .request_fifo_0(cs_fifo_slicer_0_request_fifo_0),
        .request_fifo_1(cs_fifo_slicer_0_request_fifo_1),
        .request_fifo_2(cs_fifo_slicer_0_request_fifo_2),
        .request_fifo_3(cs_fifo_slicer_0_request_fifo_3),
        .request_fifos(cs_data_processor_0_fifo_req),
        .reset_fifo_0(cs_fifo_slicer_0_reset_fifo_0),
        .reset_fifo_1(cs_fifo_slicer_0_reset_fifo_1),
        .reset_fifo_2(cs_fifo_slicer_0_reset_fifo_2),
        .reset_fifo_3(cs_fifo_slicer_0_reset_fifo_3),
        .reset_fifos(cs_das_rx_0_reset_fifos),
        .wr_en_0(cs_fifo_slicer_0_wr_en_0),
        .wr_en_1(cs_fifo_slicer_0_wr_en_1),
        .wr_en_2(cs_fifo_slicer_0_wr_en_2),
        .wr_en_3(cs_fifo_slicer_0_wr_en_3),
        .wr_ens(cs_das_rx_0_wr_ens));
  top_block_data_sender_v1_0_0_0 data_sender_v1_0_0
       (.busy(data_sender_v1_0_0_busy),
        .clk(clk1_1),
        .full(axis_data_fifo_0_prog_full),
        .rst(event_reset_1),
        .s_axis_tdata(data_sender_v1_0_0_s_axis_TDATA),
        .s_axis_tready(data_sender_v1_0_0_s_axis_TREADY),
        .s_axis_tvalid(data_sender_v1_0_0_s_axis_TVALID),
        .wr_data(cs_event_builder_0_event_word),
        .wr_en(cs_event_builder_0_event_write));
  top_block_threshold_comparator_0_0 threshold_comparator_0
       (.clk(clk_1),
        .delayed_signals(threshold_comparator_0_delayed_signals),
        .enable(en_1),
        .external_disabled(internal_enabled_1),
        .pretrigger_select(pretrigger_select_1),
        .signals(cs_appunit_merge_0_SOs),
        .threshold(threshold_1),
        .triggered(threshold_comparator_0_triggered));
  top_block_trigger_manager_0_0 trigger_manager_0
       (.SO0(probe_in0_1),
        .busy_i(1'b0),
        .clk(clk_1),
        .clk_enable_1MHz(clk_enable_1MHz_1),
        .clk_enable_1kHz(clk_enable_1kHz_1),
        .external_disabled(internal_enabled_1),
        .external_trg(xlslice_0_Dout),
        .trg(trigger_manager_0_trg));
  top_block_util_reduced_logic_0_0 util_reduced_logic_0
       (.Op1(xlconcat_0_dout),
        .Res(util_reduced_logic_0_Res));
  top_block_xlconcat_0_0 xlconcat_0
       (.In0(threshold_comparator_0_triggered),
        .In1(trigger_manager_0_trg),
        .dout(xlconcat_0_dout));
  top_block_xlslice_0_0 xlslice_0
       (.Din(Din_1),
        .Dout(xlslice_0_Dout));
endmodule

module clock_wrapper_imp_153XBA
   (BASECLK,
    EXT_CLK_N,
    EXT_CLK_P,
    clk_out1,
    clk_out2,
    clk_out3,
    clk_out4,
    clk_out5,
    clk_out6,
    clk_out7,
    clk_out8,
    locked);
  input BASECLK;
  input EXT_CLK_N;
  input EXT_CLK_P;
  output clk_out1;
  output clk_out2;
  output clk_out3;
  output clk_out4;
  output clk_out5;
  output clk_out6;
  output clk_out7;
  output clk_out8;
  output locked;

  wire BASECLK_1;
  wire EXT_CLK_N_1;
  wire EXT_CLK_P_1;
  wire clk_wiz_0_clk_out1;
  wire clk_wiz_0_clk_out2;
  wire clk_wiz_0_clk_out3;
  wire clk_wiz_0_clk_out4;
  wire clk_wiz_0_clk_out5;
  wire clk_wiz_1_clk_out1;
  wire clk_wiz_1_clk_out2;
  wire clk_wiz_2_clk_out1;
  wire clk_wiz_2_locked;

  assign BASECLK_1 = BASECLK;
  assign EXT_CLK_N_1 = EXT_CLK_N;
  assign EXT_CLK_P_1 = EXT_CLK_P;
  assign clk_out1 = clk_wiz_0_clk_out1;
  assign clk_out2 = clk_wiz_1_clk_out1;
  assign clk_out3 = clk_wiz_0_clk_out2;
  assign clk_out4 = clk_wiz_0_clk_out3;
  assign clk_out5 = clk_wiz_0_clk_out4;
  assign clk_out6 = clk_wiz_1_clk_out2;
  assign clk_out7 = clk_wiz_0_clk_out5;
  assign clk_out8 = clk_wiz_2_clk_out1;
  assign locked = clk_wiz_2_locked;
  top_block_clk_wiz_0_0 clk_wiz_0
       (.clk_in1(BASECLK_1),
        .clk_out1(clk_wiz_0_clk_out1),
        .clk_out2(clk_wiz_0_clk_out2),
        .clk_out3(clk_wiz_0_clk_out3),
        .clk_out4(clk_wiz_0_clk_out4),
        .clk_out5(clk_wiz_0_clk_out5));
  top_block_clk_wiz_1_0 clk_wiz_1
       (.clk_in1(clk_wiz_0_clk_out1),
        .clk_out1(clk_wiz_1_clk_out1),
        .clk_out2(clk_wiz_1_clk_out2));
  top_block_clk_wiz_0_2 clk_wiz_2
       (.clk_in1_n(EXT_CLK_N_1),
        .clk_in1_p(EXT_CLK_P_1),
        .clk_out1(clk_wiz_2_clk_out1),
        .locked(clk_wiz_2_locked));
endmodule

module fakernet_imp_1GNS2XO
   (clk25_in_0,
    clk_in_0,
    gtrefclk_n_0,
    gtrefclk_p_0,
    independent_clock_0,
    m00_axi_aresetn,
    regacc_addr_o,
    regacc_data_rd_i,
    regacc_data_wr_o,
    regacc_done,
    regacc_done_i,
    regacc_read_o,
    regacc_write_o,
    reset_vio_0,
    rxn_0,
    rxp_0,
    txn_0,
    txp_0,
    user_data_commit,
    user_data_commit_len,
    user_data_free,
    user_data_offset,
    user_data_reset,
    user_data_word,
    user_data_write);
  input clk25_in_0;
  input clk_in_0;
  input gtrefclk_n_0;
  input gtrefclk_p_0;
  input independent_clock_0;
  input m00_axi_aresetn;
  output [24:0]regacc_addr_o;
  input [31:0]regacc_data_rd_i;
  output [31:0]regacc_data_wr_o;
  output regacc_done;
  input regacc_done_i;
  output regacc_read_o;
  output regacc_write_o;
  input reset_vio_0;
  input rxn_0;
  input rxp_0;
  output txn_0;
  output txp_0;
  input user_data_commit;
  input [10:0]user_data_commit_len;
  output user_data_free;
  input [9:0]user_data_offset;
  output user_data_reset;
  input [31:0]user_data_word;
  input user_data_write;

  wire RESET_INST_0_sfp_reset_pulse;
  wire clk25_in_0_1;
  wire clk_in_0_1;
  wire fakernet_top_0_eth_mdc;
  wire fakernet_top_0_eth_mdio_out;
  wire fakernet_top_0_eth_tx_en;
  wire [7:0]fakernet_top_0_eth_txd;
  wire [24:0]fakernet_top_0_regacc_addr_o;
  wire [31:0]fakernet_top_0_regacc_data_wr_o;
  wire fakernet_top_0_regacc_read_o;
  wire fakernet_top_0_regacc_write_o;
  wire fakernet_top_0_user_data_free;
  wire fakernet_top_0_user_data_reset;
  wire gig_ethernet_pcs_pma_0_gmii_rx_clk;
  wire gig_ethernet_pcs_pma_0_gmii_rx_dv;
  wire [7:0]gig_ethernet_pcs_pma_0_gmii_rxd;
  wire gig_ethernet_pcs_pma_0_mdio_o;
  wire gig_ethernet_pcs_pma_0_resetdone_out;
  wire gig_ethernet_pcs_pma_0_txn;
  wire gig_ethernet_pcs_pma_0_txp;
  wire gtrefclk_n_0_1;
  wire gtrefclk_p_0_1;
  wire [0:0]if_gate1_Res;
  wire [0:0]if_gate_Res;
  wire independent_clock_0_1;
  wire m00_axi_aresetn_1;
  wire mii_initializer_0_COMPLETE;
  wire mii_initializer_0_MDC;
  wire mii_initializer_0_MDIO_OUT;
  wire [24:0]reg_switch_0_regacc_addr_o;
  wire [31:0]reg_switch_0_regacc_data_rd_o;
  wire [31:0]reg_switch_0_regacc_data_wr_o;
  wire reg_switch_0_regacc_done_o;
  wire reg_switch_0_regacc_read_o;
  wire reg_switch_0_regacc_write_o;
  wire [31:0]regacc_data_rd_i_1;
  wire regacc_done_i_1;
  wire reset_vio_0_1;
  wire rxn_0_1;
  wire rxp_0_1;
  wire user_data_commit_1;
  wire [10:0]user_data_commit_len_1;
  wire [9:0]user_data_offset_1;
  wire [31:0]user_data_word_1;
  wire user_data_write_1;
  wire [4:0]xlconstant_0_dout;
  wire [0:0]xlconstant_1_dout;
  wire [0:0]xlconstant_2_dout;
  wire [4:0]xlconstant_3_dout;

  assign clk25_in_0_1 = clk25_in_0;
  assign clk_in_0_1 = clk_in_0;
  assign gtrefclk_n_0_1 = gtrefclk_n_0;
  assign gtrefclk_p_0_1 = gtrefclk_p_0;
  assign independent_clock_0_1 = independent_clock_0;
  assign m00_axi_aresetn_1 = m00_axi_aresetn;
  assign regacc_addr_o[24:0] = reg_switch_0_regacc_addr_o;
  assign regacc_data_rd_i_1 = regacc_data_rd_i[31:0];
  assign regacc_data_wr_o[31:0] = reg_switch_0_regacc_data_wr_o;
  assign regacc_done = reg_switch_0_regacc_done_o;
  assign regacc_done_i_1 = regacc_done_i;
  assign regacc_read_o = reg_switch_0_regacc_read_o;
  assign regacc_write_o = reg_switch_0_regacc_write_o;
  assign reset_vio_0_1 = reset_vio_0;
  assign rxn_0_1 = rxn_0;
  assign rxp_0_1 = rxp_0;
  assign txn_0 = gig_ethernet_pcs_pma_0_txn;
  assign txp_0 = gig_ethernet_pcs_pma_0_txp;
  assign user_data_commit_1 = user_data_commit;
  assign user_data_commit_len_1 = user_data_commit_len[10:0];
  assign user_data_free = fakernet_top_0_user_data_free;
  assign user_data_offset_1 = user_data_offset[9:0];
  assign user_data_reset = fakernet_top_0_user_data_reset;
  assign user_data_word_1 = user_data_word[31:0];
  assign user_data_write_1 = user_data_write;
  top_block_RESET_INST_0_0 RESET_INST_0
       (.clk125(clk_in_0_1),
        .reset_vio(reset_vio_0_1),
        .resetdone(gig_ethernet_pcs_pma_0_resetdone_out),
        .sfp_reset_pulse(RESET_INST_0_sfp_reset_pulse));
  top_block_fakernet_top_0_0 fakernet_top_0
       (.btn({1'b0,1'b0,1'b0,1'b0}),
        .clk25_in(clk25_in_0_1),
        .clk_in(clk_in_0_1),
        .eth_col(xlconstant_1_dout),
        .eth_crs(xlconstant_1_dout),
        .eth_intb(xlconstant_2_dout),
        .eth_mdc(fakernet_top_0_eth_mdc),
        .eth_mdio_in(gig_ethernet_pcs_pma_0_mdio_o),
        .eth_mdio_out(fakernet_top_0_eth_mdio_out),
        .eth_rx_clk(gig_ethernet_pcs_pma_0_gmii_rx_clk),
        .eth_rx_dv(gig_ethernet_pcs_pma_0_gmii_rx_dv),
        .eth_rxd(gig_ethernet_pcs_pma_0_gmii_rxd),
        .eth_rxerr(xlconstant_1_dout),
        .eth_tx_clk(gig_ethernet_pcs_pma_0_gmii_rx_clk),
        .eth_tx_en(fakernet_top_0_eth_tx_en),
        .eth_txd(fakernet_top_0_eth_txd),
        .ja0(1'b0),
        .ja2(1'b0),
        .ja3(1'b0),
        .jd0(1'b0),
        .jd2(1'b0),
        .regacc_addr_o(fakernet_top_0_regacc_addr_o),
        .regacc_data_rd_i(reg_switch_0_regacc_data_rd_o),
        .regacc_data_wr_o(fakernet_top_0_regacc_data_wr_o),
        .regacc_done_i(reg_switch_0_regacc_done_o),
        .regacc_read_o(fakernet_top_0_regacc_read_o),
        .regacc_write_o(fakernet_top_0_regacc_write_o),
        .spi_sdi(1'b0),
        .sw({1'b0,1'b0,1'b0,1'b0}),
        .uart_rx(1'b0),
        .user_data_commit(user_data_commit_1),
        .user_data_commit_len(user_data_commit_len_1),
        .user_data_free(fakernet_top_0_user_data_free),
        .user_data_offset(user_data_offset_1),
        .user_data_reset(fakernet_top_0_user_data_reset),
        .user_data_word(user_data_word_1),
        .user_data_write(user_data_write_1));
  top_block_gig_ethernet_pcs_pma_0_0 gig_ethernet_pcs_pma_0
       (.configuration_valid(xlconstant_2_dout),
        .configuration_vector(xlconstant_3_dout),
        .gmii_rx_clk(gig_ethernet_pcs_pma_0_gmii_rx_clk),
        .gmii_rx_dv(gig_ethernet_pcs_pma_0_gmii_rx_dv),
        .gmii_rxd(gig_ethernet_pcs_pma_0_gmii_rxd),
        .gmii_tx_clk(gig_ethernet_pcs_pma_0_gmii_rx_clk),
        .gmii_tx_en(fakernet_top_0_eth_tx_en),
        .gmii_tx_er(1'b0),
        .gmii_txd(fakernet_top_0_eth_txd),
        .gtrefclk_n(gtrefclk_n_0_1),
        .gtrefclk_p(gtrefclk_p_0_1),
        .independent_clock(independent_clock_0_1),
        .io_refclk(1'b0),
        .mdc(if_gate_Res),
        .mdio_i(if_gate1_Res),
        .mdio_o(gig_ethernet_pcs_pma_0_mdio_o),
        .phyaddr(xlconstant_0_dout),
        .reset(RESET_INST_0_sfp_reset_pulse),
        .resetdone_out(gig_ethernet_pcs_pma_0_resetdone_out),
        .rxn(rxn_0_1),
        .rxp(rxp_0_1),
        .signal_detect(xlconstant_2_dout),
        .txn(gig_ethernet_pcs_pma_0_txn),
        .txp(gig_ethernet_pcs_pma_0_txp));
  if_gate_imp_1DO02I3 if_gate
       (.Op1(mii_initializer_0_COMPLETE),
        .Op2(fakernet_top_0_eth_mdc),
        .Op3(mii_initializer_0_MDC),
        .Res(if_gate_Res));
  if_gate1_imp_O68EJJ if_gate1
       (.Op1(mii_initializer_0_COMPLETE),
        .Op2(fakernet_top_0_eth_mdio_out),
        .Op3(mii_initializer_0_MDIO_OUT),
        .Res(if_gate1_Res));
  top_block_mii_initializer_0_0 mii_initializer_0
       (.CLK(clk_in_0_1),
        .COMPLETE(mii_initializer_0_COMPLETE),
        .MDC(mii_initializer_0_MDC),
        .MDIO_OUT(mii_initializer_0_MDIO_OUT),
        .PHYAD(xlconstant_0_dout),
        .RST(RESET_INST_0_sfp_reset_pulse));
  top_block_reg_switch_0_0 reg_switch_0
       (.axi_aclk(clk_in_0_1),
        .axi_aresetn(m00_axi_aresetn_1),
        .i2c_done(1'b0),
        .i2c_rdata_i({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .regacc_addr_i(fakernet_top_0_regacc_addr_o),
        .regacc_addr_o(reg_switch_0_regacc_addr_o),
        .regacc_data_rd_i(regacc_data_rd_i_1),
        .regacc_data_rd_o(reg_switch_0_regacc_data_rd_o),
        .regacc_data_wr_i(fakernet_top_0_regacc_data_wr_o),
        .regacc_data_wr_o(reg_switch_0_regacc_data_wr_o),
        .regacc_done_i(regacc_done_i_1),
        .regacc_done_o(reg_switch_0_regacc_done_o),
        .regacc_read_i(fakernet_top_0_regacc_read_o),
        .regacc_read_o(reg_switch_0_regacc_read_o),
        .regacc_write_i(fakernet_top_0_regacc_write_o),
        .regacc_write_o(reg_switch_0_regacc_write_o));
  top_block_xlconstant_0_0 xlconstant_0
       (.dout(xlconstant_0_dout));
  top_block_xlconstant_0_1 xlconstant_1
       (.dout(xlconstant_1_dout));
  top_block_xlconstant_1_2 xlconstant_2
       (.dout(xlconstant_2_dout));
  top_block_xlconstant_1_3 xlconstant_3
       (.dout(xlconstant_3_dout));
endmodule

module fnet_wrapper_imp_RWCR3V
   (SFP0RXN,
    SFP0RXP,
    SFP0TXN,
    SFP0TXP,
    SFP_CLK_N,
    SFP_CLK_P,
    clk25_in_0,
    clk_in_0,
    independent_clock_0,
    m00_axi_araddr,
    m00_axi_aresetn,
    m00_axi_arprot,
    m00_axi_arready,
    m00_axi_arvalid,
    m00_axi_awaddr,
    m00_axi_awprot,
    m00_axi_awready,
    m00_axi_awvalid,
    m00_axi_bready,
    m00_axi_bresp,
    m00_axi_bvalid,
    m00_axi_rdata,
    m00_axi_rready,
    m00_axi_rresp,
    m00_axi_rvalid,
    m00_axi_wdata,
    m00_axi_wready,
    m00_axi_wstrb,
    m00_axi_wvalid,
    regacc_done,
    reset_vio_0,
    s00_axis_tdata,
    s00_axis_tready,
    s00_axis_tvalid,
    user_data_reset);
  input SFP0RXN;
  input SFP0RXP;
  output SFP0TXN;
  output SFP0TXP;
  input SFP_CLK_N;
  input SFP_CLK_P;
  input clk25_in_0;
  input clk_in_0;
  input independent_clock_0;
  output [31:0]m00_axi_araddr;
  input m00_axi_aresetn;
  output [2:0]m00_axi_arprot;
  input m00_axi_arready;
  output m00_axi_arvalid;
  output [31:0]m00_axi_awaddr;
  output [2:0]m00_axi_awprot;
  input m00_axi_awready;
  output m00_axi_awvalid;
  output m00_axi_bready;
  input [1:0]m00_axi_bresp;
  input m00_axi_bvalid;
  input [31:0]m00_axi_rdata;
  output m00_axi_rready;
  input [1:0]m00_axi_rresp;
  input m00_axi_rvalid;
  output [31:0]m00_axi_wdata;
  input m00_axi_wready;
  output [3:0]m00_axi_wstrb;
  output m00_axi_wvalid;
  output regacc_done;
  input reset_vio_0;
  input [31:0]s00_axis_tdata;
  output s00_axis_tready;
  input s00_axis_tvalid;
  output user_data_reset;

  wire clk25_in_0_1;
  wire clk_in_0_1;
  wire data_receiver_v1_0_0_event_commit;
  wire [10:0]data_receiver_v1_0_0_event_commit_len;
  wire [9:0]data_receiver_v1_0_0_event_offset;
  wire [31:0]data_receiver_v1_0_0_event_word;
  wire data_receiver_v1_0_0_event_write;
  wire [24:0]fakernet_regacc_addr_o;
  wire [31:0]fakernet_regacc_data_wr_o;
  wire fakernet_regacc_read_o;
  wire fakernet_txn_0;
  wire fakernet_txp_0;
  wire fakernet_user_data_free;
  wire fakernet_user_data_reset;
  wire gtrefclk_n_0_1;
  wire gtrefclk_p_0_1;
  wire independent_clock_0_1;
  wire m00_axi_aresetn_1;
  wire [31:0]native_to_axi_lite_v_0_m00_axi_ARADDR;
  wire [2:0]native_to_axi_lite_v_0_m00_axi_ARPROT;
  wire native_to_axi_lite_v_0_m00_axi_ARREADY;
  wire native_to_axi_lite_v_0_m00_axi_ARVALID;
  wire [31:0]native_to_axi_lite_v_0_m00_axi_AWADDR;
  wire [2:0]native_to_axi_lite_v_0_m00_axi_AWPROT;
  wire native_to_axi_lite_v_0_m00_axi_AWREADY;
  wire native_to_axi_lite_v_0_m00_axi_AWVALID;
  wire native_to_axi_lite_v_0_m00_axi_BREADY;
  wire [1:0]native_to_axi_lite_v_0_m00_axi_BRESP;
  wire native_to_axi_lite_v_0_m00_axi_BVALID;
  wire [31:0]native_to_axi_lite_v_0_m00_axi_RDATA;
  wire native_to_axi_lite_v_0_m00_axi_RREADY;
  wire [1:0]native_to_axi_lite_v_0_m00_axi_RRESP;
  wire native_to_axi_lite_v_0_m00_axi_RVALID;
  wire [31:0]native_to_axi_lite_v_0_m00_axi_WDATA;
  wire native_to_axi_lite_v_0_m00_axi_WREADY;
  wire [3:0]native_to_axi_lite_v_0_m00_axi_WSTRB;
  wire native_to_axi_lite_v_0_m00_axi_WVALID;
  wire [31:0]native_to_axi_lite_v_0_regacc_data_rd;
  wire native_to_axi_lite_v_0_regacc_done;
  wire reg_switch_0_regacc_done_o;
  wire reg_switch_0_regacc_write_o;
  wire reset_vio_0_1;
  wire rxn_0_1;
  wire rxp_0_1;
  wire [31:0]s00_axis_1_TDATA;
  wire s00_axis_1_TREADY;
  wire s00_axis_1_TVALID;

  assign SFP0TXN = fakernet_txn_0;
  assign SFP0TXP = fakernet_txp_0;
  assign clk25_in_0_1 = clk25_in_0;
  assign clk_in_0_1 = clk_in_0;
  assign gtrefclk_n_0_1 = SFP_CLK_N;
  assign gtrefclk_p_0_1 = SFP_CLK_P;
  assign independent_clock_0_1 = independent_clock_0;
  assign m00_axi_araddr[31:0] = native_to_axi_lite_v_0_m00_axi_ARADDR;
  assign m00_axi_aresetn_1 = m00_axi_aresetn;
  assign m00_axi_arprot[2:0] = native_to_axi_lite_v_0_m00_axi_ARPROT;
  assign m00_axi_arvalid = native_to_axi_lite_v_0_m00_axi_ARVALID;
  assign m00_axi_awaddr[31:0] = native_to_axi_lite_v_0_m00_axi_AWADDR;
  assign m00_axi_awprot[2:0] = native_to_axi_lite_v_0_m00_axi_AWPROT;
  assign m00_axi_awvalid = native_to_axi_lite_v_0_m00_axi_AWVALID;
  assign m00_axi_bready = native_to_axi_lite_v_0_m00_axi_BREADY;
  assign m00_axi_rready = native_to_axi_lite_v_0_m00_axi_RREADY;
  assign m00_axi_wdata[31:0] = native_to_axi_lite_v_0_m00_axi_WDATA;
  assign m00_axi_wstrb[3:0] = native_to_axi_lite_v_0_m00_axi_WSTRB;
  assign m00_axi_wvalid = native_to_axi_lite_v_0_m00_axi_WVALID;
  assign native_to_axi_lite_v_0_m00_axi_ARREADY = m00_axi_arready;
  assign native_to_axi_lite_v_0_m00_axi_AWREADY = m00_axi_awready;
  assign native_to_axi_lite_v_0_m00_axi_BRESP = m00_axi_bresp[1:0];
  assign native_to_axi_lite_v_0_m00_axi_BVALID = m00_axi_bvalid;
  assign native_to_axi_lite_v_0_m00_axi_RDATA = m00_axi_rdata[31:0];
  assign native_to_axi_lite_v_0_m00_axi_RRESP = m00_axi_rresp[1:0];
  assign native_to_axi_lite_v_0_m00_axi_RVALID = m00_axi_rvalid;
  assign native_to_axi_lite_v_0_m00_axi_WREADY = m00_axi_wready;
  assign regacc_done = reg_switch_0_regacc_done_o;
  assign reset_vio_0_1 = reset_vio_0;
  assign rxn_0_1 = SFP0RXN;
  assign rxp_0_1 = SFP0RXP;
  assign s00_axis_1_TDATA = s00_axis_tdata[31:0];
  assign s00_axis_1_TVALID = s00_axis_tvalid;
  assign s00_axis_tready = s00_axis_1_TREADY;
  assign user_data_reset = fakernet_user_data_reset;
  top_block_data_receiver_v1_0_0_0 data_receiver_v1_0_0
       (.clk(clk_in_0_1),
        .event_commit(data_receiver_v1_0_0_event_commit),
        .event_commit_len(data_receiver_v1_0_0_event_commit_len),
        .event_free(fakernet_user_data_free),
        .event_offset(data_receiver_v1_0_0_event_offset),
        .event_word(data_receiver_v1_0_0_event_word),
        .event_write(data_receiver_v1_0_0_event_write),
        .m_axis_tdata(s00_axis_1_TDATA),
        .m_axis_tready(s00_axis_1_TREADY),
        .m_axis_tvalid(s00_axis_1_TVALID),
        .rst(fakernet_user_data_reset));
  fakernet_imp_1GNS2XO fakernet
       (.clk25_in_0(clk25_in_0_1),
        .clk_in_0(clk_in_0_1),
        .gtrefclk_n_0(gtrefclk_n_0_1),
        .gtrefclk_p_0(gtrefclk_p_0_1),
        .independent_clock_0(independent_clock_0_1),
        .m00_axi_aresetn(m00_axi_aresetn_1),
        .regacc_addr_o(fakernet_regacc_addr_o),
        .regacc_data_rd_i(native_to_axi_lite_v_0_regacc_data_rd),
        .regacc_data_wr_o(fakernet_regacc_data_wr_o),
        .regacc_done(reg_switch_0_regacc_done_o),
        .regacc_done_i(native_to_axi_lite_v_0_regacc_done),
        .regacc_read_o(fakernet_regacc_read_o),
        .regacc_write_o(reg_switch_0_regacc_write_o),
        .reset_vio_0(reset_vio_0_1),
        .rxn_0(rxn_0_1),
        .rxp_0(rxp_0_1),
        .txn_0(fakernet_txn_0),
        .txp_0(fakernet_txp_0),
        .user_data_commit(data_receiver_v1_0_0_event_commit),
        .user_data_commit_len(data_receiver_v1_0_0_event_commit_len),
        .user_data_free(fakernet_user_data_free),
        .user_data_offset(data_receiver_v1_0_0_event_offset),
        .user_data_reset(fakernet_user_data_reset),
        .user_data_word(data_receiver_v1_0_0_event_word),
        .user_data_write(data_receiver_v1_0_0_event_write));
  top_block_native_to_axi_lite_v_0_0 native_to_axi_lite_v_0
       (.m00_axi_aclk(clk_in_0_1),
        .m00_axi_araddr(native_to_axi_lite_v_0_m00_axi_ARADDR),
        .m00_axi_aresetn(m00_axi_aresetn_1),
        .m00_axi_arprot(native_to_axi_lite_v_0_m00_axi_ARPROT),
        .m00_axi_arready(native_to_axi_lite_v_0_m00_axi_ARREADY),
        .m00_axi_arvalid(native_to_axi_lite_v_0_m00_axi_ARVALID),
        .m00_axi_awaddr(native_to_axi_lite_v_0_m00_axi_AWADDR),
        .m00_axi_awprot(native_to_axi_lite_v_0_m00_axi_AWPROT),
        .m00_axi_awready(native_to_axi_lite_v_0_m00_axi_AWREADY),
        .m00_axi_awvalid(native_to_axi_lite_v_0_m00_axi_AWVALID),
        .m00_axi_bready(native_to_axi_lite_v_0_m00_axi_BREADY),
        .m00_axi_bresp(native_to_axi_lite_v_0_m00_axi_BRESP),
        .m00_axi_bvalid(native_to_axi_lite_v_0_m00_axi_BVALID),
        .m00_axi_init_axi_txn(reg_switch_0_regacc_write_o),
        .m00_axi_rdata(native_to_axi_lite_v_0_m00_axi_RDATA),
        .m00_axi_rready(native_to_axi_lite_v_0_m00_axi_RREADY),
        .m00_axi_rresp(native_to_axi_lite_v_0_m00_axi_RRESP),
        .m00_axi_rvalid(native_to_axi_lite_v_0_m00_axi_RVALID),
        .m00_axi_wdata(native_to_axi_lite_v_0_m00_axi_WDATA),
        .m00_axi_wready(native_to_axi_lite_v_0_m00_axi_WREADY),
        .m00_axi_wstrb(native_to_axi_lite_v_0_m00_axi_WSTRB),
        .m00_axi_wvalid(native_to_axi_lite_v_0_m00_axi_WVALID),
        .regacc_addr(fakernet_regacc_addr_o),
        .regacc_data_rd(native_to_axi_lite_v_0_regacc_data_rd),
        .regacc_data_wr(fakernet_regacc_data_wr_o),
        .regacc_done(native_to_axi_lite_v_0_regacc_done),
        .regacc_read(fakernet_regacc_read_o),
        .regacc_write(reg_switch_0_regacc_write_o));
endmodule

module if_gate1_imp_O68EJJ
   (Op1,
    Op2,
    Op3,
    Res);
  input [0:0]Op1;
  input [0:0]Op2;
  input [0:0]Op3;
  output [0:0]Res;

  wire [0:0]fakernet_top_0_eth_mdc;
  wire [0:0]mii_initializer_0_COMPLETE;
  wire [0:0]mii_initializer_0_MDC;
  wire [0:0]util_vector_logic_0_Res;
  wire [0:0]util_vector_logic_1_Res;
  wire [0:0]util_vector_logic_2_Res;
  wire [0:0]util_vector_logic_3_Res;

  assign Res[0] = util_vector_logic_3_Res;
  assign fakernet_top_0_eth_mdc = Op2[0];
  assign mii_initializer_0_COMPLETE = Op1[0];
  assign mii_initializer_0_MDC = Op3[0];
  top_block_util_vector_logic_0_1 util_vector_logic_0
       (.Op1(mii_initializer_0_COMPLETE),
        .Res(util_vector_logic_0_Res));
  top_block_util_vector_logic_1_2 util_vector_logic_1
       (.Op1(mii_initializer_0_COMPLETE),
        .Op2(fakernet_top_0_eth_mdc),
        .Res(util_vector_logic_1_Res));
  top_block_util_vector_logic_2_1 util_vector_logic_2
       (.Op1(util_vector_logic_0_Res),
        .Op2(mii_initializer_0_MDC),
        .Res(util_vector_logic_2_Res));
  top_block_util_vector_logic_3_0 util_vector_logic_3
       (.Op1(util_vector_logic_2_Res),
        .Op2(util_vector_logic_1_Res),
        .Res(util_vector_logic_3_Res));
endmodule

module if_gate_imp_1DO02I3
   (Op1,
    Op2,
    Op3,
    Res);
  input [0:0]Op1;
  input [0:0]Op2;
  input [0:0]Op3;
  output [0:0]Res;

  wire [0:0]fakernet_top_0_eth_mdc;
  wire [0:0]mii_initializer_0_COMPLETE;
  wire [0:0]mii_initializer_0_MDC;
  wire [0:0]util_vector_logic_0_Res;
  wire [0:0]util_vector_logic_1_Res;
  wire [0:0]util_vector_logic_2_Res;
  wire [0:0]util_vector_logic_3_Res;

  assign Res[0] = util_vector_logic_3_Res;
  assign fakernet_top_0_eth_mdc = Op2[0];
  assign mii_initializer_0_COMPLETE = Op1[0];
  assign mii_initializer_0_MDC = Op3[0];
  top_block_util_vector_logic_0_0 util_vector_logic_0
       (.Op1(mii_initializer_0_COMPLETE),
        .Res(util_vector_logic_0_Res));
  top_block_util_vector_logic_1_0 util_vector_logic_1
       (.Op1(mii_initializer_0_COMPLETE),
        .Op2(fakernet_top_0_eth_mdc),
        .Res(util_vector_logic_1_Res));
  top_block_util_vector_logic_2_0 util_vector_logic_2
       (.Op1(util_vector_logic_0_Res),
        .Op2(mii_initializer_0_MDC),
        .Res(util_vector_logic_2_Res));
  top_block_util_vector_logic_1_1 util_vector_logic_3
       (.Op1(util_vector_logic_2_Res),
        .Op2(util_vector_logic_1_Res),
        .Res(util_vector_logic_3_Res));
endmodule

module intercon_wrapper_imp_1BZAOGM
   (M00_ACLK,
    M00_ARESETN,
    M00_AXI_araddr,
    M00_AXI_arprot,
    M00_AXI_arready,
    M00_AXI_arvalid,
    M00_AXI_awaddr,
    M00_AXI_awprot,
    M00_AXI_awready,
    M00_AXI_awvalid,
    M00_AXI_bready,
    M00_AXI_bresp,
    M00_AXI_bvalid,
    M00_AXI_rdata,
    M00_AXI_rready,
    M00_AXI_rresp,
    M00_AXI_rvalid,
    M00_AXI_wdata,
    M00_AXI_wready,
    M00_AXI_wstrb,
    M00_AXI_wvalid,
    S00_AXI_araddr,
    S00_AXI_arprot,
    S00_AXI_arready,
    S00_AXI_arvalid,
    S00_AXI_awaddr,
    S00_AXI_awprot,
    S00_AXI_awready,
    S00_AXI_awvalid,
    S00_AXI_bready,
    S00_AXI_bresp,
    S00_AXI_bvalid,
    S00_AXI_rdata,
    S00_AXI_rready,
    S00_AXI_rresp,
    S00_AXI_rvalid,
    S00_AXI_wdata,
    S00_AXI_wready,
    S00_AXI_wstrb,
    S00_AXI_wvalid,
    S01_AXI_araddr,
    S01_AXI_arprot,
    S01_AXI_arready,
    S01_AXI_arvalid,
    S01_AXI_awaddr,
    S01_AXI_awprot,
    S01_AXI_awready,
    S01_AXI_awvalid,
    S01_AXI_bready,
    S01_AXI_bresp,
    S01_AXI_bvalid,
    S01_AXI_rdata,
    S01_AXI_rready,
    S01_AXI_rresp,
    S01_AXI_rvalid,
    S01_AXI_wdata,
    S01_AXI_wready,
    S01_AXI_wstrb,
    S01_AXI_wvalid,
    S02_AXI_araddr,
    S02_AXI_arprot,
    S02_AXI_arready,
    S02_AXI_arvalid,
    S02_AXI_awaddr,
    S02_AXI_awprot,
    S02_AXI_awready,
    S02_AXI_awvalid,
    S02_AXI_bready,
    S02_AXI_bresp,
    S02_AXI_bvalid,
    S02_AXI_rdata,
    S02_AXI_rready,
    S02_AXI_rresp,
    S02_AXI_rvalid,
    S02_AXI_wdata,
    S02_AXI_wready,
    S02_AXI_wstrb,
    S02_AXI_wvalid,
    S03_AXI_araddr,
    S03_AXI_arprot,
    S03_AXI_arready,
    S03_AXI_arvalid,
    S03_AXI_awaddr,
    S03_AXI_awprot,
    S03_AXI_awready,
    S03_AXI_awvalid,
    S03_AXI_bready,
    S03_AXI_bresp,
    S03_AXI_bvalid,
    S03_AXI_rdata,
    S03_AXI_rready,
    S03_AXI_rresp,
    S03_AXI_rvalid,
    S03_AXI_wdata,
    S03_AXI_wready,
    S03_AXI_wstrb,
    S03_AXI_wvalid,
    S04_AXI_araddr,
    S04_AXI_arprot,
    S04_AXI_arready,
    S04_AXI_arvalid,
    S04_AXI_awaddr,
    S04_AXI_awprot,
    S04_AXI_awready,
    S04_AXI_awvalid,
    S04_AXI_bready,
    S04_AXI_bresp,
    S04_AXI_bvalid,
    S04_AXI_rdata,
    S04_AXI_rready,
    S04_AXI_rresp,
    S04_AXI_rvalid,
    S04_AXI_wdata,
    S04_AXI_wready,
    S04_AXI_wstrb,
    S04_AXI_wvalid,
    S05_AXI_araddr,
    S05_AXI_arprot,
    S05_AXI_arready,
    S05_AXI_arvalid,
    S05_AXI_awaddr,
    S05_AXI_awprot,
    S05_AXI_awready,
    S05_AXI_awvalid,
    S05_AXI_bready,
    S05_AXI_bresp,
    S05_AXI_bvalid,
    S05_AXI_rdata,
    S05_AXI_rready,
    S05_AXI_rresp,
    S05_AXI_rvalid,
    S05_AXI_wdata,
    S05_AXI_wready,
    S05_AXI_wstrb,
    S05_AXI_wvalid,
    S06_AXI_araddr,
    S06_AXI_arprot,
    S06_AXI_arready,
    S06_AXI_arvalid,
    S06_AXI_awaddr,
    S06_AXI_awprot,
    S06_AXI_awready,
    S06_AXI_awvalid,
    S06_AXI_bready,
    S06_AXI_bresp,
    S06_AXI_bvalid,
    S06_AXI_rdata,
    S06_AXI_rready,
    S06_AXI_rresp,
    S06_AXI_rvalid,
    S06_AXI_wdata,
    S06_AXI_wready,
    S06_AXI_wstrb,
    S06_AXI_wvalid);
  input M00_ACLK;
  input M00_ARESETN;
  output [15:0]M00_AXI_araddr;
  output [2:0]M00_AXI_arprot;
  input M00_AXI_arready;
  output M00_AXI_arvalid;
  output [15:0]M00_AXI_awaddr;
  output [2:0]M00_AXI_awprot;
  input M00_AXI_awready;
  output M00_AXI_awvalid;
  output M00_AXI_bready;
  input [1:0]M00_AXI_bresp;
  input M00_AXI_bvalid;
  input [31:0]M00_AXI_rdata;
  output M00_AXI_rready;
  input [1:0]M00_AXI_rresp;
  input M00_AXI_rvalid;
  output [31:0]M00_AXI_wdata;
  input M00_AXI_wready;
  output [3:0]M00_AXI_wstrb;
  output M00_AXI_wvalid;
  input [31:0]S00_AXI_araddr;
  input [2:0]S00_AXI_arprot;
  output [0:0]S00_AXI_arready;
  input [0:0]S00_AXI_arvalid;
  input [31:0]S00_AXI_awaddr;
  input [2:0]S00_AXI_awprot;
  output [0:0]S00_AXI_awready;
  input [0:0]S00_AXI_awvalid;
  input [0:0]S00_AXI_bready;
  output [1:0]S00_AXI_bresp;
  output [0:0]S00_AXI_bvalid;
  output [31:0]S00_AXI_rdata;
  input [0:0]S00_AXI_rready;
  output [1:0]S00_AXI_rresp;
  output [0:0]S00_AXI_rvalid;
  input [31:0]S00_AXI_wdata;
  output [0:0]S00_AXI_wready;
  input [3:0]S00_AXI_wstrb;
  input [0:0]S00_AXI_wvalid;
  input [31:0]S01_AXI_araddr;
  input [2:0]S01_AXI_arprot;
  output [0:0]S01_AXI_arready;
  input [0:0]S01_AXI_arvalid;
  input [31:0]S01_AXI_awaddr;
  input [2:0]S01_AXI_awprot;
  output [0:0]S01_AXI_awready;
  input [0:0]S01_AXI_awvalid;
  input [0:0]S01_AXI_bready;
  output [1:0]S01_AXI_bresp;
  output [0:0]S01_AXI_bvalid;
  output [31:0]S01_AXI_rdata;
  input [0:0]S01_AXI_rready;
  output [1:0]S01_AXI_rresp;
  output [0:0]S01_AXI_rvalid;
  input [31:0]S01_AXI_wdata;
  output [0:0]S01_AXI_wready;
  input [3:0]S01_AXI_wstrb;
  input [0:0]S01_AXI_wvalid;
  input [31:0]S02_AXI_araddr;
  input [2:0]S02_AXI_arprot;
  output [0:0]S02_AXI_arready;
  input [0:0]S02_AXI_arvalid;
  input [31:0]S02_AXI_awaddr;
  input [2:0]S02_AXI_awprot;
  output [0:0]S02_AXI_awready;
  input [0:0]S02_AXI_awvalid;
  input [0:0]S02_AXI_bready;
  output [1:0]S02_AXI_bresp;
  output [0:0]S02_AXI_bvalid;
  output [31:0]S02_AXI_rdata;
  input [0:0]S02_AXI_rready;
  output [1:0]S02_AXI_rresp;
  output [0:0]S02_AXI_rvalid;
  input [31:0]S02_AXI_wdata;
  output [0:0]S02_AXI_wready;
  input [3:0]S02_AXI_wstrb;
  input [0:0]S02_AXI_wvalid;
  input [31:0]S03_AXI_araddr;
  input [2:0]S03_AXI_arprot;
  output S03_AXI_arready;
  input S03_AXI_arvalid;
  input [31:0]S03_AXI_awaddr;
  input [2:0]S03_AXI_awprot;
  output S03_AXI_awready;
  input S03_AXI_awvalid;
  input S03_AXI_bready;
  output [1:0]S03_AXI_bresp;
  output S03_AXI_bvalid;
  output [31:0]S03_AXI_rdata;
  input S03_AXI_rready;
  output [1:0]S03_AXI_rresp;
  output S03_AXI_rvalid;
  input [31:0]S03_AXI_wdata;
  output S03_AXI_wready;
  input [3:0]S03_AXI_wstrb;
  input S03_AXI_wvalid;
  input [31:0]S04_AXI_araddr;
  input [2:0]S04_AXI_arprot;
  output [0:0]S04_AXI_arready;
  input [0:0]S04_AXI_arvalid;
  input [31:0]S04_AXI_awaddr;
  input [2:0]S04_AXI_awprot;
  output [0:0]S04_AXI_awready;
  input [0:0]S04_AXI_awvalid;
  input [0:0]S04_AXI_bready;
  output [1:0]S04_AXI_bresp;
  output [0:0]S04_AXI_bvalid;
  output [31:0]S04_AXI_rdata;
  input [0:0]S04_AXI_rready;
  output [1:0]S04_AXI_rresp;
  output [0:0]S04_AXI_rvalid;
  input [31:0]S04_AXI_wdata;
  output [0:0]S04_AXI_wready;
  input [3:0]S04_AXI_wstrb;
  input [0:0]S04_AXI_wvalid;
  input [31:0]S05_AXI_araddr;
  input [2:0]S05_AXI_arprot;
  output [0:0]S05_AXI_arready;
  input [0:0]S05_AXI_arvalid;
  input [31:0]S05_AXI_awaddr;
  input [2:0]S05_AXI_awprot;
  output [0:0]S05_AXI_awready;
  input [0:0]S05_AXI_awvalid;
  input [0:0]S05_AXI_bready;
  output [1:0]S05_AXI_bresp;
  output [0:0]S05_AXI_bvalid;
  output [31:0]S05_AXI_rdata;
  input [0:0]S05_AXI_rready;
  output [1:0]S05_AXI_rresp;
  output [0:0]S05_AXI_rvalid;
  input [31:0]S05_AXI_wdata;
  output [0:0]S05_AXI_wready;
  input [3:0]S05_AXI_wstrb;
  input [0:0]S05_AXI_wvalid;
  input [31:0]S06_AXI_araddr;
  input [2:0]S06_AXI_arprot;
  output [0:0]S06_AXI_arready;
  input [0:0]S06_AXI_arvalid;
  input [31:0]S06_AXI_awaddr;
  input [2:0]S06_AXI_awprot;
  output [0:0]S06_AXI_awready;
  input [0:0]S06_AXI_awvalid;
  input [0:0]S06_AXI_bready;
  output [1:0]S06_AXI_bresp;
  output [0:0]S06_AXI_bvalid;
  output [31:0]S06_AXI_rdata;
  input [0:0]S06_AXI_rready;
  output [1:0]S06_AXI_rresp;
  output [0:0]S06_AXI_rvalid;
  input [31:0]S06_AXI_wdata;
  output [0:0]S06_AXI_wready;
  input [3:0]S06_AXI_wstrb;
  input [0:0]S06_AXI_wvalid;

  wire [31:0]Conn1_ARADDR;
  wire [2:0]Conn1_ARPROT;
  wire [0:0]Conn1_ARREADY;
  wire [0:0]Conn1_ARVALID;
  wire [31:0]Conn1_AWADDR;
  wire [2:0]Conn1_AWPROT;
  wire [0:0]Conn1_AWREADY;
  wire [0:0]Conn1_AWVALID;
  wire [0:0]Conn1_BREADY;
  wire [1:0]Conn1_BRESP;
  wire [0:0]Conn1_BVALID;
  wire [31:0]Conn1_RDATA;
  wire [0:0]Conn1_RREADY;
  wire [1:0]Conn1_RRESP;
  wire [0:0]Conn1_RVALID;
  wire [31:0]Conn1_WDATA;
  wire [0:0]Conn1_WREADY;
  wire [3:0]Conn1_WSTRB;
  wire [0:0]Conn1_WVALID;
  wire [31:0]Conn2_ARADDR;
  wire [2:0]Conn2_ARPROT;
  wire [0:0]Conn2_ARREADY;
  wire [0:0]Conn2_ARVALID;
  wire [31:0]Conn2_AWADDR;
  wire [2:0]Conn2_AWPROT;
  wire [0:0]Conn2_AWREADY;
  wire [0:0]Conn2_AWVALID;
  wire [0:0]Conn2_BREADY;
  wire [1:0]Conn2_BRESP;
  wire [0:0]Conn2_BVALID;
  wire [31:0]Conn2_RDATA;
  wire [0:0]Conn2_RREADY;
  wire [1:0]Conn2_RRESP;
  wire [0:0]Conn2_RVALID;
  wire [31:0]Conn2_WDATA;
  wire [0:0]Conn2_WREADY;
  wire [3:0]Conn2_WSTRB;
  wire [0:0]Conn2_WVALID;
  wire [31:0]Conn3_ARADDR;
  wire [2:0]Conn3_ARPROT;
  wire [0:0]Conn3_ARREADY;
  wire [0:0]Conn3_ARVALID;
  wire [31:0]Conn3_AWADDR;
  wire [2:0]Conn3_AWPROT;
  wire [0:0]Conn3_AWREADY;
  wire [0:0]Conn3_AWVALID;
  wire [0:0]Conn3_BREADY;
  wire [1:0]Conn3_BRESP;
  wire [0:0]Conn3_BVALID;
  wire [31:0]Conn3_RDATA;
  wire [0:0]Conn3_RREADY;
  wire [1:0]Conn3_RRESP;
  wire [0:0]Conn3_RVALID;
  wire [31:0]Conn3_WDATA;
  wire [0:0]Conn3_WREADY;
  wire [3:0]Conn3_WSTRB;
  wire [0:0]Conn3_WVALID;
  wire [15:0]Conn4_ARADDR;
  wire [2:0]Conn4_ARPROT;
  wire Conn4_ARREADY;
  wire Conn4_ARVALID;
  wire [15:0]Conn4_AWADDR;
  wire [2:0]Conn4_AWPROT;
  wire Conn4_AWREADY;
  wire Conn4_AWVALID;
  wire Conn4_BREADY;
  wire [1:0]Conn4_BRESP;
  wire Conn4_BVALID;
  wire [31:0]Conn4_RDATA;
  wire Conn4_RREADY;
  wire [1:0]Conn4_RRESP;
  wire Conn4_RVALID;
  wire [31:0]Conn4_WDATA;
  wire Conn4_WREADY;
  wire [3:0]Conn4_WSTRB;
  wire Conn4_WVALID;
  wire [31:0]Conn5_ARADDR;
  wire [2:0]Conn5_ARPROT;
  wire Conn5_ARREADY;
  wire Conn5_ARVALID;
  wire [31:0]Conn5_AWADDR;
  wire [2:0]Conn5_AWPROT;
  wire Conn5_AWREADY;
  wire Conn5_AWVALID;
  wire Conn5_BREADY;
  wire [1:0]Conn5_BRESP;
  wire Conn5_BVALID;
  wire [31:0]Conn5_RDATA;
  wire Conn5_RREADY;
  wire [1:0]Conn5_RRESP;
  wire Conn5_RVALID;
  wire [31:0]Conn5_WDATA;
  wire Conn5_WREADY;
  wire [3:0]Conn5_WSTRB;
  wire Conn5_WVALID;
  wire M00_ACLK_1;
  wire M00_ARESETN_1;
  wire [31:0]S04_AXI_1_ARADDR;
  wire [2:0]S04_AXI_1_ARPROT;
  wire [0:0]S04_AXI_1_ARREADY;
  wire [0:0]S04_AXI_1_ARVALID;
  wire [31:0]S04_AXI_1_AWADDR;
  wire [2:0]S04_AXI_1_AWPROT;
  wire [0:0]S04_AXI_1_AWREADY;
  wire [0:0]S04_AXI_1_AWVALID;
  wire [0:0]S04_AXI_1_BREADY;
  wire [1:0]S04_AXI_1_BRESP;
  wire [0:0]S04_AXI_1_BVALID;
  wire [31:0]S04_AXI_1_RDATA;
  wire [0:0]S04_AXI_1_RREADY;
  wire [1:0]S04_AXI_1_RRESP;
  wire [0:0]S04_AXI_1_RVALID;
  wire [31:0]S04_AXI_1_WDATA;
  wire [0:0]S04_AXI_1_WREADY;
  wire [3:0]S04_AXI_1_WSTRB;
  wire [0:0]S04_AXI_1_WVALID;
  wire [31:0]S05_AXI_1_ARADDR;
  wire [2:0]S05_AXI_1_ARPROT;
  wire [0:0]S05_AXI_1_ARREADY;
  wire [0:0]S05_AXI_1_ARVALID;
  wire [31:0]S05_AXI_1_AWADDR;
  wire [2:0]S05_AXI_1_AWPROT;
  wire [0:0]S05_AXI_1_AWREADY;
  wire [0:0]S05_AXI_1_AWVALID;
  wire [0:0]S05_AXI_1_BREADY;
  wire [1:0]S05_AXI_1_BRESP;
  wire [0:0]S05_AXI_1_BVALID;
  wire [31:0]S05_AXI_1_RDATA;
  wire [0:0]S05_AXI_1_RREADY;
  wire [1:0]S05_AXI_1_RRESP;
  wire [0:0]S05_AXI_1_RVALID;
  wire [31:0]S05_AXI_1_WDATA;
  wire [0:0]S05_AXI_1_WREADY;
  wire [3:0]S05_AXI_1_WSTRB;
  wire [0:0]S05_AXI_1_WVALID;
  wire [31:0]S06_AXI_1_ARADDR;
  wire [2:0]S06_AXI_1_ARPROT;
  wire [0:0]S06_AXI_1_ARREADY;
  wire [0:0]S06_AXI_1_ARVALID;
  wire [31:0]S06_AXI_1_AWADDR;
  wire [2:0]S06_AXI_1_AWPROT;
  wire [0:0]S06_AXI_1_AWREADY;
  wire [0:0]S06_AXI_1_AWVALID;
  wire [0:0]S06_AXI_1_BREADY;
  wire [1:0]S06_AXI_1_BRESP;
  wire [0:0]S06_AXI_1_BVALID;
  wire [31:0]S06_AXI_1_RDATA;
  wire [0:0]S06_AXI_1_RREADY;
  wire [1:0]S06_AXI_1_RRESP;
  wire [0:0]S06_AXI_1_RVALID;
  wire [31:0]S06_AXI_1_WDATA;
  wire [0:0]S06_AXI_1_WREADY;
  wire [3:0]S06_AXI_1_WSTRB;
  wire [0:0]S06_AXI_1_WVALID;

  assign Conn1_ARADDR = S00_AXI_araddr[31:0];
  assign Conn1_ARPROT = S00_AXI_arprot[2:0];
  assign Conn1_ARVALID = S00_AXI_arvalid[0];
  assign Conn1_AWADDR = S00_AXI_awaddr[31:0];
  assign Conn1_AWPROT = S00_AXI_awprot[2:0];
  assign Conn1_AWVALID = S00_AXI_awvalid[0];
  assign Conn1_BREADY = S00_AXI_bready[0];
  assign Conn1_RREADY = S00_AXI_rready[0];
  assign Conn1_WDATA = S00_AXI_wdata[31:0];
  assign Conn1_WSTRB = S00_AXI_wstrb[3:0];
  assign Conn1_WVALID = S00_AXI_wvalid[0];
  assign Conn2_ARADDR = S01_AXI_araddr[31:0];
  assign Conn2_ARPROT = S01_AXI_arprot[2:0];
  assign Conn2_ARVALID = S01_AXI_arvalid[0];
  assign Conn2_AWADDR = S01_AXI_awaddr[31:0];
  assign Conn2_AWPROT = S01_AXI_awprot[2:0];
  assign Conn2_AWVALID = S01_AXI_awvalid[0];
  assign Conn2_BREADY = S01_AXI_bready[0];
  assign Conn2_RREADY = S01_AXI_rready[0];
  assign Conn2_WDATA = S01_AXI_wdata[31:0];
  assign Conn2_WSTRB = S01_AXI_wstrb[3:0];
  assign Conn2_WVALID = S01_AXI_wvalid[0];
  assign Conn3_ARADDR = S02_AXI_araddr[31:0];
  assign Conn3_ARPROT = S02_AXI_arprot[2:0];
  assign Conn3_ARVALID = S02_AXI_arvalid[0];
  assign Conn3_AWADDR = S02_AXI_awaddr[31:0];
  assign Conn3_AWPROT = S02_AXI_awprot[2:0];
  assign Conn3_AWVALID = S02_AXI_awvalid[0];
  assign Conn3_BREADY = S02_AXI_bready[0];
  assign Conn3_RREADY = S02_AXI_rready[0];
  assign Conn3_WDATA = S02_AXI_wdata[31:0];
  assign Conn3_WSTRB = S02_AXI_wstrb[3:0];
  assign Conn3_WVALID = S02_AXI_wvalid[0];
  assign Conn4_ARREADY = M00_AXI_arready;
  assign Conn4_AWREADY = M00_AXI_awready;
  assign Conn4_BRESP = M00_AXI_bresp[1:0];
  assign Conn4_BVALID = M00_AXI_bvalid;
  assign Conn4_RDATA = M00_AXI_rdata[31:0];
  assign Conn4_RRESP = M00_AXI_rresp[1:0];
  assign Conn4_RVALID = M00_AXI_rvalid;
  assign Conn4_WREADY = M00_AXI_wready;
  assign Conn5_ARADDR = S03_AXI_araddr[31:0];
  assign Conn5_ARPROT = S03_AXI_arprot[2:0];
  assign Conn5_ARVALID = S03_AXI_arvalid;
  assign Conn5_AWADDR = S03_AXI_awaddr[31:0];
  assign Conn5_AWPROT = S03_AXI_awprot[2:0];
  assign Conn5_AWVALID = S03_AXI_awvalid;
  assign Conn5_BREADY = S03_AXI_bready;
  assign Conn5_RREADY = S03_AXI_rready;
  assign Conn5_WDATA = S03_AXI_wdata[31:0];
  assign Conn5_WSTRB = S03_AXI_wstrb[3:0];
  assign Conn5_WVALID = S03_AXI_wvalid;
  assign M00_ACLK_1 = M00_ACLK;
  assign M00_ARESETN_1 = M00_ARESETN;
  assign M00_AXI_araddr[15:0] = Conn4_ARADDR;
  assign M00_AXI_arprot[2:0] = Conn4_ARPROT;
  assign M00_AXI_arvalid = Conn4_ARVALID;
  assign M00_AXI_awaddr[15:0] = Conn4_AWADDR;
  assign M00_AXI_awprot[2:0] = Conn4_AWPROT;
  assign M00_AXI_awvalid = Conn4_AWVALID;
  assign M00_AXI_bready = Conn4_BREADY;
  assign M00_AXI_rready = Conn4_RREADY;
  assign M00_AXI_wdata[31:0] = Conn4_WDATA;
  assign M00_AXI_wstrb[3:0] = Conn4_WSTRB;
  assign M00_AXI_wvalid = Conn4_WVALID;
  assign S00_AXI_arready[0] = Conn1_ARREADY;
  assign S00_AXI_awready[0] = Conn1_AWREADY;
  assign S00_AXI_bresp[1:0] = Conn1_BRESP;
  assign S00_AXI_bvalid[0] = Conn1_BVALID;
  assign S00_AXI_rdata[31:0] = Conn1_RDATA;
  assign S00_AXI_rresp[1:0] = Conn1_RRESP;
  assign S00_AXI_rvalid[0] = Conn1_RVALID;
  assign S00_AXI_wready[0] = Conn1_WREADY;
  assign S01_AXI_arready[0] = Conn2_ARREADY;
  assign S01_AXI_awready[0] = Conn2_AWREADY;
  assign S01_AXI_bresp[1:0] = Conn2_BRESP;
  assign S01_AXI_bvalid[0] = Conn2_BVALID;
  assign S01_AXI_rdata[31:0] = Conn2_RDATA;
  assign S01_AXI_rresp[1:0] = Conn2_RRESP;
  assign S01_AXI_rvalid[0] = Conn2_RVALID;
  assign S01_AXI_wready[0] = Conn2_WREADY;
  assign S02_AXI_arready[0] = Conn3_ARREADY;
  assign S02_AXI_awready[0] = Conn3_AWREADY;
  assign S02_AXI_bresp[1:0] = Conn3_BRESP;
  assign S02_AXI_bvalid[0] = Conn3_BVALID;
  assign S02_AXI_rdata[31:0] = Conn3_RDATA;
  assign S02_AXI_rresp[1:0] = Conn3_RRESP;
  assign S02_AXI_rvalid[0] = Conn3_RVALID;
  assign S02_AXI_wready[0] = Conn3_WREADY;
  assign S03_AXI_arready = Conn5_ARREADY;
  assign S03_AXI_awready = Conn5_AWREADY;
  assign S03_AXI_bresp[1:0] = Conn5_BRESP;
  assign S03_AXI_bvalid = Conn5_BVALID;
  assign S03_AXI_rdata[31:0] = Conn5_RDATA;
  assign S03_AXI_rresp[1:0] = Conn5_RRESP;
  assign S03_AXI_rvalid = Conn5_RVALID;
  assign S03_AXI_wready = Conn5_WREADY;
  assign S04_AXI_1_ARADDR = S04_AXI_araddr[31:0];
  assign S04_AXI_1_ARPROT = S04_AXI_arprot[2:0];
  assign S04_AXI_1_ARVALID = S04_AXI_arvalid[0];
  assign S04_AXI_1_AWADDR = S04_AXI_awaddr[31:0];
  assign S04_AXI_1_AWPROT = S04_AXI_awprot[2:0];
  assign S04_AXI_1_AWVALID = S04_AXI_awvalid[0];
  assign S04_AXI_1_BREADY = S04_AXI_bready[0];
  assign S04_AXI_1_RREADY = S04_AXI_rready[0];
  assign S04_AXI_1_WDATA = S04_AXI_wdata[31:0];
  assign S04_AXI_1_WSTRB = S04_AXI_wstrb[3:0];
  assign S04_AXI_1_WVALID = S04_AXI_wvalid[0];
  assign S04_AXI_arready[0] = S04_AXI_1_ARREADY;
  assign S04_AXI_awready[0] = S04_AXI_1_AWREADY;
  assign S04_AXI_bresp[1:0] = S04_AXI_1_BRESP;
  assign S04_AXI_bvalid[0] = S04_AXI_1_BVALID;
  assign S04_AXI_rdata[31:0] = S04_AXI_1_RDATA;
  assign S04_AXI_rresp[1:0] = S04_AXI_1_RRESP;
  assign S04_AXI_rvalid[0] = S04_AXI_1_RVALID;
  assign S04_AXI_wready[0] = S04_AXI_1_WREADY;
  assign S05_AXI_1_ARADDR = S05_AXI_araddr[31:0];
  assign S05_AXI_1_ARPROT = S05_AXI_arprot[2:0];
  assign S05_AXI_1_ARVALID = S05_AXI_arvalid[0];
  assign S05_AXI_1_AWADDR = S05_AXI_awaddr[31:0];
  assign S05_AXI_1_AWPROT = S05_AXI_awprot[2:0];
  assign S05_AXI_1_AWVALID = S05_AXI_awvalid[0];
  assign S05_AXI_1_BREADY = S05_AXI_bready[0];
  assign S05_AXI_1_RREADY = S05_AXI_rready[0];
  assign S05_AXI_1_WDATA = S05_AXI_wdata[31:0];
  assign S05_AXI_1_WSTRB = S05_AXI_wstrb[3:0];
  assign S05_AXI_1_WVALID = S05_AXI_wvalid[0];
  assign S05_AXI_arready[0] = S05_AXI_1_ARREADY;
  assign S05_AXI_awready[0] = S05_AXI_1_AWREADY;
  assign S05_AXI_bresp[1:0] = S05_AXI_1_BRESP;
  assign S05_AXI_bvalid[0] = S05_AXI_1_BVALID;
  assign S05_AXI_rdata[31:0] = S05_AXI_1_RDATA;
  assign S05_AXI_rresp[1:0] = S05_AXI_1_RRESP;
  assign S05_AXI_rvalid[0] = S05_AXI_1_RVALID;
  assign S05_AXI_wready[0] = S05_AXI_1_WREADY;
  assign S06_AXI_1_ARADDR = S06_AXI_araddr[31:0];
  assign S06_AXI_1_ARPROT = S06_AXI_arprot[2:0];
  assign S06_AXI_1_ARVALID = S06_AXI_arvalid[0];
  assign S06_AXI_1_AWADDR = S06_AXI_awaddr[31:0];
  assign S06_AXI_1_AWPROT = S06_AXI_awprot[2:0];
  assign S06_AXI_1_AWVALID = S06_AXI_awvalid[0];
  assign S06_AXI_1_BREADY = S06_AXI_bready[0];
  assign S06_AXI_1_RREADY = S06_AXI_rready[0];
  assign S06_AXI_1_WDATA = S06_AXI_wdata[31:0];
  assign S06_AXI_1_WSTRB = S06_AXI_wstrb[3:0];
  assign S06_AXI_1_WVALID = S06_AXI_wvalid[0];
  assign S06_AXI_arready[0] = S06_AXI_1_ARREADY;
  assign S06_AXI_awready[0] = S06_AXI_1_AWREADY;
  assign S06_AXI_bresp[1:0] = S06_AXI_1_BRESP;
  assign S06_AXI_bvalid[0] = S06_AXI_1_BVALID;
  assign S06_AXI_rdata[31:0] = S06_AXI_1_RDATA;
  assign S06_AXI_rresp[1:0] = S06_AXI_1_RRESP;
  assign S06_AXI_rvalid[0] = S06_AXI_1_RVALID;
  assign S06_AXI_wready[0] = S06_AXI_1_WREADY;
  top_block_axi_mem_intercon_3 axi_mem_intercon
       (.ACLK(M00_ACLK_1),
        .ARESETN(M00_ARESETN_1),
        .M00_ACLK(M00_ACLK_1),
        .M00_ARESETN(M00_ARESETN_1),
        .M00_AXI_araddr(Conn4_ARADDR),
        .M00_AXI_arprot(Conn4_ARPROT),
        .M00_AXI_arready(Conn4_ARREADY),
        .M00_AXI_arvalid(Conn4_ARVALID),
        .M00_AXI_awaddr(Conn4_AWADDR),
        .M00_AXI_awprot(Conn4_AWPROT),
        .M00_AXI_awready(Conn4_AWREADY),
        .M00_AXI_awvalid(Conn4_AWVALID),
        .M00_AXI_bready(Conn4_BREADY),
        .M00_AXI_bresp(Conn4_BRESP),
        .M00_AXI_bvalid(Conn4_BVALID),
        .M00_AXI_rdata(Conn4_RDATA),
        .M00_AXI_rready(Conn4_RREADY),
        .M00_AXI_rresp(Conn4_RRESP),
        .M00_AXI_rvalid(Conn4_RVALID),
        .M00_AXI_wdata(Conn4_WDATA),
        .M00_AXI_wready(Conn4_WREADY),
        .M00_AXI_wstrb(Conn4_WSTRB),
        .M00_AXI_wvalid(Conn4_WVALID),
        .S00_ACLK(M00_ACLK_1),
        .S00_ARESETN(M00_ARESETN_1),
        .S00_AXI_araddr(Conn1_ARADDR),
        .S00_AXI_arprot(Conn1_ARPROT),
        .S00_AXI_arready(Conn1_ARREADY),
        .S00_AXI_arvalid(Conn1_ARVALID),
        .S00_AXI_awaddr(Conn1_AWADDR),
        .S00_AXI_awprot(Conn1_AWPROT),
        .S00_AXI_awready(Conn1_AWREADY),
        .S00_AXI_awvalid(Conn1_AWVALID),
        .S00_AXI_bready(Conn1_BREADY),
        .S00_AXI_bresp(Conn1_BRESP),
        .S00_AXI_bvalid(Conn1_BVALID),
        .S00_AXI_rdata(Conn1_RDATA),
        .S00_AXI_rready(Conn1_RREADY),
        .S00_AXI_rresp(Conn1_RRESP),
        .S00_AXI_rvalid(Conn1_RVALID),
        .S00_AXI_wdata(Conn1_WDATA),
        .S00_AXI_wready(Conn1_WREADY),
        .S00_AXI_wstrb(Conn1_WSTRB),
        .S00_AXI_wvalid(Conn1_WVALID),
        .S01_ACLK(M00_ACLK_1),
        .S01_ARESETN(M00_ARESETN_1),
        .S01_AXI_araddr(Conn2_ARADDR),
        .S01_AXI_arprot(Conn2_ARPROT),
        .S01_AXI_arready(Conn2_ARREADY),
        .S01_AXI_arvalid(Conn2_ARVALID),
        .S01_AXI_awaddr(Conn2_AWADDR),
        .S01_AXI_awprot(Conn2_AWPROT),
        .S01_AXI_awready(Conn2_AWREADY),
        .S01_AXI_awvalid(Conn2_AWVALID),
        .S01_AXI_bready(Conn2_BREADY),
        .S01_AXI_bresp(Conn2_BRESP),
        .S01_AXI_bvalid(Conn2_BVALID),
        .S01_AXI_rdata(Conn2_RDATA),
        .S01_AXI_rready(Conn2_RREADY),
        .S01_AXI_rresp(Conn2_RRESP),
        .S01_AXI_rvalid(Conn2_RVALID),
        .S01_AXI_wdata(Conn2_WDATA),
        .S01_AXI_wready(Conn2_WREADY),
        .S01_AXI_wstrb(Conn2_WSTRB),
        .S01_AXI_wvalid(Conn2_WVALID),
        .S02_ACLK(M00_ACLK_1),
        .S02_ARESETN(M00_ARESETN_1),
        .S02_AXI_araddr(Conn3_ARADDR),
        .S02_AXI_arprot(Conn3_ARPROT),
        .S02_AXI_arready(Conn3_ARREADY),
        .S02_AXI_arvalid(Conn3_ARVALID),
        .S02_AXI_awaddr(Conn3_AWADDR),
        .S02_AXI_awprot(Conn3_AWPROT),
        .S02_AXI_awready(Conn3_AWREADY),
        .S02_AXI_awvalid(Conn3_AWVALID),
        .S02_AXI_bready(Conn3_BREADY),
        .S02_AXI_bresp(Conn3_BRESP),
        .S02_AXI_bvalid(Conn3_BVALID),
        .S02_AXI_rdata(Conn3_RDATA),
        .S02_AXI_rready(Conn3_RREADY),
        .S02_AXI_rresp(Conn3_RRESP),
        .S02_AXI_rvalid(Conn3_RVALID),
        .S02_AXI_wdata(Conn3_WDATA),
        .S02_AXI_wready(Conn3_WREADY),
        .S02_AXI_wstrb(Conn3_WSTRB),
        .S02_AXI_wvalid(Conn3_WVALID),
        .S03_ACLK(M00_ACLK_1),
        .S03_ARESETN(M00_ARESETN_1),
        .S03_AXI_araddr(Conn5_ARADDR),
        .S03_AXI_arprot(Conn5_ARPROT),
        .S03_AXI_arready(Conn5_ARREADY),
        .S03_AXI_arvalid(Conn5_ARVALID),
        .S03_AXI_awaddr(Conn5_AWADDR),
        .S03_AXI_awprot(Conn5_AWPROT),
        .S03_AXI_awready(Conn5_AWREADY),
        .S03_AXI_awvalid(Conn5_AWVALID),
        .S03_AXI_bready(Conn5_BREADY),
        .S03_AXI_bresp(Conn5_BRESP),
        .S03_AXI_bvalid(Conn5_BVALID),
        .S03_AXI_rdata(Conn5_RDATA),
        .S03_AXI_rready(Conn5_RREADY),
        .S03_AXI_rresp(Conn5_RRESP),
        .S03_AXI_rvalid(Conn5_RVALID),
        .S03_AXI_wdata(Conn5_WDATA),
        .S03_AXI_wready(Conn5_WREADY),
        .S03_AXI_wstrb(Conn5_WSTRB),
        .S03_AXI_wvalid(Conn5_WVALID),
        .S04_ACLK(M00_ACLK_1),
        .S04_ARESETN(M00_ARESETN_1),
        .S04_AXI_araddr(S04_AXI_1_ARADDR),
        .S04_AXI_arprot(S04_AXI_1_ARPROT),
        .S04_AXI_arready(S04_AXI_1_ARREADY),
        .S04_AXI_arvalid(S04_AXI_1_ARVALID),
        .S04_AXI_awaddr(S04_AXI_1_AWADDR),
        .S04_AXI_awprot(S04_AXI_1_AWPROT),
        .S04_AXI_awready(S04_AXI_1_AWREADY),
        .S04_AXI_awvalid(S04_AXI_1_AWVALID),
        .S04_AXI_bready(S04_AXI_1_BREADY),
        .S04_AXI_bresp(S04_AXI_1_BRESP),
        .S04_AXI_bvalid(S04_AXI_1_BVALID),
        .S04_AXI_rdata(S04_AXI_1_RDATA),
        .S04_AXI_rready(S04_AXI_1_RREADY),
        .S04_AXI_rresp(S04_AXI_1_RRESP),
        .S04_AXI_rvalid(S04_AXI_1_RVALID),
        .S04_AXI_wdata(S04_AXI_1_WDATA),
        .S04_AXI_wready(S04_AXI_1_WREADY),
        .S04_AXI_wstrb(S04_AXI_1_WSTRB),
        .S04_AXI_wvalid(S04_AXI_1_WVALID),
        .S05_ACLK(M00_ACLK_1),
        .S05_ARESETN(M00_ARESETN_1),
        .S05_AXI_araddr(S05_AXI_1_ARADDR),
        .S05_AXI_arprot(S05_AXI_1_ARPROT),
        .S05_AXI_arready(S05_AXI_1_ARREADY),
        .S05_AXI_arvalid(S05_AXI_1_ARVALID),
        .S05_AXI_awaddr(S05_AXI_1_AWADDR),
        .S05_AXI_awprot(S05_AXI_1_AWPROT),
        .S05_AXI_awready(S05_AXI_1_AWREADY),
        .S05_AXI_awvalid(S05_AXI_1_AWVALID),
        .S05_AXI_bready(S05_AXI_1_BREADY),
        .S05_AXI_bresp(S05_AXI_1_BRESP),
        .S05_AXI_bvalid(S05_AXI_1_BVALID),
        .S05_AXI_rdata(S05_AXI_1_RDATA),
        .S05_AXI_rready(S05_AXI_1_RREADY),
        .S05_AXI_rresp(S05_AXI_1_RRESP),
        .S05_AXI_rvalid(S05_AXI_1_RVALID),
        .S05_AXI_wdata(S05_AXI_1_WDATA),
        .S05_AXI_wready(S05_AXI_1_WREADY),
        .S05_AXI_wstrb(S05_AXI_1_WSTRB),
        .S05_AXI_wvalid(S05_AXI_1_WVALID),
        .S06_ACLK(M00_ACLK_1),
        .S06_ARESETN(M00_ARESETN_1),
        .S06_AXI_araddr(S06_AXI_1_ARADDR),
        .S06_AXI_arprot(S06_AXI_1_ARPROT),
        .S06_AXI_arready(S06_AXI_1_ARREADY),
        .S06_AXI_arvalid(S06_AXI_1_ARVALID),
        .S06_AXI_awaddr(S06_AXI_1_AWADDR),
        .S06_AXI_awprot(S06_AXI_1_AWPROT),
        .S06_AXI_awready(S06_AXI_1_AWREADY),
        .S06_AXI_awvalid(S06_AXI_1_AWVALID),
        .S06_AXI_bready(S06_AXI_1_BREADY),
        .S06_AXI_bresp(S06_AXI_1_BRESP),
        .S06_AXI_bvalid(S06_AXI_1_BVALID),
        .S06_AXI_rdata(S06_AXI_1_RDATA),
        .S06_AXI_rready(S06_AXI_1_RREADY),
        .S06_AXI_rresp(S06_AXI_1_RRESP),
        .S06_AXI_rvalid(S06_AXI_1_RVALID),
        .S06_AXI_wdata(S06_AXI_1_WDATA),
        .S06_AXI_wready(S06_AXI_1_WREADY),
        .S06_AXI_wstrb(S06_AXI_1_WSTRB),
        .S06_AXI_wvalid(S06_AXI_1_WVALID));
endmodule

module led_module_imp_CAGS8R
   (DIP_SW,
    LED,
    clk125MHz,
    ext_clk_lkd,
    fnet_txn,
    m00_axi1_araddr,
    m00_axi1_arprot,
    m00_axi1_arready,
    m00_axi1_arvalid,
    m00_axi1_awaddr,
    m00_axi1_awprot,
    m00_axi1_awready,
    m00_axi1_awvalid,
    m00_axi1_bready,
    m00_axi1_bresp,
    m00_axi1_bvalid,
    m00_axi1_rdata,
    m00_axi1_rready,
    m00_axi1_rresp,
    m00_axi1_rvalid,
    m00_axi1_wdata,
    m00_axi1_wready,
    m00_axi1_wstrb,
    m00_axi1_wvalid,
    m00_axi_araddr,
    m00_axi_aresetn,
    m00_axi_arprot,
    m00_axi_arready,
    m00_axi_arvalid,
    m00_axi_awaddr,
    m00_axi_awprot,
    m00_axi_awready,
    m00_axi_awvalid,
    m00_axi_bready,
    m00_axi_bresp,
    m00_axi_bvalid,
    m00_axi_rdata,
    m00_axi_rready,
    m00_axi_rresp,
    m00_axi_rvalid,
    m00_axi_wdata,
    m00_axi_wready,
    m00_axi_wstrb,
    m00_axi_wvalid,
    power_on,
    reset);
  input [3:0]DIP_SW;
  output [3:0]LED;
  input clk125MHz;
  input ext_clk_lkd;
  input fnet_txn;
  output [31:0]m00_axi1_araddr;
  output [2:0]m00_axi1_arprot;
  input [0:0]m00_axi1_arready;
  output [0:0]m00_axi1_arvalid;
  output [31:0]m00_axi1_awaddr;
  output [2:0]m00_axi1_awprot;
  input [0:0]m00_axi1_awready;
  output [0:0]m00_axi1_awvalid;
  output [0:0]m00_axi1_bready;
  input [1:0]m00_axi1_bresp;
  input [0:0]m00_axi1_bvalid;
  input [31:0]m00_axi1_rdata;
  output [0:0]m00_axi1_rready;
  input [1:0]m00_axi1_rresp;
  input [0:0]m00_axi1_rvalid;
  output [31:0]m00_axi1_wdata;
  input [0:0]m00_axi1_wready;
  output [3:0]m00_axi1_wstrb;
  output [0:0]m00_axi1_wvalid;
  output [31:0]m00_axi_araddr;
  input m00_axi_aresetn;
  output [2:0]m00_axi_arprot;
  input [0:0]m00_axi_arready;
  output [0:0]m00_axi_arvalid;
  output [31:0]m00_axi_awaddr;
  output [2:0]m00_axi_awprot;
  input [0:0]m00_axi_awready;
  output [0:0]m00_axi_awvalid;
  output [0:0]m00_axi_bready;
  input [1:0]m00_axi_bresp;
  input [0:0]m00_axi_bvalid;
  input [31:0]m00_axi_rdata;
  output [0:0]m00_axi_rready;
  input [1:0]m00_axi_rresp;
  input [0:0]m00_axi_rvalid;
  output [31:0]m00_axi_wdata;
  input [0:0]m00_axi_wready;
  output [3:0]m00_axi_wstrb;
  output [0:0]m00_axi_wvalid;
  input power_on;
  input reset;

  wire [31:0]Conn1_ARADDR;
  wire [2:0]Conn1_ARPROT;
  wire [0:0]Conn1_ARREADY;
  wire Conn1_ARVALID;
  wire [31:0]Conn1_AWADDR;
  wire [2:0]Conn1_AWPROT;
  wire [0:0]Conn1_AWREADY;
  wire Conn1_AWVALID;
  wire Conn1_BREADY;
  wire [1:0]Conn1_BRESP;
  wire [0:0]Conn1_BVALID;
  wire [31:0]Conn1_RDATA;
  wire Conn1_RREADY;
  wire [1:0]Conn1_RRESP;
  wire [0:0]Conn1_RVALID;
  wire [31:0]Conn1_WDATA;
  wire [0:0]Conn1_WREADY;
  wire [3:0]Conn1_WSTRB;
  wire Conn1_WVALID;
  wire [31:0]Conn2_ARADDR;
  wire [2:0]Conn2_ARPROT;
  wire [0:0]Conn2_ARREADY;
  wire Conn2_ARVALID;
  wire [31:0]Conn2_AWADDR;
  wire [2:0]Conn2_AWPROT;
  wire [0:0]Conn2_AWREADY;
  wire Conn2_AWVALID;
  wire Conn2_BREADY;
  wire [1:0]Conn2_BRESP;
  wire [0:0]Conn2_BVALID;
  wire [31:0]Conn2_RDATA;
  wire Conn2_RREADY;
  wire [1:0]Conn2_RRESP;
  wire [0:0]Conn2_RVALID;
  wire [31:0]Conn2_WDATA;
  wire [0:0]Conn2_WREADY;
  wire [3:0]Conn2_WSTRB;
  wire Conn2_WVALID;
  wire [3:0]DIP_SW_1;
  wire [31:0]LED_REG_READ_SEPARAT_0_LED_REG;
  wire LED_REG_READ_SEPARAT_0_m00_axi_txn_done;
  wire [31:0]LED_REG_READ_SEPARAT_1_LED_REG;
  wire LED_REG_READ_SEPARAT_1_m00_axi_txn_done;
  wire clk125MHz_1;
  wire ext_clk_lkd_1;
  wire fnet_txn_1;
  wire m00_axi_aresetn_1;
  wire power_on_1;
  wire reset_1;
  wire u_led_inst_0_INIT_AXI_TXN;
  wire u_led_inst_0_INIT_AXI_TXN_SUB;
  wire [3:0]u_led_inst_0_LED;
  wire [0:0]util_vector_logic_0_Res;
  wire [0:0]xlconstant_0_dout;

  assign Conn1_ARREADY = m00_axi_arready[0];
  assign Conn1_AWREADY = m00_axi_awready[0];
  assign Conn1_BRESP = m00_axi_bresp[1:0];
  assign Conn1_BVALID = m00_axi_bvalid[0];
  assign Conn1_RDATA = m00_axi_rdata[31:0];
  assign Conn1_RRESP = m00_axi_rresp[1:0];
  assign Conn1_RVALID = m00_axi_rvalid[0];
  assign Conn1_WREADY = m00_axi_wready[0];
  assign Conn2_ARREADY = m00_axi1_arready[0];
  assign Conn2_AWREADY = m00_axi1_awready[0];
  assign Conn2_BRESP = m00_axi1_bresp[1:0];
  assign Conn2_BVALID = m00_axi1_bvalid[0];
  assign Conn2_RDATA = m00_axi1_rdata[31:0];
  assign Conn2_RRESP = m00_axi1_rresp[1:0];
  assign Conn2_RVALID = m00_axi1_rvalid[0];
  assign Conn2_WREADY = m00_axi1_wready[0];
  assign DIP_SW_1 = DIP_SW[3:0];
  assign LED[3:0] = u_led_inst_0_LED;
  assign clk125MHz_1 = clk125MHz;
  assign ext_clk_lkd_1 = ext_clk_lkd;
  assign fnet_txn_1 = fnet_txn;
  assign m00_axi1_araddr[31:0] = Conn2_ARADDR;
  assign m00_axi1_arprot[2:0] = Conn2_ARPROT;
  assign m00_axi1_arvalid[0] = Conn2_ARVALID;
  assign m00_axi1_awaddr[31:0] = Conn2_AWADDR;
  assign m00_axi1_awprot[2:0] = Conn2_AWPROT;
  assign m00_axi1_awvalid[0] = Conn2_AWVALID;
  assign m00_axi1_bready[0] = Conn2_BREADY;
  assign m00_axi1_rready[0] = Conn2_RREADY;
  assign m00_axi1_wdata[31:0] = Conn2_WDATA;
  assign m00_axi1_wstrb[3:0] = Conn2_WSTRB;
  assign m00_axi1_wvalid[0] = Conn2_WVALID;
  assign m00_axi_araddr[31:0] = Conn1_ARADDR;
  assign m00_axi_aresetn_1 = m00_axi_aresetn;
  assign m00_axi_arprot[2:0] = Conn1_ARPROT;
  assign m00_axi_arvalid[0] = Conn1_ARVALID;
  assign m00_axi_awaddr[31:0] = Conn1_AWADDR;
  assign m00_axi_awprot[2:0] = Conn1_AWPROT;
  assign m00_axi_awvalid[0] = Conn1_AWVALID;
  assign m00_axi_bready[0] = Conn1_BREADY;
  assign m00_axi_rready[0] = Conn1_RREADY;
  assign m00_axi_wdata[31:0] = Conn1_WDATA;
  assign m00_axi_wstrb[3:0] = Conn1_WSTRB;
  assign m00_axi_wvalid[0] = Conn1_WVALID;
  assign power_on_1 = power_on;
  assign reset_1 = reset;
  top_block_LED_REG_READ_SEPARAT_0_0 LED_REG_READ_SEPARAT_0
       (.LED_REG(LED_REG_READ_SEPARAT_0_LED_REG),
        .m00_axi_aclk(clk125MHz_1),
        .m00_axi_araddr(Conn1_ARADDR),
        .m00_axi_aresetn(m00_axi_aresetn_1),
        .m00_axi_arprot(Conn1_ARPROT),
        .m00_axi_arready(Conn1_ARREADY),
        .m00_axi_arvalid(Conn1_ARVALID),
        .m00_axi_awaddr(Conn1_AWADDR),
        .m00_axi_awprot(Conn1_AWPROT),
        .m00_axi_awready(Conn1_AWREADY),
        .m00_axi_awvalid(Conn1_AWVALID),
        .m00_axi_bready(Conn1_BREADY),
        .m00_axi_bresp(Conn1_BRESP),
        .m00_axi_bvalid(Conn1_BVALID),
        .m00_axi_init_axi_txn(u_led_inst_0_INIT_AXI_TXN),
        .m00_axi_rdata(Conn1_RDATA),
        .m00_axi_rready(Conn1_RREADY),
        .m00_axi_rresp(Conn1_RRESP),
        .m00_axi_rvalid(Conn1_RVALID),
        .m00_axi_txn_done(LED_REG_READ_SEPARAT_0_m00_axi_txn_done),
        .m00_axi_wdata(Conn1_WDATA),
        .m00_axi_wready(Conn1_WREADY),
        .m00_axi_wstrb(Conn1_WSTRB),
        .m00_axi_wvalid(Conn1_WVALID));
  top_block_LED_REG_READ_SEPARAT_1_0 LED_REG_READ_SEPARAT_1
       (.LED_REG(LED_REG_READ_SEPARAT_1_LED_REG),
        .m00_axi_aclk(clk125MHz_1),
        .m00_axi_araddr(Conn2_ARADDR),
        .m00_axi_aresetn(m00_axi_aresetn_1),
        .m00_axi_arprot(Conn2_ARPROT),
        .m00_axi_arready(Conn2_ARREADY),
        .m00_axi_arvalid(Conn2_ARVALID),
        .m00_axi_awaddr(Conn2_AWADDR),
        .m00_axi_awprot(Conn2_AWPROT),
        .m00_axi_awready(Conn2_AWREADY),
        .m00_axi_awvalid(Conn2_AWVALID),
        .m00_axi_bready(Conn2_BREADY),
        .m00_axi_bresp(Conn2_BRESP),
        .m00_axi_bvalid(Conn2_BVALID),
        .m00_axi_init_axi_txn(u_led_inst_0_INIT_AXI_TXN_SUB),
        .m00_axi_rdata(Conn2_RDATA),
        .m00_axi_rready(Conn2_RREADY),
        .m00_axi_rresp(Conn2_RRESP),
        .m00_axi_rvalid(Conn2_RVALID),
        .m00_axi_txn_done(LED_REG_READ_SEPARAT_1_m00_axi_txn_done),
        .m00_axi_wdata(Conn2_WDATA),
        .m00_axi_wready(Conn2_WREADY),
        .m00_axi_wstrb(Conn2_WSTRB),
        .m00_axi_wvalid(Conn2_WVALID));
  top_block_u_led_inst_0_0 u_led_inst_0
       (.DIPSW(DIP_SW_1),
        .INIT_AXI_TXN(u_led_inst_0_INIT_AXI_TXN),
        .INIT_AXI_TXN_SUB(u_led_inst_0_INIT_AXI_TXN_SUB),
        .LED(u_led_inst_0_LED),
        .LED_REG0({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .LED_REG1({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .LED_REG2(LED_REG_READ_SEPARAT_0_LED_REG),
        .LED_REG3(LED_REG_READ_SEPARAT_1_LED_REG),
        .LED_TXN_DONE(util_vector_logic_0_Res),
        .clk125MHz(clk125MHz_1),
        .enable(xlconstant_0_dout),
        .ext_clk_lkd(ext_clk_lkd_1),
        .fnet_txn(fnet_txn_1),
        .power_on(power_on_1),
        .reset(reset_1));
  top_block_util_vector_logic_0_2 util_vector_logic_0
       (.Op1(LED_REG_READ_SEPARAT_0_m00_axi_txn_done),
        .Op2(LED_REG_READ_SEPARAT_1_m00_axi_txn_done),
        .Res(util_vector_logic_0_Res));
  top_block_xlconstant_0_2 xlconstant_0
       (.dout(xlconstant_0_dout));
endmodule

module m00_couplers_imp_O6Y4JN
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arprot,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awprot,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arprot,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awprot,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [15:0]M_AXI_araddr;
  output [2:0]M_AXI_arprot;
  input M_AXI_arready;
  output M_AXI_arvalid;
  output [15:0]M_AXI_awaddr;
  output [2:0]M_AXI_awprot;
  input M_AXI_awready;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [2:0]S_AXI_arprot;
  output S_AXI_arready;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [2:0]S_AXI_awprot;
  output S_AXI_awready;
  input S_AXI_awvalid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  output S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input S_AXI_wvalid;

  wire S_ACLK_1;
  wire S_ARESETN_1;
  wire [31:0]m00_couplers_to_m00_data_fifo_ARADDR;
  wire [2:0]m00_couplers_to_m00_data_fifo_ARPROT;
  wire m00_couplers_to_m00_data_fifo_ARREADY;
  wire m00_couplers_to_m00_data_fifo_ARVALID;
  wire [31:0]m00_couplers_to_m00_data_fifo_AWADDR;
  wire [2:0]m00_couplers_to_m00_data_fifo_AWPROT;
  wire m00_couplers_to_m00_data_fifo_AWREADY;
  wire m00_couplers_to_m00_data_fifo_AWVALID;
  wire m00_couplers_to_m00_data_fifo_BREADY;
  wire [1:0]m00_couplers_to_m00_data_fifo_BRESP;
  wire m00_couplers_to_m00_data_fifo_BVALID;
  wire [31:0]m00_couplers_to_m00_data_fifo_RDATA;
  wire m00_couplers_to_m00_data_fifo_RREADY;
  wire [1:0]m00_couplers_to_m00_data_fifo_RRESP;
  wire m00_couplers_to_m00_data_fifo_RVALID;
  wire [31:0]m00_couplers_to_m00_data_fifo_WDATA;
  wire m00_couplers_to_m00_data_fifo_WREADY;
  wire [3:0]m00_couplers_to_m00_data_fifo_WSTRB;
  wire m00_couplers_to_m00_data_fifo_WVALID;
  wire [15:0]m00_data_fifo_to_m00_couplers_ARADDR;
  wire [2:0]m00_data_fifo_to_m00_couplers_ARPROT;
  wire m00_data_fifo_to_m00_couplers_ARREADY;
  wire m00_data_fifo_to_m00_couplers_ARVALID;
  wire [15:0]m00_data_fifo_to_m00_couplers_AWADDR;
  wire [2:0]m00_data_fifo_to_m00_couplers_AWPROT;
  wire m00_data_fifo_to_m00_couplers_AWREADY;
  wire m00_data_fifo_to_m00_couplers_AWVALID;
  wire m00_data_fifo_to_m00_couplers_BREADY;
  wire [1:0]m00_data_fifo_to_m00_couplers_BRESP;
  wire m00_data_fifo_to_m00_couplers_BVALID;
  wire [31:0]m00_data_fifo_to_m00_couplers_RDATA;
  wire m00_data_fifo_to_m00_couplers_RREADY;
  wire [1:0]m00_data_fifo_to_m00_couplers_RRESP;
  wire m00_data_fifo_to_m00_couplers_RVALID;
  wire [31:0]m00_data_fifo_to_m00_couplers_WDATA;
  wire m00_data_fifo_to_m00_couplers_WREADY;
  wire [3:0]m00_data_fifo_to_m00_couplers_WSTRB;
  wire m00_data_fifo_to_m00_couplers_WVALID;

  assign M_AXI_araddr[15:0] = m00_data_fifo_to_m00_couplers_ARADDR;
  assign M_AXI_arprot[2:0] = m00_data_fifo_to_m00_couplers_ARPROT;
  assign M_AXI_arvalid = m00_data_fifo_to_m00_couplers_ARVALID;
  assign M_AXI_awaddr[15:0] = m00_data_fifo_to_m00_couplers_AWADDR;
  assign M_AXI_awprot[2:0] = m00_data_fifo_to_m00_couplers_AWPROT;
  assign M_AXI_awvalid = m00_data_fifo_to_m00_couplers_AWVALID;
  assign M_AXI_bready = m00_data_fifo_to_m00_couplers_BREADY;
  assign M_AXI_rready = m00_data_fifo_to_m00_couplers_RREADY;
  assign M_AXI_wdata[31:0] = m00_data_fifo_to_m00_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = m00_data_fifo_to_m00_couplers_WSTRB;
  assign M_AXI_wvalid = m00_data_fifo_to_m00_couplers_WVALID;
  assign S_ACLK_1 = S_ACLK;
  assign S_ARESETN_1 = S_ARESETN;
  assign S_AXI_arready = m00_couplers_to_m00_data_fifo_ARREADY;
  assign S_AXI_awready = m00_couplers_to_m00_data_fifo_AWREADY;
  assign S_AXI_bresp[1:0] = m00_couplers_to_m00_data_fifo_BRESP;
  assign S_AXI_bvalid = m00_couplers_to_m00_data_fifo_BVALID;
  assign S_AXI_rdata[31:0] = m00_couplers_to_m00_data_fifo_RDATA;
  assign S_AXI_rresp[1:0] = m00_couplers_to_m00_data_fifo_RRESP;
  assign S_AXI_rvalid = m00_couplers_to_m00_data_fifo_RVALID;
  assign S_AXI_wready = m00_couplers_to_m00_data_fifo_WREADY;
  assign m00_couplers_to_m00_data_fifo_ARADDR = S_AXI_araddr[31:0];
  assign m00_couplers_to_m00_data_fifo_ARPROT = S_AXI_arprot[2:0];
  assign m00_couplers_to_m00_data_fifo_ARVALID = S_AXI_arvalid;
  assign m00_couplers_to_m00_data_fifo_AWADDR = S_AXI_awaddr[31:0];
  assign m00_couplers_to_m00_data_fifo_AWPROT = S_AXI_awprot[2:0];
  assign m00_couplers_to_m00_data_fifo_AWVALID = S_AXI_awvalid;
  assign m00_couplers_to_m00_data_fifo_BREADY = S_AXI_bready;
  assign m00_couplers_to_m00_data_fifo_RREADY = S_AXI_rready;
  assign m00_couplers_to_m00_data_fifo_WDATA = S_AXI_wdata[31:0];
  assign m00_couplers_to_m00_data_fifo_WSTRB = S_AXI_wstrb[3:0];
  assign m00_couplers_to_m00_data_fifo_WVALID = S_AXI_wvalid;
  assign m00_data_fifo_to_m00_couplers_ARREADY = M_AXI_arready;
  assign m00_data_fifo_to_m00_couplers_AWREADY = M_AXI_awready;
  assign m00_data_fifo_to_m00_couplers_BRESP = M_AXI_bresp[1:0];
  assign m00_data_fifo_to_m00_couplers_BVALID = M_AXI_bvalid;
  assign m00_data_fifo_to_m00_couplers_RDATA = M_AXI_rdata[31:0];
  assign m00_data_fifo_to_m00_couplers_RRESP = M_AXI_rresp[1:0];
  assign m00_data_fifo_to_m00_couplers_RVALID = M_AXI_rvalid;
  assign m00_data_fifo_to_m00_couplers_WREADY = M_AXI_wready;
  top_block_m00_data_fifo_0 m00_data_fifo
       (.aclk(S_ACLK_1),
        .aresetn(S_ARESETN_1),
        .m_axi_araddr(m00_data_fifo_to_m00_couplers_ARADDR),
        .m_axi_arprot(m00_data_fifo_to_m00_couplers_ARPROT),
        .m_axi_arready(m00_data_fifo_to_m00_couplers_ARREADY),
        .m_axi_arvalid(m00_data_fifo_to_m00_couplers_ARVALID),
        .m_axi_awaddr(m00_data_fifo_to_m00_couplers_AWADDR),
        .m_axi_awprot(m00_data_fifo_to_m00_couplers_AWPROT),
        .m_axi_awready(m00_data_fifo_to_m00_couplers_AWREADY),
        .m_axi_awvalid(m00_data_fifo_to_m00_couplers_AWVALID),
        .m_axi_bready(m00_data_fifo_to_m00_couplers_BREADY),
        .m_axi_bresp(m00_data_fifo_to_m00_couplers_BRESP),
        .m_axi_bvalid(m00_data_fifo_to_m00_couplers_BVALID),
        .m_axi_rdata(m00_data_fifo_to_m00_couplers_RDATA),
        .m_axi_rready(m00_data_fifo_to_m00_couplers_RREADY),
        .m_axi_rresp(m00_data_fifo_to_m00_couplers_RRESP),
        .m_axi_rvalid(m00_data_fifo_to_m00_couplers_RVALID),
        .m_axi_wdata(m00_data_fifo_to_m00_couplers_WDATA),
        .m_axi_wready(m00_data_fifo_to_m00_couplers_WREADY),
        .m_axi_wstrb(m00_data_fifo_to_m00_couplers_WSTRB),
        .m_axi_wvalid(m00_data_fifo_to_m00_couplers_WVALID),
        .s_axi_araddr(m00_couplers_to_m00_data_fifo_ARADDR[15:0]),
        .s_axi_arprot(m00_couplers_to_m00_data_fifo_ARPROT),
        .s_axi_arready(m00_couplers_to_m00_data_fifo_ARREADY),
        .s_axi_arvalid(m00_couplers_to_m00_data_fifo_ARVALID),
        .s_axi_awaddr(m00_couplers_to_m00_data_fifo_AWADDR[15:0]),
        .s_axi_awprot(m00_couplers_to_m00_data_fifo_AWPROT),
        .s_axi_awready(m00_couplers_to_m00_data_fifo_AWREADY),
        .s_axi_awvalid(m00_couplers_to_m00_data_fifo_AWVALID),
        .s_axi_bready(m00_couplers_to_m00_data_fifo_BREADY),
        .s_axi_bresp(m00_couplers_to_m00_data_fifo_BRESP),
        .s_axi_bvalid(m00_couplers_to_m00_data_fifo_BVALID),
        .s_axi_rdata(m00_couplers_to_m00_data_fifo_RDATA),
        .s_axi_rready(m00_couplers_to_m00_data_fifo_RREADY),
        .s_axi_rresp(m00_couplers_to_m00_data_fifo_RRESP),
        .s_axi_rvalid(m00_couplers_to_m00_data_fifo_RVALID),
        .s_axi_wdata(m00_couplers_to_m00_data_fifo_WDATA),
        .s_axi_wready(m00_couplers_to_m00_data_fifo_WREADY),
        .s_axi_wstrb(m00_couplers_to_m00_data_fifo_WSTRB),
        .s_axi_wvalid(m00_couplers_to_m00_data_fifo_WVALID));
endmodule

module reg_bram_imp_WBS55O
   (S_AXI1_araddr,
    S_AXI1_arprot,
    S_AXI1_arready,
    S_AXI1_arvalid,
    S_AXI1_awaddr,
    S_AXI1_awprot,
    S_AXI1_awready,
    S_AXI1_awvalid,
    S_AXI1_bready,
    S_AXI1_bresp,
    S_AXI1_bvalid,
    S_AXI1_rdata,
    S_AXI1_rready,
    S_AXI1_rresp,
    S_AXI1_rvalid,
    S_AXI1_wdata,
    S_AXI1_wready,
    S_AXI1_wstrb,
    S_AXI1_wvalid,
    S_AXI_araddr,
    S_AXI_arprot,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awprot,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid,
    s_axi_aclk,
    s_axi_aresetn);
  input [15:0]S_AXI1_araddr;
  input [2:0]S_AXI1_arprot;
  output S_AXI1_arready;
  input S_AXI1_arvalid;
  input [15:0]S_AXI1_awaddr;
  input [2:0]S_AXI1_awprot;
  output S_AXI1_awready;
  input S_AXI1_awvalid;
  input S_AXI1_bready;
  output [1:0]S_AXI1_bresp;
  output S_AXI1_bvalid;
  output [31:0]S_AXI1_rdata;
  input S_AXI1_rready;
  output [1:0]S_AXI1_rresp;
  output S_AXI1_rvalid;
  input [31:0]S_AXI1_wdata;
  output S_AXI1_wready;
  input [3:0]S_AXI1_wstrb;
  input S_AXI1_wvalid;
  input [31:0]S_AXI_araddr;
  input [2:0]S_AXI_arprot;
  output S_AXI_arready;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [2:0]S_AXI_awprot;
  output S_AXI_awready;
  input S_AXI_awvalid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  output S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input S_AXI_wvalid;
  input s_axi_aclk;
  input s_axi_aresetn;

  wire [31:0]Conn1_ARADDR;
  wire [2:0]Conn1_ARPROT;
  wire Conn1_ARREADY;
  wire Conn1_ARVALID;
  wire [31:0]Conn1_AWADDR;
  wire [2:0]Conn1_AWPROT;
  wire Conn1_AWREADY;
  wire Conn1_AWVALID;
  wire Conn1_BREADY;
  wire [1:0]Conn1_BRESP;
  wire Conn1_BVALID;
  wire [31:0]Conn1_RDATA;
  wire Conn1_RREADY;
  wire [1:0]Conn1_RRESP;
  wire Conn1_RVALID;
  wire [31:0]Conn1_WDATA;
  wire Conn1_WREADY;
  wire [3:0]Conn1_WSTRB;
  wire Conn1_WVALID;
  wire [15:0]Conn2_ARADDR;
  wire [2:0]Conn2_ARPROT;
  wire Conn2_ARREADY;
  wire Conn2_ARVALID;
  wire [15:0]Conn2_AWADDR;
  wire [2:0]Conn2_AWPROT;
  wire Conn2_AWREADY;
  wire Conn2_AWVALID;
  wire Conn2_BREADY;
  wire [1:0]Conn2_BRESP;
  wire Conn2_BVALID;
  wire [31:0]Conn2_RDATA;
  wire Conn2_RREADY;
  wire [1:0]Conn2_RRESP;
  wire Conn2_RVALID;
  wire [31:0]Conn2_WDATA;
  wire Conn2_WREADY;
  wire [3:0]Conn2_WSTRB;
  wire Conn2_WVALID;
  wire [15:0]axi_bram_ctrl_0_BRAM_PORTA_ADDR;
  wire axi_bram_ctrl_0_BRAM_PORTA_CLK;
  wire [31:0]axi_bram_ctrl_0_BRAM_PORTA_DIN;
  wire [31:0]axi_bram_ctrl_0_BRAM_PORTA_DOUT;
  wire axi_bram_ctrl_0_BRAM_PORTA_EN;
  wire axi_bram_ctrl_0_BRAM_PORTA_RST;
  wire [3:0]axi_bram_ctrl_0_BRAM_PORTA_WE;
  wire [15:0]axi_bram_ctrl_1_BRAM_PORTA_ADDR;
  wire axi_bram_ctrl_1_BRAM_PORTA_CLK;
  wire [31:0]axi_bram_ctrl_1_BRAM_PORTA_DIN;
  wire [31:0]axi_bram_ctrl_1_BRAM_PORTA_DOUT;
  wire axi_bram_ctrl_1_BRAM_PORTA_EN;
  wire axi_bram_ctrl_1_BRAM_PORTA_RST;
  wire [3:0]axi_bram_ctrl_1_BRAM_PORTA_WE;
  wire s_axi_aclk_1;
  wire s_axi_aresetn_1;

  assign Conn1_ARADDR = S_AXI_araddr[31:0];
  assign Conn1_ARPROT = S_AXI_arprot[2:0];
  assign Conn1_ARVALID = S_AXI_arvalid;
  assign Conn1_AWADDR = S_AXI_awaddr[31:0];
  assign Conn1_AWPROT = S_AXI_awprot[2:0];
  assign Conn1_AWVALID = S_AXI_awvalid;
  assign Conn1_BREADY = S_AXI_bready;
  assign Conn1_RREADY = S_AXI_rready;
  assign Conn1_WDATA = S_AXI_wdata[31:0];
  assign Conn1_WSTRB = S_AXI_wstrb[3:0];
  assign Conn1_WVALID = S_AXI_wvalid;
  assign Conn2_ARADDR = S_AXI1_araddr[15:0];
  assign Conn2_ARPROT = S_AXI1_arprot[2:0];
  assign Conn2_ARVALID = S_AXI1_arvalid;
  assign Conn2_AWADDR = S_AXI1_awaddr[15:0];
  assign Conn2_AWPROT = S_AXI1_awprot[2:0];
  assign Conn2_AWVALID = S_AXI1_awvalid;
  assign Conn2_BREADY = S_AXI1_bready;
  assign Conn2_RREADY = S_AXI1_rready;
  assign Conn2_WDATA = S_AXI1_wdata[31:0];
  assign Conn2_WSTRB = S_AXI1_wstrb[3:0];
  assign Conn2_WVALID = S_AXI1_wvalid;
  assign S_AXI1_arready = Conn2_ARREADY;
  assign S_AXI1_awready = Conn2_AWREADY;
  assign S_AXI1_bresp[1:0] = Conn2_BRESP;
  assign S_AXI1_bvalid = Conn2_BVALID;
  assign S_AXI1_rdata[31:0] = Conn2_RDATA;
  assign S_AXI1_rresp[1:0] = Conn2_RRESP;
  assign S_AXI1_rvalid = Conn2_RVALID;
  assign S_AXI1_wready = Conn2_WREADY;
  assign S_AXI_arready = Conn1_ARREADY;
  assign S_AXI_awready = Conn1_AWREADY;
  assign S_AXI_bresp[1:0] = Conn1_BRESP;
  assign S_AXI_bvalid = Conn1_BVALID;
  assign S_AXI_rdata[31:0] = Conn1_RDATA;
  assign S_AXI_rresp[1:0] = Conn1_RRESP;
  assign S_AXI_rvalid = Conn1_RVALID;
  assign S_AXI_wready = Conn1_WREADY;
  assign s_axi_aclk_1 = s_axi_aclk;
  assign s_axi_aresetn_1 = s_axi_aresetn;
  top_block_axi_bram_ctrl_0_0 axi_bram_ctrl_0
       (.bram_addr_a(axi_bram_ctrl_0_BRAM_PORTA_ADDR),
        .bram_clk_a(axi_bram_ctrl_0_BRAM_PORTA_CLK),
        .bram_en_a(axi_bram_ctrl_0_BRAM_PORTA_EN),
        .bram_rddata_a(axi_bram_ctrl_0_BRAM_PORTA_DOUT),
        .bram_rst_a(axi_bram_ctrl_0_BRAM_PORTA_RST),
        .bram_we_a(axi_bram_ctrl_0_BRAM_PORTA_WE),
        .bram_wrdata_a(axi_bram_ctrl_0_BRAM_PORTA_DIN),
        .s_axi_aclk(s_axi_aclk_1),
        .s_axi_araddr(Conn1_ARADDR[15:0]),
        .s_axi_aresetn(s_axi_aresetn_1),
        .s_axi_arprot(Conn1_ARPROT),
        .s_axi_arready(Conn1_ARREADY),
        .s_axi_arvalid(Conn1_ARVALID),
        .s_axi_awaddr(Conn1_AWADDR[15:0]),
        .s_axi_awprot(Conn1_AWPROT),
        .s_axi_awready(Conn1_AWREADY),
        .s_axi_awvalid(Conn1_AWVALID),
        .s_axi_bready(Conn1_BREADY),
        .s_axi_bresp(Conn1_BRESP),
        .s_axi_bvalid(Conn1_BVALID),
        .s_axi_rdata(Conn1_RDATA),
        .s_axi_rready(Conn1_RREADY),
        .s_axi_rresp(Conn1_RRESP),
        .s_axi_rvalid(Conn1_RVALID),
        .s_axi_wdata(Conn1_WDATA),
        .s_axi_wready(Conn1_WREADY),
        .s_axi_wstrb(Conn1_WSTRB),
        .s_axi_wvalid(Conn1_WVALID));
  top_block_axi_bram_ctrl_1_0 axi_bram_ctrl_1
       (.bram_addr_a(axi_bram_ctrl_1_BRAM_PORTA_ADDR),
        .bram_clk_a(axi_bram_ctrl_1_BRAM_PORTA_CLK),
        .bram_en_a(axi_bram_ctrl_1_BRAM_PORTA_EN),
        .bram_rddata_a(axi_bram_ctrl_1_BRAM_PORTA_DOUT),
        .bram_rst_a(axi_bram_ctrl_1_BRAM_PORTA_RST),
        .bram_we_a(axi_bram_ctrl_1_BRAM_PORTA_WE),
        .bram_wrdata_a(axi_bram_ctrl_1_BRAM_PORTA_DIN),
        .s_axi_aclk(s_axi_aclk_1),
        .s_axi_araddr(Conn2_ARADDR),
        .s_axi_aresetn(s_axi_aresetn_1),
        .s_axi_arprot(Conn2_ARPROT),
        .s_axi_arready(Conn2_ARREADY),
        .s_axi_arvalid(Conn2_ARVALID),
        .s_axi_awaddr(Conn2_AWADDR),
        .s_axi_awprot(Conn2_AWPROT),
        .s_axi_awready(Conn2_AWREADY),
        .s_axi_awvalid(Conn2_AWVALID),
        .s_axi_bready(Conn2_BREADY),
        .s_axi_bresp(Conn2_BRESP),
        .s_axi_bvalid(Conn2_BVALID),
        .s_axi_rdata(Conn2_RDATA),
        .s_axi_rready(Conn2_RREADY),
        .s_axi_rresp(Conn2_RRESP),
        .s_axi_rvalid(Conn2_RVALID),
        .s_axi_wdata(Conn2_WDATA),
        .s_axi_wready(Conn2_WREADY),
        .s_axi_wstrb(Conn2_WSTRB),
        .s_axi_wvalid(Conn2_WVALID));
  top_block_blk_mem_gen_0_0 blk_mem_gen_0
       (.addra({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,axi_bram_ctrl_0_BRAM_PORTA_ADDR}),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,axi_bram_ctrl_1_BRAM_PORTA_ADDR}),
        .clka(axi_bram_ctrl_0_BRAM_PORTA_CLK),
        .clkb(axi_bram_ctrl_1_BRAM_PORTA_CLK),
        .dina(axi_bram_ctrl_0_BRAM_PORTA_DIN),
        .dinb(axi_bram_ctrl_1_BRAM_PORTA_DIN),
        .douta(axi_bram_ctrl_0_BRAM_PORTA_DOUT),
        .doutb(axi_bram_ctrl_1_BRAM_PORTA_DOUT),
        .ena(axi_bram_ctrl_0_BRAM_PORTA_EN),
        .enb(axi_bram_ctrl_1_BRAM_PORTA_EN),
        .rsta(axi_bram_ctrl_0_BRAM_PORTA_RST),
        .rstb(axi_bram_ctrl_1_BRAM_PORTA_RST),
        .wea(axi_bram_ctrl_0_BRAM_PORTA_WE),
        .web(axi_bram_ctrl_1_BRAM_PORTA_WE));
endmodule

module reset_imp_UQ2QSL
   (RST,
    dest_clk,
    dest_clk1,
    ext_reset_in,
    peripheral_aresetn,
    peripheral_aresetn1,
    peripheral_aresetn2,
    peripheral_aresetn3,
    peripheral_aresetn4,
    probe_out0,
    slowest_sync_clk,
    slowest_sync_clk1);
  input RST;
  input dest_clk;
  input dest_clk1;
  input ext_reset_in;
  output [0:0]peripheral_aresetn;
  output [0:0]peripheral_aresetn1;
  output [0:0]peripheral_aresetn2;
  output [0:0]peripheral_aresetn3;
  output [0:0]peripheral_aresetn4;
  output [0:0]probe_out0;
  input slowest_sync_clk;
  input slowest_sync_clk1;

  wire RST_1;
  wire dest_clk1_1;
  wire dest_clk_1;
  wire ext_reset_in_1;
  wire [0:0]rst_clk_wiz_0_125M1_peripheral_aresetn;
  wire [0:0]rst_clk_wiz_0_125M_peripheral_aresetn;
  wire [0:0]rst_clk_wiz_0_300M2_peripheral_aresetn;
  wire [0:0]rst_clk_wiz_1_320M1_peripheral_aresetn;
  wire [0:0]rst_clk_wiz_1_320M_peripheral_aresetn;
  wire slowest_sync_clk1_1;
  wire slowest_sync_clk_1;
  wire [0:0]vio_0_probe_out0;
  wire xpm_cdc_gen_0_dest_arst;
  wire xpm_cdc_gen_1_dest_arst;
  wire xpm_cdc_gen_2_dest_arst;
  wire xpm_cdc_gen_3_dest_arst;

  assign RST_1 = RST;
  assign dest_clk1_1 = dest_clk1;
  assign dest_clk_1 = dest_clk;
  assign ext_reset_in_1 = ext_reset_in;
  assign peripheral_aresetn[0] = rst_clk_wiz_0_125M_peripheral_aresetn;
  assign peripheral_aresetn1[0] = rst_clk_wiz_1_320M_peripheral_aresetn;
  assign peripheral_aresetn2[0] = rst_clk_wiz_1_320M1_peripheral_aresetn;
  assign peripheral_aresetn3[0] = rst_clk_wiz_0_125M1_peripheral_aresetn;
  assign peripheral_aresetn4[0] = rst_clk_wiz_0_300M2_peripheral_aresetn;
  assign probe_out0[0] = vio_0_probe_out0;
  assign slowest_sync_clk1_1 = slowest_sync_clk1;
  assign slowest_sync_clk_1 = slowest_sync_clk;
  top_block_rst_clk_wiz_0_125M_0 rst_clk_wiz_0_125M
       (.aux_reset_in(1'b1),
        .dcm_locked(1'b1),
        .ext_reset_in(xpm_cdc_gen_0_dest_arst),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(rst_clk_wiz_0_125M_peripheral_aresetn),
        .slowest_sync_clk(slowest_sync_clk_1));
  top_block_rst_clk_wiz_0_125M_1 rst_clk_wiz_0_300M1
       (.aux_reset_in(1'b1),
        .dcm_locked(1'b1),
        .ext_reset_in(xpm_cdc_gen_2_dest_arst),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(rst_clk_wiz_0_125M1_peripheral_aresetn),
        .slowest_sync_clk(dest_clk_1));
  top_block_rst_clk_wiz_0_300M1_0 rst_clk_wiz_0_300M2
       (.aux_reset_in(1'b1),
        .dcm_locked(1'b1),
        .ext_reset_in(xpm_cdc_gen_3_dest_arst),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(rst_clk_wiz_0_300M2_peripheral_aresetn),
        .slowest_sync_clk(dest_clk1_1));
  top_block_rst_clk_wiz_1_320M_0 rst_clk_wiz_1_320M
       (.aux_reset_in(1'b1),
        .dcm_locked(1'b1),
        .ext_reset_in(ext_reset_in_1),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(rst_clk_wiz_1_320M_peripheral_aresetn),
        .slowest_sync_clk(slowest_sync_clk1_1));
  top_block_rst_clk_wiz_1_320M_1 rst_clk_wiz_1_320M1
       (.aux_reset_in(1'b1),
        .dcm_locked(1'b1),
        .ext_reset_in(xpm_cdc_gen_1_dest_arst),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(rst_clk_wiz_1_320M1_peripheral_aresetn),
        .slowest_sync_clk(slowest_sync_clk1_1));
  top_block_vio_0_0 vio_0
       (.clk(slowest_sync_clk_1),
        .probe_out0(vio_0_probe_out0));
  top_block_xpm_cdc_gen_0_0 xpm_cdc_gen_0
       (.dest_arst(xpm_cdc_gen_0_dest_arst),
        .dest_clk(slowest_sync_clk_1),
        .src_arst(RST_1));
  top_block_xpm_cdc_gen_0_2 xpm_cdc_gen_1
       (.dest_arst(xpm_cdc_gen_1_dest_arst),
        .dest_clk(slowest_sync_clk1_1),
        .src_arst(RST_1));
  top_block_xpm_cdc_gen_0_3 xpm_cdc_gen_2
       (.dest_arst(xpm_cdc_gen_2_dest_arst),
        .dest_clk(dest_clk_1),
        .src_arst(RST_1));
  top_block_xpm_cdc_gen_2_0 xpm_cdc_gen_3
       (.dest_arst(xpm_cdc_gen_3_dest_arst),
        .dest_clk(dest_clk1_1),
        .src_arst(RST_1));
endmodule

module s00_couplers_imp_1LGP333
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arprot,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awprot,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arprot,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awprot,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [2:0]M_AXI_arprot;
  input [0:0]M_AXI_arready;
  output [0:0]M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [2:0]M_AXI_awprot;
  input [0:0]M_AXI_awready;
  output [0:0]M_AXI_awvalid;
  output [0:0]M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input [0:0]M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output [0:0]M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input [0:0]M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input [0:0]M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output [0:0]M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [2:0]S_AXI_arprot;
  output [0:0]S_AXI_arready;
  input [0:0]S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [2:0]S_AXI_awprot;
  output [0:0]S_AXI_awready;
  input [0:0]S_AXI_awvalid;
  input [0:0]S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output [0:0]S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input [0:0]S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output [0:0]S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  output [0:0]S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input [0:0]S_AXI_wvalid;

  wire [31:0]s00_couplers_to_s00_couplers_ARADDR;
  wire [2:0]s00_couplers_to_s00_couplers_ARPROT;
  wire [0:0]s00_couplers_to_s00_couplers_ARREADY;
  wire [0:0]s00_couplers_to_s00_couplers_ARVALID;
  wire [31:0]s00_couplers_to_s00_couplers_AWADDR;
  wire [2:0]s00_couplers_to_s00_couplers_AWPROT;
  wire [0:0]s00_couplers_to_s00_couplers_AWREADY;
  wire [0:0]s00_couplers_to_s00_couplers_AWVALID;
  wire [0:0]s00_couplers_to_s00_couplers_BREADY;
  wire [1:0]s00_couplers_to_s00_couplers_BRESP;
  wire [0:0]s00_couplers_to_s00_couplers_BVALID;
  wire [31:0]s00_couplers_to_s00_couplers_RDATA;
  wire [0:0]s00_couplers_to_s00_couplers_RREADY;
  wire [1:0]s00_couplers_to_s00_couplers_RRESP;
  wire [0:0]s00_couplers_to_s00_couplers_RVALID;
  wire [31:0]s00_couplers_to_s00_couplers_WDATA;
  wire [0:0]s00_couplers_to_s00_couplers_WREADY;
  wire [3:0]s00_couplers_to_s00_couplers_WSTRB;
  wire [0:0]s00_couplers_to_s00_couplers_WVALID;

  assign M_AXI_araddr[31:0] = s00_couplers_to_s00_couplers_ARADDR;
  assign M_AXI_arprot[2:0] = s00_couplers_to_s00_couplers_ARPROT;
  assign M_AXI_arvalid[0] = s00_couplers_to_s00_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = s00_couplers_to_s00_couplers_AWADDR;
  assign M_AXI_awprot[2:0] = s00_couplers_to_s00_couplers_AWPROT;
  assign M_AXI_awvalid[0] = s00_couplers_to_s00_couplers_AWVALID;
  assign M_AXI_bready[0] = s00_couplers_to_s00_couplers_BREADY;
  assign M_AXI_rready[0] = s00_couplers_to_s00_couplers_RREADY;
  assign M_AXI_wdata[31:0] = s00_couplers_to_s00_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = s00_couplers_to_s00_couplers_WSTRB;
  assign M_AXI_wvalid[0] = s00_couplers_to_s00_couplers_WVALID;
  assign S_AXI_arready[0] = s00_couplers_to_s00_couplers_ARREADY;
  assign S_AXI_awready[0] = s00_couplers_to_s00_couplers_AWREADY;
  assign S_AXI_bresp[1:0] = s00_couplers_to_s00_couplers_BRESP;
  assign S_AXI_bvalid[0] = s00_couplers_to_s00_couplers_BVALID;
  assign S_AXI_rdata[31:0] = s00_couplers_to_s00_couplers_RDATA;
  assign S_AXI_rresp[1:0] = s00_couplers_to_s00_couplers_RRESP;
  assign S_AXI_rvalid[0] = s00_couplers_to_s00_couplers_RVALID;
  assign S_AXI_wready[0] = s00_couplers_to_s00_couplers_WREADY;
  assign s00_couplers_to_s00_couplers_ARADDR = S_AXI_araddr[31:0];
  assign s00_couplers_to_s00_couplers_ARPROT = S_AXI_arprot[2:0];
  assign s00_couplers_to_s00_couplers_ARREADY = M_AXI_arready[0];
  assign s00_couplers_to_s00_couplers_ARVALID = S_AXI_arvalid[0];
  assign s00_couplers_to_s00_couplers_AWADDR = S_AXI_awaddr[31:0];
  assign s00_couplers_to_s00_couplers_AWPROT = S_AXI_awprot[2:0];
  assign s00_couplers_to_s00_couplers_AWREADY = M_AXI_awready[0];
  assign s00_couplers_to_s00_couplers_AWVALID = S_AXI_awvalid[0];
  assign s00_couplers_to_s00_couplers_BREADY = S_AXI_bready[0];
  assign s00_couplers_to_s00_couplers_BRESP = M_AXI_bresp[1:0];
  assign s00_couplers_to_s00_couplers_BVALID = M_AXI_bvalid[0];
  assign s00_couplers_to_s00_couplers_RDATA = M_AXI_rdata[31:0];
  assign s00_couplers_to_s00_couplers_RREADY = S_AXI_rready[0];
  assign s00_couplers_to_s00_couplers_RRESP = M_AXI_rresp[1:0];
  assign s00_couplers_to_s00_couplers_RVALID = M_AXI_rvalid[0];
  assign s00_couplers_to_s00_couplers_WDATA = S_AXI_wdata[31:0];
  assign s00_couplers_to_s00_couplers_WREADY = M_AXI_wready[0];
  assign s00_couplers_to_s00_couplers_WSTRB = S_AXI_wstrb[3:0];
  assign s00_couplers_to_s00_couplers_WVALID = S_AXI_wvalid[0];
endmodule

module s01_couplers_imp_6XFXC7
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arprot,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awprot,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arprot,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awprot,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [2:0]M_AXI_arprot;
  input [0:0]M_AXI_arready;
  output [0:0]M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [2:0]M_AXI_awprot;
  input [0:0]M_AXI_awready;
  output [0:0]M_AXI_awvalid;
  output [0:0]M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input [0:0]M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output [0:0]M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input [0:0]M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input [0:0]M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output [0:0]M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [2:0]S_AXI_arprot;
  output [0:0]S_AXI_arready;
  input [0:0]S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [2:0]S_AXI_awprot;
  output [0:0]S_AXI_awready;
  input [0:0]S_AXI_awvalid;
  input [0:0]S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output [0:0]S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input [0:0]S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output [0:0]S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  output [0:0]S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input [0:0]S_AXI_wvalid;

  wire [31:0]s01_couplers_to_s01_couplers_ARADDR;
  wire [2:0]s01_couplers_to_s01_couplers_ARPROT;
  wire [0:0]s01_couplers_to_s01_couplers_ARREADY;
  wire [0:0]s01_couplers_to_s01_couplers_ARVALID;
  wire [31:0]s01_couplers_to_s01_couplers_AWADDR;
  wire [2:0]s01_couplers_to_s01_couplers_AWPROT;
  wire [0:0]s01_couplers_to_s01_couplers_AWREADY;
  wire [0:0]s01_couplers_to_s01_couplers_AWVALID;
  wire [0:0]s01_couplers_to_s01_couplers_BREADY;
  wire [1:0]s01_couplers_to_s01_couplers_BRESP;
  wire [0:0]s01_couplers_to_s01_couplers_BVALID;
  wire [31:0]s01_couplers_to_s01_couplers_RDATA;
  wire [0:0]s01_couplers_to_s01_couplers_RREADY;
  wire [1:0]s01_couplers_to_s01_couplers_RRESP;
  wire [0:0]s01_couplers_to_s01_couplers_RVALID;
  wire [31:0]s01_couplers_to_s01_couplers_WDATA;
  wire [0:0]s01_couplers_to_s01_couplers_WREADY;
  wire [3:0]s01_couplers_to_s01_couplers_WSTRB;
  wire [0:0]s01_couplers_to_s01_couplers_WVALID;

  assign M_AXI_araddr[31:0] = s01_couplers_to_s01_couplers_ARADDR;
  assign M_AXI_arprot[2:0] = s01_couplers_to_s01_couplers_ARPROT;
  assign M_AXI_arvalid[0] = s01_couplers_to_s01_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = s01_couplers_to_s01_couplers_AWADDR;
  assign M_AXI_awprot[2:0] = s01_couplers_to_s01_couplers_AWPROT;
  assign M_AXI_awvalid[0] = s01_couplers_to_s01_couplers_AWVALID;
  assign M_AXI_bready[0] = s01_couplers_to_s01_couplers_BREADY;
  assign M_AXI_rready[0] = s01_couplers_to_s01_couplers_RREADY;
  assign M_AXI_wdata[31:0] = s01_couplers_to_s01_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = s01_couplers_to_s01_couplers_WSTRB;
  assign M_AXI_wvalid[0] = s01_couplers_to_s01_couplers_WVALID;
  assign S_AXI_arready[0] = s01_couplers_to_s01_couplers_ARREADY;
  assign S_AXI_awready[0] = s01_couplers_to_s01_couplers_AWREADY;
  assign S_AXI_bresp[1:0] = s01_couplers_to_s01_couplers_BRESP;
  assign S_AXI_bvalid[0] = s01_couplers_to_s01_couplers_BVALID;
  assign S_AXI_rdata[31:0] = s01_couplers_to_s01_couplers_RDATA;
  assign S_AXI_rresp[1:0] = s01_couplers_to_s01_couplers_RRESP;
  assign S_AXI_rvalid[0] = s01_couplers_to_s01_couplers_RVALID;
  assign S_AXI_wready[0] = s01_couplers_to_s01_couplers_WREADY;
  assign s01_couplers_to_s01_couplers_ARADDR = S_AXI_araddr[31:0];
  assign s01_couplers_to_s01_couplers_ARPROT = S_AXI_arprot[2:0];
  assign s01_couplers_to_s01_couplers_ARREADY = M_AXI_arready[0];
  assign s01_couplers_to_s01_couplers_ARVALID = S_AXI_arvalid[0];
  assign s01_couplers_to_s01_couplers_AWADDR = S_AXI_awaddr[31:0];
  assign s01_couplers_to_s01_couplers_AWPROT = S_AXI_awprot[2:0];
  assign s01_couplers_to_s01_couplers_AWREADY = M_AXI_awready[0];
  assign s01_couplers_to_s01_couplers_AWVALID = S_AXI_awvalid[0];
  assign s01_couplers_to_s01_couplers_BREADY = S_AXI_bready[0];
  assign s01_couplers_to_s01_couplers_BRESP = M_AXI_bresp[1:0];
  assign s01_couplers_to_s01_couplers_BVALID = M_AXI_bvalid[0];
  assign s01_couplers_to_s01_couplers_RDATA = M_AXI_rdata[31:0];
  assign s01_couplers_to_s01_couplers_RREADY = S_AXI_rready[0];
  assign s01_couplers_to_s01_couplers_RRESP = M_AXI_rresp[1:0];
  assign s01_couplers_to_s01_couplers_RVALID = M_AXI_rvalid[0];
  assign s01_couplers_to_s01_couplers_WDATA = S_AXI_wdata[31:0];
  assign s01_couplers_to_s01_couplers_WREADY = M_AXI_wready[0];
  assign s01_couplers_to_s01_couplers_WSTRB = S_AXI_wstrb[3:0];
  assign s01_couplers_to_s01_couplers_WVALID = S_AXI_wvalid[0];
endmodule

module s02_couplers_imp_1G2P25Q
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arprot,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awprot,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arprot,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awprot,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [2:0]M_AXI_arprot;
  input [0:0]M_AXI_arready;
  output [0:0]M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [2:0]M_AXI_awprot;
  input [0:0]M_AXI_awready;
  output [0:0]M_AXI_awvalid;
  output [0:0]M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input [0:0]M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output [0:0]M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input [0:0]M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input [0:0]M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output [0:0]M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [2:0]S_AXI_arprot;
  output [0:0]S_AXI_arready;
  input [0:0]S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [2:0]S_AXI_awprot;
  output [0:0]S_AXI_awready;
  input [0:0]S_AXI_awvalid;
  input [0:0]S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output [0:0]S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input [0:0]S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output [0:0]S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  output [0:0]S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input [0:0]S_AXI_wvalid;

  wire [31:0]s02_couplers_to_s02_couplers_ARADDR;
  wire [2:0]s02_couplers_to_s02_couplers_ARPROT;
  wire [0:0]s02_couplers_to_s02_couplers_ARREADY;
  wire [0:0]s02_couplers_to_s02_couplers_ARVALID;
  wire [31:0]s02_couplers_to_s02_couplers_AWADDR;
  wire [2:0]s02_couplers_to_s02_couplers_AWPROT;
  wire [0:0]s02_couplers_to_s02_couplers_AWREADY;
  wire [0:0]s02_couplers_to_s02_couplers_AWVALID;
  wire [0:0]s02_couplers_to_s02_couplers_BREADY;
  wire [1:0]s02_couplers_to_s02_couplers_BRESP;
  wire [0:0]s02_couplers_to_s02_couplers_BVALID;
  wire [31:0]s02_couplers_to_s02_couplers_RDATA;
  wire [0:0]s02_couplers_to_s02_couplers_RREADY;
  wire [1:0]s02_couplers_to_s02_couplers_RRESP;
  wire [0:0]s02_couplers_to_s02_couplers_RVALID;
  wire [31:0]s02_couplers_to_s02_couplers_WDATA;
  wire [0:0]s02_couplers_to_s02_couplers_WREADY;
  wire [3:0]s02_couplers_to_s02_couplers_WSTRB;
  wire [0:0]s02_couplers_to_s02_couplers_WVALID;

  assign M_AXI_araddr[31:0] = s02_couplers_to_s02_couplers_ARADDR;
  assign M_AXI_arprot[2:0] = s02_couplers_to_s02_couplers_ARPROT;
  assign M_AXI_arvalid[0] = s02_couplers_to_s02_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = s02_couplers_to_s02_couplers_AWADDR;
  assign M_AXI_awprot[2:0] = s02_couplers_to_s02_couplers_AWPROT;
  assign M_AXI_awvalid[0] = s02_couplers_to_s02_couplers_AWVALID;
  assign M_AXI_bready[0] = s02_couplers_to_s02_couplers_BREADY;
  assign M_AXI_rready[0] = s02_couplers_to_s02_couplers_RREADY;
  assign M_AXI_wdata[31:0] = s02_couplers_to_s02_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = s02_couplers_to_s02_couplers_WSTRB;
  assign M_AXI_wvalid[0] = s02_couplers_to_s02_couplers_WVALID;
  assign S_AXI_arready[0] = s02_couplers_to_s02_couplers_ARREADY;
  assign S_AXI_awready[0] = s02_couplers_to_s02_couplers_AWREADY;
  assign S_AXI_bresp[1:0] = s02_couplers_to_s02_couplers_BRESP;
  assign S_AXI_bvalid[0] = s02_couplers_to_s02_couplers_BVALID;
  assign S_AXI_rdata[31:0] = s02_couplers_to_s02_couplers_RDATA;
  assign S_AXI_rresp[1:0] = s02_couplers_to_s02_couplers_RRESP;
  assign S_AXI_rvalid[0] = s02_couplers_to_s02_couplers_RVALID;
  assign S_AXI_wready[0] = s02_couplers_to_s02_couplers_WREADY;
  assign s02_couplers_to_s02_couplers_ARADDR = S_AXI_araddr[31:0];
  assign s02_couplers_to_s02_couplers_ARPROT = S_AXI_arprot[2:0];
  assign s02_couplers_to_s02_couplers_ARREADY = M_AXI_arready[0];
  assign s02_couplers_to_s02_couplers_ARVALID = S_AXI_arvalid[0];
  assign s02_couplers_to_s02_couplers_AWADDR = S_AXI_awaddr[31:0];
  assign s02_couplers_to_s02_couplers_AWPROT = S_AXI_awprot[2:0];
  assign s02_couplers_to_s02_couplers_AWREADY = M_AXI_awready[0];
  assign s02_couplers_to_s02_couplers_AWVALID = S_AXI_awvalid[0];
  assign s02_couplers_to_s02_couplers_BREADY = S_AXI_bready[0];
  assign s02_couplers_to_s02_couplers_BRESP = M_AXI_bresp[1:0];
  assign s02_couplers_to_s02_couplers_BVALID = M_AXI_bvalid[0];
  assign s02_couplers_to_s02_couplers_RDATA = M_AXI_rdata[31:0];
  assign s02_couplers_to_s02_couplers_RREADY = S_AXI_rready[0];
  assign s02_couplers_to_s02_couplers_RRESP = M_AXI_rresp[1:0];
  assign s02_couplers_to_s02_couplers_RVALID = M_AXI_rvalid[0];
  assign s02_couplers_to_s02_couplers_WDATA = S_AXI_wdata[31:0];
  assign s02_couplers_to_s02_couplers_WREADY = M_AXI_wready[0];
  assign s02_couplers_to_s02_couplers_WSTRB = S_AXI_wstrb[3:0];
  assign s02_couplers_to_s02_couplers_WVALID = S_AXI_wvalid[0];
endmodule

module s03_couplers_imp_U1S6LY
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arprot,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awprot,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arprot,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awprot,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [2:0]M_AXI_arprot;
  input M_AXI_arready;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [2:0]M_AXI_awprot;
  input M_AXI_awready;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [2:0]S_AXI_arprot;
  output S_AXI_arready;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [2:0]S_AXI_awprot;
  output S_AXI_awready;
  input S_AXI_awvalid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  output S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input S_AXI_wvalid;

  wire [31:0]s03_couplers_to_s03_couplers_ARADDR;
  wire [2:0]s03_couplers_to_s03_couplers_ARPROT;
  wire s03_couplers_to_s03_couplers_ARREADY;
  wire s03_couplers_to_s03_couplers_ARVALID;
  wire [31:0]s03_couplers_to_s03_couplers_AWADDR;
  wire [2:0]s03_couplers_to_s03_couplers_AWPROT;
  wire s03_couplers_to_s03_couplers_AWREADY;
  wire s03_couplers_to_s03_couplers_AWVALID;
  wire s03_couplers_to_s03_couplers_BREADY;
  wire [1:0]s03_couplers_to_s03_couplers_BRESP;
  wire s03_couplers_to_s03_couplers_BVALID;
  wire [31:0]s03_couplers_to_s03_couplers_RDATA;
  wire s03_couplers_to_s03_couplers_RREADY;
  wire [1:0]s03_couplers_to_s03_couplers_RRESP;
  wire s03_couplers_to_s03_couplers_RVALID;
  wire [31:0]s03_couplers_to_s03_couplers_WDATA;
  wire s03_couplers_to_s03_couplers_WREADY;
  wire [3:0]s03_couplers_to_s03_couplers_WSTRB;
  wire s03_couplers_to_s03_couplers_WVALID;

  assign M_AXI_araddr[31:0] = s03_couplers_to_s03_couplers_ARADDR;
  assign M_AXI_arprot[2:0] = s03_couplers_to_s03_couplers_ARPROT;
  assign M_AXI_arvalid = s03_couplers_to_s03_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = s03_couplers_to_s03_couplers_AWADDR;
  assign M_AXI_awprot[2:0] = s03_couplers_to_s03_couplers_AWPROT;
  assign M_AXI_awvalid = s03_couplers_to_s03_couplers_AWVALID;
  assign M_AXI_bready = s03_couplers_to_s03_couplers_BREADY;
  assign M_AXI_rready = s03_couplers_to_s03_couplers_RREADY;
  assign M_AXI_wdata[31:0] = s03_couplers_to_s03_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = s03_couplers_to_s03_couplers_WSTRB;
  assign M_AXI_wvalid = s03_couplers_to_s03_couplers_WVALID;
  assign S_AXI_arready = s03_couplers_to_s03_couplers_ARREADY;
  assign S_AXI_awready = s03_couplers_to_s03_couplers_AWREADY;
  assign S_AXI_bresp[1:0] = s03_couplers_to_s03_couplers_BRESP;
  assign S_AXI_bvalid = s03_couplers_to_s03_couplers_BVALID;
  assign S_AXI_rdata[31:0] = s03_couplers_to_s03_couplers_RDATA;
  assign S_AXI_rresp[1:0] = s03_couplers_to_s03_couplers_RRESP;
  assign S_AXI_rvalid = s03_couplers_to_s03_couplers_RVALID;
  assign S_AXI_wready = s03_couplers_to_s03_couplers_WREADY;
  assign s03_couplers_to_s03_couplers_ARADDR = S_AXI_araddr[31:0];
  assign s03_couplers_to_s03_couplers_ARPROT = S_AXI_arprot[2:0];
  assign s03_couplers_to_s03_couplers_ARREADY = M_AXI_arready;
  assign s03_couplers_to_s03_couplers_ARVALID = S_AXI_arvalid;
  assign s03_couplers_to_s03_couplers_AWADDR = S_AXI_awaddr[31:0];
  assign s03_couplers_to_s03_couplers_AWPROT = S_AXI_awprot[2:0];
  assign s03_couplers_to_s03_couplers_AWREADY = M_AXI_awready;
  assign s03_couplers_to_s03_couplers_AWVALID = S_AXI_awvalid;
  assign s03_couplers_to_s03_couplers_BREADY = S_AXI_bready;
  assign s03_couplers_to_s03_couplers_BRESP = M_AXI_bresp[1:0];
  assign s03_couplers_to_s03_couplers_BVALID = M_AXI_bvalid;
  assign s03_couplers_to_s03_couplers_RDATA = M_AXI_rdata[31:0];
  assign s03_couplers_to_s03_couplers_RREADY = S_AXI_rready;
  assign s03_couplers_to_s03_couplers_RRESP = M_AXI_rresp[1:0];
  assign s03_couplers_to_s03_couplers_RVALID = M_AXI_rvalid;
  assign s03_couplers_to_s03_couplers_WDATA = S_AXI_wdata[31:0];
  assign s03_couplers_to_s03_couplers_WREADY = M_AXI_wready;
  assign s03_couplers_to_s03_couplers_WSTRB = S_AXI_wstrb[3:0];
  assign s03_couplers_to_s03_couplers_WVALID = S_AXI_wvalid;
endmodule

module s04_couplers_imp_AO18OT
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arprot,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awprot,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arprot,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awprot,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [2:0]M_AXI_arprot;
  input [0:0]M_AXI_arready;
  output [0:0]M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [2:0]M_AXI_awprot;
  input [0:0]M_AXI_awready;
  output [0:0]M_AXI_awvalid;
  output [0:0]M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input [0:0]M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output [0:0]M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input [0:0]M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input [0:0]M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output [0:0]M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [2:0]S_AXI_arprot;
  output [0:0]S_AXI_arready;
  input [0:0]S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [2:0]S_AXI_awprot;
  output [0:0]S_AXI_awready;
  input [0:0]S_AXI_awvalid;
  input [0:0]S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output [0:0]S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input [0:0]S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output [0:0]S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  output [0:0]S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input [0:0]S_AXI_wvalid;

  wire [31:0]s04_couplers_to_s04_couplers_ARADDR;
  wire [2:0]s04_couplers_to_s04_couplers_ARPROT;
  wire [0:0]s04_couplers_to_s04_couplers_ARREADY;
  wire [0:0]s04_couplers_to_s04_couplers_ARVALID;
  wire [31:0]s04_couplers_to_s04_couplers_AWADDR;
  wire [2:0]s04_couplers_to_s04_couplers_AWPROT;
  wire [0:0]s04_couplers_to_s04_couplers_AWREADY;
  wire [0:0]s04_couplers_to_s04_couplers_AWVALID;
  wire [0:0]s04_couplers_to_s04_couplers_BREADY;
  wire [1:0]s04_couplers_to_s04_couplers_BRESP;
  wire [0:0]s04_couplers_to_s04_couplers_BVALID;
  wire [31:0]s04_couplers_to_s04_couplers_RDATA;
  wire [0:0]s04_couplers_to_s04_couplers_RREADY;
  wire [1:0]s04_couplers_to_s04_couplers_RRESP;
  wire [0:0]s04_couplers_to_s04_couplers_RVALID;
  wire [31:0]s04_couplers_to_s04_couplers_WDATA;
  wire [0:0]s04_couplers_to_s04_couplers_WREADY;
  wire [3:0]s04_couplers_to_s04_couplers_WSTRB;
  wire [0:0]s04_couplers_to_s04_couplers_WVALID;

  assign M_AXI_araddr[31:0] = s04_couplers_to_s04_couplers_ARADDR;
  assign M_AXI_arprot[2:0] = s04_couplers_to_s04_couplers_ARPROT;
  assign M_AXI_arvalid[0] = s04_couplers_to_s04_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = s04_couplers_to_s04_couplers_AWADDR;
  assign M_AXI_awprot[2:0] = s04_couplers_to_s04_couplers_AWPROT;
  assign M_AXI_awvalid[0] = s04_couplers_to_s04_couplers_AWVALID;
  assign M_AXI_bready[0] = s04_couplers_to_s04_couplers_BREADY;
  assign M_AXI_rready[0] = s04_couplers_to_s04_couplers_RREADY;
  assign M_AXI_wdata[31:0] = s04_couplers_to_s04_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = s04_couplers_to_s04_couplers_WSTRB;
  assign M_AXI_wvalid[0] = s04_couplers_to_s04_couplers_WVALID;
  assign S_AXI_arready[0] = s04_couplers_to_s04_couplers_ARREADY;
  assign S_AXI_awready[0] = s04_couplers_to_s04_couplers_AWREADY;
  assign S_AXI_bresp[1:0] = s04_couplers_to_s04_couplers_BRESP;
  assign S_AXI_bvalid[0] = s04_couplers_to_s04_couplers_BVALID;
  assign S_AXI_rdata[31:0] = s04_couplers_to_s04_couplers_RDATA;
  assign S_AXI_rresp[1:0] = s04_couplers_to_s04_couplers_RRESP;
  assign S_AXI_rvalid[0] = s04_couplers_to_s04_couplers_RVALID;
  assign S_AXI_wready[0] = s04_couplers_to_s04_couplers_WREADY;
  assign s04_couplers_to_s04_couplers_ARADDR = S_AXI_araddr[31:0];
  assign s04_couplers_to_s04_couplers_ARPROT = S_AXI_arprot[2:0];
  assign s04_couplers_to_s04_couplers_ARREADY = M_AXI_arready[0];
  assign s04_couplers_to_s04_couplers_ARVALID = S_AXI_arvalid[0];
  assign s04_couplers_to_s04_couplers_AWADDR = S_AXI_awaddr[31:0];
  assign s04_couplers_to_s04_couplers_AWPROT = S_AXI_awprot[2:0];
  assign s04_couplers_to_s04_couplers_AWREADY = M_AXI_awready[0];
  assign s04_couplers_to_s04_couplers_AWVALID = S_AXI_awvalid[0];
  assign s04_couplers_to_s04_couplers_BREADY = S_AXI_bready[0];
  assign s04_couplers_to_s04_couplers_BRESP = M_AXI_bresp[1:0];
  assign s04_couplers_to_s04_couplers_BVALID = M_AXI_bvalid[0];
  assign s04_couplers_to_s04_couplers_RDATA = M_AXI_rdata[31:0];
  assign s04_couplers_to_s04_couplers_RREADY = S_AXI_rready[0];
  assign s04_couplers_to_s04_couplers_RRESP = M_AXI_rresp[1:0];
  assign s04_couplers_to_s04_couplers_RVALID = M_AXI_rvalid[0];
  assign s04_couplers_to_s04_couplers_WDATA = S_AXI_wdata[31:0];
  assign s04_couplers_to_s04_couplers_WREADY = M_AXI_wready[0];
  assign s04_couplers_to_s04_couplers_WSTRB = S_AXI_wstrb[3:0];
  assign s04_couplers_to_s04_couplers_WVALID = S_AXI_wvalid[0];
endmodule

module s05_couplers_imp_1V0XNQD
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arprot,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awprot,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arprot,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awprot,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [2:0]M_AXI_arprot;
  input [0:0]M_AXI_arready;
  output [0:0]M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [2:0]M_AXI_awprot;
  input [0:0]M_AXI_awready;
  output [0:0]M_AXI_awvalid;
  output [0:0]M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input [0:0]M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output [0:0]M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input [0:0]M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input [0:0]M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output [0:0]M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [2:0]S_AXI_arprot;
  output [0:0]S_AXI_arready;
  input [0:0]S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [2:0]S_AXI_awprot;
  output [0:0]S_AXI_awready;
  input [0:0]S_AXI_awvalid;
  input [0:0]S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output [0:0]S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input [0:0]S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output [0:0]S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  output [0:0]S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input [0:0]S_AXI_wvalid;

  wire [31:0]s05_couplers_to_s05_couplers_ARADDR;
  wire [2:0]s05_couplers_to_s05_couplers_ARPROT;
  wire [0:0]s05_couplers_to_s05_couplers_ARREADY;
  wire [0:0]s05_couplers_to_s05_couplers_ARVALID;
  wire [31:0]s05_couplers_to_s05_couplers_AWADDR;
  wire [2:0]s05_couplers_to_s05_couplers_AWPROT;
  wire [0:0]s05_couplers_to_s05_couplers_AWREADY;
  wire [0:0]s05_couplers_to_s05_couplers_AWVALID;
  wire [0:0]s05_couplers_to_s05_couplers_BREADY;
  wire [1:0]s05_couplers_to_s05_couplers_BRESP;
  wire [0:0]s05_couplers_to_s05_couplers_BVALID;
  wire [31:0]s05_couplers_to_s05_couplers_RDATA;
  wire [0:0]s05_couplers_to_s05_couplers_RREADY;
  wire [1:0]s05_couplers_to_s05_couplers_RRESP;
  wire [0:0]s05_couplers_to_s05_couplers_RVALID;
  wire [31:0]s05_couplers_to_s05_couplers_WDATA;
  wire [0:0]s05_couplers_to_s05_couplers_WREADY;
  wire [3:0]s05_couplers_to_s05_couplers_WSTRB;
  wire [0:0]s05_couplers_to_s05_couplers_WVALID;

  assign M_AXI_araddr[31:0] = s05_couplers_to_s05_couplers_ARADDR;
  assign M_AXI_arprot[2:0] = s05_couplers_to_s05_couplers_ARPROT;
  assign M_AXI_arvalid[0] = s05_couplers_to_s05_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = s05_couplers_to_s05_couplers_AWADDR;
  assign M_AXI_awprot[2:0] = s05_couplers_to_s05_couplers_AWPROT;
  assign M_AXI_awvalid[0] = s05_couplers_to_s05_couplers_AWVALID;
  assign M_AXI_bready[0] = s05_couplers_to_s05_couplers_BREADY;
  assign M_AXI_rready[0] = s05_couplers_to_s05_couplers_RREADY;
  assign M_AXI_wdata[31:0] = s05_couplers_to_s05_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = s05_couplers_to_s05_couplers_WSTRB;
  assign M_AXI_wvalid[0] = s05_couplers_to_s05_couplers_WVALID;
  assign S_AXI_arready[0] = s05_couplers_to_s05_couplers_ARREADY;
  assign S_AXI_awready[0] = s05_couplers_to_s05_couplers_AWREADY;
  assign S_AXI_bresp[1:0] = s05_couplers_to_s05_couplers_BRESP;
  assign S_AXI_bvalid[0] = s05_couplers_to_s05_couplers_BVALID;
  assign S_AXI_rdata[31:0] = s05_couplers_to_s05_couplers_RDATA;
  assign S_AXI_rresp[1:0] = s05_couplers_to_s05_couplers_RRESP;
  assign S_AXI_rvalid[0] = s05_couplers_to_s05_couplers_RVALID;
  assign S_AXI_wready[0] = s05_couplers_to_s05_couplers_WREADY;
  assign s05_couplers_to_s05_couplers_ARADDR = S_AXI_araddr[31:0];
  assign s05_couplers_to_s05_couplers_ARPROT = S_AXI_arprot[2:0];
  assign s05_couplers_to_s05_couplers_ARREADY = M_AXI_arready[0];
  assign s05_couplers_to_s05_couplers_ARVALID = S_AXI_arvalid[0];
  assign s05_couplers_to_s05_couplers_AWADDR = S_AXI_awaddr[31:0];
  assign s05_couplers_to_s05_couplers_AWPROT = S_AXI_awprot[2:0];
  assign s05_couplers_to_s05_couplers_AWREADY = M_AXI_awready[0];
  assign s05_couplers_to_s05_couplers_AWVALID = S_AXI_awvalid[0];
  assign s05_couplers_to_s05_couplers_BREADY = S_AXI_bready[0];
  assign s05_couplers_to_s05_couplers_BRESP = M_AXI_bresp[1:0];
  assign s05_couplers_to_s05_couplers_BVALID = M_AXI_bvalid[0];
  assign s05_couplers_to_s05_couplers_RDATA = M_AXI_rdata[31:0];
  assign s05_couplers_to_s05_couplers_RREADY = S_AXI_rready[0];
  assign s05_couplers_to_s05_couplers_RRESP = M_AXI_rresp[1:0];
  assign s05_couplers_to_s05_couplers_RVALID = M_AXI_rvalid[0];
  assign s05_couplers_to_s05_couplers_WDATA = S_AXI_wdata[31:0];
  assign s05_couplers_to_s05_couplers_WREADY = M_AXI_wready[0];
  assign s05_couplers_to_s05_couplers_WSTRB = S_AXI_wstrb[3:0];
  assign s05_couplers_to_s05_couplers_WVALID = S_AXI_wvalid[0];
endmodule

module s06_couplers_imp_MYTDQK
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arprot,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awprot,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arprot,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awprot,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [2:0]M_AXI_arprot;
  input [0:0]M_AXI_arready;
  output [0:0]M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [2:0]M_AXI_awprot;
  input [0:0]M_AXI_awready;
  output [0:0]M_AXI_awvalid;
  output [0:0]M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input [0:0]M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output [0:0]M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input [0:0]M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input [0:0]M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output [0:0]M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [2:0]S_AXI_arprot;
  output [0:0]S_AXI_arready;
  input [0:0]S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [2:0]S_AXI_awprot;
  output [0:0]S_AXI_awready;
  input [0:0]S_AXI_awvalid;
  input [0:0]S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output [0:0]S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input [0:0]S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output [0:0]S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  output [0:0]S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input [0:0]S_AXI_wvalid;

  wire [31:0]s06_couplers_to_s06_couplers_ARADDR;
  wire [2:0]s06_couplers_to_s06_couplers_ARPROT;
  wire [0:0]s06_couplers_to_s06_couplers_ARREADY;
  wire [0:0]s06_couplers_to_s06_couplers_ARVALID;
  wire [31:0]s06_couplers_to_s06_couplers_AWADDR;
  wire [2:0]s06_couplers_to_s06_couplers_AWPROT;
  wire [0:0]s06_couplers_to_s06_couplers_AWREADY;
  wire [0:0]s06_couplers_to_s06_couplers_AWVALID;
  wire [0:0]s06_couplers_to_s06_couplers_BREADY;
  wire [1:0]s06_couplers_to_s06_couplers_BRESP;
  wire [0:0]s06_couplers_to_s06_couplers_BVALID;
  wire [31:0]s06_couplers_to_s06_couplers_RDATA;
  wire [0:0]s06_couplers_to_s06_couplers_RREADY;
  wire [1:0]s06_couplers_to_s06_couplers_RRESP;
  wire [0:0]s06_couplers_to_s06_couplers_RVALID;
  wire [31:0]s06_couplers_to_s06_couplers_WDATA;
  wire [0:0]s06_couplers_to_s06_couplers_WREADY;
  wire [3:0]s06_couplers_to_s06_couplers_WSTRB;
  wire [0:0]s06_couplers_to_s06_couplers_WVALID;

  assign M_AXI_araddr[31:0] = s06_couplers_to_s06_couplers_ARADDR;
  assign M_AXI_arprot[2:0] = s06_couplers_to_s06_couplers_ARPROT;
  assign M_AXI_arvalid[0] = s06_couplers_to_s06_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = s06_couplers_to_s06_couplers_AWADDR;
  assign M_AXI_awprot[2:0] = s06_couplers_to_s06_couplers_AWPROT;
  assign M_AXI_awvalid[0] = s06_couplers_to_s06_couplers_AWVALID;
  assign M_AXI_bready[0] = s06_couplers_to_s06_couplers_BREADY;
  assign M_AXI_rready[0] = s06_couplers_to_s06_couplers_RREADY;
  assign M_AXI_wdata[31:0] = s06_couplers_to_s06_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = s06_couplers_to_s06_couplers_WSTRB;
  assign M_AXI_wvalid[0] = s06_couplers_to_s06_couplers_WVALID;
  assign S_AXI_arready[0] = s06_couplers_to_s06_couplers_ARREADY;
  assign S_AXI_awready[0] = s06_couplers_to_s06_couplers_AWREADY;
  assign S_AXI_bresp[1:0] = s06_couplers_to_s06_couplers_BRESP;
  assign S_AXI_bvalid[0] = s06_couplers_to_s06_couplers_BVALID;
  assign S_AXI_rdata[31:0] = s06_couplers_to_s06_couplers_RDATA;
  assign S_AXI_rresp[1:0] = s06_couplers_to_s06_couplers_RRESP;
  assign S_AXI_rvalid[0] = s06_couplers_to_s06_couplers_RVALID;
  assign S_AXI_wready[0] = s06_couplers_to_s06_couplers_WREADY;
  assign s06_couplers_to_s06_couplers_ARADDR = S_AXI_araddr[31:0];
  assign s06_couplers_to_s06_couplers_ARPROT = S_AXI_arprot[2:0];
  assign s06_couplers_to_s06_couplers_ARREADY = M_AXI_arready[0];
  assign s06_couplers_to_s06_couplers_ARVALID = S_AXI_arvalid[0];
  assign s06_couplers_to_s06_couplers_AWADDR = S_AXI_awaddr[31:0];
  assign s06_couplers_to_s06_couplers_AWPROT = S_AXI_awprot[2:0];
  assign s06_couplers_to_s06_couplers_AWREADY = M_AXI_awready[0];
  assign s06_couplers_to_s06_couplers_AWVALID = S_AXI_awvalid[0];
  assign s06_couplers_to_s06_couplers_BREADY = S_AXI_bready[0];
  assign s06_couplers_to_s06_couplers_BRESP = M_AXI_bresp[1:0];
  assign s06_couplers_to_s06_couplers_BVALID = M_AXI_bvalid[0];
  assign s06_couplers_to_s06_couplers_RDATA = M_AXI_rdata[31:0];
  assign s06_couplers_to_s06_couplers_RREADY = S_AXI_rready[0];
  assign s06_couplers_to_s06_couplers_RRESP = M_AXI_rresp[1:0];
  assign s06_couplers_to_s06_couplers_RVALID = M_AXI_rvalid[0];
  assign s06_couplers_to_s06_couplers_WDATA = S_AXI_wdata[31:0];
  assign s06_couplers_to_s06_couplers_WREADY = M_AXI_wready[0];
  assign s06_couplers_to_s06_couplers_WSTRB = S_AXI_wstrb[3:0];
  assign s06_couplers_to_s06_couplers_WVALID = S_AXI_wvalid[0];
endmodule

/* POL 1:Neg, 0:Pos

Gain: Shaping Time: (CTS,CG0,CG1)
30mV/fC : 160ns : (low,high,high)
20mV/fC : 160ns : (low,low,high)
  4mV/fC : 300ns : (high,low,low)

other modes are unsuppprted
some SO pins have inverse POL.
proper not gate is added */
(* CORE_GENERATION_INFO = "top_block,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=top_block,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=121,numReposBlks=95,numNonXlnxBlks=0,numHierBlks=26,maxHierDepth=3,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=38,numPkgbdBlks=0,bdsource=USER,\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"da_axi4_cnt\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"=24,\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"da_board_cnt\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"=4,\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"da_clkrst_cnt\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"=20,\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"da_board_cnt\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"=1,\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"da_clkrst_cnt\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"=1,\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"da_clkrst_cnt\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"=1,\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"da_clkrst_cnt\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"=1,\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"da_axi4_cnt\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"=2,\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"da_axi4_cnt\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"=1,\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"da_clkrst_cnt\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"=1,\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"da_clkrst_cnt\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"=1,synth_mode=Global}" *) (* HW_HANDOFF = "top_block.hwdef" *) 
module top_block
   (BASECLK,
    BX_SYNC_TRG_N,
    BX_SYNC_TRG_P,
    CG0,
    CG1,
    CLKSOIN_N,
    CLKSOIN_P,
    CLK_CFG,
    CTS,
    DIP_SW,
    GPION,
    GPIOP,
    HBTRG_N,
    HBTRG_P,
    HRSTB_N,
    HRSTB_P,
    LED,
    POL,
    PUSH_SW,
    SAMPA_EN_A,
    SAMPA_EN_D,
    SFP0RXN,
    SFP0RXP,
    SFP0TXN,
    SFP0TXP,
    SFP_CLK_N,
    SFP_CLK_P,
    SO0N,
    SO0P,
    SO1N,
    SO1P,
    SO2N,
    SO2P,
    SO3N,
    SO3P,
    S_I2C_SCL,
    S_I2C_SDA,
    TRG_N,
    TRG_P);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.BASECLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.BASECLK, CLK_DOMAIN top_block_BASECLK, FREQ_HZ 40000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input BASECLK;
  output [0:0]BX_SYNC_TRG_N;
  output [0:0]BX_SYNC_TRG_P;
  output [0:0]CG0;
  output [0:0]CG1;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLKSOIN_N CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLKSOIN_N, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) output [3:0]CLKSOIN_N;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLKSOIN_P CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLKSOIN_P, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) output [3:0]CLKSOIN_P;
  output [6:0]CLK_CFG;
  output [0:0]CTS;
  input [3:0]DIP_SW;
  input [7:0]GPION;
  input [7:0]GPIOP;
  output [0:0]HBTRG_N;
  output [0:0]HBTRG_P;
  output [3:0]HRSTB_N;
  output [3:0]HRSTB_P;
  output [3:0]LED;
  output [0:0]POL;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.PUSH_SW RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.PUSH_SW, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input PUSH_SW;
  output SAMPA_EN_A;
  output SAMPA_EN_D;
  input SFP0RXN;
  input SFP0RXP;
  output SFP0TXN;
  output SFP0TXP;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.SFP_CLK_N CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.SFP_CLK_N, CLK_DOMAIN top_block_SFP_CLK_N, FREQ_HZ 156250000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input SFP_CLK_N;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.SFP_CLK_P CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.SFP_CLK_P, CLK_DOMAIN top_block_SFP_CLK_P, FREQ_HZ 156250000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input SFP_CLK_P;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.SO0N DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.SO0N, LAYERED_METADATA undef" *) input [10:0]SO0N;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.SO0P DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.SO0P, LAYERED_METADATA undef" *) input [10:0]SO0P;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.SO1N DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.SO1N, LAYERED_METADATA undef" *) input [10:0]SO1N;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.SO1P DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.SO1P, LAYERED_METADATA undef" *) input [10:0]SO1P;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.SO2N DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.SO2N, LAYERED_METADATA undef" *) input [10:0]SO2N;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.SO2P DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.SO2P, LAYERED_METADATA undef" *) input [10:0]SO2P;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.SO3N DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.SO3N, LAYERED_METADATA undef" *) input [10:0]SO3N;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.SO3P DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.SO3P, LAYERED_METADATA undef" *) input [10:0]SO3P;
  inout S_I2C_SCL;
  inout S_I2C_SDA;
  output [3:0]TRG_N;
  output [3:0]TRG_P;

  wire BASECLK_1;
  wire [0:0]Const_wrapper_BX_SYNC_TRG_N;
  wire [0:0]Const_wrapper_BX_SYNC_TRG_P;
  wire [0:0]Const_wrapper_HBTRG_N;
  wire [0:0]Const_wrapper_HBTRG_P;
  wire [3:0]Const_wrapper_HRSTB_N;
  wire [3:0]Const_wrapper_HRSTB_P;
  wire [3:0]DIP_SW_1;
  wire [0:0]EXT_CLK_N_1;
  wire [0:0]EXT_CLK_P_1;
  wire [7:0]GPION_0_1;
  wire [7:0]GPIOP_1;
  wire [6:0]GPIO_Slicer_Dout;
  wire [6:0]GPIO_Slicer_Dout1;
  wire [6:0]GPIO_rx_0_GPIO;
  wire Net;
  wire Net1;
  wire [3:0]OBUFDS_CLKSOIN_0_ON;
  wire [3:0]OBUFDS_CLKSOIN_0_OP;
  wire PUSH_SW_1;
  wire [31:0]S03_AXI_1_ARADDR;
  wire [2:0]S03_AXI_1_ARPROT;
  wire S03_AXI_1_ARREADY;
  wire S03_AXI_1_ARVALID;
  wire [31:0]S03_AXI_1_AWADDR;
  wire [2:0]S03_AXI_1_AWPROT;
  wire S03_AXI_1_AWREADY;
  wire S03_AXI_1_AWVALID;
  wire S03_AXI_1_BREADY;
  wire [1:0]S03_AXI_1_BRESP;
  wire S03_AXI_1_BVALID;
  wire [31:0]S03_AXI_1_RDATA;
  wire S03_AXI_1_RREADY;
  wire [1:0]S03_AXI_1_RRESP;
  wire S03_AXI_1_RVALID;
  wire [31:0]S03_AXI_1_WDATA;
  wire S03_AXI_1_WREADY;
  wire [3:0]S03_AXI_1_WSTRB;
  wire S03_AXI_1_WVALID;
  wire [31:0]SAMPA_I2C_wrapper_m00_axi1_ARADDR;
  wire [2:0]SAMPA_I2C_wrapper_m00_axi1_ARPROT;
  wire [0:0]SAMPA_I2C_wrapper_m00_axi1_ARREADY;
  wire [0:0]SAMPA_I2C_wrapper_m00_axi1_ARVALID;
  wire [31:0]SAMPA_I2C_wrapper_m00_axi1_AWADDR;
  wire [2:0]SAMPA_I2C_wrapper_m00_axi1_AWPROT;
  wire [0:0]SAMPA_I2C_wrapper_m00_axi1_AWREADY;
  wire [0:0]SAMPA_I2C_wrapper_m00_axi1_AWVALID;
  wire [0:0]SAMPA_I2C_wrapper_m00_axi1_BREADY;
  wire [1:0]SAMPA_I2C_wrapper_m00_axi1_BRESP;
  wire [0:0]SAMPA_I2C_wrapper_m00_axi1_BVALID;
  wire [31:0]SAMPA_I2C_wrapper_m00_axi1_RDATA;
  wire [0:0]SAMPA_I2C_wrapper_m00_axi1_RREADY;
  wire [1:0]SAMPA_I2C_wrapper_m00_axi1_RRESP;
  wire [0:0]SAMPA_I2C_wrapper_m00_axi1_RVALID;
  wire [31:0]SAMPA_I2C_wrapper_m00_axi1_WDATA;
  wire [0:0]SAMPA_I2C_wrapper_m00_axi1_WREADY;
  wire [3:0]SAMPA_I2C_wrapper_m00_axi1_WSTRB;
  wire [0:0]SAMPA_I2C_wrapper_m00_axi1_WVALID;
  wire [31:0]SAMPA_I2C_wrapper_m00_axi_ARADDR;
  wire [2:0]SAMPA_I2C_wrapper_m00_axi_ARPROT;
  wire [0:0]SAMPA_I2C_wrapper_m00_axi_ARREADY;
  wire [0:0]SAMPA_I2C_wrapper_m00_axi_ARVALID;
  wire [31:0]SAMPA_I2C_wrapper_m00_axi_AWADDR;
  wire [2:0]SAMPA_I2C_wrapper_m00_axi_AWPROT;
  wire [0:0]SAMPA_I2C_wrapper_m00_axi_AWREADY;
  wire [0:0]SAMPA_I2C_wrapper_m00_axi_AWVALID;
  wire [0:0]SAMPA_I2C_wrapper_m00_axi_BREADY;
  wire [1:0]SAMPA_I2C_wrapper_m00_axi_BRESP;
  wire [0:0]SAMPA_I2C_wrapper_m00_axi_BVALID;
  wire [31:0]SAMPA_I2C_wrapper_m00_axi_RDATA;
  wire [0:0]SAMPA_I2C_wrapper_m00_axi_RREADY;
  wire [1:0]SAMPA_I2C_wrapper_m00_axi_RRESP;
  wire [0:0]SAMPA_I2C_wrapper_m00_axi_RVALID;
  wire [31:0]SAMPA_I2C_wrapper_m00_axi_WDATA;
  wire [0:0]SAMPA_I2C_wrapper_m00_axi_WREADY;
  wire [3:0]SAMPA_I2C_wrapper_m00_axi_WSTRB;
  wire [0:0]SAMPA_I2C_wrapper_m00_axi_WVALID;
  wire SAMPA_PON_v1_0_0_cg0;
  wire SAMPA_PON_v1_0_0_cg1;
  wire SAMPA_PON_v1_0_0_cts;
  wire SAMPA_PON_v1_0_0_ext_clk_en;
  wire SAMPA_PON_v1_0_0_n_samp_0;
  wire SAMPA_PON_v1_0_0_n_samp_1;
  wire SAMPA_PON_v1_0_0_pol;
  wire [1:0]SAMPA_PON_v1_0_0_pretrigger_select;
  wire SAMPA_PON_v1_0_0_sampa_power_on;
  wire SFP0RXN_1;
  wire SFP0RXP_1;
  wire SFP_CLK_N_1;
  wire SFP_CLK_P_1;
  wire [10:0]SO0N_1;
  wire [10:0]SO0P_1;
  wire [10:0]SO0_1;
  wire [10:0]SO1N_1;
  wire [10:0]SO1P_1;
  wire [10:0]SO1_1;
  wire [10:0]SO2N_1;
  wire [10:0]SO2P_1;
  wire [10:0]SO2_1;
  wire [10:0]SO3N_1;
  wire [10:0]SO3P_1;
  wire [10:0]SO3_1;
  wire [31:0]SO_receiver_m00_axi_ARADDR;
  wire [2:0]SO_receiver_m00_axi_ARPROT;
  wire [0:0]SO_receiver_m00_axi_ARREADY;
  wire [0:0]SO_receiver_m00_axi_ARVALID;
  wire [31:0]SO_receiver_m00_axi_AWADDR;
  wire [2:0]SO_receiver_m00_axi_AWPROT;
  wire [0:0]SO_receiver_m00_axi_AWREADY;
  wire [0:0]SO_receiver_m00_axi_AWVALID;
  wire [0:0]SO_receiver_m00_axi_BREADY;
  wire [1:0]SO_receiver_m00_axi_BRESP;
  wire [0:0]SO_receiver_m00_axi_BVALID;
  wire [31:0]SO_receiver_m00_axi_RDATA;
  wire [0:0]SO_receiver_m00_axi_RREADY;
  wire [1:0]SO_receiver_m00_axi_RRESP;
  wire [0:0]SO_receiver_m00_axi_RVALID;
  wire [31:0]SO_receiver_m00_axi_WDATA;
  wire [0:0]SO_receiver_m00_axi_WREADY;
  wire [3:0]SO_receiver_m00_axi_WSTRB;
  wire [0:0]SO_receiver_m00_axi_WVALID;
  wire SO_receiver_ready;
  wire SO_receiver_trg;
  wire [15:0]S_AXI1_1_ARADDR;
  wire [2:0]S_AXI1_1_ARPROT;
  wire S_AXI1_1_ARREADY;
  wire S_AXI1_1_ARVALID;
  wire [15:0]S_AXI1_1_AWADDR;
  wire [2:0]S_AXI1_1_AWPROT;
  wire S_AXI1_1_AWREADY;
  wire S_AXI1_1_AWVALID;
  wire S_AXI1_1_BREADY;
  wire [1:0]S_AXI1_1_BRESP;
  wire S_AXI1_1_BVALID;
  wire [31:0]S_AXI1_1_RDATA;
  wire S_AXI1_1_RREADY;
  wire [1:0]S_AXI1_1_RRESP;
  wire S_AXI1_1_RVALID;
  wire [31:0]S_AXI1_1_WDATA;
  wire S_AXI1_1_WREADY;
  wire [3:0]S_AXI1_1_WSTRB;
  wire S_AXI1_1_WVALID;
  wire [31:0]S_AXI_1_ARADDR;
  wire [2:0]S_AXI_1_ARPROT;
  wire S_AXI_1_ARREADY;
  wire S_AXI_1_ARVALID;
  wire [31:0]S_AXI_1_AWADDR;
  wire [2:0]S_AXI_1_AWPROT;
  wire S_AXI_1_AWREADY;
  wire S_AXI_1_AWVALID;
  wire S_AXI_1_BREADY;
  wire [1:0]S_AXI_1_BRESP;
  wire S_AXI_1_BVALID;
  wire [31:0]S_AXI_1_RDATA;
  wire S_AXI_1_RREADY;
  wire [1:0]S_AXI_1_RRESP;
  wire S_AXI_1_RVALID;
  wire [31:0]S_AXI_1_WDATA;
  wire S_AXI_1_WREADY;
  wire [3:0]S_AXI_1_WSTRB;
  wire S_AXI_1_WVALID;
  wire [31:0]appUnit_M_AXIS_data_TDATA;
  wire appUnit_M_AXIS_data_TREADY;
  wire appUnit_M_AXIS_data_TVALID;
  wire [0:0]areset_1;
  wire clk1_1;
  wire clk25_in_0_1;
  wire clk_enable_1MHz_1;
  wire clk_enable_1kHz_1;
  wire clk_in_0_1;
  wire clk_wiz_0_clk_out1;
  wire clk_wiz_1_clk_out1;
  wire clock_wrapper_clk_out6;
  wire clock_wrapper_locked;
  wire dest_clk1_1;
  wire event_reset_1;
  wire fnet_txn_1;
  wire fnet_wrapper_SFP0TXN;
  wire fnet_wrapper_SFP0TXP;
  wire independent_clock_0_1;
  wire internal_enabled_1;
  wire [3:0]led_module_LED;
  wire [31:0]led_module_m00_axi1_ARADDR;
  wire [2:0]led_module_m00_axi1_ARPROT;
  wire [0:0]led_module_m00_axi1_ARREADY;
  wire [0:0]led_module_m00_axi1_ARVALID;
  wire [31:0]led_module_m00_axi1_AWADDR;
  wire [2:0]led_module_m00_axi1_AWPROT;
  wire [0:0]led_module_m00_axi1_AWREADY;
  wire [0:0]led_module_m00_axi1_AWVALID;
  wire [0:0]led_module_m00_axi1_BREADY;
  wire [1:0]led_module_m00_axi1_BRESP;
  wire [0:0]led_module_m00_axi1_BVALID;
  wire [31:0]led_module_m00_axi1_RDATA;
  wire [0:0]led_module_m00_axi1_RREADY;
  wire [1:0]led_module_m00_axi1_RRESP;
  wire [0:0]led_module_m00_axi1_RVALID;
  wire [31:0]led_module_m00_axi1_WDATA;
  wire [0:0]led_module_m00_axi1_WREADY;
  wire [3:0]led_module_m00_axi1_WSTRB;
  wire [0:0]led_module_m00_axi1_WVALID;
  wire [31:0]led_module_m00_axi_ARADDR;
  wire [2:0]led_module_m00_axi_ARPROT;
  wire [0:0]led_module_m00_axi_ARREADY;
  wire [0:0]led_module_m00_axi_ARVALID;
  wire [31:0]led_module_m00_axi_AWADDR;
  wire [2:0]led_module_m00_axi_AWPROT;
  wire [0:0]led_module_m00_axi_AWREADY;
  wire [0:0]led_module_m00_axi_AWVALID;
  wire [0:0]led_module_m00_axi_BREADY;
  wire [1:0]led_module_m00_axi_BRESP;
  wire [0:0]led_module_m00_axi_BVALID;
  wire [31:0]led_module_m00_axi_RDATA;
  wire [0:0]led_module_m00_axi_RREADY;
  wire [1:0]led_module_m00_axi_RRESP;
  wire [0:0]led_module_m00_axi_RVALID;
  wire [31:0]led_module_m00_axi_WDATA;
  wire [0:0]led_module_m00_axi_WREADY;
  wire [3:0]led_module_m00_axi_WSTRB;
  wire [0:0]led_module_m00_axi_WVALID;
  wire [7:0]n_samples_1;
  wire [0:0]reset_peripheral_aresetn3;
  wire [0:0]reset_peripheral_aresetn4;
  wire [0:0]rst_clk_wiz_0_125M_peripheral_aresetn;
  wire [9:0]threshold_1;
  wire [3:0]trg_en_TRG_N;
  wire [3:0]trg_en_TRG_P;
  wire [31:0]trg_en_m00_axi_ARADDR;
  wire [2:0]trg_en_m00_axi_ARPROT;
  wire [0:0]trg_en_m00_axi_ARREADY;
  wire [0:0]trg_en_m00_axi_ARVALID;
  wire [31:0]trg_en_m00_axi_AWADDR;
  wire [2:0]trg_en_m00_axi_AWPROT;
  wire [0:0]trg_en_m00_axi_AWREADY;
  wire [0:0]trg_en_m00_axi_AWVALID;
  wire [0:0]trg_en_m00_axi_BREADY;
  wire [1:0]trg_en_m00_axi_BRESP;
  wire [0:0]trg_en_m00_axi_BVALID;
  wire [31:0]trg_en_m00_axi_RDATA;
  wire [0:0]trg_en_m00_axi_RREADY;
  wire [1:0]trg_en_m00_axi_RRESP;
  wire [0:0]trg_en_m00_axi_RVALID;
  wire [31:0]trg_en_m00_axi_WDATA;
  wire [0:0]trg_en_m00_axi_WREADY;
  wire [3:0]trg_en_m00_axi_WSTRB;
  wire [0:0]trg_en_m00_axi_WVALID;
  wire trg_en_sampa_trg_en;
  wire [0:0]util_vector_logic_0_Res;
  wire [0:0]vio_0_probe_out0;
  wire [6:0]xlconstant_0_dout;

  assign BASECLK_1 = BASECLK;
  assign BX_SYNC_TRG_N[0] = Const_wrapper_BX_SYNC_TRG_N;
  assign BX_SYNC_TRG_P[0] = Const_wrapper_BX_SYNC_TRG_P;
  assign CG0[0] = SAMPA_PON_v1_0_0_cg0;
  assign CG1[0] = SAMPA_PON_v1_0_0_cg1;
  assign CLKSOIN_N[3:0] = OBUFDS_CLKSOIN_0_ON;
  assign CLKSOIN_P[3:0] = OBUFDS_CLKSOIN_0_OP;
  assign CLK_CFG[6:0] = xlconstant_0_dout;
  assign CTS[0] = SAMPA_PON_v1_0_0_cts;
  assign DIP_SW_1 = DIP_SW[3:0];
  assign GPION_0_1 = GPION[7:0];
  assign GPIOP_1 = GPIOP[7:0];
  assign HBTRG_N[0] = Const_wrapper_HBTRG_N;
  assign HBTRG_P[0] = Const_wrapper_HBTRG_P;
  assign HRSTB_N[3:0] = Const_wrapper_HRSTB_N;
  assign HRSTB_P[3:0] = Const_wrapper_HRSTB_P;
  assign LED[3:0] = led_module_LED;
  assign POL[0] = SAMPA_PON_v1_0_0_pol;
  assign PUSH_SW_1 = PUSH_SW;
  assign SAMPA_EN_A = SAMPA_PON_v1_0_0_sampa_power_on;
  assign SAMPA_EN_D = SAMPA_PON_v1_0_0_sampa_power_on;
  assign SFP0RXN_1 = SFP0RXN;
  assign SFP0RXP_1 = SFP0RXP;
  assign SFP0TXN = fnet_wrapper_SFP0TXN;
  assign SFP0TXP = fnet_wrapper_SFP0TXP;
  assign SFP_CLK_N_1 = SFP_CLK_N;
  assign SFP_CLK_P_1 = SFP_CLK_P;
  assign SO0N_1 = SO0N[10:0];
  assign SO0P_1 = SO0P[10:0];
  assign SO1N_1 = SO1N[10:0];
  assign SO1P_1 = SO1P[10:0];
  assign SO2N_1 = SO2N[10:0];
  assign SO2P_1 = SO2P[10:0];
  assign SO3N_1 = SO3N[10:0];
  assign SO3P_1 = SO3P[10:0];
  assign TRG_N[3:0] = trg_en_TRG_N;
  assign TRG_P[3:0] = trg_en_TRG_P;
  Const_wrapper_imp_OSYF0A Const_wrapper
       (.BX_SYNC_TRG_N(Const_wrapper_BX_SYNC_TRG_N),
        .BX_SYNC_TRG_P(Const_wrapper_BX_SYNC_TRG_P),
        .HBTRG_N(Const_wrapper_HBTRG_N),
        .HBTRG_P(Const_wrapper_HBTRG_P),
        .HRSTB_N(Const_wrapper_HRSTB_N),
        .HRSTB_P(Const_wrapper_HRSTB_P));
  GPIO_Slicer_imp_IQC7PQ GPIO_Slicer
       (.Dout(EXT_CLK_N_1),
        .Dout1(EXT_CLK_P_1),
        .GPION(GPION_0_1),
        .GPION_W7(GPIO_Slicer_Dout),
        .GPIOP(GPIOP_1),
        .GPIOP_W7(GPIO_Slicer_Dout1));
  top_block_GPIO_rx_0_0 GPIO_rx_0
       (.GPIO(GPIO_rx_0_GPIO),
        .GPION(GPIO_Slicer_Dout),
        .GPIOP(GPIO_Slicer_Dout1));
  top_block_OBUFDS_CLKSOIN_0_0 OBUFDS_CLKSOIN_0
       (.I(clk_wiz_1_clk_out1),
        .O(OBUFDS_CLKSOIN_0_OP),
        .OB(OBUFDS_CLKSOIN_0_ON));
  SAMPA_I2C_wrapper_imp_VOP84W SAMPA_I2C_wrapper
       (.S_I2C_SCL(S_I2C_SCL),
        .S_I2C_SDA(S_I2C_SDA),
        .m00_axi1_araddr(SAMPA_I2C_wrapper_m00_axi1_ARADDR),
        .m00_axi1_arprot(SAMPA_I2C_wrapper_m00_axi1_ARPROT),
        .m00_axi1_arready(SAMPA_I2C_wrapper_m00_axi1_ARREADY),
        .m00_axi1_arvalid(SAMPA_I2C_wrapper_m00_axi1_ARVALID),
        .m00_axi1_awaddr(SAMPA_I2C_wrapper_m00_axi1_AWADDR),
        .m00_axi1_awprot(SAMPA_I2C_wrapper_m00_axi1_AWPROT),
        .m00_axi1_awready(SAMPA_I2C_wrapper_m00_axi1_AWREADY),
        .m00_axi1_awvalid(SAMPA_I2C_wrapper_m00_axi1_AWVALID),
        .m00_axi1_bready(SAMPA_I2C_wrapper_m00_axi1_BREADY),
        .m00_axi1_bresp(SAMPA_I2C_wrapper_m00_axi1_BRESP),
        .m00_axi1_bvalid(SAMPA_I2C_wrapper_m00_axi1_BVALID),
        .m00_axi1_rdata(SAMPA_I2C_wrapper_m00_axi1_RDATA),
        .m00_axi1_rready(SAMPA_I2C_wrapper_m00_axi1_RREADY),
        .m00_axi1_rresp(SAMPA_I2C_wrapper_m00_axi1_RRESP),
        .m00_axi1_rvalid(SAMPA_I2C_wrapper_m00_axi1_RVALID),
        .m00_axi1_wdata(SAMPA_I2C_wrapper_m00_axi1_WDATA),
        .m00_axi1_wready(SAMPA_I2C_wrapper_m00_axi1_WREADY),
        .m00_axi1_wstrb(SAMPA_I2C_wrapper_m00_axi1_WSTRB),
        .m00_axi1_wvalid(SAMPA_I2C_wrapper_m00_axi1_WVALID),
        .m00_axi_aclk(clk_in_0_1),
        .m00_axi_araddr(SAMPA_I2C_wrapper_m00_axi_ARADDR),
        .m00_axi_aresetn(rst_clk_wiz_0_125M_peripheral_aresetn),
        .m00_axi_arprot(SAMPA_I2C_wrapper_m00_axi_ARPROT),
        .m00_axi_arready(SAMPA_I2C_wrapper_m00_axi_ARREADY),
        .m00_axi_arvalid(SAMPA_I2C_wrapper_m00_axi_ARVALID),
        .m00_axi_awaddr(SAMPA_I2C_wrapper_m00_axi_AWADDR),
        .m00_axi_awprot(SAMPA_I2C_wrapper_m00_axi_AWPROT),
        .m00_axi_awready(SAMPA_I2C_wrapper_m00_axi_AWREADY),
        .m00_axi_awvalid(SAMPA_I2C_wrapper_m00_axi_AWVALID),
        .m00_axi_bready(SAMPA_I2C_wrapper_m00_axi_BREADY),
        .m00_axi_bresp(SAMPA_I2C_wrapper_m00_axi_BRESP),
        .m00_axi_bvalid(SAMPA_I2C_wrapper_m00_axi_BVALID),
        .m00_axi_rdata(SAMPA_I2C_wrapper_m00_axi_RDATA),
        .m00_axi_rready(SAMPA_I2C_wrapper_m00_axi_RREADY),
        .m00_axi_rresp(SAMPA_I2C_wrapper_m00_axi_RRESP),
        .m00_axi_rvalid(SAMPA_I2C_wrapper_m00_axi_RVALID),
        .m00_axi_wdata(SAMPA_I2C_wrapper_m00_axi_WDATA),
        .m00_axi_wready(SAMPA_I2C_wrapper_m00_axi_WREADY),
        .m00_axi_wstrb(SAMPA_I2C_wrapper_m00_axi_WSTRB),
        .m00_axi_wvalid(SAMPA_I2C_wrapper_m00_axi_WVALID),
        .s_axi_aclk(clk_wiz_0_clk_out1));
  top_block_SAMPA_PON_v1_0_0_0 SAMPA_PON_v1_0_0
       (.cg0(SAMPA_PON_v1_0_0_cg0),
        .cg1(SAMPA_PON_v1_0_0_cg1),
        .clk_enable_1MHz(clk_enable_1MHz_1),
        .clk_enable_1kHz(clk_enable_1kHz_1),
        .cts(SAMPA_PON_v1_0_0_cts),
        .ext_clk_en(SAMPA_PON_v1_0_0_ext_clk_en),
        .int_trig_en(internal_enabled_1),
        .m00_axi_aclk(clk_in_0_1),
        .m00_axi_araddr(S03_AXI_1_ARADDR),
        .m00_axi_aresetn(rst_clk_wiz_0_125M_peripheral_aresetn),
        .m00_axi_arprot(S03_AXI_1_ARPROT),
        .m00_axi_arready(S03_AXI_1_ARREADY),
        .m00_axi_arvalid(S03_AXI_1_ARVALID),
        .m00_axi_awaddr(S03_AXI_1_AWADDR),
        .m00_axi_awprot(S03_AXI_1_AWPROT),
        .m00_axi_awready(S03_AXI_1_AWREADY),
        .m00_axi_awvalid(S03_AXI_1_AWVALID),
        .m00_axi_bready(S03_AXI_1_BREADY),
        .m00_axi_bresp(S03_AXI_1_BRESP),
        .m00_axi_bvalid(S03_AXI_1_BVALID),
        .m00_axi_init_axi_txn(1'b0),
        .m00_axi_rdata(S03_AXI_1_RDATA),
        .m00_axi_rready(S03_AXI_1_RREADY),
        .m00_axi_rresp(S03_AXI_1_RRESP),
        .m00_axi_rvalid(S03_AXI_1_RVALID),
        .m00_axi_wdata(S03_AXI_1_WDATA),
        .m00_axi_wready(S03_AXI_1_WREADY),
        .m00_axi_wstrb(S03_AXI_1_WSTRB),
        .m00_axi_wvalid(S03_AXI_1_WVALID),
        .n_samp_0(SAMPA_PON_v1_0_0_n_samp_0),
        .n_samp_1(SAMPA_PON_v1_0_0_n_samp_1),
        .pol(SAMPA_PON_v1_0_0_pol),
        .pretrigger_select(SAMPA_PON_v1_0_0_pretrigger_select),
        .sampa_power_on(SAMPA_PON_v1_0_0_sampa_power_on),
        .trig_threshold(threshold_1));
  SO_receiver_imp_J5HCEK SO_receiver
       (.IBUF_OUT0(SO0_1),
        .IBUF_OUT1(SO1_1),
        .IBUF_OUT2(SO2_1),
        .IBUF_OUT3(SO3_1),
        .SO0N(SO0N_1),
        .SO0P(SO0P_1),
        .SO1N(SO1N_1),
        .SO1P(SO1P_1),
        .SO2N(SO2N_1),
        .SO2P(SO2P_1),
        .SO3N(SO3N_1),
        .SO3P(SO3P_1),
        .areset(areset_1),
        .areset_ref(reset_peripheral_aresetn3),
        .areset_ref2(reset_peripheral_aresetn4),
        .clk(clk_wiz_1_clk_out1),
        .idelay_refclk(clock_wrapper_clk_out6),
        .idelay_refclk2(dest_clk1_1),
        .m00_axi_aclk(clk_in_0_1),
        .m00_axi_araddr(SO_receiver_m00_axi_ARADDR),
        .m00_axi_aresetn(rst_clk_wiz_0_125M_peripheral_aresetn),
        .m00_axi_arprot(SO_receiver_m00_axi_ARPROT),
        .m00_axi_arready(SO_receiver_m00_axi_ARREADY),
        .m00_axi_arvalid(SO_receiver_m00_axi_ARVALID),
        .m00_axi_awaddr(SO_receiver_m00_axi_AWADDR),
        .m00_axi_awprot(SO_receiver_m00_axi_AWPROT),
        .m00_axi_awready(SO_receiver_m00_axi_AWREADY),
        .m00_axi_awvalid(SO_receiver_m00_axi_AWVALID),
        .m00_axi_bready(SO_receiver_m00_axi_BREADY),
        .m00_axi_bresp(SO_receiver_m00_axi_BRESP),
        .m00_axi_bvalid(SO_receiver_m00_axi_BVALID),
        .m00_axi_rdata(SO_receiver_m00_axi_RDATA),
        .m00_axi_rready(SO_receiver_m00_axi_RREADY),
        .m00_axi_rresp(SO_receiver_m00_axi_RRESP),
        .m00_axi_rvalid(SO_receiver_m00_axi_RVALID),
        .m00_axi_wdata(SO_receiver_m00_axi_WDATA),
        .m00_axi_wready(SO_receiver_m00_axi_WREADY),
        .m00_axi_wstrb(SO_receiver_m00_axi_WSTRB),
        .m00_axi_wvalid(SO_receiver_m00_axi_WVALID),
        .ready(SO_receiver_ready),
        .trg(SO_receiver_trg));
  appUnit_imp_1BHH9Z2 appUnit
       (.Din(GPIO_rx_0_GPIO),
        .M_AXIS_data_tdata(appUnit_M_AXIS_data_TDATA),
        .M_AXIS_data_tready(appUnit_M_AXIS_data_TREADY),
        .M_AXIS_data_tvalid(appUnit_M_AXIS_data_TVALID),
        .SO0(SO0_1),
        .SO1(SO1_1),
        .SO2(SO2_1),
        .SO3(SO3_1),
        .clk(clk_wiz_1_clk_out1),
        .clk1(clk1_1),
        .clk125MHz(clk_in_0_1),
        .clk_enable_1MHz(clk_enable_1MHz_1),
        .clk_enable_1kHz(clk_enable_1kHz_1),
        .en(util_vector_logic_0_Res),
        .event_reset(event_reset_1),
        .internal_enabled(internal_enabled_1),
        .n_samples(n_samples_1),
        .pretrigger_select(SAMPA_PON_v1_0_0_pretrigger_select),
        .s_axis_aresetn_0(rst_clk_wiz_0_125M_peripheral_aresetn),
        .select_ext(SAMPA_PON_v1_0_0_ext_clk_en),
        .threshold(threshold_1),
        .user_clk(clk_wiz_0_clk_out1));
  top_block_bits_to_n_samples_0_0 bits_to_n_samples_0
       (.n_samp_0(SAMPA_PON_v1_0_0_n_samp_0),
        .n_samp_1(SAMPA_PON_v1_0_0_n_samp_1),
        .n_samples(n_samples_1));
  clock_wrapper_imp_153XBA clock_wrapper
       (.BASECLK(BASECLK_1),
        .EXT_CLK_N(EXT_CLK_N_1),
        .EXT_CLK_P(EXT_CLK_P_1),
        .clk_out1(clk_wiz_0_clk_out1),
        .clk_out2(clk_wiz_1_clk_out1),
        .clk_out3(clk25_in_0_1),
        .clk_out4(independent_clock_0_1),
        .clk_out5(clk_in_0_1),
        .clk_out6(clock_wrapper_clk_out6),
        .clk_out7(dest_clk1_1),
        .clk_out8(clk1_1),
        .locked(clock_wrapper_locked));
  fnet_wrapper_imp_RWCR3V fnet_wrapper
       (.SFP0RXN(SFP0RXN_1),
        .SFP0RXP(SFP0RXP_1),
        .SFP0TXN(fnet_wrapper_SFP0TXN),
        .SFP0TXP(fnet_wrapper_SFP0TXP),
        .SFP_CLK_N(SFP_CLK_N_1),
        .SFP_CLK_P(SFP_CLK_P_1),
        .clk25_in_0(clk25_in_0_1),
        .clk_in_0(clk_in_0_1),
        .independent_clock_0(independent_clock_0_1),
        .m00_axi_araddr(S_AXI_1_ARADDR),
        .m00_axi_aresetn(rst_clk_wiz_0_125M_peripheral_aresetn),
        .m00_axi_arprot(S_AXI_1_ARPROT),
        .m00_axi_arready(S_AXI_1_ARREADY),
        .m00_axi_arvalid(S_AXI_1_ARVALID),
        .m00_axi_awaddr(S_AXI_1_AWADDR),
        .m00_axi_awprot(S_AXI_1_AWPROT),
        .m00_axi_awready(S_AXI_1_AWREADY),
        .m00_axi_awvalid(S_AXI_1_AWVALID),
        .m00_axi_bready(S_AXI_1_BREADY),
        .m00_axi_bresp(S_AXI_1_BRESP),
        .m00_axi_bvalid(S_AXI_1_BVALID),
        .m00_axi_rdata(S_AXI_1_RDATA),
        .m00_axi_rready(S_AXI_1_RREADY),
        .m00_axi_rresp(S_AXI_1_RRESP),
        .m00_axi_rvalid(S_AXI_1_RVALID),
        .m00_axi_wdata(S_AXI_1_WDATA),
        .m00_axi_wready(S_AXI_1_WREADY),
        .m00_axi_wstrb(S_AXI_1_WSTRB),
        .m00_axi_wvalid(S_AXI_1_WVALID),
        .regacc_done(fnet_txn_1),
        .reset_vio_0(vio_0_probe_out0),
        .s00_axis_tdata(appUnit_M_AXIS_data_TDATA),
        .s00_axis_tready(appUnit_M_AXIS_data_TREADY),
        .s00_axis_tvalid(appUnit_M_AXIS_data_TVALID),
        .user_data_reset(event_reset_1));
  intercon_wrapper_imp_1BZAOGM intercon_wrapper
       (.M00_ACLK(clk_in_0_1),
        .M00_ARESETN(rst_clk_wiz_0_125M_peripheral_aresetn),
        .M00_AXI_araddr(S_AXI1_1_ARADDR),
        .M00_AXI_arprot(S_AXI1_1_ARPROT),
        .M00_AXI_arready(S_AXI1_1_ARREADY),
        .M00_AXI_arvalid(S_AXI1_1_ARVALID),
        .M00_AXI_awaddr(S_AXI1_1_AWADDR),
        .M00_AXI_awprot(S_AXI1_1_AWPROT),
        .M00_AXI_awready(S_AXI1_1_AWREADY),
        .M00_AXI_awvalid(S_AXI1_1_AWVALID),
        .M00_AXI_bready(S_AXI1_1_BREADY),
        .M00_AXI_bresp(S_AXI1_1_BRESP),
        .M00_AXI_bvalid(S_AXI1_1_BVALID),
        .M00_AXI_rdata(S_AXI1_1_RDATA),
        .M00_AXI_rready(S_AXI1_1_RREADY),
        .M00_AXI_rresp(S_AXI1_1_RRESP),
        .M00_AXI_rvalid(S_AXI1_1_RVALID),
        .M00_AXI_wdata(S_AXI1_1_WDATA),
        .M00_AXI_wready(S_AXI1_1_WREADY),
        .M00_AXI_wstrb(S_AXI1_1_WSTRB),
        .M00_AXI_wvalid(S_AXI1_1_WVALID),
        .S00_AXI_araddr(SAMPA_I2C_wrapper_m00_axi_ARADDR),
        .S00_AXI_arprot(SAMPA_I2C_wrapper_m00_axi_ARPROT),
        .S00_AXI_arready(SAMPA_I2C_wrapper_m00_axi_ARREADY),
        .S00_AXI_arvalid(SAMPA_I2C_wrapper_m00_axi_ARVALID),
        .S00_AXI_awaddr(SAMPA_I2C_wrapper_m00_axi_AWADDR),
        .S00_AXI_awprot(SAMPA_I2C_wrapper_m00_axi_AWPROT),
        .S00_AXI_awready(SAMPA_I2C_wrapper_m00_axi_AWREADY),
        .S00_AXI_awvalid(SAMPA_I2C_wrapper_m00_axi_AWVALID),
        .S00_AXI_bready(SAMPA_I2C_wrapper_m00_axi_BREADY),
        .S00_AXI_bresp(SAMPA_I2C_wrapper_m00_axi_BRESP),
        .S00_AXI_bvalid(SAMPA_I2C_wrapper_m00_axi_BVALID),
        .S00_AXI_rdata(SAMPA_I2C_wrapper_m00_axi_RDATA),
        .S00_AXI_rready(SAMPA_I2C_wrapper_m00_axi_RREADY),
        .S00_AXI_rresp(SAMPA_I2C_wrapper_m00_axi_RRESP),
        .S00_AXI_rvalid(SAMPA_I2C_wrapper_m00_axi_RVALID),
        .S00_AXI_wdata(SAMPA_I2C_wrapper_m00_axi_WDATA),
        .S00_AXI_wready(SAMPA_I2C_wrapper_m00_axi_WREADY),
        .S00_AXI_wstrb(SAMPA_I2C_wrapper_m00_axi_WSTRB),
        .S00_AXI_wvalid(SAMPA_I2C_wrapper_m00_axi_WVALID),
        .S01_AXI_araddr(led_module_m00_axi_ARADDR),
        .S01_AXI_arprot(led_module_m00_axi_ARPROT),
        .S01_AXI_arready(led_module_m00_axi_ARREADY),
        .S01_AXI_arvalid(led_module_m00_axi_ARVALID),
        .S01_AXI_awaddr(led_module_m00_axi_AWADDR),
        .S01_AXI_awprot(led_module_m00_axi_AWPROT),
        .S01_AXI_awready(led_module_m00_axi_AWREADY),
        .S01_AXI_awvalid(led_module_m00_axi_AWVALID),
        .S01_AXI_bready(led_module_m00_axi_BREADY),
        .S01_AXI_bresp(led_module_m00_axi_BRESP),
        .S01_AXI_bvalid(led_module_m00_axi_BVALID),
        .S01_AXI_rdata(led_module_m00_axi_RDATA),
        .S01_AXI_rready(led_module_m00_axi_RREADY),
        .S01_AXI_rresp(led_module_m00_axi_RRESP),
        .S01_AXI_rvalid(led_module_m00_axi_RVALID),
        .S01_AXI_wdata(led_module_m00_axi_WDATA),
        .S01_AXI_wready(led_module_m00_axi_WREADY),
        .S01_AXI_wstrb(led_module_m00_axi_WSTRB),
        .S01_AXI_wvalid(led_module_m00_axi_WVALID),
        .S02_AXI_araddr(led_module_m00_axi1_ARADDR),
        .S02_AXI_arprot(led_module_m00_axi1_ARPROT),
        .S02_AXI_arready(led_module_m00_axi1_ARREADY),
        .S02_AXI_arvalid(led_module_m00_axi1_ARVALID),
        .S02_AXI_awaddr(led_module_m00_axi1_AWADDR),
        .S02_AXI_awprot(led_module_m00_axi1_AWPROT),
        .S02_AXI_awready(led_module_m00_axi1_AWREADY),
        .S02_AXI_awvalid(led_module_m00_axi1_AWVALID),
        .S02_AXI_bready(led_module_m00_axi1_BREADY),
        .S02_AXI_bresp(led_module_m00_axi1_BRESP),
        .S02_AXI_bvalid(led_module_m00_axi1_BVALID),
        .S02_AXI_rdata(led_module_m00_axi1_RDATA),
        .S02_AXI_rready(led_module_m00_axi1_RREADY),
        .S02_AXI_rresp(led_module_m00_axi1_RRESP),
        .S02_AXI_rvalid(led_module_m00_axi1_RVALID),
        .S02_AXI_wdata(led_module_m00_axi1_WDATA),
        .S02_AXI_wready(led_module_m00_axi1_WREADY),
        .S02_AXI_wstrb(led_module_m00_axi1_WSTRB),
        .S02_AXI_wvalid(led_module_m00_axi1_WVALID),
        .S03_AXI_araddr(S03_AXI_1_ARADDR),
        .S03_AXI_arprot(S03_AXI_1_ARPROT),
        .S03_AXI_arready(S03_AXI_1_ARREADY),
        .S03_AXI_arvalid(S03_AXI_1_ARVALID),
        .S03_AXI_awaddr(S03_AXI_1_AWADDR),
        .S03_AXI_awprot(S03_AXI_1_AWPROT),
        .S03_AXI_awready(S03_AXI_1_AWREADY),
        .S03_AXI_awvalid(S03_AXI_1_AWVALID),
        .S03_AXI_bready(S03_AXI_1_BREADY),
        .S03_AXI_bresp(S03_AXI_1_BRESP),
        .S03_AXI_bvalid(S03_AXI_1_BVALID),
        .S03_AXI_rdata(S03_AXI_1_RDATA),
        .S03_AXI_rready(S03_AXI_1_RREADY),
        .S03_AXI_rresp(S03_AXI_1_RRESP),
        .S03_AXI_rvalid(S03_AXI_1_RVALID),
        .S03_AXI_wdata(S03_AXI_1_WDATA),
        .S03_AXI_wready(S03_AXI_1_WREADY),
        .S03_AXI_wstrb(S03_AXI_1_WSTRB),
        .S03_AXI_wvalid(S03_AXI_1_WVALID),
        .S04_AXI_araddr(trg_en_m00_axi_ARADDR),
        .S04_AXI_arprot(trg_en_m00_axi_ARPROT),
        .S04_AXI_arready(trg_en_m00_axi_ARREADY),
        .S04_AXI_arvalid(trg_en_m00_axi_ARVALID),
        .S04_AXI_awaddr(trg_en_m00_axi_AWADDR),
        .S04_AXI_awprot(trg_en_m00_axi_AWPROT),
        .S04_AXI_awready(trg_en_m00_axi_AWREADY),
        .S04_AXI_awvalid(trg_en_m00_axi_AWVALID),
        .S04_AXI_bready(trg_en_m00_axi_BREADY),
        .S04_AXI_bresp(trg_en_m00_axi_BRESP),
        .S04_AXI_bvalid(trg_en_m00_axi_BVALID),
        .S04_AXI_rdata(trg_en_m00_axi_RDATA),
        .S04_AXI_rready(trg_en_m00_axi_RREADY),
        .S04_AXI_rresp(trg_en_m00_axi_RRESP),
        .S04_AXI_rvalid(trg_en_m00_axi_RVALID),
        .S04_AXI_wdata(trg_en_m00_axi_WDATA),
        .S04_AXI_wready(trg_en_m00_axi_WREADY),
        .S04_AXI_wstrb(trg_en_m00_axi_WSTRB),
        .S04_AXI_wvalid(trg_en_m00_axi_WVALID),
        .S05_AXI_araddr(SAMPA_I2C_wrapper_m00_axi1_ARADDR),
        .S05_AXI_arprot(SAMPA_I2C_wrapper_m00_axi1_ARPROT),
        .S05_AXI_arready(SAMPA_I2C_wrapper_m00_axi1_ARREADY),
        .S05_AXI_arvalid(SAMPA_I2C_wrapper_m00_axi1_ARVALID),
        .S05_AXI_awaddr(SAMPA_I2C_wrapper_m00_axi1_AWADDR),
        .S05_AXI_awprot(SAMPA_I2C_wrapper_m00_axi1_AWPROT),
        .S05_AXI_awready(SAMPA_I2C_wrapper_m00_axi1_AWREADY),
        .S05_AXI_awvalid(SAMPA_I2C_wrapper_m00_axi1_AWVALID),
        .S05_AXI_bready(SAMPA_I2C_wrapper_m00_axi1_BREADY),
        .S05_AXI_bresp(SAMPA_I2C_wrapper_m00_axi1_BRESP),
        .S05_AXI_bvalid(SAMPA_I2C_wrapper_m00_axi1_BVALID),
        .S05_AXI_rdata(SAMPA_I2C_wrapper_m00_axi1_RDATA),
        .S05_AXI_rready(SAMPA_I2C_wrapper_m00_axi1_RREADY),
        .S05_AXI_rresp(SAMPA_I2C_wrapper_m00_axi1_RRESP),
        .S05_AXI_rvalid(SAMPA_I2C_wrapper_m00_axi1_RVALID),
        .S05_AXI_wdata(SAMPA_I2C_wrapper_m00_axi1_WDATA),
        .S05_AXI_wready(SAMPA_I2C_wrapper_m00_axi1_WREADY),
        .S05_AXI_wstrb(SAMPA_I2C_wrapper_m00_axi1_WSTRB),
        .S05_AXI_wvalid(SAMPA_I2C_wrapper_m00_axi1_WVALID),
        .S06_AXI_araddr(SO_receiver_m00_axi_ARADDR),
        .S06_AXI_arprot(SO_receiver_m00_axi_ARPROT),
        .S06_AXI_arready(SO_receiver_m00_axi_ARREADY),
        .S06_AXI_arvalid(SO_receiver_m00_axi_ARVALID),
        .S06_AXI_awaddr(SO_receiver_m00_axi_AWADDR),
        .S06_AXI_awprot(SO_receiver_m00_axi_AWPROT),
        .S06_AXI_awready(SO_receiver_m00_axi_AWREADY),
        .S06_AXI_awvalid(SO_receiver_m00_axi_AWVALID),
        .S06_AXI_bready(SO_receiver_m00_axi_BREADY),
        .S06_AXI_bresp(SO_receiver_m00_axi_BRESP),
        .S06_AXI_bvalid(SO_receiver_m00_axi_BVALID),
        .S06_AXI_rdata(SO_receiver_m00_axi_RDATA),
        .S06_AXI_rready(SO_receiver_m00_axi_RREADY),
        .S06_AXI_rresp(SO_receiver_m00_axi_RRESP),
        .S06_AXI_rvalid(SO_receiver_m00_axi_RVALID),
        .S06_AXI_wdata(SO_receiver_m00_axi_WDATA),
        .S06_AXI_wready(SO_receiver_m00_axi_WREADY),
        .S06_AXI_wstrb(SO_receiver_m00_axi_WSTRB),
        .S06_AXI_wvalid(SO_receiver_m00_axi_WVALID));
  led_module_imp_CAGS8R led_module
       (.DIP_SW(DIP_SW_1),
        .LED(led_module_LED),
        .clk125MHz(clk_in_0_1),
        .ext_clk_lkd(clock_wrapper_locked),
        .fnet_txn(fnet_txn_1),
        .m00_axi1_araddr(led_module_m00_axi1_ARADDR),
        .m00_axi1_arprot(led_module_m00_axi1_ARPROT),
        .m00_axi1_arready(led_module_m00_axi1_ARREADY),
        .m00_axi1_arvalid(led_module_m00_axi1_ARVALID),
        .m00_axi1_awaddr(led_module_m00_axi1_AWADDR),
        .m00_axi1_awprot(led_module_m00_axi1_AWPROT),
        .m00_axi1_awready(led_module_m00_axi1_AWREADY),
        .m00_axi1_awvalid(led_module_m00_axi1_AWVALID),
        .m00_axi1_bready(led_module_m00_axi1_BREADY),
        .m00_axi1_bresp(led_module_m00_axi1_BRESP),
        .m00_axi1_bvalid(led_module_m00_axi1_BVALID),
        .m00_axi1_rdata(led_module_m00_axi1_RDATA),
        .m00_axi1_rready(led_module_m00_axi1_RREADY),
        .m00_axi1_rresp(led_module_m00_axi1_RRESP),
        .m00_axi1_rvalid(led_module_m00_axi1_RVALID),
        .m00_axi1_wdata(led_module_m00_axi1_WDATA),
        .m00_axi1_wready(led_module_m00_axi1_WREADY),
        .m00_axi1_wstrb(led_module_m00_axi1_WSTRB),
        .m00_axi1_wvalid(led_module_m00_axi1_WVALID),
        .m00_axi_araddr(led_module_m00_axi_ARADDR),
        .m00_axi_aresetn(rst_clk_wiz_0_125M_peripheral_aresetn),
        .m00_axi_arprot(led_module_m00_axi_ARPROT),
        .m00_axi_arready(led_module_m00_axi_ARREADY),
        .m00_axi_arvalid(led_module_m00_axi_ARVALID),
        .m00_axi_awaddr(led_module_m00_axi_AWADDR),
        .m00_axi_awprot(led_module_m00_axi_AWPROT),
        .m00_axi_awready(led_module_m00_axi_AWREADY),
        .m00_axi_awvalid(led_module_m00_axi_AWVALID),
        .m00_axi_bready(led_module_m00_axi_BREADY),
        .m00_axi_bresp(led_module_m00_axi_BRESP),
        .m00_axi_bvalid(led_module_m00_axi_BVALID),
        .m00_axi_rdata(led_module_m00_axi_RDATA),
        .m00_axi_rready(led_module_m00_axi_RREADY),
        .m00_axi_rresp(led_module_m00_axi_RRESP),
        .m00_axi_rvalid(led_module_m00_axi_RVALID),
        .m00_axi_wdata(led_module_m00_axi_WDATA),
        .m00_axi_wready(led_module_m00_axi_WREADY),
        .m00_axi_wstrb(led_module_m00_axi_WSTRB),
        .m00_axi_wvalid(led_module_m00_axi_WVALID),
        .power_on(SAMPA_PON_v1_0_0_sampa_power_on),
        .reset(vio_0_probe_out0));
  reg_bram_imp_WBS55O reg_bram
       (.S_AXI1_araddr(S_AXI1_1_ARADDR),
        .S_AXI1_arprot(S_AXI1_1_ARPROT),
        .S_AXI1_arready(S_AXI1_1_ARREADY),
        .S_AXI1_arvalid(S_AXI1_1_ARVALID),
        .S_AXI1_awaddr(S_AXI1_1_AWADDR),
        .S_AXI1_awprot(S_AXI1_1_AWPROT),
        .S_AXI1_awready(S_AXI1_1_AWREADY),
        .S_AXI1_awvalid(S_AXI1_1_AWVALID),
        .S_AXI1_bready(S_AXI1_1_BREADY),
        .S_AXI1_bresp(S_AXI1_1_BRESP),
        .S_AXI1_bvalid(S_AXI1_1_BVALID),
        .S_AXI1_rdata(S_AXI1_1_RDATA),
        .S_AXI1_rready(S_AXI1_1_RREADY),
        .S_AXI1_rresp(S_AXI1_1_RRESP),
        .S_AXI1_rvalid(S_AXI1_1_RVALID),
        .S_AXI1_wdata(S_AXI1_1_WDATA),
        .S_AXI1_wready(S_AXI1_1_WREADY),
        .S_AXI1_wstrb(S_AXI1_1_WSTRB),
        .S_AXI1_wvalid(S_AXI1_1_WVALID),
        .S_AXI_araddr(S_AXI_1_ARADDR),
        .S_AXI_arprot(S_AXI_1_ARPROT),
        .S_AXI_arready(S_AXI_1_ARREADY),
        .S_AXI_arvalid(S_AXI_1_ARVALID),
        .S_AXI_awaddr(S_AXI_1_AWADDR),
        .S_AXI_awprot(S_AXI_1_AWPROT),
        .S_AXI_awready(S_AXI_1_AWREADY),
        .S_AXI_awvalid(S_AXI_1_AWVALID),
        .S_AXI_bready(S_AXI_1_BREADY),
        .S_AXI_bresp(S_AXI_1_BRESP),
        .S_AXI_bvalid(S_AXI_1_BVALID),
        .S_AXI_rdata(S_AXI_1_RDATA),
        .S_AXI_rready(S_AXI_1_RREADY),
        .S_AXI_rresp(S_AXI_1_RRESP),
        .S_AXI_rvalid(S_AXI_1_RVALID),
        .S_AXI_wdata(S_AXI_1_WDATA),
        .S_AXI_wready(S_AXI_1_WREADY),
        .S_AXI_wstrb(S_AXI_1_WSTRB),
        .S_AXI_wvalid(S_AXI_1_WVALID),
        .s_axi_aclk(clk_in_0_1),
        .s_axi_aresetn(rst_clk_wiz_0_125M_peripheral_aresetn));
  reset_imp_UQ2QSL reset
       (.RST(PUSH_SW_1),
        .dest_clk(clock_wrapper_clk_out6),
        .dest_clk1(dest_clk1_1),
        .ext_reset_in(event_reset_1),
        .peripheral_aresetn(rst_clk_wiz_0_125M_peripheral_aresetn),
        .peripheral_aresetn2(areset_1),
        .peripheral_aresetn3(reset_peripheral_aresetn3),
        .peripheral_aresetn4(reset_peripheral_aresetn4),
        .probe_out0(vio_0_probe_out0),
        .slowest_sync_clk(clk_in_0_1),
        .slowest_sync_clk1(clk_wiz_1_clk_out1));
  trg_en_imp_1M4NTOV trg_en
       (.TRG_N(trg_en_TRG_N),
        .TRG_P(trg_en_TRG_P),
        .clk(clk_in_0_1),
        .init_trg(SO_receiver_trg),
        .m00_axi_araddr(trg_en_m00_axi_ARADDR),
        .m00_axi_aresetn(rst_clk_wiz_0_125M_peripheral_aresetn),
        .m00_axi_arprot(trg_en_m00_axi_ARPROT),
        .m00_axi_arready(trg_en_m00_axi_ARREADY),
        .m00_axi_arvalid(trg_en_m00_axi_ARVALID),
        .m00_axi_awaddr(trg_en_m00_axi_AWADDR),
        .m00_axi_awprot(trg_en_m00_axi_AWPROT),
        .m00_axi_awready(trg_en_m00_axi_AWREADY),
        .m00_axi_awvalid(trg_en_m00_axi_AWVALID),
        .m00_axi_bready(trg_en_m00_axi_BREADY),
        .m00_axi_bresp(trg_en_m00_axi_BRESP),
        .m00_axi_bvalid(trg_en_m00_axi_BVALID),
        .m00_axi_rdata(trg_en_m00_axi_RDATA),
        .m00_axi_rready(trg_en_m00_axi_RREADY),
        .m00_axi_rresp(trg_en_m00_axi_RRESP),
        .m00_axi_rvalid(trg_en_m00_axi_RVALID),
        .m00_axi_wdata(trg_en_m00_axi_WDATA),
        .m00_axi_wready(trg_en_m00_axi_WREADY),
        .m00_axi_wstrb(trg_en_m00_axi_WSTRB),
        .m00_axi_wvalid(trg_en_m00_axi_WVALID),
        .rst(rst_clk_wiz_0_125M_peripheral_aresetn),
        .sampa_trg_en(trg_en_sampa_trg_en));
  top_block_util_vector_logic_0_3 util_vector_logic_0
       (.Op1(SO_receiver_ready),
        .Op2(trg_en_sampa_trg_en),
        .Res(util_vector_logic_0_Res));
  top_block_xlconstant_0_3 xlconstant_0
       (.dout(xlconstant_0_dout));
endmodule

module top_block_axi_mem_intercon_3
   (ACLK,
    ARESETN,
    M00_ACLK,
    M00_ARESETN,
    M00_AXI_araddr,
    M00_AXI_arprot,
    M00_AXI_arready,
    M00_AXI_arvalid,
    M00_AXI_awaddr,
    M00_AXI_awprot,
    M00_AXI_awready,
    M00_AXI_awvalid,
    M00_AXI_bready,
    M00_AXI_bresp,
    M00_AXI_bvalid,
    M00_AXI_rdata,
    M00_AXI_rready,
    M00_AXI_rresp,
    M00_AXI_rvalid,
    M00_AXI_wdata,
    M00_AXI_wready,
    M00_AXI_wstrb,
    M00_AXI_wvalid,
    S00_ACLK,
    S00_ARESETN,
    S00_AXI_araddr,
    S00_AXI_arprot,
    S00_AXI_arready,
    S00_AXI_arvalid,
    S00_AXI_awaddr,
    S00_AXI_awprot,
    S00_AXI_awready,
    S00_AXI_awvalid,
    S00_AXI_bready,
    S00_AXI_bresp,
    S00_AXI_bvalid,
    S00_AXI_rdata,
    S00_AXI_rready,
    S00_AXI_rresp,
    S00_AXI_rvalid,
    S00_AXI_wdata,
    S00_AXI_wready,
    S00_AXI_wstrb,
    S00_AXI_wvalid,
    S01_ACLK,
    S01_ARESETN,
    S01_AXI_araddr,
    S01_AXI_arprot,
    S01_AXI_arready,
    S01_AXI_arvalid,
    S01_AXI_awaddr,
    S01_AXI_awprot,
    S01_AXI_awready,
    S01_AXI_awvalid,
    S01_AXI_bready,
    S01_AXI_bresp,
    S01_AXI_bvalid,
    S01_AXI_rdata,
    S01_AXI_rready,
    S01_AXI_rresp,
    S01_AXI_rvalid,
    S01_AXI_wdata,
    S01_AXI_wready,
    S01_AXI_wstrb,
    S01_AXI_wvalid,
    S02_ACLK,
    S02_ARESETN,
    S02_AXI_araddr,
    S02_AXI_arprot,
    S02_AXI_arready,
    S02_AXI_arvalid,
    S02_AXI_awaddr,
    S02_AXI_awprot,
    S02_AXI_awready,
    S02_AXI_awvalid,
    S02_AXI_bready,
    S02_AXI_bresp,
    S02_AXI_bvalid,
    S02_AXI_rdata,
    S02_AXI_rready,
    S02_AXI_rresp,
    S02_AXI_rvalid,
    S02_AXI_wdata,
    S02_AXI_wready,
    S02_AXI_wstrb,
    S02_AXI_wvalid,
    S03_ACLK,
    S03_ARESETN,
    S03_AXI_araddr,
    S03_AXI_arprot,
    S03_AXI_arready,
    S03_AXI_arvalid,
    S03_AXI_awaddr,
    S03_AXI_awprot,
    S03_AXI_awready,
    S03_AXI_awvalid,
    S03_AXI_bready,
    S03_AXI_bresp,
    S03_AXI_bvalid,
    S03_AXI_rdata,
    S03_AXI_rready,
    S03_AXI_rresp,
    S03_AXI_rvalid,
    S03_AXI_wdata,
    S03_AXI_wready,
    S03_AXI_wstrb,
    S03_AXI_wvalid,
    S04_ACLK,
    S04_ARESETN,
    S04_AXI_araddr,
    S04_AXI_arprot,
    S04_AXI_arready,
    S04_AXI_arvalid,
    S04_AXI_awaddr,
    S04_AXI_awprot,
    S04_AXI_awready,
    S04_AXI_awvalid,
    S04_AXI_bready,
    S04_AXI_bresp,
    S04_AXI_bvalid,
    S04_AXI_rdata,
    S04_AXI_rready,
    S04_AXI_rresp,
    S04_AXI_rvalid,
    S04_AXI_wdata,
    S04_AXI_wready,
    S04_AXI_wstrb,
    S04_AXI_wvalid,
    S05_ACLK,
    S05_ARESETN,
    S05_AXI_araddr,
    S05_AXI_arprot,
    S05_AXI_arready,
    S05_AXI_arvalid,
    S05_AXI_awaddr,
    S05_AXI_awprot,
    S05_AXI_awready,
    S05_AXI_awvalid,
    S05_AXI_bready,
    S05_AXI_bresp,
    S05_AXI_bvalid,
    S05_AXI_rdata,
    S05_AXI_rready,
    S05_AXI_rresp,
    S05_AXI_rvalid,
    S05_AXI_wdata,
    S05_AXI_wready,
    S05_AXI_wstrb,
    S05_AXI_wvalid,
    S06_ACLK,
    S06_ARESETN,
    S06_AXI_araddr,
    S06_AXI_arprot,
    S06_AXI_arready,
    S06_AXI_arvalid,
    S06_AXI_awaddr,
    S06_AXI_awprot,
    S06_AXI_awready,
    S06_AXI_awvalid,
    S06_AXI_bready,
    S06_AXI_bresp,
    S06_AXI_bvalid,
    S06_AXI_rdata,
    S06_AXI_rready,
    S06_AXI_rresp,
    S06_AXI_rvalid,
    S06_AXI_wdata,
    S06_AXI_wready,
    S06_AXI_wstrb,
    S06_AXI_wvalid);
  input ACLK;
  input ARESETN;
  input M00_ACLK;
  input M00_ARESETN;
  output [15:0]M00_AXI_araddr;
  output [2:0]M00_AXI_arprot;
  input M00_AXI_arready;
  output M00_AXI_arvalid;
  output [15:0]M00_AXI_awaddr;
  output [2:0]M00_AXI_awprot;
  input M00_AXI_awready;
  output M00_AXI_awvalid;
  output M00_AXI_bready;
  input [1:0]M00_AXI_bresp;
  input M00_AXI_bvalid;
  input [31:0]M00_AXI_rdata;
  output M00_AXI_rready;
  input [1:0]M00_AXI_rresp;
  input M00_AXI_rvalid;
  output [31:0]M00_AXI_wdata;
  input M00_AXI_wready;
  output [3:0]M00_AXI_wstrb;
  output M00_AXI_wvalid;
  input S00_ACLK;
  input S00_ARESETN;
  input [31:0]S00_AXI_araddr;
  input [2:0]S00_AXI_arprot;
  output [0:0]S00_AXI_arready;
  input [0:0]S00_AXI_arvalid;
  input [31:0]S00_AXI_awaddr;
  input [2:0]S00_AXI_awprot;
  output [0:0]S00_AXI_awready;
  input [0:0]S00_AXI_awvalid;
  input [0:0]S00_AXI_bready;
  output [1:0]S00_AXI_bresp;
  output [0:0]S00_AXI_bvalid;
  output [31:0]S00_AXI_rdata;
  input [0:0]S00_AXI_rready;
  output [1:0]S00_AXI_rresp;
  output [0:0]S00_AXI_rvalid;
  input [31:0]S00_AXI_wdata;
  output [0:0]S00_AXI_wready;
  input [3:0]S00_AXI_wstrb;
  input [0:0]S00_AXI_wvalid;
  input S01_ACLK;
  input S01_ARESETN;
  input [31:0]S01_AXI_araddr;
  input [2:0]S01_AXI_arprot;
  output [0:0]S01_AXI_arready;
  input [0:0]S01_AXI_arvalid;
  input [31:0]S01_AXI_awaddr;
  input [2:0]S01_AXI_awprot;
  output [0:0]S01_AXI_awready;
  input [0:0]S01_AXI_awvalid;
  input [0:0]S01_AXI_bready;
  output [1:0]S01_AXI_bresp;
  output [0:0]S01_AXI_bvalid;
  output [31:0]S01_AXI_rdata;
  input [0:0]S01_AXI_rready;
  output [1:0]S01_AXI_rresp;
  output [0:0]S01_AXI_rvalid;
  input [31:0]S01_AXI_wdata;
  output [0:0]S01_AXI_wready;
  input [3:0]S01_AXI_wstrb;
  input [0:0]S01_AXI_wvalid;
  input S02_ACLK;
  input S02_ARESETN;
  input [31:0]S02_AXI_araddr;
  input [2:0]S02_AXI_arprot;
  output [0:0]S02_AXI_arready;
  input [0:0]S02_AXI_arvalid;
  input [31:0]S02_AXI_awaddr;
  input [2:0]S02_AXI_awprot;
  output [0:0]S02_AXI_awready;
  input [0:0]S02_AXI_awvalid;
  input [0:0]S02_AXI_bready;
  output [1:0]S02_AXI_bresp;
  output [0:0]S02_AXI_bvalid;
  output [31:0]S02_AXI_rdata;
  input [0:0]S02_AXI_rready;
  output [1:0]S02_AXI_rresp;
  output [0:0]S02_AXI_rvalid;
  input [31:0]S02_AXI_wdata;
  output [0:0]S02_AXI_wready;
  input [3:0]S02_AXI_wstrb;
  input [0:0]S02_AXI_wvalid;
  input S03_ACLK;
  input S03_ARESETN;
  input [31:0]S03_AXI_araddr;
  input [2:0]S03_AXI_arprot;
  output S03_AXI_arready;
  input S03_AXI_arvalid;
  input [31:0]S03_AXI_awaddr;
  input [2:0]S03_AXI_awprot;
  output S03_AXI_awready;
  input S03_AXI_awvalid;
  input S03_AXI_bready;
  output [1:0]S03_AXI_bresp;
  output S03_AXI_bvalid;
  output [31:0]S03_AXI_rdata;
  input S03_AXI_rready;
  output [1:0]S03_AXI_rresp;
  output S03_AXI_rvalid;
  input [31:0]S03_AXI_wdata;
  output S03_AXI_wready;
  input [3:0]S03_AXI_wstrb;
  input S03_AXI_wvalid;
  input S04_ACLK;
  input S04_ARESETN;
  input [31:0]S04_AXI_araddr;
  input [2:0]S04_AXI_arprot;
  output [0:0]S04_AXI_arready;
  input [0:0]S04_AXI_arvalid;
  input [31:0]S04_AXI_awaddr;
  input [2:0]S04_AXI_awprot;
  output [0:0]S04_AXI_awready;
  input [0:0]S04_AXI_awvalid;
  input [0:0]S04_AXI_bready;
  output [1:0]S04_AXI_bresp;
  output [0:0]S04_AXI_bvalid;
  output [31:0]S04_AXI_rdata;
  input [0:0]S04_AXI_rready;
  output [1:0]S04_AXI_rresp;
  output [0:0]S04_AXI_rvalid;
  input [31:0]S04_AXI_wdata;
  output [0:0]S04_AXI_wready;
  input [3:0]S04_AXI_wstrb;
  input [0:0]S04_AXI_wvalid;
  input S05_ACLK;
  input S05_ARESETN;
  input [31:0]S05_AXI_araddr;
  input [2:0]S05_AXI_arprot;
  output [0:0]S05_AXI_arready;
  input [0:0]S05_AXI_arvalid;
  input [31:0]S05_AXI_awaddr;
  input [2:0]S05_AXI_awprot;
  output [0:0]S05_AXI_awready;
  input [0:0]S05_AXI_awvalid;
  input [0:0]S05_AXI_bready;
  output [1:0]S05_AXI_bresp;
  output [0:0]S05_AXI_bvalid;
  output [31:0]S05_AXI_rdata;
  input [0:0]S05_AXI_rready;
  output [1:0]S05_AXI_rresp;
  output [0:0]S05_AXI_rvalid;
  input [31:0]S05_AXI_wdata;
  output [0:0]S05_AXI_wready;
  input [3:0]S05_AXI_wstrb;
  input [0:0]S05_AXI_wvalid;
  input S06_ACLK;
  input S06_ARESETN;
  input [31:0]S06_AXI_araddr;
  input [2:0]S06_AXI_arprot;
  output [0:0]S06_AXI_arready;
  input [0:0]S06_AXI_arvalid;
  input [31:0]S06_AXI_awaddr;
  input [2:0]S06_AXI_awprot;
  output [0:0]S06_AXI_awready;
  input [0:0]S06_AXI_awvalid;
  input [0:0]S06_AXI_bready;
  output [1:0]S06_AXI_bresp;
  output [0:0]S06_AXI_bvalid;
  output [31:0]S06_AXI_rdata;
  input [0:0]S06_AXI_rready;
  output [1:0]S06_AXI_rresp;
  output [0:0]S06_AXI_rvalid;
  input [31:0]S06_AXI_wdata;
  output [0:0]S06_AXI_wready;
  input [3:0]S06_AXI_wstrb;
  input [0:0]S06_AXI_wvalid;

  wire axi_mem_intercon_ACLK_net;
  wire axi_mem_intercon_ARESETN_net;
  wire [31:0]axi_mem_intercon_to_s00_couplers_ARADDR;
  wire [2:0]axi_mem_intercon_to_s00_couplers_ARPROT;
  wire [0:0]axi_mem_intercon_to_s00_couplers_ARREADY;
  wire [0:0]axi_mem_intercon_to_s00_couplers_ARVALID;
  wire [31:0]axi_mem_intercon_to_s00_couplers_AWADDR;
  wire [2:0]axi_mem_intercon_to_s00_couplers_AWPROT;
  wire [0:0]axi_mem_intercon_to_s00_couplers_AWREADY;
  wire [0:0]axi_mem_intercon_to_s00_couplers_AWVALID;
  wire [0:0]axi_mem_intercon_to_s00_couplers_BREADY;
  wire [1:0]axi_mem_intercon_to_s00_couplers_BRESP;
  wire [0:0]axi_mem_intercon_to_s00_couplers_BVALID;
  wire [31:0]axi_mem_intercon_to_s00_couplers_RDATA;
  wire [0:0]axi_mem_intercon_to_s00_couplers_RREADY;
  wire [1:0]axi_mem_intercon_to_s00_couplers_RRESP;
  wire [0:0]axi_mem_intercon_to_s00_couplers_RVALID;
  wire [31:0]axi_mem_intercon_to_s00_couplers_WDATA;
  wire [0:0]axi_mem_intercon_to_s00_couplers_WREADY;
  wire [3:0]axi_mem_intercon_to_s00_couplers_WSTRB;
  wire [0:0]axi_mem_intercon_to_s00_couplers_WVALID;
  wire [31:0]axi_mem_intercon_to_s01_couplers_ARADDR;
  wire [2:0]axi_mem_intercon_to_s01_couplers_ARPROT;
  wire [0:0]axi_mem_intercon_to_s01_couplers_ARREADY;
  wire [0:0]axi_mem_intercon_to_s01_couplers_ARVALID;
  wire [31:0]axi_mem_intercon_to_s01_couplers_AWADDR;
  wire [2:0]axi_mem_intercon_to_s01_couplers_AWPROT;
  wire [0:0]axi_mem_intercon_to_s01_couplers_AWREADY;
  wire [0:0]axi_mem_intercon_to_s01_couplers_AWVALID;
  wire [0:0]axi_mem_intercon_to_s01_couplers_BREADY;
  wire [1:0]axi_mem_intercon_to_s01_couplers_BRESP;
  wire [0:0]axi_mem_intercon_to_s01_couplers_BVALID;
  wire [31:0]axi_mem_intercon_to_s01_couplers_RDATA;
  wire [0:0]axi_mem_intercon_to_s01_couplers_RREADY;
  wire [1:0]axi_mem_intercon_to_s01_couplers_RRESP;
  wire [0:0]axi_mem_intercon_to_s01_couplers_RVALID;
  wire [31:0]axi_mem_intercon_to_s01_couplers_WDATA;
  wire [0:0]axi_mem_intercon_to_s01_couplers_WREADY;
  wire [3:0]axi_mem_intercon_to_s01_couplers_WSTRB;
  wire [0:0]axi_mem_intercon_to_s01_couplers_WVALID;
  wire [31:0]axi_mem_intercon_to_s02_couplers_ARADDR;
  wire [2:0]axi_mem_intercon_to_s02_couplers_ARPROT;
  wire [0:0]axi_mem_intercon_to_s02_couplers_ARREADY;
  wire [0:0]axi_mem_intercon_to_s02_couplers_ARVALID;
  wire [31:0]axi_mem_intercon_to_s02_couplers_AWADDR;
  wire [2:0]axi_mem_intercon_to_s02_couplers_AWPROT;
  wire [0:0]axi_mem_intercon_to_s02_couplers_AWREADY;
  wire [0:0]axi_mem_intercon_to_s02_couplers_AWVALID;
  wire [0:0]axi_mem_intercon_to_s02_couplers_BREADY;
  wire [1:0]axi_mem_intercon_to_s02_couplers_BRESP;
  wire [0:0]axi_mem_intercon_to_s02_couplers_BVALID;
  wire [31:0]axi_mem_intercon_to_s02_couplers_RDATA;
  wire [0:0]axi_mem_intercon_to_s02_couplers_RREADY;
  wire [1:0]axi_mem_intercon_to_s02_couplers_RRESP;
  wire [0:0]axi_mem_intercon_to_s02_couplers_RVALID;
  wire [31:0]axi_mem_intercon_to_s02_couplers_WDATA;
  wire [0:0]axi_mem_intercon_to_s02_couplers_WREADY;
  wire [3:0]axi_mem_intercon_to_s02_couplers_WSTRB;
  wire [0:0]axi_mem_intercon_to_s02_couplers_WVALID;
  wire [31:0]axi_mem_intercon_to_s03_couplers_ARADDR;
  wire [2:0]axi_mem_intercon_to_s03_couplers_ARPROT;
  wire axi_mem_intercon_to_s03_couplers_ARREADY;
  wire axi_mem_intercon_to_s03_couplers_ARVALID;
  wire [31:0]axi_mem_intercon_to_s03_couplers_AWADDR;
  wire [2:0]axi_mem_intercon_to_s03_couplers_AWPROT;
  wire axi_mem_intercon_to_s03_couplers_AWREADY;
  wire axi_mem_intercon_to_s03_couplers_AWVALID;
  wire axi_mem_intercon_to_s03_couplers_BREADY;
  wire [1:0]axi_mem_intercon_to_s03_couplers_BRESP;
  wire axi_mem_intercon_to_s03_couplers_BVALID;
  wire [31:0]axi_mem_intercon_to_s03_couplers_RDATA;
  wire axi_mem_intercon_to_s03_couplers_RREADY;
  wire [1:0]axi_mem_intercon_to_s03_couplers_RRESP;
  wire axi_mem_intercon_to_s03_couplers_RVALID;
  wire [31:0]axi_mem_intercon_to_s03_couplers_WDATA;
  wire axi_mem_intercon_to_s03_couplers_WREADY;
  wire [3:0]axi_mem_intercon_to_s03_couplers_WSTRB;
  wire axi_mem_intercon_to_s03_couplers_WVALID;
  wire [31:0]axi_mem_intercon_to_s04_couplers_ARADDR;
  wire [2:0]axi_mem_intercon_to_s04_couplers_ARPROT;
  wire [0:0]axi_mem_intercon_to_s04_couplers_ARREADY;
  wire [0:0]axi_mem_intercon_to_s04_couplers_ARVALID;
  wire [31:0]axi_mem_intercon_to_s04_couplers_AWADDR;
  wire [2:0]axi_mem_intercon_to_s04_couplers_AWPROT;
  wire [0:0]axi_mem_intercon_to_s04_couplers_AWREADY;
  wire [0:0]axi_mem_intercon_to_s04_couplers_AWVALID;
  wire [0:0]axi_mem_intercon_to_s04_couplers_BREADY;
  wire [1:0]axi_mem_intercon_to_s04_couplers_BRESP;
  wire [0:0]axi_mem_intercon_to_s04_couplers_BVALID;
  wire [31:0]axi_mem_intercon_to_s04_couplers_RDATA;
  wire [0:0]axi_mem_intercon_to_s04_couplers_RREADY;
  wire [1:0]axi_mem_intercon_to_s04_couplers_RRESP;
  wire [0:0]axi_mem_intercon_to_s04_couplers_RVALID;
  wire [31:0]axi_mem_intercon_to_s04_couplers_WDATA;
  wire [0:0]axi_mem_intercon_to_s04_couplers_WREADY;
  wire [3:0]axi_mem_intercon_to_s04_couplers_WSTRB;
  wire [0:0]axi_mem_intercon_to_s04_couplers_WVALID;
  wire [31:0]axi_mem_intercon_to_s05_couplers_ARADDR;
  wire [2:0]axi_mem_intercon_to_s05_couplers_ARPROT;
  wire [0:0]axi_mem_intercon_to_s05_couplers_ARREADY;
  wire [0:0]axi_mem_intercon_to_s05_couplers_ARVALID;
  wire [31:0]axi_mem_intercon_to_s05_couplers_AWADDR;
  wire [2:0]axi_mem_intercon_to_s05_couplers_AWPROT;
  wire [0:0]axi_mem_intercon_to_s05_couplers_AWREADY;
  wire [0:0]axi_mem_intercon_to_s05_couplers_AWVALID;
  wire [0:0]axi_mem_intercon_to_s05_couplers_BREADY;
  wire [1:0]axi_mem_intercon_to_s05_couplers_BRESP;
  wire [0:0]axi_mem_intercon_to_s05_couplers_BVALID;
  wire [31:0]axi_mem_intercon_to_s05_couplers_RDATA;
  wire [0:0]axi_mem_intercon_to_s05_couplers_RREADY;
  wire [1:0]axi_mem_intercon_to_s05_couplers_RRESP;
  wire [0:0]axi_mem_intercon_to_s05_couplers_RVALID;
  wire [31:0]axi_mem_intercon_to_s05_couplers_WDATA;
  wire [0:0]axi_mem_intercon_to_s05_couplers_WREADY;
  wire [3:0]axi_mem_intercon_to_s05_couplers_WSTRB;
  wire [0:0]axi_mem_intercon_to_s05_couplers_WVALID;
  wire [31:0]axi_mem_intercon_to_s06_couplers_ARADDR;
  wire [2:0]axi_mem_intercon_to_s06_couplers_ARPROT;
  wire [0:0]axi_mem_intercon_to_s06_couplers_ARREADY;
  wire [0:0]axi_mem_intercon_to_s06_couplers_ARVALID;
  wire [31:0]axi_mem_intercon_to_s06_couplers_AWADDR;
  wire [2:0]axi_mem_intercon_to_s06_couplers_AWPROT;
  wire [0:0]axi_mem_intercon_to_s06_couplers_AWREADY;
  wire [0:0]axi_mem_intercon_to_s06_couplers_AWVALID;
  wire [0:0]axi_mem_intercon_to_s06_couplers_BREADY;
  wire [1:0]axi_mem_intercon_to_s06_couplers_BRESP;
  wire [0:0]axi_mem_intercon_to_s06_couplers_BVALID;
  wire [31:0]axi_mem_intercon_to_s06_couplers_RDATA;
  wire [0:0]axi_mem_intercon_to_s06_couplers_RREADY;
  wire [1:0]axi_mem_intercon_to_s06_couplers_RRESP;
  wire [0:0]axi_mem_intercon_to_s06_couplers_RVALID;
  wire [31:0]axi_mem_intercon_to_s06_couplers_WDATA;
  wire [0:0]axi_mem_intercon_to_s06_couplers_WREADY;
  wire [3:0]axi_mem_intercon_to_s06_couplers_WSTRB;
  wire [0:0]axi_mem_intercon_to_s06_couplers_WVALID;
  wire [15:0]m00_couplers_to_axi_mem_intercon_ARADDR;
  wire [2:0]m00_couplers_to_axi_mem_intercon_ARPROT;
  wire m00_couplers_to_axi_mem_intercon_ARREADY;
  wire m00_couplers_to_axi_mem_intercon_ARVALID;
  wire [15:0]m00_couplers_to_axi_mem_intercon_AWADDR;
  wire [2:0]m00_couplers_to_axi_mem_intercon_AWPROT;
  wire m00_couplers_to_axi_mem_intercon_AWREADY;
  wire m00_couplers_to_axi_mem_intercon_AWVALID;
  wire m00_couplers_to_axi_mem_intercon_BREADY;
  wire [1:0]m00_couplers_to_axi_mem_intercon_BRESP;
  wire m00_couplers_to_axi_mem_intercon_BVALID;
  wire [31:0]m00_couplers_to_axi_mem_intercon_RDATA;
  wire m00_couplers_to_axi_mem_intercon_RREADY;
  wire [1:0]m00_couplers_to_axi_mem_intercon_RRESP;
  wire m00_couplers_to_axi_mem_intercon_RVALID;
  wire [31:0]m00_couplers_to_axi_mem_intercon_WDATA;
  wire m00_couplers_to_axi_mem_intercon_WREADY;
  wire [3:0]m00_couplers_to_axi_mem_intercon_WSTRB;
  wire m00_couplers_to_axi_mem_intercon_WVALID;
  wire [31:0]s00_couplers_to_xbar_ARADDR;
  wire [2:0]s00_couplers_to_xbar_ARPROT;
  wire [0:0]s00_couplers_to_xbar_ARREADY;
  wire [0:0]s00_couplers_to_xbar_ARVALID;
  wire [31:0]s00_couplers_to_xbar_AWADDR;
  wire [2:0]s00_couplers_to_xbar_AWPROT;
  wire [0:0]s00_couplers_to_xbar_AWREADY;
  wire [0:0]s00_couplers_to_xbar_AWVALID;
  wire [0:0]s00_couplers_to_xbar_BREADY;
  wire [1:0]s00_couplers_to_xbar_BRESP;
  wire [0:0]s00_couplers_to_xbar_BVALID;
  wire [31:0]s00_couplers_to_xbar_RDATA;
  wire [0:0]s00_couplers_to_xbar_RREADY;
  wire [1:0]s00_couplers_to_xbar_RRESP;
  wire [0:0]s00_couplers_to_xbar_RVALID;
  wire [31:0]s00_couplers_to_xbar_WDATA;
  wire [0:0]s00_couplers_to_xbar_WREADY;
  wire [3:0]s00_couplers_to_xbar_WSTRB;
  wire [0:0]s00_couplers_to_xbar_WVALID;
  wire [31:0]s01_couplers_to_xbar_ARADDR;
  wire [2:0]s01_couplers_to_xbar_ARPROT;
  wire [1:1]s01_couplers_to_xbar_ARREADY;
  wire [0:0]s01_couplers_to_xbar_ARVALID;
  wire [31:0]s01_couplers_to_xbar_AWADDR;
  wire [2:0]s01_couplers_to_xbar_AWPROT;
  wire [1:1]s01_couplers_to_xbar_AWREADY;
  wire [0:0]s01_couplers_to_xbar_AWVALID;
  wire [0:0]s01_couplers_to_xbar_BREADY;
  wire [3:2]s01_couplers_to_xbar_BRESP;
  wire [1:1]s01_couplers_to_xbar_BVALID;
  wire [63:32]s01_couplers_to_xbar_RDATA;
  wire [0:0]s01_couplers_to_xbar_RREADY;
  wire [3:2]s01_couplers_to_xbar_RRESP;
  wire [1:1]s01_couplers_to_xbar_RVALID;
  wire [31:0]s01_couplers_to_xbar_WDATA;
  wire [1:1]s01_couplers_to_xbar_WREADY;
  wire [3:0]s01_couplers_to_xbar_WSTRB;
  wire [0:0]s01_couplers_to_xbar_WVALID;
  wire [31:0]s02_couplers_to_xbar_ARADDR;
  wire [2:0]s02_couplers_to_xbar_ARPROT;
  wire [2:2]s02_couplers_to_xbar_ARREADY;
  wire [0:0]s02_couplers_to_xbar_ARVALID;
  wire [31:0]s02_couplers_to_xbar_AWADDR;
  wire [2:0]s02_couplers_to_xbar_AWPROT;
  wire [2:2]s02_couplers_to_xbar_AWREADY;
  wire [0:0]s02_couplers_to_xbar_AWVALID;
  wire [0:0]s02_couplers_to_xbar_BREADY;
  wire [5:4]s02_couplers_to_xbar_BRESP;
  wire [2:2]s02_couplers_to_xbar_BVALID;
  wire [95:64]s02_couplers_to_xbar_RDATA;
  wire [0:0]s02_couplers_to_xbar_RREADY;
  wire [5:4]s02_couplers_to_xbar_RRESP;
  wire [2:2]s02_couplers_to_xbar_RVALID;
  wire [31:0]s02_couplers_to_xbar_WDATA;
  wire [2:2]s02_couplers_to_xbar_WREADY;
  wire [3:0]s02_couplers_to_xbar_WSTRB;
  wire [0:0]s02_couplers_to_xbar_WVALID;
  wire [31:0]s03_couplers_to_xbar_ARADDR;
  wire [2:0]s03_couplers_to_xbar_ARPROT;
  wire [3:3]s03_couplers_to_xbar_ARREADY;
  wire s03_couplers_to_xbar_ARVALID;
  wire [31:0]s03_couplers_to_xbar_AWADDR;
  wire [2:0]s03_couplers_to_xbar_AWPROT;
  wire [3:3]s03_couplers_to_xbar_AWREADY;
  wire s03_couplers_to_xbar_AWVALID;
  wire s03_couplers_to_xbar_BREADY;
  wire [7:6]s03_couplers_to_xbar_BRESP;
  wire [3:3]s03_couplers_to_xbar_BVALID;
  wire [127:96]s03_couplers_to_xbar_RDATA;
  wire s03_couplers_to_xbar_RREADY;
  wire [7:6]s03_couplers_to_xbar_RRESP;
  wire [3:3]s03_couplers_to_xbar_RVALID;
  wire [31:0]s03_couplers_to_xbar_WDATA;
  wire [3:3]s03_couplers_to_xbar_WREADY;
  wire [3:0]s03_couplers_to_xbar_WSTRB;
  wire s03_couplers_to_xbar_WVALID;
  wire [31:0]s04_couplers_to_xbar_ARADDR;
  wire [2:0]s04_couplers_to_xbar_ARPROT;
  wire [4:4]s04_couplers_to_xbar_ARREADY;
  wire [0:0]s04_couplers_to_xbar_ARVALID;
  wire [31:0]s04_couplers_to_xbar_AWADDR;
  wire [2:0]s04_couplers_to_xbar_AWPROT;
  wire [4:4]s04_couplers_to_xbar_AWREADY;
  wire [0:0]s04_couplers_to_xbar_AWVALID;
  wire [0:0]s04_couplers_to_xbar_BREADY;
  wire [9:8]s04_couplers_to_xbar_BRESP;
  wire [4:4]s04_couplers_to_xbar_BVALID;
  wire [159:128]s04_couplers_to_xbar_RDATA;
  wire [0:0]s04_couplers_to_xbar_RREADY;
  wire [9:8]s04_couplers_to_xbar_RRESP;
  wire [4:4]s04_couplers_to_xbar_RVALID;
  wire [31:0]s04_couplers_to_xbar_WDATA;
  wire [4:4]s04_couplers_to_xbar_WREADY;
  wire [3:0]s04_couplers_to_xbar_WSTRB;
  wire [0:0]s04_couplers_to_xbar_WVALID;
  wire [31:0]s05_couplers_to_xbar_ARADDR;
  wire [2:0]s05_couplers_to_xbar_ARPROT;
  wire [5:5]s05_couplers_to_xbar_ARREADY;
  wire [0:0]s05_couplers_to_xbar_ARVALID;
  wire [31:0]s05_couplers_to_xbar_AWADDR;
  wire [2:0]s05_couplers_to_xbar_AWPROT;
  wire [5:5]s05_couplers_to_xbar_AWREADY;
  wire [0:0]s05_couplers_to_xbar_AWVALID;
  wire [0:0]s05_couplers_to_xbar_BREADY;
  wire [11:10]s05_couplers_to_xbar_BRESP;
  wire [5:5]s05_couplers_to_xbar_BVALID;
  wire [191:160]s05_couplers_to_xbar_RDATA;
  wire [0:0]s05_couplers_to_xbar_RREADY;
  wire [11:10]s05_couplers_to_xbar_RRESP;
  wire [5:5]s05_couplers_to_xbar_RVALID;
  wire [31:0]s05_couplers_to_xbar_WDATA;
  wire [5:5]s05_couplers_to_xbar_WREADY;
  wire [3:0]s05_couplers_to_xbar_WSTRB;
  wire [0:0]s05_couplers_to_xbar_WVALID;
  wire [31:0]s06_couplers_to_xbar_ARADDR;
  wire [2:0]s06_couplers_to_xbar_ARPROT;
  wire [6:6]s06_couplers_to_xbar_ARREADY;
  wire [0:0]s06_couplers_to_xbar_ARVALID;
  wire [31:0]s06_couplers_to_xbar_AWADDR;
  wire [2:0]s06_couplers_to_xbar_AWPROT;
  wire [6:6]s06_couplers_to_xbar_AWREADY;
  wire [0:0]s06_couplers_to_xbar_AWVALID;
  wire [0:0]s06_couplers_to_xbar_BREADY;
  wire [13:12]s06_couplers_to_xbar_BRESP;
  wire [6:6]s06_couplers_to_xbar_BVALID;
  wire [223:192]s06_couplers_to_xbar_RDATA;
  wire [0:0]s06_couplers_to_xbar_RREADY;
  wire [13:12]s06_couplers_to_xbar_RRESP;
  wire [6:6]s06_couplers_to_xbar_RVALID;
  wire [31:0]s06_couplers_to_xbar_WDATA;
  wire [6:6]s06_couplers_to_xbar_WREADY;
  wire [3:0]s06_couplers_to_xbar_WSTRB;
  wire [0:0]s06_couplers_to_xbar_WVALID;
  wire [31:0]xbar_to_m00_couplers_ARADDR;
  wire [2:0]xbar_to_m00_couplers_ARPROT;
  wire xbar_to_m00_couplers_ARREADY;
  wire [0:0]xbar_to_m00_couplers_ARVALID;
  wire [31:0]xbar_to_m00_couplers_AWADDR;
  wire [2:0]xbar_to_m00_couplers_AWPROT;
  wire xbar_to_m00_couplers_AWREADY;
  wire [0:0]xbar_to_m00_couplers_AWVALID;
  wire [0:0]xbar_to_m00_couplers_BREADY;
  wire [1:0]xbar_to_m00_couplers_BRESP;
  wire xbar_to_m00_couplers_BVALID;
  wire [31:0]xbar_to_m00_couplers_RDATA;
  wire [0:0]xbar_to_m00_couplers_RREADY;
  wire [1:0]xbar_to_m00_couplers_RRESP;
  wire xbar_to_m00_couplers_RVALID;
  wire [31:0]xbar_to_m00_couplers_WDATA;
  wire xbar_to_m00_couplers_WREADY;
  wire [3:0]xbar_to_m00_couplers_WSTRB;
  wire [0:0]xbar_to_m00_couplers_WVALID;

  assign M00_AXI_araddr[15:0] = m00_couplers_to_axi_mem_intercon_ARADDR;
  assign M00_AXI_arprot[2:0] = m00_couplers_to_axi_mem_intercon_ARPROT;
  assign M00_AXI_arvalid = m00_couplers_to_axi_mem_intercon_ARVALID;
  assign M00_AXI_awaddr[15:0] = m00_couplers_to_axi_mem_intercon_AWADDR;
  assign M00_AXI_awprot[2:0] = m00_couplers_to_axi_mem_intercon_AWPROT;
  assign M00_AXI_awvalid = m00_couplers_to_axi_mem_intercon_AWVALID;
  assign M00_AXI_bready = m00_couplers_to_axi_mem_intercon_BREADY;
  assign M00_AXI_rready = m00_couplers_to_axi_mem_intercon_RREADY;
  assign M00_AXI_wdata[31:0] = m00_couplers_to_axi_mem_intercon_WDATA;
  assign M00_AXI_wstrb[3:0] = m00_couplers_to_axi_mem_intercon_WSTRB;
  assign M00_AXI_wvalid = m00_couplers_to_axi_mem_intercon_WVALID;
  assign S00_AXI_arready[0] = axi_mem_intercon_to_s00_couplers_ARREADY;
  assign S00_AXI_awready[0] = axi_mem_intercon_to_s00_couplers_AWREADY;
  assign S00_AXI_bresp[1:0] = axi_mem_intercon_to_s00_couplers_BRESP;
  assign S00_AXI_bvalid[0] = axi_mem_intercon_to_s00_couplers_BVALID;
  assign S00_AXI_rdata[31:0] = axi_mem_intercon_to_s00_couplers_RDATA;
  assign S00_AXI_rresp[1:0] = axi_mem_intercon_to_s00_couplers_RRESP;
  assign S00_AXI_rvalid[0] = axi_mem_intercon_to_s00_couplers_RVALID;
  assign S00_AXI_wready[0] = axi_mem_intercon_to_s00_couplers_WREADY;
  assign S01_AXI_arready[0] = axi_mem_intercon_to_s01_couplers_ARREADY;
  assign S01_AXI_awready[0] = axi_mem_intercon_to_s01_couplers_AWREADY;
  assign S01_AXI_bresp[1:0] = axi_mem_intercon_to_s01_couplers_BRESP;
  assign S01_AXI_bvalid[0] = axi_mem_intercon_to_s01_couplers_BVALID;
  assign S01_AXI_rdata[31:0] = axi_mem_intercon_to_s01_couplers_RDATA;
  assign S01_AXI_rresp[1:0] = axi_mem_intercon_to_s01_couplers_RRESP;
  assign S01_AXI_rvalid[0] = axi_mem_intercon_to_s01_couplers_RVALID;
  assign S01_AXI_wready[0] = axi_mem_intercon_to_s01_couplers_WREADY;
  assign S02_AXI_arready[0] = axi_mem_intercon_to_s02_couplers_ARREADY;
  assign S02_AXI_awready[0] = axi_mem_intercon_to_s02_couplers_AWREADY;
  assign S02_AXI_bresp[1:0] = axi_mem_intercon_to_s02_couplers_BRESP;
  assign S02_AXI_bvalid[0] = axi_mem_intercon_to_s02_couplers_BVALID;
  assign S02_AXI_rdata[31:0] = axi_mem_intercon_to_s02_couplers_RDATA;
  assign S02_AXI_rresp[1:0] = axi_mem_intercon_to_s02_couplers_RRESP;
  assign S02_AXI_rvalid[0] = axi_mem_intercon_to_s02_couplers_RVALID;
  assign S02_AXI_wready[0] = axi_mem_intercon_to_s02_couplers_WREADY;
  assign S03_AXI_arready = axi_mem_intercon_to_s03_couplers_ARREADY;
  assign S03_AXI_awready = axi_mem_intercon_to_s03_couplers_AWREADY;
  assign S03_AXI_bresp[1:0] = axi_mem_intercon_to_s03_couplers_BRESP;
  assign S03_AXI_bvalid = axi_mem_intercon_to_s03_couplers_BVALID;
  assign S03_AXI_rdata[31:0] = axi_mem_intercon_to_s03_couplers_RDATA;
  assign S03_AXI_rresp[1:0] = axi_mem_intercon_to_s03_couplers_RRESP;
  assign S03_AXI_rvalid = axi_mem_intercon_to_s03_couplers_RVALID;
  assign S03_AXI_wready = axi_mem_intercon_to_s03_couplers_WREADY;
  assign S04_AXI_arready[0] = axi_mem_intercon_to_s04_couplers_ARREADY;
  assign S04_AXI_awready[0] = axi_mem_intercon_to_s04_couplers_AWREADY;
  assign S04_AXI_bresp[1:0] = axi_mem_intercon_to_s04_couplers_BRESP;
  assign S04_AXI_bvalid[0] = axi_mem_intercon_to_s04_couplers_BVALID;
  assign S04_AXI_rdata[31:0] = axi_mem_intercon_to_s04_couplers_RDATA;
  assign S04_AXI_rresp[1:0] = axi_mem_intercon_to_s04_couplers_RRESP;
  assign S04_AXI_rvalid[0] = axi_mem_intercon_to_s04_couplers_RVALID;
  assign S04_AXI_wready[0] = axi_mem_intercon_to_s04_couplers_WREADY;
  assign S05_AXI_arready[0] = axi_mem_intercon_to_s05_couplers_ARREADY;
  assign S05_AXI_awready[0] = axi_mem_intercon_to_s05_couplers_AWREADY;
  assign S05_AXI_bresp[1:0] = axi_mem_intercon_to_s05_couplers_BRESP;
  assign S05_AXI_bvalid[0] = axi_mem_intercon_to_s05_couplers_BVALID;
  assign S05_AXI_rdata[31:0] = axi_mem_intercon_to_s05_couplers_RDATA;
  assign S05_AXI_rresp[1:0] = axi_mem_intercon_to_s05_couplers_RRESP;
  assign S05_AXI_rvalid[0] = axi_mem_intercon_to_s05_couplers_RVALID;
  assign S05_AXI_wready[0] = axi_mem_intercon_to_s05_couplers_WREADY;
  assign S06_AXI_arready[0] = axi_mem_intercon_to_s06_couplers_ARREADY;
  assign S06_AXI_awready[0] = axi_mem_intercon_to_s06_couplers_AWREADY;
  assign S06_AXI_bresp[1:0] = axi_mem_intercon_to_s06_couplers_BRESP;
  assign S06_AXI_bvalid[0] = axi_mem_intercon_to_s06_couplers_BVALID;
  assign S06_AXI_rdata[31:0] = axi_mem_intercon_to_s06_couplers_RDATA;
  assign S06_AXI_rresp[1:0] = axi_mem_intercon_to_s06_couplers_RRESP;
  assign S06_AXI_rvalid[0] = axi_mem_intercon_to_s06_couplers_RVALID;
  assign S06_AXI_wready[0] = axi_mem_intercon_to_s06_couplers_WREADY;
  assign axi_mem_intercon_ACLK_net = ACLK;
  assign axi_mem_intercon_ARESETN_net = ARESETN;
  assign axi_mem_intercon_to_s00_couplers_ARADDR = S00_AXI_araddr[31:0];
  assign axi_mem_intercon_to_s00_couplers_ARPROT = S00_AXI_arprot[2:0];
  assign axi_mem_intercon_to_s00_couplers_ARVALID = S00_AXI_arvalid[0];
  assign axi_mem_intercon_to_s00_couplers_AWADDR = S00_AXI_awaddr[31:0];
  assign axi_mem_intercon_to_s00_couplers_AWPROT = S00_AXI_awprot[2:0];
  assign axi_mem_intercon_to_s00_couplers_AWVALID = S00_AXI_awvalid[0];
  assign axi_mem_intercon_to_s00_couplers_BREADY = S00_AXI_bready[0];
  assign axi_mem_intercon_to_s00_couplers_RREADY = S00_AXI_rready[0];
  assign axi_mem_intercon_to_s00_couplers_WDATA = S00_AXI_wdata[31:0];
  assign axi_mem_intercon_to_s00_couplers_WSTRB = S00_AXI_wstrb[3:0];
  assign axi_mem_intercon_to_s00_couplers_WVALID = S00_AXI_wvalid[0];
  assign axi_mem_intercon_to_s01_couplers_ARADDR = S01_AXI_araddr[31:0];
  assign axi_mem_intercon_to_s01_couplers_ARPROT = S01_AXI_arprot[2:0];
  assign axi_mem_intercon_to_s01_couplers_ARVALID = S01_AXI_arvalid[0];
  assign axi_mem_intercon_to_s01_couplers_AWADDR = S01_AXI_awaddr[31:0];
  assign axi_mem_intercon_to_s01_couplers_AWPROT = S01_AXI_awprot[2:0];
  assign axi_mem_intercon_to_s01_couplers_AWVALID = S01_AXI_awvalid[0];
  assign axi_mem_intercon_to_s01_couplers_BREADY = S01_AXI_bready[0];
  assign axi_mem_intercon_to_s01_couplers_RREADY = S01_AXI_rready[0];
  assign axi_mem_intercon_to_s01_couplers_WDATA = S01_AXI_wdata[31:0];
  assign axi_mem_intercon_to_s01_couplers_WSTRB = S01_AXI_wstrb[3:0];
  assign axi_mem_intercon_to_s01_couplers_WVALID = S01_AXI_wvalid[0];
  assign axi_mem_intercon_to_s02_couplers_ARADDR = S02_AXI_araddr[31:0];
  assign axi_mem_intercon_to_s02_couplers_ARPROT = S02_AXI_arprot[2:0];
  assign axi_mem_intercon_to_s02_couplers_ARVALID = S02_AXI_arvalid[0];
  assign axi_mem_intercon_to_s02_couplers_AWADDR = S02_AXI_awaddr[31:0];
  assign axi_mem_intercon_to_s02_couplers_AWPROT = S02_AXI_awprot[2:0];
  assign axi_mem_intercon_to_s02_couplers_AWVALID = S02_AXI_awvalid[0];
  assign axi_mem_intercon_to_s02_couplers_BREADY = S02_AXI_bready[0];
  assign axi_mem_intercon_to_s02_couplers_RREADY = S02_AXI_rready[0];
  assign axi_mem_intercon_to_s02_couplers_WDATA = S02_AXI_wdata[31:0];
  assign axi_mem_intercon_to_s02_couplers_WSTRB = S02_AXI_wstrb[3:0];
  assign axi_mem_intercon_to_s02_couplers_WVALID = S02_AXI_wvalid[0];
  assign axi_mem_intercon_to_s03_couplers_ARADDR = S03_AXI_araddr[31:0];
  assign axi_mem_intercon_to_s03_couplers_ARPROT = S03_AXI_arprot[2:0];
  assign axi_mem_intercon_to_s03_couplers_ARVALID = S03_AXI_arvalid;
  assign axi_mem_intercon_to_s03_couplers_AWADDR = S03_AXI_awaddr[31:0];
  assign axi_mem_intercon_to_s03_couplers_AWPROT = S03_AXI_awprot[2:0];
  assign axi_mem_intercon_to_s03_couplers_AWVALID = S03_AXI_awvalid;
  assign axi_mem_intercon_to_s03_couplers_BREADY = S03_AXI_bready;
  assign axi_mem_intercon_to_s03_couplers_RREADY = S03_AXI_rready;
  assign axi_mem_intercon_to_s03_couplers_WDATA = S03_AXI_wdata[31:0];
  assign axi_mem_intercon_to_s03_couplers_WSTRB = S03_AXI_wstrb[3:0];
  assign axi_mem_intercon_to_s03_couplers_WVALID = S03_AXI_wvalid;
  assign axi_mem_intercon_to_s04_couplers_ARADDR = S04_AXI_araddr[31:0];
  assign axi_mem_intercon_to_s04_couplers_ARPROT = S04_AXI_arprot[2:0];
  assign axi_mem_intercon_to_s04_couplers_ARVALID = S04_AXI_arvalid[0];
  assign axi_mem_intercon_to_s04_couplers_AWADDR = S04_AXI_awaddr[31:0];
  assign axi_mem_intercon_to_s04_couplers_AWPROT = S04_AXI_awprot[2:0];
  assign axi_mem_intercon_to_s04_couplers_AWVALID = S04_AXI_awvalid[0];
  assign axi_mem_intercon_to_s04_couplers_BREADY = S04_AXI_bready[0];
  assign axi_mem_intercon_to_s04_couplers_RREADY = S04_AXI_rready[0];
  assign axi_mem_intercon_to_s04_couplers_WDATA = S04_AXI_wdata[31:0];
  assign axi_mem_intercon_to_s04_couplers_WSTRB = S04_AXI_wstrb[3:0];
  assign axi_mem_intercon_to_s04_couplers_WVALID = S04_AXI_wvalid[0];
  assign axi_mem_intercon_to_s05_couplers_ARADDR = S05_AXI_araddr[31:0];
  assign axi_mem_intercon_to_s05_couplers_ARPROT = S05_AXI_arprot[2:0];
  assign axi_mem_intercon_to_s05_couplers_ARVALID = S05_AXI_arvalid[0];
  assign axi_mem_intercon_to_s05_couplers_AWADDR = S05_AXI_awaddr[31:0];
  assign axi_mem_intercon_to_s05_couplers_AWPROT = S05_AXI_awprot[2:0];
  assign axi_mem_intercon_to_s05_couplers_AWVALID = S05_AXI_awvalid[0];
  assign axi_mem_intercon_to_s05_couplers_BREADY = S05_AXI_bready[0];
  assign axi_mem_intercon_to_s05_couplers_RREADY = S05_AXI_rready[0];
  assign axi_mem_intercon_to_s05_couplers_WDATA = S05_AXI_wdata[31:0];
  assign axi_mem_intercon_to_s05_couplers_WSTRB = S05_AXI_wstrb[3:0];
  assign axi_mem_intercon_to_s05_couplers_WVALID = S05_AXI_wvalid[0];
  assign axi_mem_intercon_to_s06_couplers_ARADDR = S06_AXI_araddr[31:0];
  assign axi_mem_intercon_to_s06_couplers_ARPROT = S06_AXI_arprot[2:0];
  assign axi_mem_intercon_to_s06_couplers_ARVALID = S06_AXI_arvalid[0];
  assign axi_mem_intercon_to_s06_couplers_AWADDR = S06_AXI_awaddr[31:0];
  assign axi_mem_intercon_to_s06_couplers_AWPROT = S06_AXI_awprot[2:0];
  assign axi_mem_intercon_to_s06_couplers_AWVALID = S06_AXI_awvalid[0];
  assign axi_mem_intercon_to_s06_couplers_BREADY = S06_AXI_bready[0];
  assign axi_mem_intercon_to_s06_couplers_RREADY = S06_AXI_rready[0];
  assign axi_mem_intercon_to_s06_couplers_WDATA = S06_AXI_wdata[31:0];
  assign axi_mem_intercon_to_s06_couplers_WSTRB = S06_AXI_wstrb[3:0];
  assign axi_mem_intercon_to_s06_couplers_WVALID = S06_AXI_wvalid[0];
  assign m00_couplers_to_axi_mem_intercon_ARREADY = M00_AXI_arready;
  assign m00_couplers_to_axi_mem_intercon_AWREADY = M00_AXI_awready;
  assign m00_couplers_to_axi_mem_intercon_BRESP = M00_AXI_bresp[1:0];
  assign m00_couplers_to_axi_mem_intercon_BVALID = M00_AXI_bvalid;
  assign m00_couplers_to_axi_mem_intercon_RDATA = M00_AXI_rdata[31:0];
  assign m00_couplers_to_axi_mem_intercon_RRESP = M00_AXI_rresp[1:0];
  assign m00_couplers_to_axi_mem_intercon_RVALID = M00_AXI_rvalid;
  assign m00_couplers_to_axi_mem_intercon_WREADY = M00_AXI_wready;
  m00_couplers_imp_O6Y4JN m00_couplers
       (.M_ACLK(axi_mem_intercon_ACLK_net),
        .M_ARESETN(axi_mem_intercon_ARESETN_net),
        .M_AXI_araddr(m00_couplers_to_axi_mem_intercon_ARADDR),
        .M_AXI_arprot(m00_couplers_to_axi_mem_intercon_ARPROT),
        .M_AXI_arready(m00_couplers_to_axi_mem_intercon_ARREADY),
        .M_AXI_arvalid(m00_couplers_to_axi_mem_intercon_ARVALID),
        .M_AXI_awaddr(m00_couplers_to_axi_mem_intercon_AWADDR),
        .M_AXI_awprot(m00_couplers_to_axi_mem_intercon_AWPROT),
        .M_AXI_awready(m00_couplers_to_axi_mem_intercon_AWREADY),
        .M_AXI_awvalid(m00_couplers_to_axi_mem_intercon_AWVALID),
        .M_AXI_bready(m00_couplers_to_axi_mem_intercon_BREADY),
        .M_AXI_bresp(m00_couplers_to_axi_mem_intercon_BRESP),
        .M_AXI_bvalid(m00_couplers_to_axi_mem_intercon_BVALID),
        .M_AXI_rdata(m00_couplers_to_axi_mem_intercon_RDATA),
        .M_AXI_rready(m00_couplers_to_axi_mem_intercon_RREADY),
        .M_AXI_rresp(m00_couplers_to_axi_mem_intercon_RRESP),
        .M_AXI_rvalid(m00_couplers_to_axi_mem_intercon_RVALID),
        .M_AXI_wdata(m00_couplers_to_axi_mem_intercon_WDATA),
        .M_AXI_wready(m00_couplers_to_axi_mem_intercon_WREADY),
        .M_AXI_wstrb(m00_couplers_to_axi_mem_intercon_WSTRB),
        .M_AXI_wvalid(m00_couplers_to_axi_mem_intercon_WVALID),
        .S_ACLK(axi_mem_intercon_ACLK_net),
        .S_ARESETN(axi_mem_intercon_ARESETN_net),
        .S_AXI_araddr(xbar_to_m00_couplers_ARADDR),
        .S_AXI_arprot(xbar_to_m00_couplers_ARPROT),
        .S_AXI_arready(xbar_to_m00_couplers_ARREADY),
        .S_AXI_arvalid(xbar_to_m00_couplers_ARVALID),
        .S_AXI_awaddr(xbar_to_m00_couplers_AWADDR),
        .S_AXI_awprot(xbar_to_m00_couplers_AWPROT),
        .S_AXI_awready(xbar_to_m00_couplers_AWREADY),
        .S_AXI_awvalid(xbar_to_m00_couplers_AWVALID),
        .S_AXI_bready(xbar_to_m00_couplers_BREADY),
        .S_AXI_bresp(xbar_to_m00_couplers_BRESP),
        .S_AXI_bvalid(xbar_to_m00_couplers_BVALID),
        .S_AXI_rdata(xbar_to_m00_couplers_RDATA),
        .S_AXI_rready(xbar_to_m00_couplers_RREADY),
        .S_AXI_rresp(xbar_to_m00_couplers_RRESP),
        .S_AXI_rvalid(xbar_to_m00_couplers_RVALID),
        .S_AXI_wdata(xbar_to_m00_couplers_WDATA),
        .S_AXI_wready(xbar_to_m00_couplers_WREADY),
        .S_AXI_wstrb(xbar_to_m00_couplers_WSTRB),
        .S_AXI_wvalid(xbar_to_m00_couplers_WVALID));
  s00_couplers_imp_1LGP333 s00_couplers
       (.M_ACLK(axi_mem_intercon_ACLK_net),
        .M_ARESETN(axi_mem_intercon_ARESETN_net),
        .M_AXI_araddr(s00_couplers_to_xbar_ARADDR),
        .M_AXI_arprot(s00_couplers_to_xbar_ARPROT),
        .M_AXI_arready(s00_couplers_to_xbar_ARREADY),
        .M_AXI_arvalid(s00_couplers_to_xbar_ARVALID),
        .M_AXI_awaddr(s00_couplers_to_xbar_AWADDR),
        .M_AXI_awprot(s00_couplers_to_xbar_AWPROT),
        .M_AXI_awready(s00_couplers_to_xbar_AWREADY),
        .M_AXI_awvalid(s00_couplers_to_xbar_AWVALID),
        .M_AXI_bready(s00_couplers_to_xbar_BREADY),
        .M_AXI_bresp(s00_couplers_to_xbar_BRESP),
        .M_AXI_bvalid(s00_couplers_to_xbar_BVALID),
        .M_AXI_rdata(s00_couplers_to_xbar_RDATA),
        .M_AXI_rready(s00_couplers_to_xbar_RREADY),
        .M_AXI_rresp(s00_couplers_to_xbar_RRESP),
        .M_AXI_rvalid(s00_couplers_to_xbar_RVALID),
        .M_AXI_wdata(s00_couplers_to_xbar_WDATA),
        .M_AXI_wready(s00_couplers_to_xbar_WREADY),
        .M_AXI_wstrb(s00_couplers_to_xbar_WSTRB),
        .M_AXI_wvalid(s00_couplers_to_xbar_WVALID),
        .S_ACLK(axi_mem_intercon_ACLK_net),
        .S_ARESETN(axi_mem_intercon_ARESETN_net),
        .S_AXI_araddr(axi_mem_intercon_to_s00_couplers_ARADDR),
        .S_AXI_arprot(axi_mem_intercon_to_s00_couplers_ARPROT),
        .S_AXI_arready(axi_mem_intercon_to_s00_couplers_ARREADY),
        .S_AXI_arvalid(axi_mem_intercon_to_s00_couplers_ARVALID),
        .S_AXI_awaddr(axi_mem_intercon_to_s00_couplers_AWADDR),
        .S_AXI_awprot(axi_mem_intercon_to_s00_couplers_AWPROT),
        .S_AXI_awready(axi_mem_intercon_to_s00_couplers_AWREADY),
        .S_AXI_awvalid(axi_mem_intercon_to_s00_couplers_AWVALID),
        .S_AXI_bready(axi_mem_intercon_to_s00_couplers_BREADY),
        .S_AXI_bresp(axi_mem_intercon_to_s00_couplers_BRESP),
        .S_AXI_bvalid(axi_mem_intercon_to_s00_couplers_BVALID),
        .S_AXI_rdata(axi_mem_intercon_to_s00_couplers_RDATA),
        .S_AXI_rready(axi_mem_intercon_to_s00_couplers_RREADY),
        .S_AXI_rresp(axi_mem_intercon_to_s00_couplers_RRESP),
        .S_AXI_rvalid(axi_mem_intercon_to_s00_couplers_RVALID),
        .S_AXI_wdata(axi_mem_intercon_to_s00_couplers_WDATA),
        .S_AXI_wready(axi_mem_intercon_to_s00_couplers_WREADY),
        .S_AXI_wstrb(axi_mem_intercon_to_s00_couplers_WSTRB),
        .S_AXI_wvalid(axi_mem_intercon_to_s00_couplers_WVALID));
  s01_couplers_imp_6XFXC7 s01_couplers
       (.M_ACLK(axi_mem_intercon_ACLK_net),
        .M_ARESETN(axi_mem_intercon_ARESETN_net),
        .M_AXI_araddr(s01_couplers_to_xbar_ARADDR),
        .M_AXI_arprot(s01_couplers_to_xbar_ARPROT),
        .M_AXI_arready(s01_couplers_to_xbar_ARREADY),
        .M_AXI_arvalid(s01_couplers_to_xbar_ARVALID),
        .M_AXI_awaddr(s01_couplers_to_xbar_AWADDR),
        .M_AXI_awprot(s01_couplers_to_xbar_AWPROT),
        .M_AXI_awready(s01_couplers_to_xbar_AWREADY),
        .M_AXI_awvalid(s01_couplers_to_xbar_AWVALID),
        .M_AXI_bready(s01_couplers_to_xbar_BREADY),
        .M_AXI_bresp(s01_couplers_to_xbar_BRESP),
        .M_AXI_bvalid(s01_couplers_to_xbar_BVALID),
        .M_AXI_rdata(s01_couplers_to_xbar_RDATA),
        .M_AXI_rready(s01_couplers_to_xbar_RREADY),
        .M_AXI_rresp(s01_couplers_to_xbar_RRESP),
        .M_AXI_rvalid(s01_couplers_to_xbar_RVALID),
        .M_AXI_wdata(s01_couplers_to_xbar_WDATA),
        .M_AXI_wready(s01_couplers_to_xbar_WREADY),
        .M_AXI_wstrb(s01_couplers_to_xbar_WSTRB),
        .M_AXI_wvalid(s01_couplers_to_xbar_WVALID),
        .S_ACLK(axi_mem_intercon_ACLK_net),
        .S_ARESETN(axi_mem_intercon_ARESETN_net),
        .S_AXI_araddr(axi_mem_intercon_to_s01_couplers_ARADDR),
        .S_AXI_arprot(axi_mem_intercon_to_s01_couplers_ARPROT),
        .S_AXI_arready(axi_mem_intercon_to_s01_couplers_ARREADY),
        .S_AXI_arvalid(axi_mem_intercon_to_s01_couplers_ARVALID),
        .S_AXI_awaddr(axi_mem_intercon_to_s01_couplers_AWADDR),
        .S_AXI_awprot(axi_mem_intercon_to_s01_couplers_AWPROT),
        .S_AXI_awready(axi_mem_intercon_to_s01_couplers_AWREADY),
        .S_AXI_awvalid(axi_mem_intercon_to_s01_couplers_AWVALID),
        .S_AXI_bready(axi_mem_intercon_to_s01_couplers_BREADY),
        .S_AXI_bresp(axi_mem_intercon_to_s01_couplers_BRESP),
        .S_AXI_bvalid(axi_mem_intercon_to_s01_couplers_BVALID),
        .S_AXI_rdata(axi_mem_intercon_to_s01_couplers_RDATA),
        .S_AXI_rready(axi_mem_intercon_to_s01_couplers_RREADY),
        .S_AXI_rresp(axi_mem_intercon_to_s01_couplers_RRESP),
        .S_AXI_rvalid(axi_mem_intercon_to_s01_couplers_RVALID),
        .S_AXI_wdata(axi_mem_intercon_to_s01_couplers_WDATA),
        .S_AXI_wready(axi_mem_intercon_to_s01_couplers_WREADY),
        .S_AXI_wstrb(axi_mem_intercon_to_s01_couplers_WSTRB),
        .S_AXI_wvalid(axi_mem_intercon_to_s01_couplers_WVALID));
  s02_couplers_imp_1G2P25Q s02_couplers
       (.M_ACLK(axi_mem_intercon_ACLK_net),
        .M_ARESETN(axi_mem_intercon_ARESETN_net),
        .M_AXI_araddr(s02_couplers_to_xbar_ARADDR),
        .M_AXI_arprot(s02_couplers_to_xbar_ARPROT),
        .M_AXI_arready(s02_couplers_to_xbar_ARREADY),
        .M_AXI_arvalid(s02_couplers_to_xbar_ARVALID),
        .M_AXI_awaddr(s02_couplers_to_xbar_AWADDR),
        .M_AXI_awprot(s02_couplers_to_xbar_AWPROT),
        .M_AXI_awready(s02_couplers_to_xbar_AWREADY),
        .M_AXI_awvalid(s02_couplers_to_xbar_AWVALID),
        .M_AXI_bready(s02_couplers_to_xbar_BREADY),
        .M_AXI_bresp(s02_couplers_to_xbar_BRESP),
        .M_AXI_bvalid(s02_couplers_to_xbar_BVALID),
        .M_AXI_rdata(s02_couplers_to_xbar_RDATA),
        .M_AXI_rready(s02_couplers_to_xbar_RREADY),
        .M_AXI_rresp(s02_couplers_to_xbar_RRESP),
        .M_AXI_rvalid(s02_couplers_to_xbar_RVALID),
        .M_AXI_wdata(s02_couplers_to_xbar_WDATA),
        .M_AXI_wready(s02_couplers_to_xbar_WREADY),
        .M_AXI_wstrb(s02_couplers_to_xbar_WSTRB),
        .M_AXI_wvalid(s02_couplers_to_xbar_WVALID),
        .S_ACLK(axi_mem_intercon_ACLK_net),
        .S_ARESETN(axi_mem_intercon_ARESETN_net),
        .S_AXI_araddr(axi_mem_intercon_to_s02_couplers_ARADDR),
        .S_AXI_arprot(axi_mem_intercon_to_s02_couplers_ARPROT),
        .S_AXI_arready(axi_mem_intercon_to_s02_couplers_ARREADY),
        .S_AXI_arvalid(axi_mem_intercon_to_s02_couplers_ARVALID),
        .S_AXI_awaddr(axi_mem_intercon_to_s02_couplers_AWADDR),
        .S_AXI_awprot(axi_mem_intercon_to_s02_couplers_AWPROT),
        .S_AXI_awready(axi_mem_intercon_to_s02_couplers_AWREADY),
        .S_AXI_awvalid(axi_mem_intercon_to_s02_couplers_AWVALID),
        .S_AXI_bready(axi_mem_intercon_to_s02_couplers_BREADY),
        .S_AXI_bresp(axi_mem_intercon_to_s02_couplers_BRESP),
        .S_AXI_bvalid(axi_mem_intercon_to_s02_couplers_BVALID),
        .S_AXI_rdata(axi_mem_intercon_to_s02_couplers_RDATA),
        .S_AXI_rready(axi_mem_intercon_to_s02_couplers_RREADY),
        .S_AXI_rresp(axi_mem_intercon_to_s02_couplers_RRESP),
        .S_AXI_rvalid(axi_mem_intercon_to_s02_couplers_RVALID),
        .S_AXI_wdata(axi_mem_intercon_to_s02_couplers_WDATA),
        .S_AXI_wready(axi_mem_intercon_to_s02_couplers_WREADY),
        .S_AXI_wstrb(axi_mem_intercon_to_s02_couplers_WSTRB),
        .S_AXI_wvalid(axi_mem_intercon_to_s02_couplers_WVALID));
  s03_couplers_imp_U1S6LY s03_couplers
       (.M_ACLK(axi_mem_intercon_ACLK_net),
        .M_ARESETN(axi_mem_intercon_ARESETN_net),
        .M_AXI_araddr(s03_couplers_to_xbar_ARADDR),
        .M_AXI_arprot(s03_couplers_to_xbar_ARPROT),
        .M_AXI_arready(s03_couplers_to_xbar_ARREADY),
        .M_AXI_arvalid(s03_couplers_to_xbar_ARVALID),
        .M_AXI_awaddr(s03_couplers_to_xbar_AWADDR),
        .M_AXI_awprot(s03_couplers_to_xbar_AWPROT),
        .M_AXI_awready(s03_couplers_to_xbar_AWREADY),
        .M_AXI_awvalid(s03_couplers_to_xbar_AWVALID),
        .M_AXI_bready(s03_couplers_to_xbar_BREADY),
        .M_AXI_bresp(s03_couplers_to_xbar_BRESP),
        .M_AXI_bvalid(s03_couplers_to_xbar_BVALID),
        .M_AXI_rdata(s03_couplers_to_xbar_RDATA),
        .M_AXI_rready(s03_couplers_to_xbar_RREADY),
        .M_AXI_rresp(s03_couplers_to_xbar_RRESP),
        .M_AXI_rvalid(s03_couplers_to_xbar_RVALID),
        .M_AXI_wdata(s03_couplers_to_xbar_WDATA),
        .M_AXI_wready(s03_couplers_to_xbar_WREADY),
        .M_AXI_wstrb(s03_couplers_to_xbar_WSTRB),
        .M_AXI_wvalid(s03_couplers_to_xbar_WVALID),
        .S_ACLK(axi_mem_intercon_ACLK_net),
        .S_ARESETN(axi_mem_intercon_ARESETN_net),
        .S_AXI_araddr(axi_mem_intercon_to_s03_couplers_ARADDR),
        .S_AXI_arprot(axi_mem_intercon_to_s03_couplers_ARPROT),
        .S_AXI_arready(axi_mem_intercon_to_s03_couplers_ARREADY),
        .S_AXI_arvalid(axi_mem_intercon_to_s03_couplers_ARVALID),
        .S_AXI_awaddr(axi_mem_intercon_to_s03_couplers_AWADDR),
        .S_AXI_awprot(axi_mem_intercon_to_s03_couplers_AWPROT),
        .S_AXI_awready(axi_mem_intercon_to_s03_couplers_AWREADY),
        .S_AXI_awvalid(axi_mem_intercon_to_s03_couplers_AWVALID),
        .S_AXI_bready(axi_mem_intercon_to_s03_couplers_BREADY),
        .S_AXI_bresp(axi_mem_intercon_to_s03_couplers_BRESP),
        .S_AXI_bvalid(axi_mem_intercon_to_s03_couplers_BVALID),
        .S_AXI_rdata(axi_mem_intercon_to_s03_couplers_RDATA),
        .S_AXI_rready(axi_mem_intercon_to_s03_couplers_RREADY),
        .S_AXI_rresp(axi_mem_intercon_to_s03_couplers_RRESP),
        .S_AXI_rvalid(axi_mem_intercon_to_s03_couplers_RVALID),
        .S_AXI_wdata(axi_mem_intercon_to_s03_couplers_WDATA),
        .S_AXI_wready(axi_mem_intercon_to_s03_couplers_WREADY),
        .S_AXI_wstrb(axi_mem_intercon_to_s03_couplers_WSTRB),
        .S_AXI_wvalid(axi_mem_intercon_to_s03_couplers_WVALID));
  s04_couplers_imp_AO18OT s04_couplers
       (.M_ACLK(axi_mem_intercon_ACLK_net),
        .M_ARESETN(axi_mem_intercon_ARESETN_net),
        .M_AXI_araddr(s04_couplers_to_xbar_ARADDR),
        .M_AXI_arprot(s04_couplers_to_xbar_ARPROT),
        .M_AXI_arready(s04_couplers_to_xbar_ARREADY),
        .M_AXI_arvalid(s04_couplers_to_xbar_ARVALID),
        .M_AXI_awaddr(s04_couplers_to_xbar_AWADDR),
        .M_AXI_awprot(s04_couplers_to_xbar_AWPROT),
        .M_AXI_awready(s04_couplers_to_xbar_AWREADY),
        .M_AXI_awvalid(s04_couplers_to_xbar_AWVALID),
        .M_AXI_bready(s04_couplers_to_xbar_BREADY),
        .M_AXI_bresp(s04_couplers_to_xbar_BRESP),
        .M_AXI_bvalid(s04_couplers_to_xbar_BVALID),
        .M_AXI_rdata(s04_couplers_to_xbar_RDATA),
        .M_AXI_rready(s04_couplers_to_xbar_RREADY),
        .M_AXI_rresp(s04_couplers_to_xbar_RRESP),
        .M_AXI_rvalid(s04_couplers_to_xbar_RVALID),
        .M_AXI_wdata(s04_couplers_to_xbar_WDATA),
        .M_AXI_wready(s04_couplers_to_xbar_WREADY),
        .M_AXI_wstrb(s04_couplers_to_xbar_WSTRB),
        .M_AXI_wvalid(s04_couplers_to_xbar_WVALID),
        .S_ACLK(axi_mem_intercon_ACLK_net),
        .S_ARESETN(axi_mem_intercon_ARESETN_net),
        .S_AXI_araddr(axi_mem_intercon_to_s04_couplers_ARADDR),
        .S_AXI_arprot(axi_mem_intercon_to_s04_couplers_ARPROT),
        .S_AXI_arready(axi_mem_intercon_to_s04_couplers_ARREADY),
        .S_AXI_arvalid(axi_mem_intercon_to_s04_couplers_ARVALID),
        .S_AXI_awaddr(axi_mem_intercon_to_s04_couplers_AWADDR),
        .S_AXI_awprot(axi_mem_intercon_to_s04_couplers_AWPROT),
        .S_AXI_awready(axi_mem_intercon_to_s04_couplers_AWREADY),
        .S_AXI_awvalid(axi_mem_intercon_to_s04_couplers_AWVALID),
        .S_AXI_bready(axi_mem_intercon_to_s04_couplers_BREADY),
        .S_AXI_bresp(axi_mem_intercon_to_s04_couplers_BRESP),
        .S_AXI_bvalid(axi_mem_intercon_to_s04_couplers_BVALID),
        .S_AXI_rdata(axi_mem_intercon_to_s04_couplers_RDATA),
        .S_AXI_rready(axi_mem_intercon_to_s04_couplers_RREADY),
        .S_AXI_rresp(axi_mem_intercon_to_s04_couplers_RRESP),
        .S_AXI_rvalid(axi_mem_intercon_to_s04_couplers_RVALID),
        .S_AXI_wdata(axi_mem_intercon_to_s04_couplers_WDATA),
        .S_AXI_wready(axi_mem_intercon_to_s04_couplers_WREADY),
        .S_AXI_wstrb(axi_mem_intercon_to_s04_couplers_WSTRB),
        .S_AXI_wvalid(axi_mem_intercon_to_s04_couplers_WVALID));
  s05_couplers_imp_1V0XNQD s05_couplers
       (.M_ACLK(axi_mem_intercon_ACLK_net),
        .M_ARESETN(axi_mem_intercon_ARESETN_net),
        .M_AXI_araddr(s05_couplers_to_xbar_ARADDR),
        .M_AXI_arprot(s05_couplers_to_xbar_ARPROT),
        .M_AXI_arready(s05_couplers_to_xbar_ARREADY),
        .M_AXI_arvalid(s05_couplers_to_xbar_ARVALID),
        .M_AXI_awaddr(s05_couplers_to_xbar_AWADDR),
        .M_AXI_awprot(s05_couplers_to_xbar_AWPROT),
        .M_AXI_awready(s05_couplers_to_xbar_AWREADY),
        .M_AXI_awvalid(s05_couplers_to_xbar_AWVALID),
        .M_AXI_bready(s05_couplers_to_xbar_BREADY),
        .M_AXI_bresp(s05_couplers_to_xbar_BRESP),
        .M_AXI_bvalid(s05_couplers_to_xbar_BVALID),
        .M_AXI_rdata(s05_couplers_to_xbar_RDATA),
        .M_AXI_rready(s05_couplers_to_xbar_RREADY),
        .M_AXI_rresp(s05_couplers_to_xbar_RRESP),
        .M_AXI_rvalid(s05_couplers_to_xbar_RVALID),
        .M_AXI_wdata(s05_couplers_to_xbar_WDATA),
        .M_AXI_wready(s05_couplers_to_xbar_WREADY),
        .M_AXI_wstrb(s05_couplers_to_xbar_WSTRB),
        .M_AXI_wvalid(s05_couplers_to_xbar_WVALID),
        .S_ACLK(axi_mem_intercon_ACLK_net),
        .S_ARESETN(axi_mem_intercon_ARESETN_net),
        .S_AXI_araddr(axi_mem_intercon_to_s05_couplers_ARADDR),
        .S_AXI_arprot(axi_mem_intercon_to_s05_couplers_ARPROT),
        .S_AXI_arready(axi_mem_intercon_to_s05_couplers_ARREADY),
        .S_AXI_arvalid(axi_mem_intercon_to_s05_couplers_ARVALID),
        .S_AXI_awaddr(axi_mem_intercon_to_s05_couplers_AWADDR),
        .S_AXI_awprot(axi_mem_intercon_to_s05_couplers_AWPROT),
        .S_AXI_awready(axi_mem_intercon_to_s05_couplers_AWREADY),
        .S_AXI_awvalid(axi_mem_intercon_to_s05_couplers_AWVALID),
        .S_AXI_bready(axi_mem_intercon_to_s05_couplers_BREADY),
        .S_AXI_bresp(axi_mem_intercon_to_s05_couplers_BRESP),
        .S_AXI_bvalid(axi_mem_intercon_to_s05_couplers_BVALID),
        .S_AXI_rdata(axi_mem_intercon_to_s05_couplers_RDATA),
        .S_AXI_rready(axi_mem_intercon_to_s05_couplers_RREADY),
        .S_AXI_rresp(axi_mem_intercon_to_s05_couplers_RRESP),
        .S_AXI_rvalid(axi_mem_intercon_to_s05_couplers_RVALID),
        .S_AXI_wdata(axi_mem_intercon_to_s05_couplers_WDATA),
        .S_AXI_wready(axi_mem_intercon_to_s05_couplers_WREADY),
        .S_AXI_wstrb(axi_mem_intercon_to_s05_couplers_WSTRB),
        .S_AXI_wvalid(axi_mem_intercon_to_s05_couplers_WVALID));
  s06_couplers_imp_MYTDQK s06_couplers
       (.M_ACLK(axi_mem_intercon_ACLK_net),
        .M_ARESETN(axi_mem_intercon_ARESETN_net),
        .M_AXI_araddr(s06_couplers_to_xbar_ARADDR),
        .M_AXI_arprot(s06_couplers_to_xbar_ARPROT),
        .M_AXI_arready(s06_couplers_to_xbar_ARREADY),
        .M_AXI_arvalid(s06_couplers_to_xbar_ARVALID),
        .M_AXI_awaddr(s06_couplers_to_xbar_AWADDR),
        .M_AXI_awprot(s06_couplers_to_xbar_AWPROT),
        .M_AXI_awready(s06_couplers_to_xbar_AWREADY),
        .M_AXI_awvalid(s06_couplers_to_xbar_AWVALID),
        .M_AXI_bready(s06_couplers_to_xbar_BREADY),
        .M_AXI_bresp(s06_couplers_to_xbar_BRESP),
        .M_AXI_bvalid(s06_couplers_to_xbar_BVALID),
        .M_AXI_rdata(s06_couplers_to_xbar_RDATA),
        .M_AXI_rready(s06_couplers_to_xbar_RREADY),
        .M_AXI_rresp(s06_couplers_to_xbar_RRESP),
        .M_AXI_rvalid(s06_couplers_to_xbar_RVALID),
        .M_AXI_wdata(s06_couplers_to_xbar_WDATA),
        .M_AXI_wready(s06_couplers_to_xbar_WREADY),
        .M_AXI_wstrb(s06_couplers_to_xbar_WSTRB),
        .M_AXI_wvalid(s06_couplers_to_xbar_WVALID),
        .S_ACLK(axi_mem_intercon_ACLK_net),
        .S_ARESETN(axi_mem_intercon_ARESETN_net),
        .S_AXI_araddr(axi_mem_intercon_to_s06_couplers_ARADDR),
        .S_AXI_arprot(axi_mem_intercon_to_s06_couplers_ARPROT),
        .S_AXI_arready(axi_mem_intercon_to_s06_couplers_ARREADY),
        .S_AXI_arvalid(axi_mem_intercon_to_s06_couplers_ARVALID),
        .S_AXI_awaddr(axi_mem_intercon_to_s06_couplers_AWADDR),
        .S_AXI_awprot(axi_mem_intercon_to_s06_couplers_AWPROT),
        .S_AXI_awready(axi_mem_intercon_to_s06_couplers_AWREADY),
        .S_AXI_awvalid(axi_mem_intercon_to_s06_couplers_AWVALID),
        .S_AXI_bready(axi_mem_intercon_to_s06_couplers_BREADY),
        .S_AXI_bresp(axi_mem_intercon_to_s06_couplers_BRESP),
        .S_AXI_bvalid(axi_mem_intercon_to_s06_couplers_BVALID),
        .S_AXI_rdata(axi_mem_intercon_to_s06_couplers_RDATA),
        .S_AXI_rready(axi_mem_intercon_to_s06_couplers_RREADY),
        .S_AXI_rresp(axi_mem_intercon_to_s06_couplers_RRESP),
        .S_AXI_rvalid(axi_mem_intercon_to_s06_couplers_RVALID),
        .S_AXI_wdata(axi_mem_intercon_to_s06_couplers_WDATA),
        .S_AXI_wready(axi_mem_intercon_to_s06_couplers_WREADY),
        .S_AXI_wstrb(axi_mem_intercon_to_s06_couplers_WSTRB),
        .S_AXI_wvalid(axi_mem_intercon_to_s06_couplers_WVALID));
  top_block_xbar_1 xbar
       (.aclk(axi_mem_intercon_ACLK_net),
        .aresetn(axi_mem_intercon_ARESETN_net),
        .m_axi_araddr(xbar_to_m00_couplers_ARADDR),
        .m_axi_arprot(xbar_to_m00_couplers_ARPROT),
        .m_axi_arready(xbar_to_m00_couplers_ARREADY),
        .m_axi_arvalid(xbar_to_m00_couplers_ARVALID),
        .m_axi_awaddr(xbar_to_m00_couplers_AWADDR),
        .m_axi_awprot(xbar_to_m00_couplers_AWPROT),
        .m_axi_awready(xbar_to_m00_couplers_AWREADY),
        .m_axi_awvalid(xbar_to_m00_couplers_AWVALID),
        .m_axi_bready(xbar_to_m00_couplers_BREADY),
        .m_axi_bresp(xbar_to_m00_couplers_BRESP),
        .m_axi_bvalid(xbar_to_m00_couplers_BVALID),
        .m_axi_rdata(xbar_to_m00_couplers_RDATA),
        .m_axi_rready(xbar_to_m00_couplers_RREADY),
        .m_axi_rresp(xbar_to_m00_couplers_RRESP),
        .m_axi_rvalid(xbar_to_m00_couplers_RVALID),
        .m_axi_wdata(xbar_to_m00_couplers_WDATA),
        .m_axi_wready(xbar_to_m00_couplers_WREADY),
        .m_axi_wstrb(xbar_to_m00_couplers_WSTRB),
        .m_axi_wvalid(xbar_to_m00_couplers_WVALID),
        .s_axi_araddr({s06_couplers_to_xbar_ARADDR,s05_couplers_to_xbar_ARADDR,s04_couplers_to_xbar_ARADDR,s03_couplers_to_xbar_ARADDR,s02_couplers_to_xbar_ARADDR,s01_couplers_to_xbar_ARADDR,s00_couplers_to_xbar_ARADDR}),
        .s_axi_arprot({s06_couplers_to_xbar_ARPROT,s05_couplers_to_xbar_ARPROT,s04_couplers_to_xbar_ARPROT,s03_couplers_to_xbar_ARPROT,s02_couplers_to_xbar_ARPROT,s01_couplers_to_xbar_ARPROT,s00_couplers_to_xbar_ARPROT}),
        .s_axi_arready({s06_couplers_to_xbar_ARREADY,s05_couplers_to_xbar_ARREADY,s04_couplers_to_xbar_ARREADY,s03_couplers_to_xbar_ARREADY,s02_couplers_to_xbar_ARREADY,s01_couplers_to_xbar_ARREADY,s00_couplers_to_xbar_ARREADY}),
        .s_axi_arvalid({s06_couplers_to_xbar_ARVALID,s05_couplers_to_xbar_ARVALID,s04_couplers_to_xbar_ARVALID,s03_couplers_to_xbar_ARVALID,s02_couplers_to_xbar_ARVALID,s01_couplers_to_xbar_ARVALID,s00_couplers_to_xbar_ARVALID}),
        .s_axi_awaddr({s06_couplers_to_xbar_AWADDR,s05_couplers_to_xbar_AWADDR,s04_couplers_to_xbar_AWADDR,s03_couplers_to_xbar_AWADDR,s02_couplers_to_xbar_AWADDR,s01_couplers_to_xbar_AWADDR,s00_couplers_to_xbar_AWADDR}),
        .s_axi_awprot({s06_couplers_to_xbar_AWPROT,s05_couplers_to_xbar_AWPROT,s04_couplers_to_xbar_AWPROT,s03_couplers_to_xbar_AWPROT,s02_couplers_to_xbar_AWPROT,s01_couplers_to_xbar_AWPROT,s00_couplers_to_xbar_AWPROT}),
        .s_axi_awready({s06_couplers_to_xbar_AWREADY,s05_couplers_to_xbar_AWREADY,s04_couplers_to_xbar_AWREADY,s03_couplers_to_xbar_AWREADY,s02_couplers_to_xbar_AWREADY,s01_couplers_to_xbar_AWREADY,s00_couplers_to_xbar_AWREADY}),
        .s_axi_awvalid({s06_couplers_to_xbar_AWVALID,s05_couplers_to_xbar_AWVALID,s04_couplers_to_xbar_AWVALID,s03_couplers_to_xbar_AWVALID,s02_couplers_to_xbar_AWVALID,s01_couplers_to_xbar_AWVALID,s00_couplers_to_xbar_AWVALID}),
        .s_axi_bready({s06_couplers_to_xbar_BREADY,s05_couplers_to_xbar_BREADY,s04_couplers_to_xbar_BREADY,s03_couplers_to_xbar_BREADY,s02_couplers_to_xbar_BREADY,s01_couplers_to_xbar_BREADY,s00_couplers_to_xbar_BREADY}),
        .s_axi_bresp({s06_couplers_to_xbar_BRESP,s05_couplers_to_xbar_BRESP,s04_couplers_to_xbar_BRESP,s03_couplers_to_xbar_BRESP,s02_couplers_to_xbar_BRESP,s01_couplers_to_xbar_BRESP,s00_couplers_to_xbar_BRESP}),
        .s_axi_bvalid({s06_couplers_to_xbar_BVALID,s05_couplers_to_xbar_BVALID,s04_couplers_to_xbar_BVALID,s03_couplers_to_xbar_BVALID,s02_couplers_to_xbar_BVALID,s01_couplers_to_xbar_BVALID,s00_couplers_to_xbar_BVALID}),
        .s_axi_rdata({s06_couplers_to_xbar_RDATA,s05_couplers_to_xbar_RDATA,s04_couplers_to_xbar_RDATA,s03_couplers_to_xbar_RDATA,s02_couplers_to_xbar_RDATA,s01_couplers_to_xbar_RDATA,s00_couplers_to_xbar_RDATA}),
        .s_axi_rready({s06_couplers_to_xbar_RREADY,s05_couplers_to_xbar_RREADY,s04_couplers_to_xbar_RREADY,s03_couplers_to_xbar_RREADY,s02_couplers_to_xbar_RREADY,s01_couplers_to_xbar_RREADY,s00_couplers_to_xbar_RREADY}),
        .s_axi_rresp({s06_couplers_to_xbar_RRESP,s05_couplers_to_xbar_RRESP,s04_couplers_to_xbar_RRESP,s03_couplers_to_xbar_RRESP,s02_couplers_to_xbar_RRESP,s01_couplers_to_xbar_RRESP,s00_couplers_to_xbar_RRESP}),
        .s_axi_rvalid({s06_couplers_to_xbar_RVALID,s05_couplers_to_xbar_RVALID,s04_couplers_to_xbar_RVALID,s03_couplers_to_xbar_RVALID,s02_couplers_to_xbar_RVALID,s01_couplers_to_xbar_RVALID,s00_couplers_to_xbar_RVALID}),
        .s_axi_wdata({s06_couplers_to_xbar_WDATA,s05_couplers_to_xbar_WDATA,s04_couplers_to_xbar_WDATA,s03_couplers_to_xbar_WDATA,s02_couplers_to_xbar_WDATA,s01_couplers_to_xbar_WDATA,s00_couplers_to_xbar_WDATA}),
        .s_axi_wready({s06_couplers_to_xbar_WREADY,s05_couplers_to_xbar_WREADY,s04_couplers_to_xbar_WREADY,s03_couplers_to_xbar_WREADY,s02_couplers_to_xbar_WREADY,s01_couplers_to_xbar_WREADY,s00_couplers_to_xbar_WREADY}),
        .s_axi_wstrb({s06_couplers_to_xbar_WSTRB,s05_couplers_to_xbar_WSTRB,s04_couplers_to_xbar_WSTRB,s03_couplers_to_xbar_WSTRB,s02_couplers_to_xbar_WSTRB,s01_couplers_to_xbar_WSTRB,s00_couplers_to_xbar_WSTRB}),
        .s_axi_wvalid({s06_couplers_to_xbar_WVALID,s05_couplers_to_xbar_WVALID,s04_couplers_to_xbar_WVALID,s03_couplers_to_xbar_WVALID,s02_couplers_to_xbar_WVALID,s01_couplers_to_xbar_WVALID,s00_couplers_to_xbar_WVALID}));
endmodule

module trg_en_imp_1M4NTOV
   (TRG_N,
    TRG_P,
    clk,
    init_trg,
    m00_axi_araddr,
    m00_axi_aresetn,
    m00_axi_arprot,
    m00_axi_arready,
    m00_axi_arvalid,
    m00_axi_awaddr,
    m00_axi_awprot,
    m00_axi_awready,
    m00_axi_awvalid,
    m00_axi_bready,
    m00_axi_bresp,
    m00_axi_bvalid,
    m00_axi_rdata,
    m00_axi_rready,
    m00_axi_rresp,
    m00_axi_rvalid,
    m00_axi_wdata,
    m00_axi_wready,
    m00_axi_wstrb,
    m00_axi_wvalid,
    rst,
    sampa_trg_en);
  output [3:0]TRG_N;
  output [3:0]TRG_P;
  input clk;
  input init_trg;
  output [31:0]m00_axi_araddr;
  input m00_axi_aresetn;
  output [2:0]m00_axi_arprot;
  input [0:0]m00_axi_arready;
  output [0:0]m00_axi_arvalid;
  output [31:0]m00_axi_awaddr;
  output [2:0]m00_axi_awprot;
  input [0:0]m00_axi_awready;
  output [0:0]m00_axi_awvalid;
  output [0:0]m00_axi_bready;
  input [1:0]m00_axi_bresp;
  input [0:0]m00_axi_bvalid;
  input [31:0]m00_axi_rdata;
  output [0:0]m00_axi_rready;
  input [1:0]m00_axi_rresp;
  input [0:0]m00_axi_rvalid;
  output [31:0]m00_axi_wdata;
  input [0:0]m00_axi_wready;
  output [3:0]m00_axi_wstrb;
  output [0:0]m00_axi_wvalid;
  input rst;
  output sampa_trg_en;

  wire [3:0]OBUFDS_TRG_0_O;
  wire [3:0]OBUFDS_TRG_0_OB;
  wire [31:0]SAMPA_TRG_EN_v1_0_0_m00_axi_ARADDR;
  wire [2:0]SAMPA_TRG_EN_v1_0_0_m00_axi_ARPROT;
  wire [0:0]SAMPA_TRG_EN_v1_0_0_m00_axi_ARREADY;
  wire SAMPA_TRG_EN_v1_0_0_m00_axi_ARVALID;
  wire [31:0]SAMPA_TRG_EN_v1_0_0_m00_axi_AWADDR;
  wire [2:0]SAMPA_TRG_EN_v1_0_0_m00_axi_AWPROT;
  wire [0:0]SAMPA_TRG_EN_v1_0_0_m00_axi_AWREADY;
  wire SAMPA_TRG_EN_v1_0_0_m00_axi_AWVALID;
  wire SAMPA_TRG_EN_v1_0_0_m00_axi_BREADY;
  wire [1:0]SAMPA_TRG_EN_v1_0_0_m00_axi_BRESP;
  wire [0:0]SAMPA_TRG_EN_v1_0_0_m00_axi_BVALID;
  wire [31:0]SAMPA_TRG_EN_v1_0_0_m00_axi_RDATA;
  wire SAMPA_TRG_EN_v1_0_0_m00_axi_RREADY;
  wire [1:0]SAMPA_TRG_EN_v1_0_0_m00_axi_RRESP;
  wire [0:0]SAMPA_TRG_EN_v1_0_0_m00_axi_RVALID;
  wire [31:0]SAMPA_TRG_EN_v1_0_0_m00_axi_WDATA;
  wire [0:0]SAMPA_TRG_EN_v1_0_0_m00_axi_WREADY;
  wire [3:0]SAMPA_TRG_EN_v1_0_0_m00_axi_WSTRB;
  wire SAMPA_TRG_EN_v1_0_0_m00_axi_WVALID;
  wire SAMPA_TRG_EN_v1_0_0_sampa_trg_en;
  wire [3:0]TRG_MODULE_0_trg;
  wire clk_1;
  wire init_trg_1;
  wire m00_axi_aresetn_1;
  wire rst_1;

  assign SAMPA_TRG_EN_v1_0_0_m00_axi_ARREADY = m00_axi_arready[0];
  assign SAMPA_TRG_EN_v1_0_0_m00_axi_AWREADY = m00_axi_awready[0];
  assign SAMPA_TRG_EN_v1_0_0_m00_axi_BRESP = m00_axi_bresp[1:0];
  assign SAMPA_TRG_EN_v1_0_0_m00_axi_BVALID = m00_axi_bvalid[0];
  assign SAMPA_TRG_EN_v1_0_0_m00_axi_RDATA = m00_axi_rdata[31:0];
  assign SAMPA_TRG_EN_v1_0_0_m00_axi_RRESP = m00_axi_rresp[1:0];
  assign SAMPA_TRG_EN_v1_0_0_m00_axi_RVALID = m00_axi_rvalid[0];
  assign SAMPA_TRG_EN_v1_0_0_m00_axi_WREADY = m00_axi_wready[0];
  assign TRG_N[3:0] = OBUFDS_TRG_0_OB;
  assign TRG_P[3:0] = OBUFDS_TRG_0_O;
  assign clk_1 = clk;
  assign init_trg_1 = init_trg;
  assign m00_axi_araddr[31:0] = SAMPA_TRG_EN_v1_0_0_m00_axi_ARADDR;
  assign m00_axi_aresetn_1 = m00_axi_aresetn;
  assign m00_axi_arprot[2:0] = SAMPA_TRG_EN_v1_0_0_m00_axi_ARPROT;
  assign m00_axi_arvalid[0] = SAMPA_TRG_EN_v1_0_0_m00_axi_ARVALID;
  assign m00_axi_awaddr[31:0] = SAMPA_TRG_EN_v1_0_0_m00_axi_AWADDR;
  assign m00_axi_awprot[2:0] = SAMPA_TRG_EN_v1_0_0_m00_axi_AWPROT;
  assign m00_axi_awvalid[0] = SAMPA_TRG_EN_v1_0_0_m00_axi_AWVALID;
  assign m00_axi_bready[0] = SAMPA_TRG_EN_v1_0_0_m00_axi_BREADY;
  assign m00_axi_rready[0] = SAMPA_TRG_EN_v1_0_0_m00_axi_RREADY;
  assign m00_axi_wdata[31:0] = SAMPA_TRG_EN_v1_0_0_m00_axi_WDATA;
  assign m00_axi_wstrb[3:0] = SAMPA_TRG_EN_v1_0_0_m00_axi_WSTRB;
  assign m00_axi_wvalid[0] = SAMPA_TRG_EN_v1_0_0_m00_axi_WVALID;
  assign rst_1 = rst;
  assign sampa_trg_en = SAMPA_TRG_EN_v1_0_0_sampa_trg_en;
  top_block_OBUFDS_TRG_0_0 OBUFDS_TRG_0
       (.I(TRG_MODULE_0_trg),
        .O(OBUFDS_TRG_0_O),
        .OB(OBUFDS_TRG_0_OB));
  top_block_SAMPA_TRG_EN_v1_0_0_0 SAMPA_TRG_EN_v1_0_0
       (.m00_axi_aclk(clk_1),
        .m00_axi_araddr(SAMPA_TRG_EN_v1_0_0_m00_axi_ARADDR),
        .m00_axi_aresetn(m00_axi_aresetn_1),
        .m00_axi_arprot(SAMPA_TRG_EN_v1_0_0_m00_axi_ARPROT),
        .m00_axi_arready(SAMPA_TRG_EN_v1_0_0_m00_axi_ARREADY),
        .m00_axi_arvalid(SAMPA_TRG_EN_v1_0_0_m00_axi_ARVALID),
        .m00_axi_awaddr(SAMPA_TRG_EN_v1_0_0_m00_axi_AWADDR),
        .m00_axi_awprot(SAMPA_TRG_EN_v1_0_0_m00_axi_AWPROT),
        .m00_axi_awready(SAMPA_TRG_EN_v1_0_0_m00_axi_AWREADY),
        .m00_axi_awvalid(SAMPA_TRG_EN_v1_0_0_m00_axi_AWVALID),
        .m00_axi_bready(SAMPA_TRG_EN_v1_0_0_m00_axi_BREADY),
        .m00_axi_bresp(SAMPA_TRG_EN_v1_0_0_m00_axi_BRESP),
        .m00_axi_bvalid(SAMPA_TRG_EN_v1_0_0_m00_axi_BVALID),
        .m00_axi_init_axi_txn(1'b0),
        .m00_axi_rdata(SAMPA_TRG_EN_v1_0_0_m00_axi_RDATA),
        .m00_axi_rready(SAMPA_TRG_EN_v1_0_0_m00_axi_RREADY),
        .m00_axi_rresp(SAMPA_TRG_EN_v1_0_0_m00_axi_RRESP),
        .m00_axi_rvalid(SAMPA_TRG_EN_v1_0_0_m00_axi_RVALID),
        .m00_axi_wdata(SAMPA_TRG_EN_v1_0_0_m00_axi_WDATA),
        .m00_axi_wready(SAMPA_TRG_EN_v1_0_0_m00_axi_WREADY),
        .m00_axi_wstrb(SAMPA_TRG_EN_v1_0_0_m00_axi_WSTRB),
        .m00_axi_wvalid(SAMPA_TRG_EN_v1_0_0_m00_axi_WVALID),
        .sampa_trg_en(SAMPA_TRG_EN_v1_0_0_sampa_trg_en));
  top_block_TRG_MODULE_0_0 TRG_MODULE_0
       (.clk(clk_1),
        .en(SAMPA_TRG_EN_v1_0_0_sampa_trg_en),
        .init_trg(init_trg_1),
        .rst(rst_1),
        .trg(TRG_MODULE_0_trg));
endmodule
