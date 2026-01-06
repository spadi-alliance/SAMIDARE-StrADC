`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2025 10:21:40 AM
// Design Name: 
// Module Name: cs_ccd_dflop
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


module cs_ccd_dflop #(
    parameter WIDTH = 1
    )(
    input wire clk,
    input wire [WIDTH-1:0] d,
    output wire [WIDTH-1:0] dout
    );
    
    reg [WIDTH-1:0] dmeta;
    reg [WIDTH-1:0] dflop;

    always @(posedge clk) begin
        dmeta <= d;
        dflop <= dmeta;
    end
    assign dout = dflop;

endmodule
