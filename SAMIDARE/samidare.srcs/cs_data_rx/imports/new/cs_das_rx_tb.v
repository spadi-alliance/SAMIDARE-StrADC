`timescale 1ns / 1ps

module cs_das_rx_tb;

    // Inputs
    reg clk_SO;
    reg en;
    reg [9:0] SO0;
    reg [9:0] SO1;
    reg [9:0] SO2;
    reg [9:0] SO3;
    reg [3:0] full;
    reg trg;

    // Outputs
    wire wr_en0;
    wire wr_en1;
    wire wr_en2;
    wire wr_en3;
    wire [323:0] bus0;
    wire [323:0] bus1;
    wire [323:0] bus2;
    wire [323:0] bus3;
    wire [3:0] sync_error;

    // Instantiate the Unit Under Test (UUT)
    cs_das_rx
    #(
        .N_SO(4)
    ) uut
    (
        .clk_SO(clk_SO),
        .en(en),
        .SOs({SO3, SO2, SO1, SO0}),
        .fifo_full(full),
        .wr_ens({wr_en3, wr_en2, wr_en1, wr_en0}),
        .buses({bus3, bus2, bus1, bus0}),
        .sync_errors(sync_error),
        .reset_fifos({reset_fifo_3, reset_fifo_2, reset_fifo_1, reset_fifo_0}),
        .n_samples(4'b0011),
        .trg(trg)
    );

    localparam sync_pattern = 32'b01010101001100110101010100110011;
    localparam sync_zero = 10'h2B5;
    localparam sync_one = 10'h14A;
    localparam delta_SO = 10;
    integer i;
    integer j;
    integer z;
    integer y;
    
    // Clock generation
    initial begin
        clk_SO = 0;
        forever #1 clk_SO = ~clk_SO; // 320 MHz clock
    end

    // Test stimulus
    initial begin
        $dumpfile ("wave.vcd");
        $dumpvars (0, cs_das_rx_tb);
        #1
        
        // Initialize Inputs
        en = 0;
        SO0 = 0;
        SO1 = 0;
        SO2 = 0;
        SO3 = 0;
        full = 0;

        #100;
        en = 1;
        #100;
        for (j=0 ; j<2 ; j=j+1) begin
            for (i=0 ; i<4 ; i=i+1) begin
            #2; SO0 = sync_zero;
            #2; SO0 = sync_one;
            end
            for (i=0 ; i<2 ; i=i+1) begin
                #2; SO0 = sync_zero;
                #2; SO0 = sync_zero;
                #2; SO0 = sync_one;
                #2; SO0 = sync_one;
            end
        end

        // Signals on the bus
        for (z=0 ; z<2 ; z=z+1) begin
            trg = 1;
            for (y=0 ; y<5 ; y=y+1) begin
                for (i=0 ; i<32 ; i=i+1) begin
                    #2; SO0 = delta_SO*i;
                    trg = 0;
                end
                for (i=0 ; i<32 ; i=i+1) begin
                    #2; SO0 = 310 - delta_SO*i;
                end
            end
            
        end
        $finish;
    end
endmodule