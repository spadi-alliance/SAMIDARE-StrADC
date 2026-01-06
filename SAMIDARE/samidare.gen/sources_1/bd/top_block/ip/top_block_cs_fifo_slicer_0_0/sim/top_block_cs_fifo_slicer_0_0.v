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


// IP VLNV: xilinx.com:module_ref:cs_fifo_slicer:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module top_block_cs_fifo_slicer_0_0 (
  wr_ens,
  reset_fifos,
  request_fifos,
  buses,
  wr_en_0,
  wr_en_1,
  wr_en_2,
  wr_en_3,
  reset_fifo_0,
  reset_fifo_1,
  reset_fifo_2,
  reset_fifo_3,
  request_fifo_0,
  request_fifo_1,
  request_fifo_2,
  request_fifo_3,
  bus_0,
  bus_1,
  bus_2,
  bus_3
);

input wire [3 : 0] wr_ens;
input wire [3 : 0] reset_fifos;
input wire [3 : 0] request_fifos;
input wire [1311 : 0] buses;
output wire [0 : 0] wr_en_0;
output wire [0 : 0] wr_en_1;
output wire [0 : 0] wr_en_2;
output wire [0 : 0] wr_en_3;
output wire [0 : 0] reset_fifo_0;
output wire [0 : 0] reset_fifo_1;
output wire [0 : 0] reset_fifo_2;
output wire [0 : 0] reset_fifo_3;
output wire [0 : 0] request_fifo_0;
output wire [0 : 0] request_fifo_1;
output wire [0 : 0] request_fifo_2;
output wire [0 : 0] request_fifo_3;
output wire [327 : 0] bus_0;
output wire [327 : 0] bus_1;
output wire [327 : 0] bus_2;
output wire [327 : 0] bus_3;

  cs_fifo_slicer #(
    .N_SO(4),
    .MAX_BIT_SAMPLES(8)
  ) inst (
    .wr_ens(wr_ens),
    .reset_fifos(reset_fifos),
    .request_fifos(request_fifos),
    .buses(buses),
    .wr_en_0(wr_en_0),
    .wr_en_1(wr_en_1),
    .wr_en_2(wr_en_2),
    .wr_en_3(wr_en_3),
    .reset_fifo_0(reset_fifo_0),
    .reset_fifo_1(reset_fifo_1),
    .reset_fifo_2(reset_fifo_2),
    .reset_fifo_3(reset_fifo_3),
    .request_fifo_0(request_fifo_0),
    .request_fifo_1(request_fifo_1),
    .request_fifo_2(request_fifo_2),
    .request_fifo_3(request_fifo_3),
    .bus_0(bus_0),
    .bus_1(bus_1),
    .bus_2(bus_2),
    .bus_3(bus_3)
  );
endmodule
