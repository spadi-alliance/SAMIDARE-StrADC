`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/26/2025 11:28:16 PM
// Design Name: 
// Module Name: GPIO_rx
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


module GPIO_rx(
    input [6:0] GPION,
    input [6:0] GPIOP,
    (*mark_debug="true"*)output [6:0] GPIO
    );
    wire [6:0] sig_o;
    genvar i;
    generate
        for(i=0;i<7;i=i+1)begin
              if(i==1||i==2||i==3)begin
                  IBUFDS u_ibufds(
                    .O(sig_o[i]),
                    .I(GPION[i]),
                    .IB(GPIOP[i])
                  );
                  assign GPIO[i] = sig_o[i];
              end else begin
                  IBUFDS u_ibufds(
                    .O(sig_o[i]),
                    .I(GPIOP[i]),
                    .IB(GPION[i])
                  );
                  assign GPIO[i] = !sig_o[i];
              
              end
        end
    endgenerate

endmodule
