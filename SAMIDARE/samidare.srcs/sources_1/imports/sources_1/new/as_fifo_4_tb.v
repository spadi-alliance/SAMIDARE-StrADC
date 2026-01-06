`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/04/2025 02:22:04 PM
// Design Name: 
// Module Name: as_fifo_4_tb
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

module asyncfifo #(
                 parameter WIDTH = 328,                // Data width
                 parameter DEPTH = 64                  // FIFO depth
                 )(
                 input wire write_clk,           //input write clock
                 input wire read_clk,            //input read clock 
                 input wire reset,               //input reset
                 input wire write_en,            //input write enable
                 input wire read_en,             //input read enable
                 input wire [WIDTH-1:0] data_in,           //input data
                 output reg mem_full,            //output memory full 
                 output reg mem_empty,           //output memory empty
                 output reg [WIDTH-1:0] out_bus            //output data
                 );

// Internal signals
reg [WIDTH-1:0] mem [0:DEPTH-1];                       // Memory array
reg [$clog2(DEPTH)-1:0] write_ptr;                     // Write pointer
reg [$clog2(DEPTH)-1:0] read_ptr;                      // Read pointer
(*mark_debug="true"*)reg [$clog2(DEPTH+1)-1:0] count;                       // Count

// Condition for mem_full and mem_empty
initial begin
    // Debug monitor everything
   mem_full <= 0;
   mem_empty <= 1;
    //$monitor("time=%0t, write_clk=%b, read_clk=%b, reset=%b, write_en=%b, read_en=%b, data_in=%b, mem_full=%b, mem_empty=%b, out=%b, write_ptr=%b, read_ptr=%b, count=%b, empty_reg=%b, full_reg=%b", $time, write_clk, read_clk, reset, write_en, read_en, data_in[2:0], mem_full, mem_empty, out[2:0], write_ptr, read_ptr, count, empty_reg, full_reg);
end

/* Whenever the reset is 0 then make write pointer 0 otherwise if write enable
 * and memory is not full then write data into memory and increment write
 * pointer */
always @ (posedge write_clk)
   begin
      if(reset)
         begin
            write_ptr <= 0;                            // Reset pointer
            mem_full <= 0;
         end
      else
         begin
            if((write_en == 1) && (write_ptr+1 != read_ptr))
               begin
                  $display("writing to memory");
                  mem[write_ptr] <= data_in;           // Data is written 
                  write_ptr      <= write_ptr + 1'b1;  // Pointer increment
                  out_bus            <= {WIDTH{1'bz}};
                  count <= count + 1'b1;
                  mem_full <= (write_ptr + 2) == read_ptr;
               end
            else
               begin
                  mem_full <= (write_ptr + 1) == read_ptr;
               end
         end
    end

/* Whenever the reset is 0 then make read pointer 0 otherwise if read enable
 * and memory is not empty then read data from memory and increment read
 * pointer */
always @ (posedge read_clk)
   begin
      if(reset)
         begin
            read_ptr <= 0;                             // Reset pointer
            mem_empty <= 1;
         end
      else
         begin
            if((read_en == 1) && (read_ptr != write_ptr))
               begin
                  out_bus    <= mem[read_ptr];             // Data is read 
                  read_ptr <= read_ptr + 1'b1;         // Pointer increment
                  count <= count - 1'b1;
                  mem_empty <= (read_ptr + 1) == write_ptr;
               end
            else
               begin
                  mem_empty <= (read_ptr) == write_ptr;
               end
         end
    end

/* Increment count for write enable 1 and decrement count for read enable 1 */
always @ (posedge write_clk)
   begin
      if(reset)
         count <= 0;
   end
endmodule                                              // End of async FIFO
