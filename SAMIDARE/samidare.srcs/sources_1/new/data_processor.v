`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/20/2024 06:02:45 PM
// Design Name: 
// Module Name: data_processor
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


//module data_processor(
//    input clk,
//    input [319:0] bus0,
//    input [319:0] bus1,
//    input [319:0] bus2,
//    input [319:0] bus3,
//    input [3:0]empty,
//    input busy_i,
    
//    output [3:0] rd_en,
//    output [1:0] bus_sel,
//    output [7:0] data_length,
//    output valid,
//    output ready,
//    output busy,
//    output [319:0] data_o
//    );
//endmodule

module data_processor (
    input wire clk,                    // System clock
    input wire event_reset,                  // Active high reset
    input wire trg,                    // Trigger signal
    input wire ack,                    // Acknowledge signal from downstream module
    input wire busy_i,
    input wire [320*4-1:0] fifo_data_i,  // 4 FIFOs with 320-bit data width
    input wire [3:0] samples_i,
    output wire [3:0] samples_o,
    output reg [319:0] data_out,       // 320-bit data to downstream module
    output reg [1:0] bus_sel,          // FIFO selector for downstream module
    output reg [3:0] req,
    output reg busy,
    output reg last_data,
    output reg valid                   // Valid signal indicating data is ready
);
    (*mark_debuig = "true"*)reg [2:0] state;                   // FSM state
    reg [7:0] counter;                 // Counter for data samples
    reg [1:0] bus_sel_internal;        // Internal FIFO selector
    wire [319:0] fifo_data [3:0];
    assign fifo_data[0] = fifo_data_i[320*1-1:320*(1-1)]; 
    assign fifo_data[1] = fifo_data_i[320*2-1:320*(2-1)]; 
    assign fifo_data[2] = fifo_data_i[320*3-1:320*(3-1)]; 
    assign fifo_data[3] = fifo_data_i[320*4-1:320*(4-1)]; 
    //parameter samples = 8'd16;         // Number of samples to read from each FIFO
    // FSM States
    localparam WAIT      = 3'b000;
    localparam LOAD      = 3'b001;
    localparam SEND      = 3'b010;
    localparam ACK_WAIT  = 3'b011;
    localparam INCREMENT = 3'b100;
    
    assign samples_o = counter;
    always @(posedge clk or posedge event_reset) begin
        if (event_reset) begin
            // Reset logic
            state <= WAIT;
            counter <= 8'd0;
            bus_sel_internal <= 2'd0;
            data_out <= 320'd0;
            bus_sel <= 2'd0;
            valid <= 1'b0;
            busy <= 1'b0;
            last_data <= 1'b0;
        end else begin
            case (state)
                WAIT: begin
                    // Wait state, wait for the trigger signal
                    valid <= 1'b0;
                    if (trg & !busy_i) begin
                        counter <= 8'd0;
                        bus_sel_internal <= 2'd0;
                        busy <= 1'b1;
                        last_data <= 1'b0;
                        state <= LOAD;
                    end else begin
                        busy <= 1'b0;
                    end
                end
                LOAD: begin
                    // Trigger detected, initialize counter and bus_sel
                    data_out <= fifo_data[bus_sel_internal];  // Load data from selected FIFO
                    req[bus_sel_internal] <= 1'b1;
                    bus_sel <= bus_sel_internal;
                    counter <= counter + 1;
                    valid <= 1'b1;  // Indicate that data is ready to be sent
                    state <= SEND;
                    if(counter==samples_i&&bus_sel_internal==2'd3)begin
                        last_data <= 1'b1;
                    end
                end
                SEND: begin
                    req[bus_sel_internal] <= 1'b0;
                    // Send data and bus_sel to downstream module
                    state <= ACK_WAIT;
                end
                ACK_WAIT: begin
                    // Wait for ack signal from downstream module
                    if (ack) begin
                        valid <= 1'b0;  // Clear valid signal when ack is received
                        if (counter == samples_i) begin
                            // If counter equals the set number of samples
                            if (bus_sel_internal == 2'd3) begin
                                // If bus_sel equals 3, reset to WAIT state
                                state <= WAIT;
                            end else begin
                                state <= LOAD;
                            end
                            bus_sel_internal <= bus_sel_internal + 1;
                            counter <= 8'd0;
                        end else begin
                            // Continue reading data from the current FIFO
                            if(!busy_i)begin
                            state <= LOAD;
                            end
                        end
                    end
                end
                default: begin
                    // Default state reset
                    state <= WAIT;
                end
            endcase
        end
    end
endmodule
