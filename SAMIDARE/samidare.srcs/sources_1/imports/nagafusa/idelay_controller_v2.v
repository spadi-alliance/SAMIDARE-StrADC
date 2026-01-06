// idelay_controller.v
// This module manages the delay adjustment process for SAMPA.
// It aggregates the state signals from each channel (both normal and special) and produces an overall system state.
// The controller state machine has 4 states: IDLE, ADJUST_CLK, ADJUST_DATA, DONE.
//   - When a reg_change is detected, the controller transitions from IDLE to ADJUST_CLK, and outputs an init pulse.
//   - In ADJUST_CLK, the special modules are adjusted.
//   - When all special module states are DONE, the controller transitions to ADJUST_DATA.
//   - In ADJUST_DATA, normal module adjustment is performed, and a periodic trg signal is generated (128 cycles high, 128 cycles low).
//   - When all normal module states are DONE, the controller transitions to DONE.
module idelay_controller_v2 #(
  parameter C_S_AXI_ADDR_WIDTH = 4,
  parameter C_S_AXI_DATA_WIDTH = 32
)(  input        clk,               // clock
    input        reset,             // async reset（active High）
    input        init,              // start init signal
    output          clock_adj_start,
    input [3:0]  clock_adj_done,    // SOx[10] done signal
    output reg       signal_adj_start,
    output       trg_en,            // toggle trigger enable for initialize pattern
    input [39:0] signal_adj_done,   // SOx[9:0] done signal
    output reg   clock_done,        // done flag
    output reg   done               // done flag
);

  // 状態定義
  localparam IDLE                = 2'd0;
  localparam STATE_CLOCK_ADJUST  = 2'd1;
  localparam STATE_SIGNAL_ADJUST = 2'd2;
  localparam STATE_DONE          = 2'd3;
  (*mark_debug = "true"*)reg [1:0] state, next_state;
  reg trg_en_r;
  reg [7:0] toggle_counter;
  reg [63:0] clock_adj_r;
  assign clock_adj_start = clock_adj_r[0];
  assign trg_en = trg_en_r;
  always @(posedge clk or posedge reset) begin
    if (reset)
      trg_en_r <= 1'b0;
    else begin
          
        if (state == STATE_SIGNAL_ADJUST) begin
            if (toggle_counter == 6'd63) begin
                toggle_counter <= 6'd0;
                trg_en_r         <= ~trg_en_r; // 64clock
            end else begin
                toggle_counter <= toggle_counter + 6'd1;
            end
        end else begin
            toggle_counter <= 6'd0;
            trg_en_r         <= 1'b0;
        end
    end
  end
  always @(posedge clk) begin
    if (reset) begin
          state <= IDLE;
  
          clock_adj_r <= 'b0;
          end
    else begin
    
    case (state)
      IDLE: begin
        if (init) begin
          state <= STATE_CLOCK_ADJUST;
//          clock_adj_start <= 1'b0;
          signal_adj_start <= 1'b0;
          clock_adj_r <= 'b0;
        end
      end
      STATE_CLOCK_ADJUST: begin
        clock_adj_r <= {1'b1, clock_adj_r[63:1]};
        if (&clock_adj_done)
          state <= STATE_SIGNAL_ADJUST;
      end
      STATE_SIGNAL_ADJUST: begin
        signal_adj_start <= 1'b1;
        if ((&signal_adj_done))
          state <= STATE_DONE;
      end
      STATE_DONE: begin
        state <= STATE_DONE;  // 完了状態はそのまま維持
      end
      default: state <= IDLE;
    endcase
    end
  end
  
  
  always @(posedge clk or posedge reset) begin
    if (reset)
      done <= 1'b0;
    else if (state == STATE_DONE)
      done <= 1'b1;
    else
      done <= 1'b0;
  end
endmodule