`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2025 11:27:39 AM
// Design Name: 
// Module Name: cs_clk_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//   48-bit counter in the internal 320 MHz clock domain.
//   - When select_ext = 0, counts every internal clock cycle.
//   - When select_ext = 1, counts rising edges of an external GPIO clock.
//   The external clock is treated as data, synchronized into the
//   internal clock domain using a 2-FF synchronizer and edge detection.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Counter implementation with GPIO sync
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cs_clk_sel(
    input  wire [47:0] int_cnt,        // Internal clock cycle count
    input  wire [47:0] ext_cnt,        // External clock edge count
    input  wire        clk,            // Internal clock (320 MHz)
    input  wire        select_ext,     // 0: count internal cycles, 1: count external edges
    output reg  [47:0] count           // 48-bit counter value
);

    always @(posedge clk) begin
        if(select_ext) begin
            count <= ext_cnt;
        end else begin
            count <= int_cnt;
        end
    end



endmodule