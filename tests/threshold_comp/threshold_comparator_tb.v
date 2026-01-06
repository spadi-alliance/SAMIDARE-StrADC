`timescale 1ns / 1ps

module threshold_comparator_tb;

    parameter N = 4;
    parameter n_bits = 10;
    parameter channels = 32;
    reg clk;
    reg enable;
    reg [N*n_bits-1:0] signals_in;
    reg [9:0] threshold;
    reg [1:0] pretrigger_select;
    wire [N-1:0] triggered;
    wire [N*n_bits-1:0] delayed_signals_out;

    threshold_comparator #(
        .N(N),
        .n_bits(n_bits),
        .channels(channels)
    ) uut (
        .clk(clk),
        .enable(enable),
        .signals(signals_in),
        .threshold(threshold),
        .pretrigger_select(pretrigger_select),
        .triggered(triggered),
        .delayed_signals(delayed_signals_out)
    );

    // Clock generation
    initial clk = 0;
    always #1 clk = ~clk; // 500MHz for fast simulation

    integer i, ch, cyc;

    initial begin

        enable = 0;
        signals_in = 0;
        threshold = 10'd10;
        pretrigger_select = 2'b10; // 8-sample pretrigger

        // Dump waveform to file
        $dumpfile("wave.vcd");
        $dumpvars(0, threshold_comparator_tb);
        #4;

        // Demonstrate pretrigger_delay only changes when enable is off
        $display("Setting pretrigger_select to 2'b01 (4 samples) while enable is off");
        pretrigger_select = 2'b00;
        #4;

        enable = 1;

        // Cycle through all channels for 6*channels cycles (simulate 2 full samples)
        for (i = 0; i < 17; i = i + 1) begin
            for (ch = 0; ch < channels; ch = ch + 1) begin
            signals_in = { 30'b0 + i , {10'b0 + ch }};
            #2;
            $display("T=%0t en=%b pretrig=%b ch=%0d signals=%h triggered=%b delayed=%h",
                     $time, enable, pretrigger_select, ch, signals_in, triggered, delayed_signals_out);
            end
        end

        // Now ramp up chip 0 for channel 0 to test trigger/delay
        for (i = 0; i < 20; i = i + 1) begin
            // Only chip 0 ramps, others are fixed
            signals_in = {30'd0, i[9:0]};
            #2;
        end

        enable = 0;
        $display("Setting pretrigger_select to 2'b00 (0 samples) while enable is off (should update delay)");
        pretrigger_select = 2'b00;
        #10;
        $finish;
    end

endmodule