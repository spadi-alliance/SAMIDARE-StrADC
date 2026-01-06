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
    input wire user_clk,       // 40MHz clk
    (*mark_debug="true"*) input wire [10:0] SO0,      // SO0
    (*mark_debug="true"*) input wire [10:0] SO1,      // SO1
    (*mark_debug="true"*) input wire [10:0] SO2,      // SO2
    (*mark_debug="true"*) input wire [10:0] SO3,      // SO3
    
    
    (*mark_debug="true"*) input wire [3:0] full,
    (*mark_debug="true"*) output wire wr_en0,
    (*mark_debug="true"*) output wire wr_en1,
    (*mark_debug="true"*) output wire wr_en2,
    (*mark_debug="true"*) output wire wr_en3,
    (*mark_debug="true"*) output wire [319:0] bus0,    // 320 bit ouput for SO0
    (*mark_debug="true"*) output wire [319:0] bus1,    // 320 bit ouput for SO1
    (*mark_debug="true"*) output wire [319:0] bus2,    // 320 bit ouput for SO2
    (*mark_debug="true"*) output wire [319:0] bus3     // 320 bit ouput for SO3
);
    // counter
    reg [4:0] count; // 32 ch cycle
    reg [319:0] bus [3:0];
    reg [319:0] bus_r [3:0];
    wire [10:0] SO [3:0];
    assign SO[0] = SO0; 
    assign SO[1] = SO1; 
    assign SO[2] = SO2; 
    assign SO[3] = SO3; 

//    assign clk_10MHz[0] = SO0[10];
    
    reg [3:0] clk_10MHz_r;
    reg [3:0] clk_10MHz_rr;
    
    wire [3:0] wr_en;
    assign wr_en0 = wr_en[0];
    assign wr_en1 = wr_en[1];
    assign wr_en2 = wr_en[2];
    assign wr_en3 = wr_en[3];
    generate
        genvar i;
        for(i=0;i<4;i=i+1) begin
            //assign clk_10MHz[i] = clk_10MHz_rr[i];
            assign wr_en[i] = clk_10MHz_rr[i] && ~full[i];
             // 320MHz shift
            always @(posedge clk_SO) begin        
                clk_10MHz_r[i] <= SO[i][10];
                clk_10MHz_rr[i] <= SO[i][10]&&~clk_10MHz_r[i];
                bus_r[i] <= {bus_r[i][309:0], SO[i][9:0]}; // SO0 10 bit data shift
                
                if(SO[i][10]&&~clk_10MHz_r[i])begin // assign data when posedge of SO[10]
                    bus[i] <= bus_r[i];
                end
            end
       
        end
    endgenerate
    
    assign bus0 = bus[0];
    assign bus1 = bus[1];
    assign bus2 = bus[2];
    assign bus3 = bus[3];
    
    
//    reg clk_10MHz;

    // reset in edge of 10MHz counter
    assign wr_en0 = wr_en[0];
    assign wr_en1 = wr_en[1];
    assign wr_en2 = wr_en[2];
    assign wr_en3 = wr_en[3];
endmodule

