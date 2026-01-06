`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2025 01:03:33 AM
// Design Name: 
// Module Name: OBUFDS_TRG
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


module OBUFDS_TRG(
    input [3:0] I,
    output[3:0] O,
    output[3:0] OB
    );
    OBUFDS OBUFDS_inst0(
        .I(I[0]),
        .O(O[0]),
        .OB(OB[0])
    );
    OBUFDS OBUFDS_inst1(
        .I(I[1]),
        .O(O[1]),
        .OB(OB[1])
    );
    OBUFDS OBUFDS_inst2(
        .I(I[2]),
        .O(O[2]),
        .OB(OB[2])
    );
    OBUFDS OBUFDS_inst3(
        .I(I[3]),
        .O(O[3]),
        .OB(OB[3])
    );
endmodule
