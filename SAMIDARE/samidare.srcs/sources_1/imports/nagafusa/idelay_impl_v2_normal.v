// idelay_impl_v2_norm.v
// This module implements the NORMAL delay adjustment functionality for one bit,
// to be used after the special adjustment is complete. The module uses the IDELAYE3
// primitive in VAR_LOAD mode. The expected initialize pattern is set as a parameter.
// When all 512 taps have been evaluated, if max_cnt is at least 1 then the final idelay is set to the tap value farthest
// from edge_idelay, otherwise tap=256. The input special_state (from the special module)
// must be 'DONE' (4'b1000) before the normal state machine starts.
// The trigger signal (trg) is provided externally (by idelay_controller) as an input.
module idelay_impl_v2_normal #(
    parameter IODELAY_GROUP_NAME = "default_name",
    parameter IODELAY_GROUP_ID = 2'b00,
    parameter EXPECTED_PATTERN = 31'b1010_1010_1100_1100_1010_1010_1100_110, // 1010_1100_1100_1010, 
    parameter DEFAULT_DELAY = 5,        // Default initial delay tap value
    parameter integer kNumTaps = 512,     // Number of delay taps (512 for UltraScale)
    parameter integer kStepCount = 100    // Steps per idelay value
)
//(
//    input  wire clk,           // Clock
//    input  wire reset,         // Active-high reset
//    input  wire init,          // External init pulse (may be used by IDELAYE3 load)
//    input  wire init_pol,      // Inversion control for output
//    input  wire data_in_p,     // Differential input (post IBUF)
//    input  wire data_in_n,     // Differential input (post IBUF)
//    // Normal mode related inputs:
//    input  wire trg,         // Trigger signal from idelay_controller (external); used as input here.
//    input  wire clk_edge,    // Signal from special module indicating edge detection timing
//    input  wire init_pattern,// If 1 then expected delay is 5 cycles, else 4 cycles
//    input  wire [3:0] special_state, // State from special module; NORMAL machine starts when special_state == 4'b1000
//    (*mark_debug="true"*)input  wire all_zero, //all normal elink is 0
//    output wire data_out,    // Delayed output
//    (*mark_debug="true"*)output reg [3:0] state  // Overall state output (reflects NORMAL state in this module)
//);
(
    input         clk,         // 
    input         reset,       // async reset
    input         start,       // 
    input         clock_edge,  // 
    input         pol,         // 
    input         all_zero,
    input         raw_signal_p,// 
    input         raw_signal_n,// 
    output reg    done,        // 
    output        delayed_signal, // 
    output reg [8:0] delay_val // 
);
  // IDELAYE3 instantiation
  // For UPDATE_MODE = "SYNC", the LOAD pin is tied to GND.
  // Instantiate the IDELAYE3 primitive in VARIABLE mode.
  reg ld;
  reg inc_ce;
  reg delay_inc;
//  assign ld = 1'b0;  // Use init pulse to load delay tap value
  wire cascade_wire_a;// master -> middle
  wire cascade_wire_b;// middle -> end
  wire cascade_wire_c;// end -> middle
  wire cascade_wire_d;// middle -> master
  
  wire [8:0] check_delay_master;
  wire [8:0] check_delay_slave_middle;
  wire [8:0] check_delay_slave_end;
  
  
//  assign current_idelay_master = (current_idelay[9]==1'b0) ? current_idelay[8:0]:
//                                 'b1;
//  assign current_idelay_slave  = (current_idelay[9]==1'b0) ? 'b0:
//                                 current_idelay[8:0];
//  assign check_delay[9]   = &check_delay_master;
//  assign check_delay[8:0] = (&check_delay_master) ? check_delay_slave:
//                            check_delay_master;
//    assign check_delay =   
  wire buf_data;
  reg buf_data_r;
  reg buf_data_rr;
  reg data_out_r;
  
  
    // tap index
  (*mark_debug = "true"*)reg [8:0] current_tap;
  // cycle count for raw_signal 1 from clock_edge
  (*mark_debug = "true"*)reg [7:0] delay_cycle_cnt;
  (*mark_debug = "true"*)reg [PATTERN_WIDTH-1:0] pattern_reg;
  (*mark_debug = "true"*)reg [4:0] pattern_count;
  (*mark_debug = "true"*)reg [7:0] tap_delay [0:TAPS-1]; 
  (*mark_debug = "true"*)reg       tap_good  [0:TAPS-1];
  (*mark_debug = "true"*)reg [8:0] final_tap;

localparam IODELAY_GROUP_NAME_VAL = (IODELAY_GROUP_ID==2'b00)?"SO0":
                                     (IODELAY_GROUP_ID==2'b01)?"SO1_2":
                                     "SO3";
//  (* IODELAY_GROUP = IODELAY_GROUP_NAME, SIM_DEVICE = "ULTRASCALE_PLUS" *)
  (* IODELAY_GROUP = IODELAY_GROUP_NAME_VAL, SIM_DEVICE = "ULTRASCALE_PLUS" *)
  IBUFDS u_ibufds(
    .O(buf_data),
    .I(raw_signal_p),
    .IB(raw_signal_n)
  );
  
//  wire raw_data_out;
  assign data_out = (pol)? ~raw_data_out:raw_data_out;
//  assign data_out = raw_data_out;
//  assign buf_data_i = (pol) ? ~buf_data:buf_data;
//  /*
    IDELAYE3 #(
    .CASCADE("MASTER"),
//    .CASCADE("NONE"),
    .DELAY_FORMAT("COUNT"),
    .DELAY_SRC("IDATAIN"),//IDATAIN is used to connect input pins
    .DELAY_TYPE("VAR_LOAD"),
    .DELAY_VALUE(DEFAULT_DELAY),
    .IS_CLK_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .REFCLK_FREQUENCY(300.0),
    .SIM_DEVICE("ULTRASCALE_PLUS"),
    .UPDATE_MODE("MANUAL")
  ) idelay_master (
    .CASC_IN(1'b0),
    .CASC_OUT(cascade_wire_a),          
//    .CASC_OUT(),          
    .CASC_RETURN(cascade_wire_d),
//    .CASC_RETURN(1'b0),
    .CE(inc_ce),
//    .CE(1'b0),
    .CLK(clk),
    .CNTVALUEIN(current_tap),
    .CNTVALUEOUT(check_delay_master),       // Optionally monitor current tap value
    .DATAIN(1'b0),        // Unused if using IDATAIN
    .IDATAIN(buf_data),
    .DATAOUT(raw_data_out),
    .EN_VTC(1'b0),
    .INC(1'b0),
    .LOAD(ld),
    .RST(reset)
  );
  ODELAYE3 #(
    .CASCADE("SLAVE_END"),
    .DELAY_FORMAT("COUNT"),
    .DELAY_TYPE("VAR_LOAD"),
    .DELAY_VALUE(DEFAULT_DELAY),
    .IS_CLK_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .REFCLK_FREQUENCY(300.0),
    .SIM_DEVICE("ULTRASCALE_PLUS"),
    .UPDATE_MODE("MANUAL")
  ) odelay_slave_middle (
    .CASC_IN(cascade_wire_a),
    .CASC_OUT(),          
    .CASC_RETURN(),
    .CE(inc_ce),
//    .CE(1'b0),
    .CLK(clk),
    .CNTVALUEIN(current_tap),
    .CNTVALUEOUT(check_delay_slave_middle),       // Optionally monitor current tap value
    .ODATAIN(),       // Unused in slave
    .DATAOUT(cascade_wire_d),
    .EN_VTC(1'b0),
//    .INC(delay_inc),
    .INC(1'b0),
    .LOAD(ld),
    .RST(reset)
  );
//  */
  /*
//  assign raw_data_out = buf_data;
  IDELAYE3 #(
    .CASCADE("MASTER"),
//    .CASCADE("NONE"),
    .DELAY_FORMAT("COUNT"),
    .DELAY_SRC("IDATAIN"),//IDATAIN is used to connect input pins
    .DELAY_TYPE("VAR_LOAD"),
    .DELAY_VALUE(DEFAULT_DELAY),
    .IS_CLK_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .REFCLK_FREQUENCY(300.0),
    .SIM_DEVICE("ULTRASCALE_PLUS"),
    .UPDATE_MODE("MANUAL")
  ) idelay_master (
    .CASC_IN(1'b0),
    .CASC_OUT(cascade_wire_a),    
    .CASC_RETURN(cascade_wire_d),
    .CE(inc_ce),
//    .CE(1'b0),
    .CLK(clk),
    .CNTVALUEIN(current_idelay),
    .CNTVALUEOUT(check_delay_master),       // Optionally monitor current tap value
    .DATAIN(1'b0),        // Unused if using IDATAIN
    .IDATAIN(buf_data),
    .DATAOUT(raw_data_out),
    .EN_VTC(1'b0),
    .INC(1'b0),
    .LOAD(ld),
    .RST(reset)
  );
  ODELAYE3 #(
    .CASCADE("SLAVE_MIDDLE"),
    .DELAY_FORMAT("COUNT"),
    .DELAY_TYPE("VAR_LOAD"),
    .DELAY_VALUE(DEFAULT_DELAY),
    .IS_CLK_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .REFCLK_FREQUENCY(300.0),
    .SIM_DEVICE("ULTRASCALE_PLUS"),
    .UPDATE_MODE("MANUAL")
  ) odelay_slave_middle (
    .CASC_IN(cascade_wire_a),
    .CASC_OUT(cascade_wire_b),          
    .CASC_RETURN(cascade_wire_c),
    .CE(inc_ce),
//    .CE(1'b0),
    .CLK(clk),
    .CNTVALUEIN(current_idelay),
    .CNTVALUEOUT(check_delay_slave_middle),       // Optionally monitor current tap value
    .ODATAIN(),       // Unused in slave
    .DATAOUT(cascade_wire_d),
    .EN_VTC(1'b0),
//    .INC(delay_inc),
    .INC(1'b0),
    .LOAD(ld),
    .RST(reset)
  );
  IDELAYE3 #(
    .CASCADE("SLAVE_END"),
    .DELAY_FORMAT("COUNT"),
    .DELAY_SRC("IDATAIN"),
    .DELAY_TYPE("VAR_LOAD"),
    .DELAY_VALUE(DEFAULT_DELAY),
    .IS_CLK_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .REFCLK_FREQUENCY(300.0),
    .SIM_DEVICE("ULTRASCALE_PLUS"),
    .UPDATE_MODE("MANUAL")
  ) idelay_slave (
    .CASC_IN(cascade_wire_b),
    .CASC_OUT(),          
    .CASC_RETURN(1'b0),
    .CE(inc_ce),
//    .CE(1'b0),
    .CLK(clk),
    .CNTVALUEIN(current_idelay),
//    .CNTVALUEIN(),
    .CNTVALUEOUT(check_delay_slave_end),       // Optionally monitor current tap value
//    .CNTVALUEOUT(),       // Optionally monitor current tap value
    .DATAIN(1'b0),        // Unused if using IDATAIN
    .IDATAIN(1'b0),       // Unused in slave
    .DATAOUT(cascade_wire_c),
    .EN_VTC(1'b0),
//    .INC(delay_inc),
    .INC(1'b0),
//    .LOAD(1'b0),
    .LOAD(ld),
    .RST(reset)
  );
  */
  
  parameter TAPS = 512;             // tap: 512
  parameter PATTERN_WIDTH = 31;       // pattern length
  // ----------------------
  // state machine
  localparam IDLE          = 8'b00000001;
  localparam WAIT_EDGE     = 8'b00000010;
  localparam START_MEASURE = 8'b00000100;
  localparam VERIFY        = 8'b00001000;
  localparam NEXT_TAP      = 8'b00010000;
  localparam SET_TAP       = 8'b00100000;
  localparam FINISH        = 8'b01000000;
  (*mark_debug = "true"*)reg [7:0] state;
  
  reg[15:0] time_out;
  assign delayed_signal = (final_tap[8])?data_out:data_out_r;
              integer i;
              reg[9:0] good_count;
              reg[9:0] good_count_r;
              reg [8:0] max_tap;
  always @(posedge clk or posedge reset) begin
      if (reset) begin
          state <= IDLE;
          delay_cycle_cnt <= 0;
          pattern_reg <= 0;
          pattern_count <= 0;
          current_tap <= 0;
          final_tap <= 0;
          time_out <= 'b0;
      end else begin
         data_out_r <= data_out;
         good_count_r <= good_count;
         case (state)
           IDLE: begin
              final_tap <= 0;
              delay_cycle_cnt <= 0;
              pattern_reg <= 0;
              pattern_count <= 0;
              done <= 0;
              good_count <= 0;
              max_tap <= 0;
              if(start==1'b1)begin
                state <= WAIT_EDGE;
                time_out <= 'b0;
              end
           end
           WAIT_EDGE: begin
              if(clock_edge && all_zero)begin
                state <= START_MEASURE;
                delay_cycle_cnt <= 1;
              end else if(time_out[11]) begin
                  state <= SET_TAP;
                  tap_delay[current_tap] <= delay_cycle_cnt;
                  current_tap <= current_tap + 1;
                  // counter reset
                  delay_cycle_cnt <= 0;
                  pattern_count <= 0;
              end else begin
                time_out <= time_out + 1;
              end
           end
           START_MEASURE: begin
              if(delay_cycle_cnt >= PATTERN_WIDTH-10) begin
                state <= WAIT_EDGE;
              end else
              if(data_out == 1'b1) begin
                state <= VERIFY;
                pattern_reg <= 1;
              end 
              delay_cycle_cnt <= delay_cycle_cnt + 1;
              pattern_count <= 1;
           end
           VERIFY: begin
              if(pattern_count == PATTERN_WIDTH-1) begin
                state <= NEXT_TAP;
              end
              pattern_reg <= {pattern_reg[PATTERN_WIDTH-2:0], data_out};
              pattern_count <= pattern_count + 1;
           end
           NEXT_TAP: begin
              
              if (pattern_reg == EXPECTED_PATTERN)
                begin
                 tap_good[current_tap] <= 1;
                 good_count <= good_count+1;
                end else begin
                 tap_good[current_tap] <= 0;
                end
              state <= SET_TAP;
              tap_delay[current_tap] <= delay_cycle_cnt;
              current_tap <= current_tap + 1;
              // counter reset
              delay_cycle_cnt <= 0;
              pattern_count <= 0;
           end
           SET_TAP: begin
              pattern_reg <= 0;
              if(current_tap == check_delay_master && current_tap == TAPS-1) begin
                state <= FINISH;
                ld <= 1'b0;
              end else 
              if(current_tap == check_delay_master) begin
                state <= WAIT_EDGE;
                time_out <= 'b0;
                ld <= 1'b0;
              end else begin
                ld <= 1'b1;
              end
           end
           FINISH: begin
              
              if (good_count_r == TAPS)
                 final_tap <= TAPS/2;
              else if (good_count_r > TAPS/2)
                 final_tap <= 0;
              else if (good_count_r <= TAPS/2)
                 final_tap <= TAPS;
              
              if(current_tap != check_delay_master) begin
                  ld <= 1'b1;
                end else begin
                  ld <= 1'b1;
                end
                 
              delay_val <= final_tap;
              current_tap <= final_tap;
              done <= 1;
           end
           default: 
             state <= IDLE;
           
         endcase
      end
  end
  


  // (Optional) Additional logic to drive the physical IDELAYE3 based on current_idelay can be added here.
endmodule
