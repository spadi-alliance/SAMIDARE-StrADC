// idelay_top.v
// This top-level module receives four 11-bit input channels (SO0, SO1, SO2, SO3)
// and outputs four 11-bit delayed channels (SO0_out, SO1_out, SO2_out, SO3_out).
// It instantiates 11 idelay_impl modules per channel (one per bit). For bit index 10,
// the instance is created with SPECIAL = 1; for bits 0-9, SPECIAL = 0.
// It aggregates the states from each channel and passes them to the idelay_controller,
// which produces an overall system state and an AXI-lite interface for polling.
module delayAdjust (
  input  wire clk,
  input  wire reset,
  input  wire reg_change,   // Trigger signal from the AXI-lite-polled BRAM
  input  wire [10:0] SO0,   // Channel 0 input
  input  wire [10:0] SO1,   // Channel 1 input
  input  wire [10:0] SO2,   // Channel 2 input
  input  wire [10:0] SO3,   // Channel 3 input
  output wire [10:0] SO0_out, // Channel 0 delayed output
  output wire [10:0] SO1_out, // Channel 1 delayed output
  output wire [10:0] SO2_out, // Channel 2 delayed output
  output wire [10:0] SO3_out, // Channel 3 delayed output
  output wire [3:0] overall_state, // Overall aggregated state (one-hot)
  // AXI-lite interface from idelay_controller
  input  wire [3:0] S_AXI_ARADDR,
  input  wire S_AXI_ARVALID,
  output wire S_AXI_ARREADY,
  output wire [31:0] S_AXI_RDATA,
  output wire [1:0] S_AXI_RRESP,
  output wire S_AXI_RVALID,
  input  wire S_AXI_RREADY
);

  // Common init pulse from the controller
  wire common_init;
  
  // For each channel, create arrays of state outputs from each idelay_impl instance.
  // There are 11 bits per channel.
  wire [3:0] state_SO0 [0:10];
  wire [3:0] state_SO1 [0:10];
  wire [3:0] state_SO2 [0:10];
  wire [3:0] state_SO3 [0:10];

  // Function to aggregate the 10 normal states (for bits 0-9) for a channel.
  function [3:0] aggregate_state;
    input [3:0] states [0:9];
    integer j;
    reg [3:0] result;
    begin
      result = 4'b0001; // Default to IDLE
      // If any state is ERROR, set result to ERROR.
      for (j = 0; j < 10; j = j + 1) begin
        if (states[j] == 4'b1000)
          result = 4'b1000;
      end
      // If not ERROR and any state is ADJUSTING, then result = ADJUSTING.
      if (result != 4'b1000) begin
        for (j = 0; j < 10; j = j + 1) begin
          if (states[j] == 4'b0010)
            result = 4'b0010;
        end
      end
      // If not ERROR or ADJUSTING, check if all states are DONE.
      if (result != 4'b1000 && result != 4'b0010) begin
        result = 4'b0100; // Assume DONE
        for (j = 0; j < 10; j = j + 1) begin
          if (states[j] != 4'b0100)
            result = 4'b0001; // Otherwise, IDLE
        end
      end
      aggregate_state = result;
    end
  endfunction

  // Compute aggregated normal state for each channel from bits [9:0]
  wire [3:0] ch0_normal_state = aggregate_state(state_SO0);
  wire [3:0] ch1_normal_state = aggregate_state(state_SO1);
  wire [3:0] ch2_normal_state = aggregate_state(state_SO2);
  wire [3:0] ch3_normal_state = aggregate_state(state_SO3);

  // For the special state of each channel, simply take the state from bit 10.
  wire [3:0] ch0_special_state = state_SO0[10];
  wire [3:0] ch1_special_state = state_SO1[10];
  wire [3:0] ch2_special_state = state_SO2[10];
  wire [3:0] ch3_special_state = state_SO3[10];

  // Instantiate idelay_impl instances for each channel.
  genvar i;
  // Channel 0
  generate
    for (i = 0; i < 11; i = i + 1) begin : gen_SO0
      if (i == 10) begin: special_inst
        idelay_impl #(
          .SPECIAL(1)
        ) u_idelay_impl_SO0 (
          .clk(clk),
          .reset(reset),
          .init(common_init),
          .data_in(SO0[i]),
          .data_out(SO0_out[i]),
          .state(state_SO0[i])
        );
      end else begin: normal_inst
        idelay_impl #(
          .SPECIAL(0)
        ) u_idelay_impl_SO0 (
          .clk(clk),
          .reset(reset),
          .init(common_init),
          .data_in(SO0[i]),
          .data_out(SO0_out[i]),
          .state(state_SO0[i])
        );
      end
    end
  endgenerate

  // Channel 1
  generate
    for (i = 0; i < 11; i = i + 1) begin : gen_SO1
      if (i == 10) begin: special_inst
        idelay_impl #(
          .SPECIAL(1)
        ) u_idelay_impl_SO1 (
          .clk(clk),
          .reset(reset),
          .init(common_init),
          .data_in(SO1[i]),
          .data_out(SO1_out[i]),
          .state(state_SO1[i])
        );
      end else begin: normal_inst
        idelay_impl #(
          .SPECIAL(0)
        ) u_idelay_impl_SO1 (
          .clk(clk),
          .reset(reset),
          .init(common_init),
          .data_in(SO1[i]),
          .data_out(SO1_out[i]),
          .state(state_SO1[i])
        );
      end
    end
  endgenerate

  // Channel 2
  generate
    for (i = 0; i < 11; i = i + 1) begin : gen_SO2
      if (i == 10) begin: special_inst
        idelay_impl #(
          .SPECIAL(1)
        ) u_idelay_impl_SO2 (
          .clk(clk),
          .reset(reset),
          .init(common_init),
          .data_in(SO2[i]),
          .data_out(SO2_out[i]),
          .state(state_SO2[i])
        );
      end else begin: normal_inst
        idelay_impl #(
          .SPECIAL(0)
        ) u_idelay_impl_SO2 (
          .clk(clk),
          .reset(reset),
          .init(common_init),
          .data_in(SO2[i]),
          .data_out(SO2_out[i]),
          .state(state_SO2[i])
        );
      end
    end
  endgenerate

  // Channel 3
  generate
    for (i = 0; i < 11; i = i + 1) begin : gen_SO3
      if (i == 10) begin: special_inst
        idelay_impl #(
          .SPECIAL(1)
        ) u_idelay_impl_SO3 (
          .clk(clk),
          .reset(reset),
          .init(common_init),
          .data_in(SO3[i]),
          .data_out(SO3_out[i]),
          .state(state_SO3[i])
        );
      end else begin: normal_inst
        idelay_impl #(
          .SPECIAL(0)
        ) u_idelay_impl_SO3 (
          .clk(clk),
          .reset(reset),
          .init(common_init),
          .data_in(SO3[i]),
          .data_out(SO3_out[i]),
          .state(state_SO3[i])
        );
      end
    end
  endgenerate

  // Instantiate the idelay_controller module.
  // The controller takes as input the aggregated normal and special state signals from all four channels.
  idelay_controller controller_inst (
    .clk(clk),
    .reset(reset),
    .reg_change(reg_change),
    .ch0_normal(ch0_normal_state),
    .ch0_special(ch0_special_state),
    .ch1_normal(ch1_normal_state),
    .ch1_special(ch1_special_state),
    .ch2_normal(ch2_normal_state),
    .ch2_special(ch2_special_state),
    .ch3_normal(ch3_normal_state),
    .ch3_special(ch3_special_state),
    .init(common_init),         // Controller issues the common init pulse
    .overall_state(overall_state),
    // AXI-lite interface connections:
    .S_AXI_ARADDR(S_AXI_ARADDR),
    .S_AXI_ARVALID(S_AXI_ARVALID),
    .S_AXI_ARREADY(S_AXI_ARREADY),
    .S_AXI_RDATA(S_AXI_RDATA),
    .S_AXI_RRESP(S_AXI_RRESP),
    .S_AXI_RVALID(S_AXI_RVALID),
    .S_AXI_RREADY(S_AXI_RREADY)
  );

endmodule
