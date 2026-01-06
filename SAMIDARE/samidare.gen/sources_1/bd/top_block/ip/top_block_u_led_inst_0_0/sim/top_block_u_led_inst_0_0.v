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


// IP VLNV: xilinx.com:module_ref:u_led_inst:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module top_block_u_led_inst_0_0 (
  clk125MHz,
  reset,
  enable,
  fnet_txn,
  power_on,
  ext_clk_lkd,
  LED_REG0,
  LED_REG1,
  LED_REG2,
  LED_REG3,
  DIPSW,
  INIT_AXI_TXN,
  INIT_AXI_TXN_SUB,
  LED_TXN_DONE,
  LED
);

input wire clk125MHz;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME reset, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset RST" *)
input wire reset;
input wire enable;
input wire fnet_txn;
input wire power_on;
input wire ext_clk_lkd;
input wire [31 : 0] LED_REG0;
input wire [31 : 0] LED_REG1;
input wire [31 : 0] LED_REG2;
input wire [31 : 0] LED_REG3;
input wire [3 : 0] DIPSW;
output wire INIT_AXI_TXN;
output wire INIT_AXI_TXN_SUB;
input wire LED_TXN_DONE;
output wire [3 : 0] LED;

  u_led_inst inst (
    .clk125MHz(clk125MHz),
    .reset(reset),
    .enable(enable),
    .fnet_txn(fnet_txn),
    .power_on(power_on),
    .ext_clk_lkd(ext_clk_lkd),
    .LED_REG0(LED_REG0),
    .LED_REG1(LED_REG1),
    .LED_REG2(LED_REG2),
    .LED_REG3(LED_REG3),
    .DIPSW(DIPSW),
    .INIT_AXI_TXN(INIT_AXI_TXN),
    .INIT_AXI_TXN_SUB(INIT_AXI_TXN_SUB),
    .LED_TXN_DONE(LED_TXN_DONE),
    .LED(LED)
  );
endmodule
