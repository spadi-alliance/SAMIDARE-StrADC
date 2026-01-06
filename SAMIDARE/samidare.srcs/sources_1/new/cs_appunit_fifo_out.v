`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2025 10:52:49 AM
// Design Name: 
// Module Name: cs_appunit_fifo_out
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

module cs_appunit_fifo_out
#(
    parameter MAX_BIT_SAMPLES = 8,
    parameter COUNTER_WIDTH = 48
)
(
    input [(320+MAX_BIT_SAMPLES+COUNTER_WIDTH)-1:0] bus_0,
    input [(320+MAX_BIT_SAMPLES+COUNTER_WIDTH)-1:0] bus_1,
    input [(320+MAX_BIT_SAMPLES+COUNTER_WIDTH)-1:0] bus_2,
    input [(320+MAX_BIT_SAMPLES+COUNTER_WIDTH)-1:0] bus_3,
    input empty_0,
    input empty_1,
    input empty_2,
    input empty_3,
    output [4*(320+MAX_BIT_SAMPLES+COUNTER_WIDTH)-1:0] fifos_out,
    output [3:0] fifos_empty
    );

    assign fifos_empty = {empty_3, empty_2, empty_1, empty_0};
    assign fifos_out = {
        bus_3,
        bus_2,
        bus_1,
        bus_0
    };

endmodule
