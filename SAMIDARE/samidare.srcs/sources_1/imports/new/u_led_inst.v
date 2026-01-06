`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/11 10:09:08
// Design Name: 
// Module Name: u_led_inst
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


module u_led_inst(
    input clk125MHz,
    input reset,
    input enable,
    
    input fnet_txn,
    input power_on,
    input ext_clk_lkd,
    
    input [31:0] LED_REG0,
    input [31:0] LED_REG1,
    input [31:0] LED_REG2,
    input [31:0] LED_REG3,
    
    input [3:0] DIPSW,
    output INIT_AXI_TXN,
    output INIT_AXI_TXN_SUB,
    input LED_TXN_DONE,
    
    
    output [3:0] LED
    
    );
    wire CLK;
    assign CLK = clk125MHz;
    wire RST;
    assign RST = reset;
    
    reg [31:0]counter;
    reg [31:0] course_counter;
    reg [31:0] r0;
    reg [31:0] r1;
    reg [31:0] r2;
    reg [31:0] r3;
    
    reg [3:0]txn_acc;
    reg [3:0]fnet_txn_acc;
    reg [3:0]led;
    
    reg axi_txn;
    reg axi_txn_sub;
    always@(posedge CLK or posedge RST)begin
        if(RST) begin
            led[0]<=1'b0;
            led[1]<=1'b0;
            led[2]<=1'b0;
            led[3]<=1'b0;
            
            r0 <= 'b0;
            r1 <= 'b0;
            r2 <= 'b0;
            r3 <= 'b0;
        end else begin
            if(!enable) begin
                led[0]<=1'b0;
                led[1]<=1'b0;
                led[2]<=1'b0;
                led[3]<=1'b0;
            end else begin
                counter <= counter+1;
                if(counter[24:0]=='b0) begin
                    course_counter <= course_counter+1;
                end
            end
            
            if(counter[27:0]=='b0)begin
                axi_txn <= 1'b1;
            end else begin
                axi_txn <= 1'b0;
            end
            
            if(counter[27]==1'b1&&counter[26:0]=='b0)begin
                axi_txn_sub <= 1'b1;
            end else begin
                axi_txn_sub <= 1'b0;
            end
            
            if(counter[27:0]=='b0)begin
                r0 <= LED_REG0;
                r1 <= LED_REG1;
                r2 <= LED_REG2;
                r3 <= LED_REG3;
            end else if(counter[22:0] == 'b0) begin
                r0 <= {1'b0 , r0[31:1]};
                r1 <= {1'b0 , r1[31:1]};
                r2 <= {1'b0 , r2[31:1]};
                r3 <= {1'b0 , r3[31:1]};
            end
            
//            if(LED_TXN_DONE==1'b1)begin
            if(axi_txn==1'b1)begin
                txn_acc <= 4;
            end else if(txn_acc > 0 && counter[23:0] == 'b0) begin
                txn_acc <= txn_acc-1;
            end
            
            if(fnet_txn==1'b1)begin
                fnet_txn_acc <= 4;
            end else if(fnet_txn_acc > 0 && counter[23:0] == 'b0) begin
                fnet_txn_acc <= fnet_txn_acc-1;
            end
        end
        
    end
    
//    assign LED[0] = r0[0];
//    assign LED[1] = r1[0];
    assign LED[0] = txn_acc[0];
    assign LED[1] = power_on;    
//    assign LED[1] = fnet_txn_acc[0];    
//    assign LED[2] = r2[0];
    assign LED[2] = DIPSW[0];
    assign LED[3] = ext_clk_lkd;
    assign INIT_AXI_TXN = axi_txn;
    assign INIT_AXI_TXN_SUB = axi_txn_sub;
//    genvar i;
//    for(i=0;i<4;i=i+1)begin
//        assign LED[i] = led[i];
//    end
    
endmodule
