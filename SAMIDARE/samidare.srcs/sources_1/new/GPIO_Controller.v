`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/16/2025 10:56:03 AM
// Design Name: 
// Module Name: GPIO_Controller
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


module GPIO_Controller(
    input clk,
    input rst,
    input [7:0] gpio_i,
    output [7:0] gpio_o,
    output [7:0] gpio_t
    );
    assign gpio_o = 8'b00000000;
    assign gpio_t = 8'b11111111;
endmodule
