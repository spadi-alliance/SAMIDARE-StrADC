`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/17/2024 05:42:33 PM
// Design Name: 
// Module Name: event_builder_v0
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


module event_builder_v0 (
    input wire clk,      //125MHz
    input wire [3:0] empty,
    output wire rd_en,
                        
    input wire [319:0] bus0,                 
    input wire [319:0] bus1,                 
    input wire [319:0] bus2,                 
    input wire [319:0] bus3,                  
    output reg [31:0] event_word,             
    output reg [9:0] event_offset,            
    output reg event_write,                   
    output reg [10:0] event_commit_len,       
    output reg event_commit,                  
    input wire event_free,                    
    input wire event_reset                    
);

    localparam IDLE          = 3'b000,
               SEND_HEADER   = 3'b001,
               SENDING_EVENT = 3'b010,
               SEND_FOOTER   = 3'b011,
               END_EVENT     = 3'b100,
               REST          = 3'b101;
               
    reg [319:0] busx_reg;                     // busx register
    reg [319:0] bus0_r;                     // busx register
    reg [319:0] bus1_r;                     // busx register
    reg [319:0] bus2_r;                     // busx register
    reg [319:0] bus3_r;                     // busx register
    reg [4:0] index;                          // index (0 to 9)
    reg [1:0] bus_sel;                        // sel index of bus0 to bus3
    reg [10:0] data_length;                   // data length
    reg [2:0] state;            
    
    wire bus_ready;   
    reg rd_en_r;
    (*mark_debug = "true"*)reg [9:0] rest_count;
    assign rd_en = rd_en_r;
    assign bus_ready = ~(&empty);           
    // init
    initial begin
        state = IDLE;
        index = 5'd0;
        bus_sel = 2'd0;
        data_length = 11'd0;
        rd_en_r = 1'b0;
    end
    
    always @(posedge clk) begin
        if (event_reset) begin
            state <= IDLE;
            index <= 5'd0;
            bus_sel <= 2'd0;
            data_length <= 11'd0;
            event_word <= 32'd0;
            event_offset <= 10'd0;
            event_write <= 1'b0;
            event_commit_len <= 11'd0;
            event_commit <= 1'b0;
            rd_en_r <= 1'b0; 
        end else begin
            event_write <= 1'b0;
            event_commit <= 1'b0;
            case (state)
                IDLE: begin
                    if (event_free & bus_ready) begin
                        state <= SEND_HEADER;
                        bus0_r <= bus0;
                        bus1_r <= bus1;
                        bus2_r <= bus2;
                        bus3_r <= bus3;
                        rd_en_r <= 1'b1;
                    end
                end
                SEND_HEADER: begin
                    event_word <= {16'hfafa, 6'd0, bus_sel, 6'd0, bus_sel}; // header 0xfafa0i0i
                    event_offset <= 10'd0;
                    event_write <= 1'b1;
                    state <= SENDING_EVENT;
                    rd_en_r <= 1'b0;
                    case (bus_sel)
                        2'd0: busx_reg <= bus0_r;
                        2'd1: busx_reg <= bus1_r;
                        2'd2: busx_reg <= bus2_r;
                        2'd3: busx_reg <= bus3_r;
                    endcase
                    index <= 5'd0;
                    data_length <= 11'd0;
                end
                SENDING_EVENT: begin
                    rd_en_r <= 1'b0;
                    event_word <= busx_reg >> (288 - index * 32);  // every 32bit
//                    event_word <= busx_reg[319:319-31];  // every 32bit
//                    busx_reg <= {busx_reg[319-31:0], 32'd0};
                    event_offset <= data_length[9:0] + 10'd1;      // 
                    event_write <= 1'b1;
                    data_length <= data_length + 11'd1;
                    if (index == 5'd9) begin
                        state <= SEND_FOOTER;
                    end else begin
                        index <= index + 5'd1;
                    end
                end
                SEND_FOOTER: begin
                    rd_en_r <= 1'b0;
                    event_word <= {16'hfafa, 6'd0, bus_sel, 6'd0, bus_sel}; // footer 0xfafa0i0i
                    event_offset <= data_length[9:0] + 10'd1;
                    event_write <= 1'b1;
                    state <= END_EVENT;
                end
                END_EVENT: begin
                    rd_en_r <= 1'b0;
                    event_commit_len <= data_length + 11'd2; // data length (data, header, footer)
                    event_commit <= 1'b1;
                    if (bus_sel == 2'd3) begin
                        state <= REST;
                        rest_count <= 'b0;
                    end else begin
                        bus_sel <= bus_sel + 2'd1; // next bus
                        state <= SEND_HEADER;
                    end
                end
                REST: begin
                    event_write <= 1'b0;
                    event_commit <= 1'b0;
                      rest_count <= rest_count + 1'b1;
                      if (rest_count >= 100) begin
                        state <= IDLE;
                        bus_sel <= 2'd0; // reset bus_sel for next cycle
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
