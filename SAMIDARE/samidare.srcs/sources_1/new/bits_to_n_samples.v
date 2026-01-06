`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/20/2025 02:10:01 PM
// Design Name: 
// Module Name: bits_to_n_samples
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


module bits_to_n_samples(
    input wire n_samp_0,
    input wire n_samp_1,
    output wire [7:0] n_samples
);

assign n_samples = (n_samp_1 == 0 && n_samp_0 == 0) ? 8'd16  :
                   (n_samp_1 == 0 && n_samp_0 == 1) ? 8'd32  :
                   (n_samp_1 == 1 && n_samp_0 == 0) ? 8'd64  :
                   (n_samp_1 == 1 && n_samp_0 == 1) ? 8'd128 : 8'd1;

endmodule
