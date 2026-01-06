`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/28/2025 02:58:31 PM
// Design Name: 
// Module Name: cs_data_processor
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


module cs_data_processor
#(
    parameter N_SO = 4,
    parameter BIT_SAMPLES = 8,
    parameter COUNTER_WIDTH = 48
)(
    input wire clk,                    // System clock
    input wire event_reset,                  // Active high reset
    input wire [N_SO-1:0] fifo_empty,                    // Empty signal
    input wire ack,                    // Acknowledge signal from downstream module
    input wire busy_i,                    // Acknowledge signal from downstream module
    input wire [N_SO*(320+BIT_SAMPLES+COUNTER_WIDTH)-1:0] fifo_data_i,  // 4 FIFOs with 320-bit data width
    (*mark_debug="true"*)output wire [BIT_SAMPLES-1:0] sample, // 4-bit sample counter
    (*mark_debug="true"*)output reg [COUNTER_WIDTH-1:0] counter, // 4-bit sample counter
    (*mark_debug="true"*)output reg [319:0] data_out,       // 320-bit data to downstream module
    (*mark_debug="true"*)output reg [($clog2(N_SO)-1):0] bus_sel,          // FIFO selector for downstream module
    (*mark_debug="true"*)output reg [N_SO-1:0] fifo_req,    // FIFO request signal, 0 for none
    (*mark_debug="true"*)output reg busy,
    (*mark_debug="true"*)output reg last_data,
    (*mark_debug="true"*)output reg valid                   // Valid signal indicating data is ready
);

    localparam IDLE             = 3'b000;
    localparam REQ_DATA         = 3'b001;
    localparam FIFO_WAIT         = 3'b010;
    localparam LOAD_DATA        = 3'b011;
    localparam ACK_WAIT         = 3'b100;

    reg [2:0] state;                   // FSM state
    wire [320+BIT_SAMPLES+COUNTER_WIDTH-1:0] fifo_data [N_SO-1:0];       // Internal data output
    reg [BIT_SAMPLES-1:0] sample_reg;     // Sample counter

    assign sample = sample_reg;

    generate
        genvar i;
        for(i=0; i<N_SO; i=i+1) begin: DATA_PROCESSOR
            assign fifo_data[i] = fifo_data_i[i*(320+BIT_SAMPLES+COUNTER_WIDTH) +: 320+BIT_SAMPLES+COUNTER_WIDTH];
        end
    endgenerate

    initial begin
        $dumpfile ("wave.vcd");
        $dumpvars (0, cs_data_processor);
        #1

        state <= IDLE;
        bus_sel <= 0;
        fifo_req <= 0;
        busy <= 1'b0;
        last_data <= 1'b0;
        valid <= 1'b0;
    end
    always @(posedge clk) begin
        if(event_reset) begin
            state <= IDLE;
            bus_sel <= 0;
            fifo_req <= 0;
            busy <= 1'b0;
            last_data <= 1'b0;
            valid <= 1'b0;
        end else begin
            case(state)
                IDLE: begin
                    if(~fifo_empty) begin
                        state <= REQ_DATA;
                        bus_sel <= 0;
                        fifo_req <= 0;
                        busy <= 1'b1;
                        last_data <= 1'b0;
                        valid <= 1'b0;
                    end else begin
                        busy <= 1'b0;
                    end
                end
                REQ_DATA: begin
                    last_data <= 1'b0;
                    $display("bus_sel: %d", bus_sel);
                    if(fifo_empty[bus_sel]) begin
                        if (bus_sel == N_SO-1) begin
                            state <= IDLE;
                        end else begin
                            bus_sel <= bus_sel + 1;
                        end
                    end else begin
                        if(!busy_i)begin//added by nagafusa 20250427
                            if (bus_sel == N_SO) begin
                                state <= IDLE;
                            end else begin
                                fifo_req <= 1 << bus_sel;
                                state <= FIFO_WAIT;
                            end
                        end
                    end
                end
                FIFO_WAIT: begin
                    // wait one read clock cycle for FIFO to output data
                    state <= LOAD_DATA;
                    fifo_req <= 0;
                end
                LOAD_DATA: begin
                    // last 4 bits are sample number
                    sample_reg <= fifo_data[bus_sel][319 + BIT_SAMPLES : 320];
                    // first 320 bits are data
                    data_out <= fifo_data[bus_sel][319:0];
                    // last 48 bits are counter
                    counter <= fifo_data[bus_sel][319 + BIT_SAMPLES + COUNTER_WIDTH : 320 + BIT_SAMPLES];
                    $display("Data loaded from FIFO %d: %h", bus_sel, data_out);
                    $display("Counter: %h", counter);
                    state <= ACK_WAIT;
                    valid <= 1'b1;
                end
                ACK_WAIT: begin
                    $display("ACK_WAITING");
                    if(ack) begin
                        // checlk sample_reg is full or not
                        if (&sample_reg) begin
                            $display("Sample_reg: %b", sample_reg);
                            last_data <= 1'b1;
                            bus_sel <= bus_sel + 1;
                        end
                        state <= REQ_DATA;
                        valid <= 1'b0;
                    end
                end
                default: begin
                    state <= IDLE;
                end
                
            endcase 
        end
    end


endmodule