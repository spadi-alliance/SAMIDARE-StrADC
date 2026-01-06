// idelay_controller.v
// This module manages the delay adjustment process. It issues an init pulse on reset and when a register-change
// event (polled via an AXI-lite interface) is detected. It aggregates the state signals from each channel (both
// normal bits [9:0] and the special bit [10]) and produces an overall system state (one-hot).
// It also implements a simple read-only AXI-lite slave interface for polling.

module idelay_controller #(
  parameter C_S_AXI_ADDR_WIDTH = 4,
  parameter C_S_AXI_DATA_WIDTH = 32
)(
  input  wire clk,
  input  wire reset,
  input  wire reg_change,        // Signal indicating the register value changed (0->1 transition)
  // Aggregated state signals for each channel:
  input  wire [3:0] ch0_normal,  // Aggregated state from SO0 bits [9:0]
  input  wire [3:0] ch0_special, // State from SO0 bit 10
  input  wire [3:0] ch1_normal,
  input  wire [3:0] ch1_special,
  input  wire [3:0] ch2_normal,
  input  wire [3:0] ch2_special,
  input  wire [3:0] ch3_normal,
  input  wire [3:0] ch3_special,
  output reg  init,             // Init pulse to trigger delay adjustment in all idelay_impl instances
  output reg  [3:0] overall_state,  // Overall aggregated state (one-hot: IDLE, ADJUSTING, DONE, ERROR)
  
  // AXI-lite slave interface (read-only)
  input  wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
  input  wire S_AXI_ARVALID,
  output reg S_AXI_ARREADY,
  output reg [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
  output reg [1:0] S_AXI_RRESP,
  output reg S_AXI_RVALID,
  input  wire S_AXI_RREADY
);

  // One-hot state definitions
  localparam IDLE      = 4'b0001;
  localparam ADJUSTING = 4'b0010;
  localparam DONE      = 4'b0100;
  localparam ERROR     = 4'b1000;

  // Per-channel aggregated states.
  // For each channel, if either the normal or special state is ERROR, then channel state = ERROR.
  // Otherwise, if either is ADJUSTING then state = ADJUSTING.
  // Otherwise, if both are DONE then state = DONE.
  // Else, state = IDLE.
  reg [3:0] ch0_state, ch1_state, ch2_state, ch3_state;
  
  always @(*) begin
    // Channel 0
    if ((ch0_normal == ERROR) || (ch0_special == ERROR))
      ch0_state = ERROR;
    else if ((ch0_normal == ADJUSTING) || (ch0_special == ADJUSTING))
      ch0_state = ADJUSTING;
    else if ((ch0_normal == DONE) && (ch0_special == DONE))
      ch0_state = DONE;
    else
      ch0_state = IDLE;
      
    // Channel 1
    if ((ch1_normal == ERROR) || (ch1_special == ERROR))
      ch1_state = ERROR;
    else if ((ch1_normal == ADJUSTING) || (ch1_special == ADJUSTING))
      ch1_state = ADJUSTING;
    else if ((ch1_normal == DONE) && (ch1_special == DONE))
      ch1_state = DONE;
    else
      ch1_state = IDLE;
      
    // Channel 2
    if ((ch2_normal == ERROR) || (ch2_special == ERROR))
      ch2_state = ERROR;
    else if ((ch2_normal == ADJUSTING) || (ch2_special == ADJUSTING))
      ch2_state = ADJUSTING;
    else if ((ch2_normal == DONE) && (ch2_special == DONE))
      ch2_state = DONE;
    else
      ch2_state = IDLE;
      
    // Channel 3
    if ((ch3_normal == ERROR) || (ch3_special == ERROR))
      ch3_state = ERROR;
    else if ((ch3_normal == ADJUSTING) || (ch3_special == ADJUSTING))
      ch3_state = ADJUSTING;
    else if ((ch3_normal == DONE) && (ch3_special == DONE))
      ch3_state = DONE;
    else
      ch3_state = IDLE;
  end

  // Overall system state aggregation:
  // If any channel is ERROR, then overall_state = ERROR.
  // Else if any channel is ADJUSTING, then overall_state = ADJUSTING.
  // Else if all channels are DONE, then overall_state = DONE.
  // Otherwise, overall_state = IDLE.
  always @(*) begin
    if ((ch0_state == ERROR) || (ch1_state == ERROR) || (ch2_state == ERROR) || (ch3_state == ERROR))
      overall_state = ERROR;
    else if ((ch0_state == ADJUSTING) || (ch1_state == ADJUSTING) ||
             (ch2_state == ADJUSTING) || (ch3_state == ADJUSTING))
      overall_state = ADJUSTING;
    else if ((ch0_state == DONE) && (ch1_state == DONE) &&
             (ch2_state == DONE) && (ch3_state == DONE))
      overall_state = DONE;
    else
      overall_state = IDLE;
  end

  // Generate the init pulse. According to your spec, the init pulse is issued after reset
  // and when the monitored register (via AXI-lite) changes (0->1).
  always @(posedge clk or posedge reset) begin
    if (reset)
      init <= 1'b1;
    else if (reg_change)
      init <= 1'b1;
    else
      init <= 1'b0;
  end

  // --------------------------------------------------------------------
  // AXI-lite Read-Only Slave Interface (for polling register values)
  // We'll create a simple register map:
  // Address 0x0 : overall_state (lower 4 bits)
  // Address 0x4 : Channel 0 state (4 bits)
  // Address 0x8 : Channel 1 state (4 bits)
  // Address 0xC : Channel 2 state (4 bits)
  // Address 0x10: Channel 3 state (4 bits)
  // --------------------------------------------------------------------
  reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg0;
  reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg1;
  reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg2;
  reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg3;
  reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg4;
  
  always @(*) begin
    slv_reg0 = {28'b0, overall_state};
    slv_reg1 = {28'b0, ch0_state};
    slv_reg2 = {28'b0, ch1_state};
    slv_reg3 = {28'b0, ch2_state};
    slv_reg4 = {28'b0, ch3_state};
  end

  // Read address handshake
  always @(posedge clk or posedge reset) begin
    if (reset)
      S_AXI_ARREADY <= 1'b0;
    else if (S_AXI_ARVALID && !S_AXI_ARREADY)
      S_AXI_ARREADY <= 1'b1;
    else
      S_AXI_ARREADY <= 1'b0;
  end

  // Read data channel
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      S_AXI_RDATA  <= {C_S_AXI_DATA_WIDTH{1'b0}};
      S_AXI_RRESP  <= 2'b0;
      S_AXI_RVALID <= 1'b0;
    end else if (S_AXI_ARREADY && S_AXI_ARVALID) begin
      case (S_AXI_ARADDR)
        4'h0: S_AXI_RDATA <= slv_reg0;
        4'h1: S_AXI_RDATA <= slv_reg1;
        4'h2: S_AXI_RDATA <= slv_reg2;
        4'h3: S_AXI_RDATA <= slv_reg3;
        4'h4: S_AXI_RDATA <= slv_reg4;
        default: S_AXI_RDATA <= {C_S_AXI_DATA_WIDTH{1'b0}};
      endcase
      S_AXI_RRESP  <= 2'b0;
      S_AXI_RVALID <= 1'b1;
    end else if (S_AXI_RVALID && S_AXI_RREADY) begin
      S_AXI_RVALID <= 1'b0;
    end
  end

endmodule
