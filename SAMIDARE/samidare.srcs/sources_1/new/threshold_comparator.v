`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2025 09:34:03 AM
// Design Name: 
// Module Name: threshold_comparator
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


module threshold_comparator #(
    parameter N = 4,           // Number of SAMPA chips
    parameter n_bits = 10,     // Bits per chip
    parameter channels = 32,   // Number of channels
    parameter max_pretrigger = 16 // Maximum pretrigger samples
)(
    input wire clk,
    input wire enable,
    input wire external_disabled,
    input wire [N*n_bits-1:0] signals,
    input wire [9:0] threshold,
    input wire [1:0] pretrigger_select, // 2-bit pretrigger selection
    output wire [N-1:0] triggered,
    output wire [N*n_bits-1:0] delayed_signals
);

    localparam PRE_0 = 2'b00; // No pretrigger
    localparam PRE_1 = 2'b01; // Pretrigger 1 (4 samples delay)
    localparam PRE_2 = 2'b10; // Pretrigger 2 (8 samples delay)
    localparam PRE_3 = 2'b11; // Pretrigger 3 (16 samples delay)

    // Per-channel FIFO: [channel][sample]
    reg [N*n_bits-1:0] channel_fifo [0:channels-1][0:max_pretrigger-1];
    reg [4:0] channel_ptr = 0; // 0..31, which channel is being updated
    reg [3:0] sample_ptr = 0;  // 0..15, which sample in the FIFO

    // Pretrigger delay logic (register, updates only when enable is off)
    reg [3:0] pretrigger_delay = 0;

    // Write logic
    integer i, j;
    initial begin
        for (i = 0; i < channels; i = i + 1)
            for (j = 0; j < max_pretrigger; j = j + 1)
                channel_fifo[i][j] = 0;
        channel_ptr = 0;
        sample_ptr = 0;
    end

    always @(posedge clk) begin
        if (enable) begin
            channel_fifo[channel_ptr][sample_ptr] <= signals;
            if (channel_ptr == channels-1) begin
                channel_ptr <= 0;
                sample_ptr <= sample_ptr + 1;
            end else begin
                channel_ptr <= channel_ptr + 1;
            end
        end else begin
            // Update pretrigger_delay only when enable is off
            pretrigger_delay <= (pretrigger_select == PRE_0) ? 4'd0 :
                               (pretrigger_select == PRE_1) ? 4'd3 :
                               (pretrigger_select == PRE_2) ? 4'd7 :
                               (pretrigger_select == PRE_3) ? 4'd15 : 4'd0;
            for (i = 0; i < channels; i = i + 1)
                for (j = 0; j < max_pretrigger; j = j + 1)
                    channel_fifo[i][j] <= 0;
            channel_ptr <= 0;
            sample_ptr <= 0;
        end
    end

    // Output delayed signals for the current channel
    wire [3:0] read_sample_ptr_delayed = sample_ptr - pretrigger_delay - 1;
    assign delayed_signals = channel_fifo[channel_ptr][read_sample_ptr_delayed];
    
    genvar k;
    generate
        for (k = 0; k < N; k = k + 1) begin : COMPARE
            assign triggered[k] = external_disabled && (signals[k*n_bits +: n_bits] >= threshold);
        end
    endgenerate

endmodule
