// Example: CdcmRx.v
module CdcmRx #(
  // Parameter declarations (corresponds to VHDL generics)
  parameter genIDELAYCTRL   = 1,               // 1: TRUE, 0: FALSE
  parameter kDiffTerm       = 0,               // 0: FALSE, 1: TRUE
  parameter kRxPolarity     = 0,               // 0: Normal, 1: Inverted
  parameter kIoStandard     = "DEFAULT",       // IOSTANDARD string
  parameter kIoDelayGroup   = "DEFAULT",       // IODELAY_GROUP name
  parameter kCdcmModWidth   = 10,              // Number of CDCM time slices
  parameter real kFreqFastClk = 200.0,          // SERDES fast clock frequency (MHz)
  parameter real kFreqRefClk  = 200.0,          // IDELAYCTRL reference clock (MHz)
  parameter enDEBUG         = 0,               // Debug flag for marking debug signals
  // Constants from defCDCM (assumed values)
  parameter integer kPlateauThreshold   = 5,
  parameter integer kNumTaps            = 32,
  parameter integer kWidthCheckCount    = 8,
  parameter integer kSuccThreshold      = 8,
  parameter integer kMaxIdelayCheck     = 100,
  parameter [kCdcmModWidth-1:0] kIdleCDCM = 10'b1010101010,
  parameter integer kPattOkThreshold    = 4,
  parameter integer kMaxPattCheck       = 100,
  parameter integer kWidthDev           = 10,
  parameter integer kWidthSys           = 10,
  parameter integer kNumPattMatchCycle  = 10,
  parameter [kCdcmModWidth-1:0] kInitPCDCM = 10'b1100110011,
  parameter [kCdcmModWidth-1:0] kInitMCDCM = 10'b0011001100
)(
  // Port declarations
  input  wire         srst,         // Asynchronous assert, synchronous deassert reset (active high)
  input  wire         clkSer,       // SERDES clock (5x the clkPar frequency)
  input  wire         clkPar,       // Parallel clock
  input  wire         clkIdelayRef, // Reference clock for IDELAYCTRL (200MHz)
  input  wire         clkIsReady,   // Indicates that the clocks are available
  input  wire         initIn,       // Initialization restart signal (synchronized to clkPar)
  output reg  [2:0]   statusInit,   // Initialization status (synchronized to clkPar)
  output reg          cdcmUpRx,     // Indicates that CDCM-RX is ready for communication
  output reg          bitslipErr,   // Bit-slip error signal
  output reg          patternErr,   // Pattern error signal
  input  wire         RXP,          // CDCM input port (positive)
  input  wire         RXN,          // CDCM input port (negative)
  output wire         modClock,     // Modulated clock output (from IBUFDS, before IDELAY)
  output wire [kCdcmModWidth-1:0] payloadOut  // CDCM payload output
);

  //////////// Internal Parameters ////////////
  // State machine constants for IDELAY control
  localparam [2:0]
    ST_IDELAY_INIT      = 3'd0,
    ST_IDELAY_WAITPLL   = 3'd1,
    ST_IDELAY_CHECK     = 3'd2,
    ST_IDELAY_NUMTRIAL  = 3'd3,
    ST_IDELAY_INCREMENT = 3'd4,
    ST_IDELAY_DECREMENT = 3'd5,
    ST_IDELAY_ADJUSTED  = 3'd6;

  // State machine constants for Bit-slip control
  localparam [2:0]
    ST_BITS_INIT          = 3'd0,
    ST_BITS_WAITSTART     = 3'd1,
    ST_BITS_CHECKIDLEPATT = 3'd2,
    ST_BITS_BITSLIP       = 3'd3,
    ST_BITS_FINISHED      = 3'd4,
    ST_BITS_FAILURE       = 3'd5;

  // Initialization status (corresponds to RxInitStatusType)
  localparam [2:0]
    kWaitClkReady    = 3'd0,
    kAdjustingIdelay = 3'd1,
    kTryingBitslip   = 3'd2,
    kInitFinish      = 3'd3,
    kUndefinedRx     = 3'd4;

  //////////// Internal Signals ////////////
  // Copy external clock ready and initialization signals
  wire clk_is_ready    = clkIsReady;
  wire redo_initialize = initIn;

  // Signal for CDCM pattern checking
  reg cdcm_pattern_ok;

  // IDELAY related signals
  reg         idelay_reset;
  reg         delay_inc;
  reg         inc_ce;
  reg [kWidthCheckCount-1:0] idelay_check_count;
  reg         en_idelay_check;
  reg         idelay_is_adjusted;
  reg [2:0]   state_idelay;
  reg [5:0]   sig_idelay_check; // Example: 6-bit width

  // ISERDES related signals
  // 'dout_serdes' is provided by the CDCM implementation module
  wire [kCdcmModWidth-1:0] dout_serdes;
  reg  [kCdcmModWidth-1:0] reg_dout_serdes;
  reg  [kCdcmModWidth-1:0] prev_data;
  reg         en_bitslip;
  reg         en_idle_check;
  // Idle pattern counter (equivalent to VHDL: std_logic_vector(kWidthCheckCount-4 downto 0))
  reg [kWidthCheckCount-4:0] idle_patt_count;
  reg         bit_aligned;
  reg         bitslip_failure;
  reg [2:0]   state_bitslip;

  // Counters for the IDELAY state machine
  reg [31:0] elapsed_time_idelay;
  reg [31:0] num_idelay_appropriate;
  reg [4:0]  num_cont_appropriate;
  reg [5:0]  num_idelay_check;
  reg [5:0]  decrement_count;

  // Counters for the Bit-slip state machine
  reg [31:0] elapsed_time_bitslip;
  reg [31:0] num_patt_check;

  // Counter for CDCM up detection
  reg [31:0] init_patt_count;

  // Reset signals
  // 'rst_all' is determined by the IDELAYCTRL RDY signal (when genIDELAYCTRL == 1)
  wire rst_all;
  // 'reset_sm' = srst OR (NOT clk_is_ready) OR redo_initialize
  wire reset_sm = rst_all || (!clk_is_ready) || redo_initialize;

  // Assign payload output (corresponds to VHDL: payloadOut <= reg_dout_serdes(kPaylowdPos'range))
  assign payloadOut = reg_dout_serdes;

  //////////// IDELAYCTRL Instance ////////////
  // Generate IDELAYCTRL instance if genIDELAYCTRL is TRUE
  wire ready_ctrl;  // RDY output from IDELAYCTRL
  generate
    if (genIDELAYCTRL) begin : gen_idelayctrl
      IDELAYCTRL IDELAYCTRL_inst (
         .RDY    (ready_ctrl),
         .REFCLK (clkIdelayRef),
         .RST    (srst)
      );
      // When RDY is low, assert overall reset
      assign rst_all = srst || (!ready_ctrl);
    end else begin : nogen
      assign rst_all = srst;
    end
  endgenerate

  //////////// ISERDES/CDCM Implementation Module Instance ////////////
  generate
    if (kCdcmModWidth == 10) begin : gen_cdcm10
      CdcmRxImpl #(
         .kSysW         (kWidthSys),
         .kDevW         (kWidthDev),
         .kDiffTerm     (kDiffTerm),
         .kRxPolarity   (kRxPolarity),
         .kIoStandard   (kIoStandard),
         .kIoDelayGroup (kIoDelayGroup),
         .kFreqRefClk   (kFreqRefClk)
      ) u_cdcm_rx_iserdes (
         .dInFromPinP (RXP),
         .dInFromPinN (RXN),
         .rstIDelay   (idelay_reset),
         .ceIDelay    (inc_ce),
         .incIDelay   (delay_inc),
         .cdOutFromO  (modClock),
         .dOutToDevice(dout_serdes),
         .bitslip     (en_bitslip),
         .clkIn       (clkSer),
         .clkDivIn    (clkPar),
         .ioReset     (srst)
      );
    end else if (kCdcmModWidth == 8) begin : gen_cdcm8
      Cdcm8RxImpl #(
         .kSysW         (kWidthSys),
         .kDevW         (kWidthDev - 2),
         .kDiffTerm     (kDiffTerm),
         .kRxPolarity   (kRxPolarity),
         .kIoStandard   (kIoStandard),
         .kIoDelayGroup (kIoDelayGroup),
         .kFreqRefClk   (kFreqRefClk)
      ) u_cdcm_rx_iserdes (
         .dInFromPinP (RXP),
         .dInFromPinN (RXN),
         .rstIDelay   (idelay_reset),
         .ceIDelay    (inc_ce),
         .incIDelay   (delay_inc),
         .cdOutFromO  (modClock),
         .dOutToDevice(dout_serdes[8:1]),
         .bitslip     (en_bitslip),
         .clkIn       (clkSer),
         .clkDivIn    (clkPar),
         .ioReset     (srst)
      );
      assign dout_serdes[0] = 1'b1;
      assign dout_serdes[9] = 1'b0;
    end
  endgenerate

  //////////// Processes (always blocks) ////////////

  // u_bufdout: Synchronous latch for ISERDES output
  always @(posedge clkPar) begin
    reg_dout_serdes <= dout_serdes;
  end

  // u_bitpattern: Pattern checking process
  always @(posedge clkPar or posedge srst) begin
    if (srst)
      cdcm_pattern_ok <= 1'b0;
    else begin
      if (bit_aligned) begin
        // Example: Check if the upper 3 bits are "000" and the lower 3 bits are "111"
        if ((reg_dout_serdes[kCdcmModWidth-1 : kCdcmModWidth-3] == 3'b000) &&
            (reg_dout_serdes[2:0] == 3'b111))
          cdcm_pattern_ok <= 1'b1;
        else
          cdcm_pattern_ok <= 1'b0;
      end
      else
        cdcm_pattern_ok <= 1'b0;
    end
  end

  // u_idelay_check: Check changes in the IDELAY output
  always @(posedge clkPar) begin
    if (en_idelay_check) begin
      prev_data <= reg_dout_serdes;
      if (prev_data == reg_dout_serdes)
        idelay_check_count <= idelay_check_count + 1;
      else
        idelay_check_count <= 0;
    end else
      idelay_check_count <= 0;
  end

  // u_idelay_sm: IDELAY auto-adjust state machine
  always @(posedge clkPar or posedge reset_sm) begin
    if (reset_sm) begin
      elapsed_time_idelay    <= 0;
      num_idelay_appropriate <= 0;
      num_cont_appropriate   <= 0;
      num_idelay_check       <= 0;
      decrement_count        <= 0;
      en_idelay_check        <= 1'b0;
      inc_ce                 <= 1'b0;
      delay_inc              <= 1'b1; // Increment direction
      idelay_is_adjusted     <= 1'b0;
      state_idelay           <= ST_IDELAY_INIT;
    end else begin
      case (state_idelay)
        ST_IDELAY_INIT: begin
          state_idelay <= ST_IDELAY_WAITPLL;
        end
        ST_IDELAY_WAITPLL: begin
          if (clk_is_ready) begin
            en_idelay_check <= 1'b1;
            state_idelay   <= ST_IDELAY_CHECK;
          end
        end
        ST_IDELAY_CHECK: begin
          elapsed_time_idelay <= elapsed_time_idelay + 1;
          if (idelay_check_count == kSuccThreshold) begin
            num_idelay_appropriate <= num_idelay_appropriate + 1;
            num_idelay_check       <= num_idelay_check + 1;
            num_cont_appropriate   <= 0;
            en_idelay_check        <= 1'b0;
            state_idelay           <= ST_IDELAY_NUMTRIAL;
          end else if (elapsed_time_idelay == kMaxIdelayCheck - 1) begin
            num_cont_appropriate   <= num_idelay_appropriate;
            num_idelay_appropriate <= 0;
            num_idelay_check       <= num_idelay_check + 1;
            en_idelay_check        <= 1'b0;
            state_idelay           <= ST_IDELAY_NUMTRIAL;
          end
        end
        ST_IDELAY_NUMTRIAL: begin
          elapsed_time_idelay <= 0;
          if (num_cont_appropriate >= kPlateauThreshold) begin
            inc_ce          <= 1'b1;
            delay_inc       <= 1'b0;
            // In VHDL, conversion from num_cont_appropriate(4 downto 1) to integer
            decrement_count <= num_cont_appropriate[4:1] + 1;
            state_idelay    <= ST_IDELAY_DECREMENT;
          end else begin
            inc_ce        <= 1'b1;
            state_idelay  <= ST_IDELAY_INCREMENT;
          end
        end
        ST_IDELAY_INCREMENT: begin
          inc_ce          <= 1'b0;
          en_idelay_check <= 1'b1;
          state_idelay    <= ST_IDELAY_CHECK;
        end
        ST_IDELAY_DECREMENT: begin
          decrement_count <= decrement_count - 1;
          if (decrement_count == 0) begin
            inc_ce            <= 1'b0;
            idelay_is_adjusted <= 1'b1;
            state_idelay      <= ST_IDELAY_ADJUSTED;
          end
        end
        ST_IDELAY_ADJUSTED: begin
          // Adjustment complete: no further processing required
        end
        default: begin
          state_idelay <= ST_IDELAY_INIT;
        end
      endcase
      sig_idelay_check <= num_idelay_check;
    end
  end

  // u_check_idle: Check if the ISERDES output is an idle pattern
  always @(posedge clkPar) begin
    if (en_idle_check) begin
      if (reg_dout_serdes == kIdleCDCM)
        idle_patt_count <= idle_patt_count + 1;
      else
        idle_patt_count <= 0;
    end else
      idle_patt_count <= 0;
  end

  // u_bitslip_sm: Bit-slip state machine
  always @(posedge clkPar or posedge reset_sm) begin
    if (reset_sm) begin
      elapsed_time_bitslip <= 0;
      num_patt_check       <= 0;
      en_bitslip           <= 1'b0;
      bit_aligned          <= 1'b0;
      bitslip_failure      <= 1'b0;
      state_bitslip        <= ST_BITS_INIT;
    end else begin
      case (state_bitslip)
        ST_BITS_INIT: begin
          state_bitslip <= ST_BITS_WAITSTART;
        end
        ST_BITS_WAITSTART: begin
          if (idelay_is_adjusted) begin
            en_idle_check <= 1'b1;
            state_bitslip <= ST_BITS_CHECKIDLEPATT;
          end
        end
        ST_BITS_CHECKIDLEPATT: begin
          elapsed_time_bitslip <= elapsed_time_bitslip + 1;
          if (idle_patt_count == kPattOkThreshold) begin
            en_idle_check <= 1'b0;
            bit_aligned   <= 1'b1;
            state_bitslip <= ST_BITS_FINISHED;
          end else if (elapsed_time_bitslip == kMaxPattCheck - 1) begin
            num_patt_check <= num_patt_check + 1;
            if (num_patt_check == kWidthDev) begin
              bitslip_failure <= 1'b1;
              state_bitslip   <= ST_BITS_FAILURE;
            end else begin
              en_bitslip    <= 1'b1;
              state_bitslip <= ST_BITS_BITSLIP;
            end
          end
        end
        ST_BITS_BITSLIP: begin
          elapsed_time_bitslip <= 0;
          en_bitslip           <= 1'b0;
          state_bitslip        <= ST_BITS_CHECKIDLEPATT;
        end
        ST_BITS_FINISHED: begin
          // Bit-slip successful
        end
        ST_BITS_FAILURE: begin
          // Bit-slip failed
        end
        default: begin
          state_bitslip <= ST_BITS_INIT;
        end
      endcase
    end
  end

  // u_init_status: Update initialization status register (corresponds to RxInitStatusType)
  always @(posedge clkPar or posedge reset_sm) begin
    if (reset_sm)
      statusInit <= kWaitClkReady;
    else begin
      if ((state_idelay == ST_IDELAY_WAITPLL) && (state_bitslip == ST_BITS_WAITSTART))
        statusInit <= kWaitClkReady;
      else if ((state_idelay != ST_IDELAY_ADJUSTED) && (state_bitslip == ST_BITS_WAITSTART))
        statusInit <= kAdjustingIdelay;
      else if ((state_idelay == ST_IDELAY_ADJUSTED) && (state_bitslip != ST_BITS_FINISHED))
        statusInit <= kTryingBitslip;
      else if ((state_idelay == ST_IDELAY_ADJUSTED) && (state_bitslip == ST_BITS_FINISHED))
        statusInit <= kInitFinish;
      else
        statusInit <= kUndefinedRx;
    end
  end

  // u_cdcm_up: Detect CDCM communication ready status
  always @(posedge clkPar or posedge reset_sm) begin
    if (reset_sm) begin
      init_patt_count <= 0;
      cdcmUpRx        <= 1'b0;
    end else begin
      if ((statusInit == kInitFinish) &&
          ((reg_dout_serdes == kInitPCDCM) || (reg_dout_serdes == kInitMCDCM)))
        init_patt_count <= init_patt_count + 1;
      else if (cdcmUpRx == 1'b1)
        init_patt_count <= 0;
      if (init_patt_count == kNumPattMatchCycle)
        cdcmUpRx <= 1'b1;
    end
  end

  // u_error_sig: Generate error signals
  always @(posedge clkPar) begin
    patternErr <= ~cdcm_pattern_ok;
    if (state_bitslip == ST_BITS_FAILURE)
      bitslipErr <= 1'b1;
    else
      bitslipErr <= 1'b0;
  end

endmodule
