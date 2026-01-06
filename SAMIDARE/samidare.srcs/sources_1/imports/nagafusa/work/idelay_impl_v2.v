// idelay_impl_v2.v
// This module adjusts the delay for one bit (after IBUF conversion) using the IDELAYE2
// primitive in VARIABLE mode. It contains two state machines:
//   1. The delay-adjustment state machine (u_idelay_sm)
//   2. The bit-slip state machine (u_bitslip_sm, with an idle-check process u_check_idle)
// The final state is output as a 4-bit one-hot value.
// The SPECIAL parameter allows insertion of extra processing for a special bit (e.g. bit index 10).
module idelay_impl_v2 #(
    parameter IODELAY_GROUP_NAME = "default_group",
    parameter DEFAULT_DELAY = 0,        // Default initial delay tap value
    // Parameters for the IDelay state machine
    parameter integer kNumTaps         = 512,
    parameter integer kSuccThreshold   = 8,
    parameter integer kMaxIdelayCheck  = 100,
    parameter integer kPlateauThreshold = 5,
    parameter integer kWidthCheckCount = 8,
    // Parameters for the bit-slip state machine
    parameter integer kWidthDev        = 10,
    parameter integer kMaxPattCheck    = 100,
    parameter integer kPattOkThreshold = 4,
    // Parameter for the idle pattern (for bit-slip check)
    parameter kIdlePattern             = 1'b1
)(
    input  wire clk,           // Clock (assumed to be the same as clkPar in the original code)
    input  wire reset,         // Reset (active high)
    input  wire init,          // External init pulse (from the controller)
    input  wire pol,
    input  wire data_in_p,     // diff-ended input (post IBUF)
    input  wire data_in_n,     // diff-ended input (post IBUF)
    output wire data_out,      // Delayed output
    output wire adjust_done
);
  // ------------------------------
  reg en_idelay_check;
  reg inc_ce, delay_inc;
  reg idelay_is_adjusted;
  reg [2:0] state_idelay;
  reg [kWidthCheckCount-1:0] idelay_check_count;
  reg [31:0] elapsed_time_idelay;
  reg [31:0] num_idelay_appropriate;
  reg [4:0] num_cont_appropriate;
  reg [5:0] num_idelay_check;
  reg [5:0] decrement_count;
  reg [5:0] sig_idelay_check;
  // ------------------------------
  // Internal signals for the Bit-slip state machine
  // (Omitted or bypassed if SPECIAL==1)
  // ------------------------------
  reg en_idle_check;
  reg [kWidthCheckCount-4:0] idle_patt_count; // For example, if kWidthCheckCount = 8, width = 4
  reg en_bitslip;
  reg bit_aligned;
  reg bitslip_failure;
  reg [2:0] state_bitslip;
  reg [31:0] elapsed_time_bitslip;
  reg [31:0] num_patt_check;
  // For simplicity, we assume reset_sm is just 'reset'
  wire reset_sm = reset;
  // Internal signal from IDELAYE3
  wire raw_data_out;
  // Instantiate the IDELAYE3 primitive in VARIABLE mode.
  reg ld;
//  assign ld = 1'b0;  // Use init pulse to load delay tap value
  wire cascade_wire_a;// master -> middle
  wire cascade_wire_b;// middle -> end
  wire cascade_wire_c;// end -> middle
  wire cascade_wire_d;// middle -> master
  
  (*mark_debug = "true"*)reg [8:0] current_idelay;
  (*mark_debug = "true"*)wire [8:0] check_delay;;
  wire [8:0] current_idelay_master;
  wire [8:0] current_idelay_slave_middle;
  wire [8:0] current_idelay_slave_end;
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
  
  // Instantiate the IBUFDS
  (*DONT_TOUCH="TRUE"*) wire buf_data;
  (* IODELAY_GROUP = IODELAY_GROUP_NAME, SIM_DEVICE = "ULTRASCALE_PLUS" *)
  IBUFDS #(
    .IOSTANDARD("SLVS_400_18")
  ) u_ibufds(
    .O(buf_data),
    .I(data_in_p),
    .IB(data_in_n)
  );
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
//    .CASC_OUT(),          
    .CASC_OUT(cascade_wire_a),          
//    .CASC_RETURN(1'b0),
    .CASC_RETURN(cascade_wire_d),
    .CE(inc_ce),
//    .CE(1'b0),
    .CLK(clk),
    .CNTVALUEIN(current_idelay),
    .CNTVALUEOUT(check_delay_master),       // Optionally monitor current tap value
    .DATAIN(buf_data),        // Unused if using IDATAIN
    .IDATAIN(1'b0),
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
    .DELAY_SRC("DATAIN"),
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
  
  //signal to see: 
  //current_idelay_master. current_idelay_slave, ld, 
  
//  IDELAYE3 #(//impl for not cascade mode
//    .CASCADE("NONE"),
//    .DELAY_FORMAT("COUNT"),
//    .DELAY_SRC("IDATAIN"),
//    .DELAY_TYPE("VAR_LOAD"),
//    .DELAY_VALUE(DEFAULT_DELAY),
//    .IS_CLK_INVERTED(1'b0),
//    .IS_RST_INVERTED(1'b0),
//    .REFCLK_FREQUENCY(200.0),
//    .SIM_DEVICE("ULTRASCALE_PLUS"),
//    .UPDATE_MODE("MANUAL")
//  ) idelay_slave (
//    .CASC_IN(1'b0),
//    .CASC_OUT(),          // Not used if not cascading
//    .CASC_RETURN(1'b0),
////    .CE(inc_ce),
//    .CE(1'b0),
//    .CLK(clk),
//    .CNTVALUEIN(current_idelay),
//    .CNTVALUEOUT(check_delay),       // Optionally monitor current tap value
//    .DATAIN(1'b0),        // Unused if using IDATAIN
//    .IDATAIN(buf_data),
//    .DATAOUT(raw_data_out),
//    .EN_VTC(1'b0),
////    .INC(delay_inc),
//    .INC(1'b0),
//    .LOAD(ld),
//    .RST(reset)
//  );
  // The output is optionally inverted by pol.
  assign data_out = (pol) ? ~raw_data_out : raw_data_out;
  // ====================================================
  // Special state machine for special adjustment (when SPECIAL==1)
  // ====================================================
  // State encoding for special adjustment:
  localparam IDLE        = 4'b0001;
  localparam DETECT_EDGE = 4'b0010;
  localparam CHECK_EDGE  = 4'b0100;
  localparam DONE        = 4'b1000;
  
  assign adjust_done = (state==DONE)? 1'b1: 1'b0;
  // Registers for special state machine
  (*mark_debug="true", keep = "true"*)reg [3:0] state;
  (*mark_debug = "true"*)reg [7:0] cycle_counter;
  (*mark_debug = "true"*)reg [7:0] trial_counter;
  reg [7:0] error_count;
  (*mark_debug = "true"*)reg [4:0] edge_idelay;     // idelay value at first rising edge
  (*mark_debug="true"*)reg [4:0] max_cnt;         // maximum error count observed
  reg prev_data;             // Previous value of data_out
  // Debug: store the trial_counter value for each idelay value.
  (*mark_debug="true"*)reg [9:0] trial_counter_history [1023:0];
 
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state   <= IDLE;
      cycle_counter   <= 0;
      trial_counter   <= 0;
      error_count     <= 0;
      max_cnt         <= 0;
      edge_idelay     <= 0;
      current_idelay  <= DEFAULT_DELAY;  // initial delay value
      prev_data       <= 0;
      state           <= IDLE;  // output state
    end else begin
      prev_data <= data_out;  // Use data_out for edge detection
      case (state)
        IDLE: begin
          state <= IDLE;
          if (init) begin
            state <= DETECT_EDGE;
            cycle_counter <= 0;
            max_cnt       <= 0;
            state         <= DETECT_EDGE;
          end
        end
        DETECT_EDGE: begin
          cycle_counter <= cycle_counter + 1;
          // Detect the first rising edge (transition from 0 to 1) using data_out.
          if ((prev_data == 1'b0) && (data_out == 1'b1)) 
              begin
//                edge_idelay <= current_idelay;
                cycle_counter <= 0;
                trial_counter <= 0;
                error_count   <= 0;
                state         <= CHECK_EDGE;
              end
        end
        CHECK_EDGE: begin
          cycle_counter <= cycle_counter + 1;
          if (cycle_counter == 31) begin
            // In a 2-cycle window, check if the pattern is 0->1.
            if (!((prev_data == 1'b0) && (data_out == 1'b1))) begin
              error_count <= error_count + 1;
            end
            trial_counter <= trial_counter + 1;
            cycle_counter <= 0;
            if (trial_counter == 100) begin
              // Save trial_counter for debugging.
              trial_counter_history[current_idelay] <= error_count;
              if (error_count > max_cnt) begin
                max_cnt     <= error_count;
//                edge_idelay <= current_idelay;
              end
              // The inc_ce and delay_inc pulses are generated in a separate always block.
              // Increment the delay value for next evaluation.
              current_idelay <= current_idelay + 1;
              trial_counter  <= 0;
              error_count    <= 0;
                            // Terminate checking if maximum idelay is reached.
              if (current_idelay >= (kNumTaps - 1)) begin
                state         <= DONE;
              end else begin        
                state <= CHECK_EDGE;
              end 
            end
          end
        end
        DONE: begin
          // If max_cnt is 0, set current_idelay to kNumTaps/2;
          // otherwise, set idelay to the value farthest from edge_idelay.
          if (max_cnt == 0)
            current_idelay <= kNumTaps;
          else if (edge_idelay < (kNumTaps))
            current_idelay <= kNumTaps - 1;
          else
            current_idelay <= 0;
          // Remain in DONE state.
          state <= DONE;
        end
        default: state <= IDLE;
      endcase
    end
  end
  // -------------------------------------------------------------------
  // Generate control pulses for IDELAYE3 based on special state machine.
  // When trial_counter reaches 100, generate a one-cycle pulse (inc_ce and delay_inc high)
  // to increment the delay value by one.
  // -------------------------------------------------------------------
//  always @(posedge clk or posedge reset) begin
//    if (reset) begin
//      inc_ce <= 1'b0;
//      delay_inc <= 1'b0;
//    end else begin
//      if (SPECIAL) begin
//        if (trial_counter == 100 && cycle_counter == 31) begin
//          inc_ce <= 1'b1;
//          delay_inc <= 1'b1; // '1' indicates increment.
//        end else begin
//          inc_ce <= 1'b0;
//          delay_inc <= 1'b0;
//        end
//      end else begin
//        // In non-special mode, control signals may be driven by another state machine.
//        inc_ce <= 1'b0;
//        delay_inc <= 1'b0;
//      end
//    end
//  end
//  reg [8:0] internal_delay; // Simulated current delay tap value.
  always @(posedge clk or posedge reset) begin
    if (reset) begin
//      internal_delay <= DEFAULT_DELAY;
      inc_ce <= 1'b0;
      delay_inc <= 1'b0;
      ld <= 1'b0;
    end else begin 
//      if (trial_counter == 100 && cycle_counter == 31) begin
//        internal_delay <= 9'b0;
//      end else 
      if ((check_delay_master != current_idelay)||(check_delay_slave_middle != current_idelay)||(check_delay_slave_end != current_idelay)) begin
        inc_ce <= 1'b1;
//        delay_inc <= 1'b1;
        ld <= 1'b1;
//        internal_delay <= internal_delay + 1;
      end else begin
        inc_ce <= 1'b0;
//        delay_inc <= 1'b0;
        ld <= 1'b0;
      end
    end
  end
endmodule