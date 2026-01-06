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


// IP VLNV: xilinx.com:module_ref:idelay_top_v2:1.0
// IP Revision: 1

(* X_CORE_INFO = "idelay_top_v2,Vivado 2022.2" *)
(* CHECK_LICENSE_TYPE = "top_block_idelay_top_v2_0_0,idelay_top_v2,{}" *)
(* CORE_GENERATION_INFO = "top_block_idelay_top_v2_0_0,idelay_top_v2,{x_ipProduct=Vivado 2022.2,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=idelay_top_v2,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,pol0=11100000010,pol1=00100011010,pol2=01000100001,pol3=10111110101,pol=10111110101010001000010010001101011100000010,init_pol=1010110101,init_pattern_p=1010101011001100101010101100110,init_pattern_n=1010101001100110101010100110011,IODELAY_GROUP_BUS=00010110}" *)
(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module top_block_idelay_top_v2_0_0 (
  clk,
  idelay_refclk,
  idelay_refclk2,
  areset,
  areset_ref,
  areset_ref2,
  init,
  SO0_p,
  SO0_n,
  SO1_p,
  SO1_n,
  SO2_p,
  SO2_n,
  SO3_p,
  SO3_n,
  SO0_out,
  SO1_out,
  SO2_out,
  SO3_out,
  overall_state,
  S_AXI_ARADDR,
  S_AXI_ARVALID,
  S_AXI_ARREADY,
  S_AXI_RDATA,
  S_AXI_RRESP,
  S_AXI_RVALID,
  S_AXI_RREADY,
  ready,
  trg_en
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, FREQ_HZ 320000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN top_block_clk_wiz_1_0_clk_out1, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
input wire clk;
input wire idelay_refclk;
input wire idelay_refclk2;
input wire areset;
input wire areset_ref;
input wire areset_ref2;
input wire init;
input wire [10 : 0] SO0_p;
input wire [10 : 0] SO0_n;
input wire [10 : 0] SO1_p;
input wire [10 : 0] SO1_n;
input wire [10 : 0] SO2_p;
input wire [10 : 0] SO2_n;
input wire [10 : 0] SO3_p;
input wire [10 : 0] SO3_n;
output wire [10 : 0] SO0_out;
output wire [10 : 0] SO1_out;
output wire [10 : 0] SO2_out;
output wire [10 : 0] SO3_out;
output wire [3 : 0] overall_state;
input wire [3 : 0] S_AXI_ARADDR;
input wire S_AXI_ARVALID;
output wire S_AXI_ARREADY;
output wire [31 : 0] S_AXI_RDATA;
output wire [1 : 0] S_AXI_RRESP;
output wire S_AXI_RVALID;
input wire S_AXI_RREADY;
output wire ready;
output wire trg_en;

  idelay_top_v2 #(
    .pol0(11'B11100000010),
    .pol1(11'B00100011010),
    .pol2(11'B01000100001),
    .pol3(11'B10111110101),
    .pol(44'B10111110101010001000010010001101011100000010),
    .init_pol(10'B1010110101),
    .init_pattern_p(31'B1010101011001100101010101100110),
    .init_pattern_n(31'B1010101001100110101010100110011),
    .IODELAY_GROUP_BUS(8'B00010110)
  ) inst (
    .clk(clk),
    .idelay_refclk(idelay_refclk),
    .idelay_refclk2(idelay_refclk2),
    .areset(areset),
    .areset_ref(areset_ref),
    .areset_ref2(areset_ref2),
    .init(init),
    .SO0_p(SO0_p),
    .SO0_n(SO0_n),
    .SO1_p(SO1_p),
    .SO1_n(SO1_n),
    .SO2_p(SO2_p),
    .SO2_n(SO2_n),
    .SO3_p(SO3_p),
    .SO3_n(SO3_n),
    .SO0_out(SO0_out),
    .SO1_out(SO1_out),
    .SO2_out(SO2_out),
    .SO3_out(SO3_out),
    .overall_state(overall_state),
    .S_AXI_ARADDR(S_AXI_ARADDR),
    .S_AXI_ARVALID(S_AXI_ARVALID),
    .S_AXI_ARREADY(S_AXI_ARREADY),
    .S_AXI_RDATA(S_AXI_RDATA),
    .S_AXI_RRESP(S_AXI_RRESP),
    .S_AXI_RVALID(S_AXI_RVALID),
    .S_AXI_RREADY(S_AXI_RREADY),
    .ready(ready),
    .trg_en(trg_en)
  );
endmodule
