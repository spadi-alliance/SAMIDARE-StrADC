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
module cs_das_rx 
#(
    parameter N_SO = 4,
    parameter BIT_SAMPLES = 8
)
(
    input wire clk_SO,                  // 320MHz clk
    input wire en,                      // 40MHz clk
    input wire trg,                     // Trigger signal
    input wire [7:0] n_samples,         // Number of samples

    input wire [N_SO*10-1:0] SOs,       // SO0
    input wire [N_SO-1:0] fifo_full,        // FIFO full signal

    (*mark_debug="true"*)output wire [N_SO-1:0] wr_ens,
    output wire [N_SO*(320+BIT_SAMPLES)-1:0] buses,   // 320 bit output for SO + BIT_SAMPLES for sample number
    output wire [N_SO-1:0] sync_errors,

    (*mark_debug="true"*)output wire [N_SO-1:0] reset_fifos,

    (*mark_debug="true"*)output wire [N_SO*32-1:0] sync_regs_debug
);
    // State_reg definitions using parameter
    localparam IDLE = 2'b00;
    localparam SYNCING = 2'b01;
    localparam WAIT_FOR_SO = 2'b10;
    localparam UPDATE_BUS = 2'b11;

    localparam sync_pattern = 32'b11001100101010101100110010101010;
    localparam sync_zero = 10'h2B5;
    localparam sync_one = 10'h14A;
    localparam bit_bus = 320;
    localparam bit_bus_sample = bit_bus + BIT_SAMPLES;

    reg [31:0] sync_regs [N_SO-1:0];  // Sync pattern register
    (*mark_debug="true"*)reg [1:0] state_regs [N_SO-1:0];  // State_reg for each channel
    reg [bit_bus_sample-1:0] bus_regs [N_SO-1:0];
    reg [bit_bus-1:0] bus_internal_regs [N_SO-1:0];

    (*mark_debug="true"*)reg [4:0] clk_cnts [N_SO-1:0];
    reg wr_en_regs [N_SO-1:0];
    reg [N_SO-1:0] sync_error_regs;
    reg [N_SO-1:0] reset_fifo_regs;

    (*mark_debug="true"*)reg [N_SO-1:0] got_trigger;
    (*mark_debug="true"*)reg [BIT_SAMPLES-1:0] current_sample [N_SO-1:0];

    wire [9:0] SOs_internal [N_SO-1:0];
    genvar j;
    generate
        for (j = 0; j < N_SO; j = j + 1) begin
            assign SOs_internal[j] = SOs[j*10 +: 10];
            assign sync_regs_debug[j*32 +: 32] = sync_regs[j];
        end
    endgenerate

    // initial begin // DEBUG TEST
    //     $monitor("Time: %0t | State: %b | wr_en: %b | sync_error: %b | reset_fifo: %b", 
    //              $time, state_regs[0],  wr_en_regs[0], sync_error_regs[0], reset_fifo_regs[0]);
    // end

    // State_reg Machine Logic and Counters
    genvar i;
    generate
        for (i = 0; i < N_SO; i = i + 1) begin

            assign wr_ens[i] = wr_en_regs[i];
            assign reset_fifos[i] = reset_fifo_regs[i];
            assign sync_errors[i] = sync_error_regs[i];

            assign buses[i*bit_bus_sample +: bit_bus_sample] = bus_regs[i];

            initial begin
                state_regs[i] = IDLE;
                clk_cnts[i] = 5'b0;
                wr_en_regs[i] = 1'b0;
                current_sample[i] = 4'b0;
                got_trigger[i] = 1'b0;
            end
            always @(posedge clk_SO) begin
                // Reset condition
                if (en==0)begin
                    state_regs[i] <= IDLE;
                    sync_regs[i] <= 32'b0;
                    wr_en_regs[i] <= 1'b0;
                    sync_error_regs[i] <= 1'b1;
                    reset_fifo_regs[i] <= 1'b1;
                    bus_regs[i] <= 0;
                    bus_internal_regs[i] <= 0;
                    got_trigger[i] <= 1'b0;
                end else begin
                    clk_cnts[i] <= clk_cnts[i] + 1; 
                    reset_fifo_regs[i] <= 0;
                    if (trg) begin
                        got_trigger[i] <= 1;
                    end
                    case (state_regs[i])
                        IDLE: begin
                            if (SOs_internal[i][9:0] ==  sync_zero) begin
                                state_regs[i] <= SYNCING;
                                sync_regs[i][1] <= 0;
                                clk_cnts[i] <= 1;
                            end
                        end
                        SYNCING: begin
                            if (clk_cnts[i] == 5'd31) begin
                                state_regs[i] <= UPDATE_BUS;
                                sync_regs[i][clk_cnts[i]] <= SOs_internal[i][9:0] == sync_one;
                                sync_error_regs[i] <= !({SOs_internal[i][9:0] == sync_one, sync_regs[i][30:0]} == sync_pattern);
                            end else begin
                                if (clk_cnts[i][0] == 1) begin
                                    sync_regs[i][clk_cnts[i]] <= SOs_internal[i][9:0] == sync_one;
                                end else begin
                                    sync_regs[i][clk_cnts[i]] <= !(SOs_internal[i][9:0] == sync_zero);
                                end
                            end
                            
                        end
                        UPDATE_BUS: begin
                            wr_en_regs[i] <= 1'b0;
                            bus_internal_regs[i] <= {bus_internal_regs[i][309:0], SOs_internal[i][9:0]}; // SOx 10-bit data shift
                            if (got_trigger[i]) begin
                                if (clk_cnts[i] == 5'd31) begin
                                    bus_regs[i] <= {current_sample[i], {bus_internal_regs[i][309:0], SOs_internal[i][9:0]}};
                                    // Remain in UPDATE_BUS state_reg
                                    wr_en_regs[i] <= 1'b1;
                                    current_sample[i] <= current_sample[i] + 1;
                                end
                                if (current_sample[i] == n_samples) begin
                                    // $display("Current sample = %0d", current_sample[i]);
                                    current_sample[i] <= 0;
                                    got_trigger[i] <= 0;
                                end
                            end
                        end
                        default: state_regs[i] <= UPDATE_BUS; // Fallback to SYNCING state_reg
                    endcase
                end
            end
        end
    endgenerate

endmodule