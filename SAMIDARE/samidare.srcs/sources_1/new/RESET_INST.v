`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/04/2024 01:10:40 PM
// Design Name: 
// Module Name: RESET_INST
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


module RESET_INST(
    input clk125,
    input reset_vio,
    input resetdone,
    //input sfpFds,
    output sfp_reset_pulse
    );
    
    wire            sfpFds;
    wire    [3:0]   sfpFd;
    reg             reset_pulse;

    FDS SFP_FDS(.Q(sfpFds),   .C(clk125MHz), .D(1'b0), .S(1'b0));
    FD  SFP_FD0(.Q(sfpFd[0]), .C(clk125MHz), .D(sfpFds));
    FD  SFP_FD1(.Q(sfpFd[1]), .C(clk125MHz), .D(sfpFd[0]));
    FD  SFP_FD2(.Q(sfpFd[2]), .C(clk125MHz), .D(sfpFd[1]));
    FD  SFP_FD3(.Q(sfpFd[3]), .C(clk125MHz), .D(sfpFd[2]));

    always@(posedge clk125) begin
        reset_pulse <= (|sfpFd[3:0]);
    end
    assign o_reset_pulse = reset_pulse;

    reg             sfp_reset_enable;
    reg     [4:0]   shift_sfp_reset_enable;
    reg             resetdone_pos;

    always@(posedge clk125MHz) begin
        if (reset_pulse | reset_vio) begin
            sfp_reset_enable <= 1'b0;
        end else if (resetdone_pos) begin
            sfp_reset_enable <= 1'b1;
        end
    end

    (* ASYNC_REG = "TRUE" *) reg  async_dly_resetdone0, async_dly_resetdone1;
    reg       dly_resetdone;
    wire       resetdone_i;
    reg       sfp_reset_pulse_r;
    
    assign resetdone_i = resetdone;

    always@(posedge clk125MHz) begin
        shift_sfp_reset_enable[4:0] <= {shift_sfp_reset_enable[3:0],sfp_reset_enable};
        sfp_reset_pulse_r             <= (~shift_sfp_reset_enable[4]) & shift_sfp_reset_enable[0];
        async_dly_resetdone0        <= resetdone_i;
        async_dly_resetdone1        <= async_dly_resetdone0;
        dly_resetdone               <= async_dly_resetdone1;
        resetdone_pos               <= (~dly_resetdone) & async_dly_resetdone1;
    end

    assign sfp_reset_pulse = sfp_reset_pulse_r;
endmodule
