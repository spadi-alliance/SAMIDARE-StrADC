`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/04/2025 03:18:25 PM
// Design Name: 
// Module Name: data_to_fifo_tb
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


module data_to_fifo_tb;

    localparam sync_pattern = 32'b01010101001100110101010100110011;
    localparam sync_zero = 10'h2B5;
    localparam sync_one = 10'h14A;
    localparam delta_SO = 10;
    integer i;
    integer j;
    integer z;
    integer y;

    localparam kS = 1;
    localparam kW = kS*2;
    localparam kR = kW*2;

    // Inputs cs_das
    reg clk_SO;
    reg en;
    reg [9:0] SO0;
    wire full;
    reg trg;

    // Inputs asyncfifo
    reg read_clk;
    wire read_en_0;

    // Outputs cs_das
    wire wr_en0;
    wire [323:0] bus0;
    wire sync_error;
    wire reset_fifo_0;

    // Outputs asyncfifo
    wire mem_empty;
    wire [323:0] out;

    // Outputs cs_data_processor
    wire [319:0] data_out;
    wire [3:0] sample;
    wire [1:0] bus_sel;
    wire busy;
    wire last_data;
    wire valid;    

    // Outputs cs_event_builder
    wire ack;
    wire evet_build_busy;
    wire [31:0] event_word;
    wire [9:0] event_offset;
    wire [10:0] event_commit_len;
    wire event_write;
    wire event_commit;

    // Testbench Variables
    reg event_free;

    cs_das_rx
    #(
        .N_SO(1),
        .BIT_SAMPLES(4)
    )
    cs_das_rx_0
    (
        .clk_SO(clk_SO),
        .en(en),
        .SOs(SO0),
        .fifo_full(full),
        .wr_ens(wr_en0),
        .buses(bus0),
        .sync_errors(sync_error),
        .reset_fifos(reset_fifo_0),
        .n_samples(4'b0011),
        .trg(trg)
    );

    asyncfifo #(
        .WIDTH (328), // updated data width
        .DEPTH (64)   // FIFO depth
        ) fifo_0 (
        .write_clk (clk_SO), //input write clock
        .read_clk  (read_clk),  //input read clock
        .reset     (reset_fifo_0),     //input reset
        .write_en  (wr_en0),  //write enable
        .read_en   (read_en_0),   //read enable 
        .data_in   (bus0),   //data input
        .mem_full  (full),  //memory full
        .mem_empty (mem_empty), //memory empty 
        .out_bus       (out)        //output
    );

    cs_data_processor #(
        .N_SO(1),
        .BIT_SAMPLES(4)
    )
    cs_data_processor_0
    (
        .clk(read_clk),
        .event_reset(!en),
        .fifo_empty(mem_empty),
        .ack(ack),
        .fifo_data_i(out),
        .sample(sample),
        .data_out(data_out),
        .bus_sel(bus_sel),
        .fifo_req(read_en_0),
        .busy(busy),
        .last_data(last_data),
        .valid(valid)
    );

    cs_event_builder #(
        .N_SO(1),
        .BIT_SAMPLES(4)
    )
    cs_event_builder_0
    (
        .clk(read_clk),
        .bus_sel(bus_sel),
        .sample_n(sample),
        .data(data_out),
        .last_data(last_data),
        .valid(valid),
        .event_free(event_free),
        .event_reset(en),
        .busy_i(0),
        .data_ack_reg(ack),
        .busy(event_build_busy),
        .event_word(event_word),
        .event_offset(event_offset),
        .event_commit_len(event_commit_len),
        .event_write(event_write),
        .event_commit(event_commit)
    );

    // Clock generation
    initial begin
        clk_SO = 0;
        forever #kS clk_SO = ~clk_SO; // 320 MHz clock
    end
    initial begin
        read_clk = 0;
        forever #kR read_clk = ~read_clk; // 160 MHz clock
    end

    // Test stimulus
    initial begin
        $dumpfile ("wave.vcd");
        $dumpvars (0, data_to_fifo_tb);
        #1
        // Initialize Inputs
        en = 0;
        SO0 = 0;

        #10;
        en = 1;
        #10;
        for (j=0 ; j<2 ; j=j+1) begin
            for (i=0 ; i<4 ; i=i+1) begin
            #kW; SO0 = sync_zero;
            #kW; SO0 = sync_one;
            end
            for (i=0 ; i<2 ; i=i+1) begin
                #kW; SO0 = sync_zero;
                #kW; SO0 = sync_zero;
                #kW; SO0 = sync_one;
                #kW; SO0 = sync_one;
            end
        end

        // Signals on the bus
        for (z=0 ; z<20 ; z=z+1) begin
            trg = 1;
            for (y=0 ; y<5 ; y=y+1) begin
                for (i=0 ; i<32 ; i=i+1) begin
                    #kW; SO0 = delta_SO*i;
                    trg = 0;
                end
                for (i=0 ; i<32 ; i=i+1) begin
                    #kW; SO0 = 310 - delta_SO*i;
                end
            end
            if (z == 4) begin
                event_free = 1;
            end
        end
        $finish;
    end
endmodule
