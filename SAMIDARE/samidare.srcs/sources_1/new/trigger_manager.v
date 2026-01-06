`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/20/2024 06:10:51 PM
// Design Name: 
// Module Name: trigger_manager
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


module trigger_manager (
    input wire clk,            // System clock, 40MHz
    input wire external_disabled,        // Register trigger value (inverted logic)
    input wire external_trg,
    input wire clk_enable_1kHz,     // clock trigger enable
    input wire clk_enable_1MHz,     // clock trigger enable
    input wire busy_i,         // Busy signal from downstream module
    input wire [10:0] SO0,
    output reg trg,            // Trigger signal to data processor
    output wire en              // Enable signal for FIFO writing
);

    // Internal registers
    reg trg_active;            // Register to indicate if trigger is active
    reg [31:0] clk_counter_1kHz;
    reg [7:0] clk_counter_1MHz;
    reg trg_internal_1kHz;
    reg trg_internal_1MHz;

    assign en = ~trg_active && ~busy_i;

    always @(posedge clk) begin
        trg <= 1'b0;

        // 1kHz trigger generation
        if(clk_counter_1kHz == 32'd40000000) begin
            clk_counter_1kHz <= 32'd0;
            trg_internal_1kHz <= 1'b1;
        end else begin
            clk_counter_1kHz <= clk_counter_1kHz + 1;
            trg_internal_1kHz <= 1'b0;
        end

        // 1MHz trigger generation
        if(clk_counter_1MHz == 8'd40) begin
            clk_counter_1MHz <= 8'd0;
            trg_internal_1MHz <= 1'b1;
        end else begin
            clk_counter_1MHz <= clk_counter_1MHz + 1;
            trg_internal_1MHz <= 1'b0;            
        end

        // Generate trigger signal
        if ((!external_disabled && external_trg) || (trg_internal_1kHz && clk_enable_1kHz) || (trg_internal_1MHz && clk_enable_1MHz)) begin
            trg <= 1'b1;  // Trigger signal active
            trg_active <= 1'b1;
        end else begin
            trg_active <= 1'b0;
            trg <= 1'b0;
        end

        // When busy signal goes low, reset the trigger signal
        if (busy_i == 1'b1 && trg_active) begin
            trg <= 1'b0;  // Deactivate trigger when busy
            trg_active <= 1'b0;
        end
        
    end
endmodule