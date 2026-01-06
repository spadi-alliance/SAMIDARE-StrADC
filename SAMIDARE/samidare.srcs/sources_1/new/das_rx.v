`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 08/16/2024 12:59:05 PM
// Design Name:
// Module Name: das_rx
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
module das_rx(
    input wire clk_SO,      // 320MHz clk
    input wire user_clk,    // 40MHz clk
    input wire en,    // 40MHz clk
    (*mark_debug="true"*) input wire [10:0] SO0,      // SO0
    (*mark_debug="true"*) input wire [10:0] SO1,      // SO1
    (*mark_debug="true"*) input wire [10:0] SO2,      // SO2
    (*mark_debug="true"*) input wire [10:0] SO3,      // SO3
    (*mark_debug="true"*) input wire [3:0] full,
    (*mark_debug="true"*) output wire wr_en0,
    (*mark_debug="true"*) output wire wr_en1,
    (*mark_debug="true"*) output wire wr_en2,
    (*mark_debug="true"*) output wire wr_en3,
    (*mark_debug="true"*) output wire [319:0] bus0,   // 320 bit output for SO0
    (*mark_debug="true"*) output wire [319:0] bus1,   // 320 bit output for SO1
    (*mark_debug="true"*) output wire [319:0] bus2,   // 320 bit output for SO2
    (*mark_debug="true"*) output wire [319:0] bus3    // 320 bit output for SO3
);
    // State definitions using parameter
    parameter IDLE = 2'b00;
    parameter WAIT_FOR_SO = 2'b01;
    parameter UPDATE_BUS = 2'b10;
    reg [1:0] state [3:0];  // State for each channel
    // Counter, bus, and clk related registers
    reg [4:0] count; // 32 ch cycle
    reg [319:0] bus [3:0];
    reg [319:0] bus_r [3:0];
    wire [10:0] SO [3:0];
    assign SO[0] = SO0;
    assign SO[1] = SO1;
    assign SO[2] = SO2;
    assign SO[3] = SO3;
    reg [3:0] clk_10MHz_r;
    reg [3:0] clk_10MHz_rr;
    reg [4:0] clk_cnt [3:0];
    reg [4:0] ch0_cnt [3:0];
    reg [3:0] wr_en;
    (*mark_debug="true"*)reg [3:0] debug_SO10;
    assign wr_en0 = wr_en[0];
    assign wr_en1 = wr_en[1];
    assign wr_en2 = wr_en[2];
    assign wr_en3 = wr_en[3];
    // State Machine Logic and Counters
    
    generate
        genvar i;
        for (i = 0; i < 4; i = i + 1) begin
            //assign clk_10MHz[i] = clk_10MHz_rr[i];
            //assign wr_en[i] = clk_10MHz_rr[i] && ~full[i];
            //assign wr_en[i] = (ch0_cnt[i]!=0 && clk_cnt[i] == ch0_cnt[i]-1)||(ch0_cnt[i]==0&&clk_cnt[i] == 5'd31);
            always @(posedge clk_SO) begin
                debug_SO10[i] <= SO[i][10];
                // Reset condition
                if (en==1'b0) begin
                    state[i] <= IDLE;
                    clk_cnt[i] <= 0;
                    ch0_cnt[i] <= 0;
                end else begin
//                    clk_10MHz_r[i] <= SO[i][10];
//                    clk_10MHz_rr[i] <= SO[i][10] && ~clk_10MHz_r[i];
                    // 32 cycle counter
                    if (clk_cnt[i] == 31) begin
                        clk_cnt[i] <= 0;
                    end else begin
                        clk_cnt[i] <= clk_cnt[i] + 1;
                    end
                    case (state[i])
                        IDLE: begin
                            if (SO[i][9:0] == 10'h2B5) begin
                                ch0_cnt[i] <= clk_cnt[i];
                                state[i] <= WAIT_FOR_SO;
                            end
                        end
                        WAIT_FOR_SO: begin
                            if (clk_cnt[i] == ch0_cnt[i] - 1) begin
                                state[i] <= UPDATE_BUS;
                            end
                        end
                        UPDATE_BUS: begin
                            bus_r[i] <= {bus_r[i][309:0], SO[i][9:0]}; // SOx 10-bit data shift
                            if ((ch0_cnt[i]!=0&&clk_cnt[i] == ch0_cnt[i]-1)||(ch0_cnt[i]==0&&clk_cnt[i] == 5'd31)) begin
                                bus[i] <= bus_r[i];
                                // Remain in UPDATE_BUS state
                                wr_en[i] <= 1'b1;
                            end else begin
                                wr_en[i] <= 1'b0;
                            end
                        end
                        default: state[i] <= IDLE;
                    endcase
                end
            end
        end
    endgenerate
    // Assign outputs
    assign bus0 = bus[0];
    assign bus1 = bus[1];
    assign bus2 = bus[2];
    assign bus3 = bus[3];
endmodule