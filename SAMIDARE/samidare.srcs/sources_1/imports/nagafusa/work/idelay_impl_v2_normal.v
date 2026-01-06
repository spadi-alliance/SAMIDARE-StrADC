// idelay_impl_v2_norm.v
// This module implements the NORMAL delay adjustment functionality for one bit,
// to be used after the special adjustment is complete. The module uses the IDELAYE3
// primitive in VARIABLE mode. The expected initialize pattern is "101011001100101" (15 bits).
// The normal state machine performs 100 steps per idelay value and then selects the best one
// based on the number of successful pattern detections.
// When all 512 taps have been evaluated, if max_cnt is at least 1 then the final idelay is set to the tap value farthest
// from edge_idelay, otherwise tap=256. The input special_state (from the special module)
// must be 'DONE' (4'b1000) before the normal state machine starts.
// The trigger signal (trg) is provided externally (by idelay_controller) as an input.
module idelay_impl_v2_normal #(
    parameter IODELAY_GROUP_NAME = "default_name",
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
    input         clk,         // 制御クロック
    input         reset,       // async reset
    input         start,       // 調整開始信号
    input         clock_edge,  // パターン開始を示す信号（32クロック周期ごとに来る）
    input         pol,         // パターン反転指定（1の場合：最終delay値を反転）
    input         all_zero,
    input         raw_signal_p,// 差動入力 positive
    input         raw_signal_n,// 差動入力 negative
//    input  wire [30:0] init_patern,
    output reg    done,        // 調整完了
    output        delayed_signal, // 遅延後出力信号（実際は遅延素子の出力になるはず）
    output reg [8:0] delay_val // 最終delay値（タップ値または反転値）
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
  (*KEEP = "true"*)assign delayed_signal = data_out;
  wire buf_data;
  reg buf_data_r;
  reg buf_data_rr;
  
  (* IODELAY_GROUP = IODELAY_GROUP_NAME, SIM_DEVICE = "ULTRASCALE_PLUS" *)
  IBUFDS #(
    .IOSTANDARD("SLVS_400_18")
  )u_ibufds(
    .O(buf_data),
    .I(raw_signal_p),
    .IB(raw_signal_n)
  );
//  assign raw_data_out = buf_data;
  (* IODELAY_GROUP = IODELAY_GROUP_NAME, SIM_DEVICE = "ULTRASCALE_PLUS" *)
  IDELAYE3 #(
    .CASCADE("MASTER"),
//    .CASCADE("NONE"),
    .DELAY_FORMAT("COUNT"),
    .DELAY_SRC("DATAIN"),//IDATAIN is used to connect input pins
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
    .CNTVALUEIN(current_idelay),
    .CNTVALUEOUT(check_delay_master),       // Optionally monitor current tap value
    .DATAIN(buf_data_rr),        // Unused if using IDATAIN
    .IDATAIN(1'b0),
    .DATAOUT(raw_data_out),
    .EN_VTC(1'b0),
    .INC(1'b0),
    .LOAD(ld),
    .RST(reset)
  );
  (* IODELAY_GROUP = IODELAY_GROUP_NAME, SIM_DEVICE = "ULTRASCALE_PLUS" *)
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
  (* IODELAY_GROUP = IODELAY_GROUP_NAME, SIM_DEVICE = "ULTRASCALE_PLUS" *)
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
  // The output is optionally inverted by init_pol.
  assign data_out = (pol) ? ~raw_data_out : raw_data_out;
  
  
  
  
  parameter TAPS = 512;             // tap: 512
  parameter PATTERN_WIDTH = 31;       // pattern length
  // ----------------------
  // state machine
  localparam IDLE          = 3'd0;
  localparam WAIT_EDGE     = 3'd1;
  localparam MEASURE       = 3'd2;
  localparam VERIFY        = 3'd3;
  localparam NEXT_TAP      = 3'd4;
  localparam FINISH        = 3'd5;
  (*mark_debug = "true"*)reg [2:0] state, next_state;
  
    // tap index
  (*mark_debug = "true"*)reg [8:0] current_tap;
  // cycle count for raw_signal 1 from clock_edge
  (*mark_debug = "true"*)reg [7:0] delay_cycle_cnt;
  (*mark_debug = "true"*)reg [PATTERN_WIDTH-1:0] pattern_reg;
  (*mark_debug = "true"*)reg [3:0] pattern_count;
  (*mark_debug = "true"*)reg [7:0] tap_delay [0:TAPS-1]; 
  (*mark_debug = "true"*)reg       tap_good  [0:TAPS-1];
  // 最終的な選択tap
  (*mark_debug = "true"*)reg [8:0] final_tap;
  
   always @(posedge clk) begin
//   always @(posedge clk or posedge reset) begin
          if (reset) begin
             state <= IDLE;
//             current_tap <= 0;
//             done <= 0;
             delay_cycle_cnt <= 0;
//             pattern_reg <= 0;
             pattern_count <= 0;
          end else begin
             state <= next_state;
             buf_data_r <= buf_data;
             buf_data_rr <= buf_data_r;
             
    //         // 状態に応じた内部カウンタの更新は下記の別ブロックで行う
    //      end
    //  end
    //  // 次状態ロジック
    //  always @(*) begin
          next_state = state;
          case (state)
             IDLE: begin
                if (start)
                  next_state = WAIT_EDGE;
             end
             WAIT_EDGE: begin
                // clock_edge発生で測定開始
                if (clock_edge && all_zero)
                  next_state = MEASURE;
             end
             MEASURE: begin
                // raw_signal 1 → VERIFY
                if (data_out)
                    next_state = VERIFY;
                // もし次のclock_edgeが来た場合、まだ1が立っていなければ再挑戦（同じtapで再測定）
                else if (clock_edge)
                    next_state = WAIT_EDGE; // tapは変えず測定リセット
                else
                    next_state = MEASURE; // 継続中
             end
             VERIFY: begin
                // PATTERN_WIDTH分raw_signalをシフトレジスタに取り込み
                if (pattern_count >= PATTERN_WIDTH-1)
                  next_state = NEXT_TAP;
                else
                  next_state = VERIFY;
             end
             NEXT_TAP: begin
                // tapの結果を記録後、tapインクリメント
                if (current_tap == TAPS-1)
                  next_state = FINISH;
                else
                  next_state = WAIT_EDGE;
             end
             FINISH: begin
                next_state = FINISH;
             end
             default: next_state = IDLE;
          endcase
      end
  end
              integer i;
              reg[9:0] good_count;
              reg[9:0] good_count_r;
              reg [8:0] max_tap;
  // 内部カウンタおよび出力の更新
  always @(posedge clk or posedge reset) begin
      if (reset) begin
          delay_cycle_cnt <= 0;
          pattern_reg <= 0;
          pattern_count <= 0;
          current_tap <= 0;
          current_idelay <= 0;
              final_tap <= 0;
      end else begin
         good_count_r <= good_count;
         case (state)
           IDLE: begin
              // 初期化
              current_idelay <= 0;
              final_tap <= 0;
              delay_cycle_cnt <= 0;
              pattern_reg <= 0;
              pattern_count <= 0;
              done <= 0;
              good_count <= 0;
              max_tap <= 0;
           end
           WAIT_EDGE: begin
              // clock_edgeで測定開始時、カウンタとパターンリセット
              delay_cycle_cnt <= 0;
              pattern_reg <= 0;
              pattern_count <= 0;
           end
           MEASURE: begin
              // 毎クロック delay_cycle_cntをカウント
              delay_cycle_cnt <= delay_cycle_cnt + 1;
              pattern_reg <= {pattern_reg[PATTERN_WIDTH-2:0], data_out};
              pattern_count <= 1;
           end
           VERIFY: begin
              // raw_signalの値をシフトレジスタに取り込み、パターンを構築
              pattern_reg <= {pattern_reg[PATTERN_WIDTH-2:0], data_out};
              pattern_count <= pattern_count + 1;
           end
           NEXT_TAP: begin
              // tapごとに、もしraw_signalが1でかつパターンが正しいならgoodとして記録
              if (pattern_reg == EXPECTED_PATTERN)
                begin
                 tap_good[current_tap] <= 1;
                 good_count <= good_count+1;
                end else begin
                 tap_good[current_tap] <= 0;
                end
              current_idelay <= current_idelay+1;
              tap_delay[current_tap] <= delay_cycle_cnt;
              current_tap <= current_tap + 1;
              // counter reset
              delay_cycle_cnt <= 0;
              pattern_reg <= 0;
              pattern_count <= 0;
           end
           FINISH: begin
              // 複数のtap結果から最終delayを決定する（例：すべてgoodなら中央値、悪い場合は最大値）
              
              if (good_count_r == TAPS)
                 final_tap <= TAPS/2;
              else if (good_count_r > 0)
                 final_tap <= max_tap;
              else
                 final_tap <= 0;
                 
              delay_val <= final_tap;
              current_idelay <= final_tap;
              done <= 1;
           end
           default: ;
         endcase
      end
  end
  

  // ---------------------------------------------------------------
  // Delay Adjustment Control:
  // Drive IDELAYE3's delay_inc (and CE) until the physical delay equals current_idelay.
  // internal_delay simulates the current tap value.
  // ---------------------------------------------------------------
//  reg [8:0] internal_delay; // Simulated current delay tap value.
//  always @(posedge clk or posedge reset) begin
//    if (reset) begin
//      internal_delay <= DEFAULT_DELAY;
//      inc_ce <= 1'b0;
//      delay_inc <= 1'b0;
//    end else if (special_state == 4'b1000) begin  // Normal mode active
//      if (internal_delay < current_idelay) begin
//        inc_ce <= 1'b1;
//        delay_inc <= 1'b1;
//        internal_delay <= internal_delay + 1;
//      end else begin
//        inc_ce <= 1'b0;
//        delay_inc <= 1'b0;
//      end
//    end else begin
//      inc_ce <= 1'b0;
//      delay_inc <= 1'b0;
//    end
//  end
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
      if (check_delay_master != current_idelay) begin
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
  // (Optional) Additional logic to drive the physical IDELAYE3 based on current_idelay can be added here.
endmodule
