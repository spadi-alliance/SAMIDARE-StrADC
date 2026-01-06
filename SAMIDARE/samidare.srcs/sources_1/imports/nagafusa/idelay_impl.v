// idelay_impl.v
// This module adjusts the delay for one bit (after IBUF conversion) using the IDELAYE2
// primitive in VARIABLE mode. It contains two state machines:
//   1. The delay-adjustment state machine (u_idelay_sm)
//   2. The bit-slip state machine (u_bitslip_sm, with an idle-check process u_check_idle)
// The final state is output as a 4-bit one-hot value.
// The SPECIAL parameter allows insertion of extra processing for a special bit (e.g. bit index 10).

module idelay_impl #(
    parameter SPECIAL = 0,              // Set to 1 for special processing (e.g. bit index 10)
    parameter DEFAULT_DELAY = 5,        // Default initial delay tap value
    // Parameters for the IDelay state machine
    parameter integer kNumTaps         = 32,
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
    input  wire init_pol,
    input  wire data_in_p,       // diff-ended input (post IBUF)
    input  wire data_in_n,       // diff-ended input (post IBUF)
    output wire data_out,      // Delayed output
    output reg [3:0] state     // Final state output (one-hot: IDLE, ADJUSTING, DONE, ERROR)
);

  // Final state encoding (one-hot)
  localparam IDLE_FINAL      = 4'b0001;
  localparam ADJUSTING_FINAL = 4'b0010;
  localparam DONE_FINAL      = 4'b0100;
  localparam ERROR_FINAL     = 4'b1000;

  // State encoding for the IDelay state machine
  localparam ST_IDELAY_INIT      = 3'd0;
  localparam ST_IDELAY_WAITPLL   = 3'd1;
  localparam ST_IDELAY_CHECK     = 3'd2;
  localparam ST_IDELAY_NUMTRIAL  = 3'd3;
  localparam ST_IDELAY_INCREMENT = 3'd4;
  localparam ST_IDELAY_DECREMENT = 3'd5;
  localparam ST_IDELAY_ADJUSTED  = 3'd6;

  // State encoding for the Bit-slip state machine
  localparam BS_INIT          = 3'd0;
  localparam BS_WAITSTART     = 3'd1;
  localparam BS_CHECK_IDLE    = 3'd2;
  localparam BS_BITSLIP       = 3'd3;
  localparam BS_FINISHED      = 3'd4;
  localparam BS_FAILURE       = 3'd5;

  // ------------------------------
  // Internal signals for the IDelay state machine
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


  wire raw_data_out;
  // ====================================================
  // u_idelay_sm: IDelay Adjustment State Machine
  // ====================================================
  always @(posedge clk or posedge reset_sm) begin
    if (reset_sm) begin
      elapsed_time_idelay       <= 0;
      num_idelay_appropriate    <= 0;
      num_cont_appropriate      <= 0;
      num_idelay_check          <= 0;
      decrement_count           <= 0;
      en_idelay_check           <= 1'b0;
      inc_ce                    <= 1'b0;
      delay_inc                 <= 1'b1; // Increment direction
      idelay_is_adjusted        <= 1'b0;
      state_idelay              <= ST_IDELAY_INIT;
    end else begin
      case (state_idelay)
        ST_IDELAY_INIT: begin
          state_idelay <= ST_IDELAY_WAITPLL;
        end
        ST_IDELAY_WAITPLL: begin
          // Assume clock is ready; in a real system, clk_is_ready should be monitored.
          en_idelay_check <= 1'b1;
          state_idelay <= ST_IDELAY_CHECK;
        end
        ST_IDELAY_CHECK: begin
          elapsed_time_idelay <= elapsed_time_idelay + 1;
          if (idelay_check_count == kSuccThreshold) begin
            num_idelay_appropriate <= num_idelay_appropriate + 1;
            num_idelay_check <= num_idelay_check + 1;
            num_cont_appropriate <= 0;  // Reset the counter vector
            en_idelay_check <= 1'b0;
            state_idelay <= ST_IDELAY_NUMTRIAL;
          end else if (elapsed_time_idelay == kMaxIdelayCheck - 1) begin
            // Time out: load the appropriate count into num_cont_appropriate
            num_cont_appropriate <= num_idelay_appropriate[4:0]; // using lower 5 bits
            num_idelay_appropriate <= 0;
            num_idelay_check <= num_idelay_check + 1;
            en_idelay_check <= 1'b0;
            state_idelay <= ST_IDELAY_NUMTRIAL;
          end
        end
        ST_IDELAY_NUMTRIAL: begin
          elapsed_time_idelay <= 0;
          if (num_cont_appropriate >= kPlateauThreshold) begin
            inc_ce <= 1'b1;
            delay_inc <= 1'b0;
            decrement_count <= num_cont_appropriate[4:1] + 1;
            state_idelay <= ST_IDELAY_DECREMENT;
          end else begin
            inc_ce <= 1'b1;
            state_idelay <= ST_IDELAY_INCREMENT;
          end
        end
        ST_IDELAY_INCREMENT: begin
          inc_ce <= 1'b0;
          en_idelay_check <= 1'b1;
          state_idelay <= ST_IDELAY_CHECK;
        end
        ST_IDELAY_DECREMENT: begin
          decrement_count <= decrement_count - 1;
          if (decrement_count == 0) begin
            inc_ce <= 1'b0;
            idelay_is_adjusted <= 1'b1;
            state_idelay <= ST_IDELAY_ADJUSTED;
          end
        end
        ST_IDELAY_ADJUSTED: begin
          // Remain in adjusted state.
        end
        default: state_idelay <= ST_IDELAY_INIT;
      endcase
      sig_idelay_check <= num_idelay_check;
    end
  end

  // ====================================================
  // u_check_idle: Check for an idle pattern on the delayed output
  // ====================================================
  always @(posedge clk) begin
    if (en_idle_check) begin
      if (data_out == kIdlePattern)
        idle_patt_count <= idle_patt_count + 1;
      else
        idle_patt_count <= 0;
    end else begin
      idle_patt_count <= 0;
    end
  end

  // ====================================================
  // u_bitslip_sm: Bit-slip State Machine
  // ====================================================
  always @(posedge clk or posedge reset_sm) begin
    if (reset_sm) begin
      elapsed_time_bitslip <= 0;
      num_patt_check       <= 0;
      en_bitslip           <= 1'b0;
      bit_aligned          <= 1'b0;
      bitslip_failure      <= 1'b0;
      state_bitslip        <= BS_INIT;
    end else begin
      case (state_bitslip)
        BS_INIT: begin
          state_bitslip <= BS_WAITSTART;
        end
        BS_WAITSTART: begin
          if (idelay_is_adjusted == 1'b1) begin
            en_idle_check <= 1'b1;
            state_bitslip <= BS_CHECK_IDLE;
          end
        end
        BS_CHECK_IDLE: begin
          elapsed_time_bitslip <= elapsed_time_bitslip + 1;
          if (idle_patt_count == kPattOkThreshold) begin
            en_idle_check <= 1'b0;
            bit_aligned   <= 1'b1;
            state_bitslip <= BS_FINISHED;
          end else if (elapsed_time_bitslip == kMaxPattCheck - 1) begin
            num_patt_check <= num_patt_check + 1;
            en_bitslip     <= 1'b1;
            state_bitslip  <= BS_BITSLIP;
          end
        end
        BS_BITSLIP: begin
          elapsed_time_bitslip <= 0;
          en_bitslip           <= 1'b0;
          state_bitslip        <= BS_CHECK_IDLE;
        end
        BS_FINISHED: begin
          // Bit-slip successful; remain here.
        end
        BS_FAILURE: begin
          // Bit-slip failed; remain here.
        end
        default: state_bitslip <= BS_INIT;
      endcase
    end
  end

  // ====================================================
  // u_final_state: Combine the two state machines into a final state output.
  // Here, if the IDelay state machine is adjusted (ST_IDELAY_ADJUSTED)
  // and the Bit-slip state machine is finished (BS_FINISHED), then the final state is DONE.
  // If either is still adjusting, then the final state is ADJUSTING.
  // If bit-slip has failed, final state is ERROR.
  // Otherwise, final state is IDLE.
  // ====================================================
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= IDLE_FINAL;
    end else begin
      if (state_bitslip == BS_FAILURE)
        state <= ERROR_FINAL;
      else if ((state_idelay == ST_IDELAY_ADJUSTED) && (state_bitslip == BS_FINISHED))
        state <= DONE_FINAL;
      else if ((state_idelay != ST_IDELAY_ADJUSTED) || (state_bitslip != BS_FINISHED))
        state <= ADJUSTING_FINAL;
      else
        state <= IDLE_FINAL;
    end
  end

  // ====================================================
  // Instantiate the IDELAYE2 primitive in VARIABLE mode.
  // The control signals inc_ce and delay_inc are driven by our state machine.
  // For simplicity, we tie LD to the external init pulse.
  // ====================================================
  wire ld;
//  assign ld = init;  // For this example, use the init pulse to load the delay tap value
  assign ld = 1'b0;  // For this example, use the init pulse to load the delay tap value

  (*KEEP="TRUE"*) wire buf_data;
  IBUFDS u_ibufds(
    .O(buf_data),
    .I(data_in_p),
    .IB(data_in_n)
  );
 
//  wire buf_data_r;
//  assign buf_data_r = buf_data;
//  (*mark_debug="true"*)reg buf_data_reg;
//  always@(posedge clk or posedge reset) begin
//    if(reset)
//      buf_data_reg <= 1'b0;
//    else
//      buf_data_reg <= buf_data_r;
//  end
//  assign raw_data_out = buf_data;
(* IODELAY_GROUP = "group1", SIM_DEVICE = "ULTRASCALE_PLUS" *) 
    IDELAYE3 #( 
    .CASCADE("NONE"), 
    .DELAY_FORMAT("COUNT"), 
    .DELAY_SRC("IDATAIN"), 
    .DELAY_TYPE("VARIABLE"), 
    .DELAY_VALUE(DEFAULT_DELAY), 
    .IS_CLK_INVERTED(1'b0), 
    .IS_RST_INVERTED(1'b0), 
    .REFCLK_FREQUENCY(200.0), 
    .SIM_DEVICE("ULTRASCALE_PLUS"), 
    .UPDATE_MODE("SYNC") ) 
idelay_inst ( 
    .CASC_IN(1'b0), 
    .CASC_OUT(), // Not used if not cascading 
    .CASC_RETURN(1'b0), 
    .CE(inc_ce), 
    .CLK(clk), 
    .CNTVALUEIN({9{1'b0}}), 
    .CNTVALUEOUT(), // Optionally monitor current tap value 
    .DATAIN(1'b0), // Unused if using IDATAIN 
    .IDATAIN(buf_data), 
    .DATAOUT(raw_data_out), 
    .EN_VTC(1'b0), 
    .INC(delay_inc),
    .LOAD(ld_signal), // Tied to 0 as required 
    .RST(reset) 
);

assign data_out = (init_pol) ? ~raw_data_out : raw_data_out;


endmodule
