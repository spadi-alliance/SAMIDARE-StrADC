`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2025 01:11:56 AM
// Design Name: 
// Module Name: OBUFDS_CONST
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


module OBUFDS_CONST(
    input I,
    output O,
    output OB
    );
    OBUFDS OBUFDS_inst(
      .O(O),
      .OB(OB),
      .I(I)
    );
endmodule
