`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2024 06:27:55 PM
// Design Name: 
// Module Name: TRG_MODULE
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


module TRG_MODULE(
    input clk,
    input rst,
    input en,
    input init_trg,
    output [3:0] trg
    );
    
   
    wire trg_i;
    assign trg_i = en || init_trg;
    
    assign trg[0] = trg_i;
    assign trg[1] = !trg_i;
    assign trg[2] = !trg_i;
    assign trg[3] = trg_i;
    
endmodule
