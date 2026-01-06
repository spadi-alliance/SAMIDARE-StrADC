// (c) Copyright 1995-2025 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:module_ref:SAMPA_TRG_EN_v1_0:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module top_block_SAMPA_TRG_EN_v1_0_0_0 (
  sampa_trg_en,
  m00_axi_init_axi_txn,
  m00_axi_error,
  m00_axi_txn_done,
  m00_axi_aclk,
  m00_axi_aresetn,
  m00_axi_awaddr,
  m00_axi_awprot,
  m00_axi_awvalid,
  m00_axi_awready,
  m00_axi_wdata,
  m00_axi_wstrb,
  m00_axi_wvalid,
  m00_axi_wready,
  m00_axi_bresp,
  m00_axi_bvalid,
  m00_axi_bready,
  m00_axi_araddr,
  m00_axi_arprot,
  m00_axi_arvalid,
  m00_axi_arready,
  m00_axi_rdata,
  m00_axi_rresp,
  m00_axi_rvalid,
  m00_axi_rready
);

output wire sampa_trg_en;
input wire m00_axi_init_axi_txn;
output wire m00_axi_error;
output wire m00_axi_txn_done;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m00_axi_aclk, ASSOCIATED_BUSIF m00_axi, ASSOCIATED_RESET m00_axi_aresetn, FREQ_HZ 125000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN top_block_clk_wiz_0_0_clk_out1, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 m00_axi_aclk CLK" *)
input wire m00_axi_aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m00_axi_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 m00_axi_aresetn RST" *)
input wire m00_axi_aresetn;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi AWADDR" *)
output wire [31 : 0] m00_axi_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi AWPROT" *)
output wire [2 : 0] m00_axi_awprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi AWVALID" *)
output wire m00_axi_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi AWREADY" *)
input wire m00_axi_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi WDATA" *)
output wire [31 : 0] m00_axi_wdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi WSTRB" *)
output wire [3 : 0] m00_axi_wstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi WVALID" *)
output wire m00_axi_wvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi WREADY" *)
input wire m00_axi_wready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi BRESP" *)
input wire [1 : 0] m00_axi_bresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi BVALID" *)
input wire m00_axi_bvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi BREADY" *)
output wire m00_axi_bready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi ARADDR" *)
output wire [31 : 0] m00_axi_araddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi ARPROT" *)
output wire [2 : 0] m00_axi_arprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi ARVALID" *)
output wire m00_axi_arvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi ARREADY" *)
input wire m00_axi_arready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi RDATA" *)
input wire [31 : 0] m00_axi_rdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi RRESP" *)
input wire [1 : 0] m00_axi_rresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi RVALID" *)
input wire m00_axi_rvalid;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m00_axi, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 125000000, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.0, CLK_DOMAIN top_block_clk_wiz_0_0_clk_out1, NUM_READ_THREADS 1, NUM_WR\
ITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi RREADY" *)
output wire m00_axi_rready;

  SAMPA_TRG_EN_v1_0 #(
    .TARGET_ADDRESS(32'H00000500),
    .TXN_TIMING(28'H0200000),
    .C_M00_AXI_START_DATA_VALUE(32'HAA000000),
    .C_M00_AXI_TARGET_SLAVE_BASE_ADDR(32'HC0000000),
    .C_M00_AXI_ADDR_WIDTH(32),
    .C_M00_AXI_DATA_WIDTH(32),
    .C_M00_AXI_TRANSACTIONS_NUM(4)
  ) inst (
    .sampa_trg_en(sampa_trg_en),
    .m00_axi_init_axi_txn(m00_axi_init_axi_txn),
    .m00_axi_error(m00_axi_error),
    .m00_axi_txn_done(m00_axi_txn_done),
    .m00_axi_aclk(m00_axi_aclk),
    .m00_axi_aresetn(m00_axi_aresetn),
    .m00_axi_awaddr(m00_axi_awaddr),
    .m00_axi_awprot(m00_axi_awprot),
    .m00_axi_awvalid(m00_axi_awvalid),
    .m00_axi_awready(m00_axi_awready),
    .m00_axi_wdata(m00_axi_wdata),
    .m00_axi_wstrb(m00_axi_wstrb),
    .m00_axi_wvalid(m00_axi_wvalid),
    .m00_axi_wready(m00_axi_wready),
    .m00_axi_bresp(m00_axi_bresp),
    .m00_axi_bvalid(m00_axi_bvalid),
    .m00_axi_bready(m00_axi_bready),
    .m00_axi_araddr(m00_axi_araddr),
    .m00_axi_arprot(m00_axi_arprot),
    .m00_axi_arvalid(m00_axi_arvalid),
    .m00_axi_arready(m00_axi_arready),
    .m00_axi_rdata(m00_axi_rdata),
    .m00_axi_rresp(m00_axi_rresp),
    .m00_axi_rvalid(m00_axi_rvalid),
    .m00_axi_rready(m00_axi_rready)
  );
endmodule
