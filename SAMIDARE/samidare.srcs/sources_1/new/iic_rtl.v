`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/06/2024 08:51:29 PM
// Design Name: 
// Module Name: iic_rtl
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


module iic_rtl(
    inout wire SCL,
    output wire scl_i,
    input wire scl_o,
    input wire scl_t,
    inout wire SDA,
    output wire sda_i,
    input wire sda_o,
    input wire sda_t
    );
    
    
//    assign SCL = scl_t ? scl_o : 1'bz;
//    assign scl_i = SCL;
//    assign SDA = sda_t ? sda_o : 1'bz;
//    assign sda_i = SDA;

    IOBUF IIC_0_scl_iobuf
        (.IO(SCL),
         .I(scl_o),
         .O(scl_i),
         .T(scl_t)
        );
    IOBUF IIC_0_sda_iobuf
        (.IO(SDA),
         .I(sda_o),
         .O(sda_i),
         .T(sda_t)
        );

endmodule
