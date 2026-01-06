`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2025 10:26:27 AM
// Design Name: 
// Module Name: cs_appunit_merge
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

module cs_appunit_merge(
    input full_0,
    input full_1,
    input full_2,
    input full_3,
    input [10:0] SO_0,       // First 11-bit signal
    input [10:0] SO_1,       // Second 11-bit signal
    input [10:0] SO_2,       // Third 11-bit signal
    input [10:0] SO_3,       // Fourth 11-bit signal
    output [3:0] fulls,        // Concatenated 4-bit signal
    output [39:0] SOs      // Concatenated 40-bit signal
);

    // Concatenate the 4 full signals into a single 4-bit output
    assign fulls = {full_3, full_2, full_1, full_0};
    assign SOs = {
        SO_3[9:0], // Remove the last digit (LSB) from each 10-bit signal
        SO_2[9:0],
        SO_1[9:0],
        SO_0[9:0]
    };

endmodule