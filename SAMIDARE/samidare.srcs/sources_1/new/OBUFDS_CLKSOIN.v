`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2025 12:56:30 AM
// Design Name: 
// Module Name: OBUFDS_CLKSOIN
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module OBUFDS_CLKSOIN(
    input I,
    output [3:0]O,
    output [3:0]OB
    );
    wire [3:0]II;
    assign II[0]=I;
    assign II[1]=I;
    assign II[2]=I;
    assign II[3]=I;
    OBUFDS OBUFDS_inst0(
      .O(O[0]),
      .OB(OB[0]),
      .I(II[0])
    );
    OBUFDS OBUFDS_inst1(
      .O(O[1]),
      .OB(OB[1]),
      .I(II[1])
    );
    OBUFDS OBUFDS_inst2(
      .O(O[2]),
      .OB(OB[2]),
      .I(II[2])
    );
    OBUFDS OBUFDS_inst3(
      .O(O[3]),
      .OB(OB[3]),
      .I(II[3])
    );
endmodule
