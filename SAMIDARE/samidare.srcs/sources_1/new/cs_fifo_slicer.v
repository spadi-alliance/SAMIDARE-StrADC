`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2025 10:36:35 AM
// Design Name: 
// Module Name: cs_fifo_slicer
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


module cs_fifo_slicer
#(
    parameter N_SO = 4,
    parameter MAX_BIT_SAMPLES = 8
)
(
    input [3:0] wr_ens,
    input [3:0] reset_fifos,
    input [3:0] request_fifos,
    input [N_SO*(320+MAX_BIT_SAMPLES)-1:0] buses,
    output [0:0] wr_en_0,
    output [0:0] wr_en_1,
    output [0:0] wr_en_2,
    output [0:0] wr_en_3,
    output [0:0] reset_fifo_0,
    output [0:0] reset_fifo_1,
    output [0:0] reset_fifo_2,
    output [0:0] reset_fifo_3,
    output [0:0] request_fifo_0,
    output [0:0] request_fifo_1,
    output [0:0] request_fifo_2,
    output [0:0] request_fifo_3,
    output [(320+MAX_BIT_SAMPLES)-1:0] bus_0,
    output [(320+MAX_BIT_SAMPLES)-1:0] bus_1,
    output [(320+MAX_BIT_SAMPLES)-1:0] bus_2,
    output [(320+MAX_BIT_SAMPLES)-1:0] bus_3
    );

    assign wr_en_0 = {wr_ens[0]};
    assign wr_en_1 = {wr_ens[1]};
    assign wr_en_2 = {wr_ens[2]};
    assign wr_en_3 = {wr_ens[3]};
    assign reset_fifo_0 = {reset_fifos[0]};
    assign reset_fifo_1 = {reset_fifos[1]};
    assign reset_fifo_2 = {reset_fifos[2]};
    assign reset_fifo_3 = {reset_fifos[3]};
    assign request_fifo_0 = {request_fifos[0]};
    assign request_fifo_1 = {request_fifos[1]};
    assign request_fifo_2 = {request_fifos[2]};
    assign request_fifo_3 = {request_fifos[3]};
    assign bus_0 = buses[(320+MAX_BIT_SAMPLES)-1:0];
    assign bus_1 = buses[2*(320+MAX_BIT_SAMPLES)-1:(320+MAX_BIT_SAMPLES)];
    assign bus_2 = buses[3*(320+MAX_BIT_SAMPLES)-1:2*(320+MAX_BIT_SAMPLES)];
    assign bus_3 = buses[4*(320+MAX_BIT_SAMPLES)-1:3*(320+MAX_BIT_SAMPLES)];
    

endmodule
