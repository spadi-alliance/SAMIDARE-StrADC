`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/16/2025 11:36:54 AM
// Design Name: 
// Module Name: xpm_async_fifo_wrapper
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


module xpm_async_fifo_wrapper #(
    parameter DATA_WIDTH = 320,  //
    parameter FIFO_DEPTH = 32 //
)(
    input wire wr_clk,          // 
    input wire rd_clk,          // 
    input wire rst,             // active low
    input wire [DATA_WIDTH-1:0] din,  // data input
    input wire wr_en,           // write enable
    input wire rd_en,           // read enable
    output wire [DATA_WIDTH-1:0] dout, // data output
    output wire full,           // FIFO full
    output wire empty          // FIFO empty
);
    // XPM Async FIFO instance
    xpm_fifo_async #(
        .FIFO_MEMORY_TYPE("auto"),       // "auto", "distributed", "block"
        .FIFO_WRITE_DEPTH(FIFO_DEPTH),   // 
        .WRITE_DATA_WIDTH(DATA_WIDTH),   // 
        .READ_DATA_WIDTH(DATA_WIDTH),    // 
        .USE_ADV_FEATURES("0000"),       // advanced features 
        .READ_MODE("fwft"),              // std or fwft
        .FIFO_READ_LATENCY(0)           // latency 0（the only applicable value in FWFT mode）
    ) xpm_fifo_async_inst (
        .wr_clk(wr_clk),                 // 
        .rd_clk(rd_clk),                 // 
        .rst(!rst),                       // 
        .din(din),                       // 
        .wr_en(wr_en),                   // 
        .rd_en(rd_en),                   // 
        .dout(dout),                     // 
        .full(full),                     // 
        .empty(empty),                   // 
        .wr_rst_busy(),                  // write reset flag while writing
        .rd_rst_busy()                   // read reset flag while reading
    );
endmodule
