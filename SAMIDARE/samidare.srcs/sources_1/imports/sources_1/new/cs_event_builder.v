`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2025 01:27:04 PM
// Design Name: 
// Module Name: cs_event_builder
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


/* GENERAL STRUCTURE OF DATA
HEADER
[ 0:15 ] = 16'hafaf // Header
[16:21 ] = 6'b000000 // Reserved
[22:23 ] = 2'b00 // Bus select
[24:31 ] = 8'b00000000 // Sample number
HEADER_2
[ 0:15 ] = 16'haffa // Header
[16:31 ] = counter[47:32] // 16 bits of counter
HEADER_3
[ 0:15 ] = 16'hfaaf // Header
[16:31 ] = counter[31:16] // 16 bits of counter
HEADER_4
[ 0:15 ] = 16'hfffa // Header
[16:31 ] = counter[15:0] // 16 bits of counter
EVENT DATA
[ 0:319] = 320 bits of data (32 channels * 10 bits each)
FOOTER
[ 0:15 ] = 16'hfafa // Footer
[16:21 ] = 6'b000000 // Reserved
[22:23 ] = 2'b00 // Bus select
[24:31 ] = 8'b00000000 // Sample number
*/

module cs_event_builder
#(
    parameter N_SO = 4,
    parameter BIT_SAMPLES = 8,
    parameter COUNTER_WIDTH = 48
)(
    input wire clk,      //125MHz

    input wire [1:0] bus_sel,
    input wire [BIT_SAMPLES-1:0] sample_n,
    input wire [COUNTER_WIDTH-1:0] counter, // 48-bit counter
    input wire [319:0] data,
    input wire last_data,
    input wire valid,
    input wire event_reset,
    input wire busy_i, // 20250429 added by nagafusa

    output reg data_ack_reg,
    output reg busy,
    output reg [31:0] event_word,
    output reg [9:0] event_offset, 
    output reg [10:0] event_commit_len,
    output reg event_write,
    output reg event_commit
);


    localparam IDLE          = 3'b000,
               SEND_HEADER_0   = 3'b001,
               SEND_HEADER_1 = 3'b010,
               SEND_HEADER_2 = 3'b011,
               SEND_HEADER_3 = 3'b100,
               SENDING_EVENT = 3'b101,
               SEND_FOOTER   = 3'b110,
               END_EVENT     = 3'b111;
               
    
    reg [1:0] bus_sel_reg;
    reg [319:0] data_reg;
    reg [BIT_SAMPLES-1:0] sample_n_reg;
    reg last_data_reg;

    (*mark_debug="true"*) reg [2:0] state;
    reg [4:0] index;                          // index (0 to 9)
    reg [10:0] data_length;                   // data length

    reg [10:0] footer_cnt;

    initial begin
        data_reg = 0;
    end

    task reset;
        begin
            data_reg <= 0;
            state <= IDLE;
            last_data_reg <= 0;
            sample_n_reg <= 0;
            data_ack_reg <= 0;
            event_commit_len <= 0;
            event_commit <= 0;
            event_write <= 0;
            index <= 0;
            data_length <= 0;
            busy <= 0;
        end
    endtask

    always @(posedge clk) begin
        if (event_reset)
            reset;
        else begin
            case (state)
                IDLE: begin
                    event_commit <= 0;
//                    if (valid && event_free) begin
//                    if (valid && (event_free || page_open)) begin
                    if (!busy_i && valid) begin
                        //$display("event_free = %b, page_open = %b", event_free, page_open);
                        //$display("valid = %b, data = %h", valid, data);
                        data_reg <= data;
                        last_data_reg <= last_data;
                        sample_n_reg <= sample_n;
                        state <= SEND_HEADER_0;
                        data_ack_reg <= 1'b1;
                        busy <= 1'b1;
                    end else begin
                        reset;
                    end
                end
                SEND_HEADER_0: begin
                    event_word <= {16'hafaf, 6'd0, bus_sel, sample_n_reg[7:0]};
                    event_offset <= 0;
                    event_write <= 1;
                    data_ack_reg <= 0;
                    bus_sel_reg <= bus_sel;
                    index <= 0;
                    data_length <= 0;
                    state <= SEND_HEADER_1;
                end
                SEND_HEADER_1: begin
                    event_word <= {16'haffa, counter[47:32]};
                    event_offset <= data_length[9:0] + 1;
                    data_length <= data_length + 1;
                    event_write <= 1;
                    state <= SEND_HEADER_2;
                end
                SEND_HEADER_2: begin
                    event_word <= {16'hfaaf, counter[31:16]};
                    event_offset <= data_length[9:0] + 1;
                    data_length <= data_length + 1;
                    event_write <= 1;
                    state <= SEND_HEADER_3;
                end
                SEND_HEADER_3: begin
                    event_word <= {16'hfffa, counter[15:0]};
                    event_offset <= data_length[9:0] + 1;
                    data_length <= data_length + 1;
                    event_write <= 1;
                    state <= SENDING_EVENT;
                end
                SENDING_EVENT: begin
                    data_ack_reg <= 0;
                    event_word <= data_reg >> (288 - index * 32);
                    event_offset <= data_length[9:0] + 1;
                    data_length <= data_length + 1;
                    event_write <= 1;
                    if (index == 9) begin
                        state <= SEND_FOOTER;
                    end else begin
                        index <= index + 1;
                    end
                end
                SEND_FOOTER: begin
                    event_word <= {16'hfafa, 6'd0, bus_sel_reg, sample_n_reg[7:0]};
                    event_offset <= data_length[9:0] + 10'd1;
                    event_write <= 1;
                    state <= END_EVENT;
//                    state <= END_FOOTER_TEST;//additional fotter testnc
//                    data_length <= data_length + 1;
//                    footer_cnt <= 1;
                end
//                END_FOOTER_TEST: begin//added by nagafusa 20250428
//                    if(footer_cnt == 11'd1000)begin
//                        state <= END_EVENT;
//                    end else begin
//                        data_length <= data_length + 1;
//                    end
//                        event_word <= {16'hfafa, footer_cnt[5:0], bus_sel_reg, 4'd0, sample_n[3:0]};
//                        footer_cnt <= footer_cnt + 11'b1;
//                        event_offset <= data_length[9:0] + 10'd1;
//                        event_write <= 1;
//    //                    state <= END_FOOTER_TEST;
////                        state <= END_EVENT;
                                    
//                end
                END_EVENT: begin
                    event_commit_len <= data_length + 11'd2; // +1 for footer, +1 for 0-based indexing
//                    event_commit_len <= {data_length[8:0],2'b00} + 11'd8;
                    event_commit <= 1;
                    busy <= 0;
                    event_write <= 0;
                    state <= IDLE;
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
