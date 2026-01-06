// idelay_top.v
// (Plain Verilog‑2001 version)
module idelay_top_v2 (
  input  wire clk,
  input wire idelay_refclk, // 300MHz for idelayctrl
  input wire idelay_refclk2, // 300MHz for idelayctrl
  input  wire areset, // active low, 320MHz
  input  wire areset_ref, // active low, 300MHz
  input  wire areset_ref2, // active low, 300MHz
  input  wire init,   // Trigger from AXI-lite/BRAM indicating register value change
  input  wire [10:0] SO0_p,   // Channel 0 input
  input  wire [10:0] SO0_n,   // Channel 0 input
  input  wire [10:0] SO1_p,   // Channel 1 input
  input  wire [10:0] SO1_n,   // Channel 1 input
  input  wire [10:0] SO2_p,   // Channel 2 input
  input  wire [10:0] SO2_n,   // Channel 2 input
  input  wire [10:0] SO3_p,   // Channel 3 input
  input  wire [10:0] SO3_n,   // Channel 3 input
  (*mark_debug = "true"*)output wire [10:0] SO0_out, // Channel 0 delayed output
  (*mark_debug = "true"*)output wire [10:0] SO1_out, // Channel 1 delayed output
  (*mark_debug = "true"*)output wire [10:0] SO2_out, // Channel 2 delayed output
  (*mark_debug = "true"*)output wire [10:0] SO3_out, // Channel 3 delayed output
  output wire [3:0] overall_state, // Overall aggregated state (one-hot)
  // AXI-lite interface from idelay_controller:
  input  wire [3:0] S_AXI_ARADDR,
  input  wire S_AXI_ARVALID,
  output wire S_AXI_ARREADY,
  output wire [31:0] S_AXI_RDATA,
  output wire [1:0] S_AXI_RRESP,
  output wire S_AXI_RVALID,
  input  wire S_AXI_RREADY,
  output wire ready,
  output wire trg_en
);



//============================================================================
//
//2025/04/14 wire from ibufds cannot be routed properly, so through this module




  parameter [10:0] pol0 =11'b11100000010;//10,9,8,1
  parameter [10:0] pol1 =11'b00100011010;//8,4,3,1
  parameter [10:0] pol2 =11'b01000100001;//9,5,0
  parameter [10:0] pol3 =11'b10111110101;//10,8,7,6,5,4,2,0

  wire [10:0]out_buf0;
  wire [10:0]out_buf1;
  wire [10:0]out_buf2;
  wire [10:0]out_buf3;

  assign ready = 1'b1;
  assign trg_en = 1'b0;
  genvar i;
  generate    
    for (i = 0; i < 11; i = i + 1) begin : gen_SO0
          begin : signal_inst
            IBUFDS #(
                .IOSTANDARD("SLVS_400_18")
              )u_ibufds(
                .O(out_buf0[i]),
                .I(SO0_p[i]),
                .IB(SO0_n[i])
              );       
          end
          assign SO0_out[i] = (pol0[i])?!out_buf0[i]:out_buf0[i];
    end
  endgenerate
  
  generate    
    for (i = 0; i < 11; i = i + 1) begin : gen_SO1
          begin : signal_inst
            IBUFDS #(
                .IOSTANDARD("SLVS_400_18")
              )u_ibufds(
                .O(out_buf),
                .I(SO1_p[i]),
                .IB(SO1_n[i])
              );       
      end
          assign SO1_out[i] = (pol1[i])?!out_buf1[i]:out_buf1[i];
    end
  endgenerate
  generate    
    for (i = 0; i < 11; i = i + 1) begin : gen_SO2
          begin : signal_inst
            IBUFDS #(
                .IOSTANDARD("SLVS_400_18")
              )u_ibufds(
                .O(out_buf),
                .I(SO2_p[i]),
                .IB(SO2_n[i])
              );       
      end
          assign SO2_out[i] = (pol2[i])?!out_buf2[i]:out_buf2[i];
    end
  endgenerate
  generate    
    for (i = 0; i < 11; i = i + 1) begin : gen_SO3
          begin : signal_inst
            IBUFDS #(
                .IOSTANDARD("SLVS_400_18")
              )u_ibufds(
                .O(out_buf),
                .I(SO3_p[i]),
                .IB(SO3_n[i])
              );       
      end
          assign SO3_out[i] = (pol3[i])?!out_buf3[i]:out_buf3[i];
    end
  endgenerate
/*
  reg init_r;
  
  always @(posedge clk ) begin
    init_r <= init;
  end
  wire reset;
  wire reset_ref;
  wire reset_ref2;
  assign reset = ~areset;
  assign reset_ref = ~areset_ref;
  assign reset_ref2 = ~areset_ref2;

  

//  (* IODELAY_GROUP="SO0", SIM_DEVICE="ULTRASCALE" *)//BANK66
  IDELAYCTRL IDELAYCTRL_inst0(
    .RDY(idelay_rdy0),
    .REFCLK(idelay_refclk),
    .RST(reset_ref)
  );
////  (* IODELAY_GROUP="SO0", SIM_DEVICE="ULTRASCALE" *)//BANK66
//  IDELAYCTRL IDELAYCTRL_inst02(
//    .RDY(idelay_rdy0),
//    .REFCLK(idelay_refclk),
//    .RST(reset_ref)
//  );

//  (* IODELAY_GROUP="SO1_2", SIM_DEVICE="ULTRASCALE" *)//BANK65
  IDELAYCTRL IDELAYCTRL_inst1_2(
    .RDY(idelay_rdy1_2),
    .REFCLK(idelay_refclk2),
    .RST(reset_ref2)
  );

////  (* IODELAY_GROUP="SO1_2", SIM_DEVICE="ULTRASCALE" *)//BANK65
//  IDELAYCTRL IDELAYCTRL_inst1_22(
//    .RDY(idelay_rdy1_2),
//    .REFCLK(idelay_refclk),
//    .RST(reset_ref)
//  );

//  (* IODELAY_GROUP="SO3", SIM_DEVICE="ULTRASCALE" *)//BANK64
  IDELAYCTRL IDELAYCTRL_inst3(
    .RDY(idelay_rdy3),
    .REFCLK(idelay_refclk2),
    .RST(reset_ref2) //active high
  );

////  (* IODELAY_GROUP="SO3", SIM_DEVICE="ULTRASCALE" *)//BANK64
//  IDELAYCTRL IDELAYCTRL_inst32(
//    .RDY(idelay_rdy32),
//    .REFCLK(idelay_refclk),
//    .RST(reset_ref) //active high
//  );

  // Instantiate idelay_impl modules for each channel.W
  
  //pol: reversed channel
  parameter [10:0] pol0 =11'b111_0000_0010;//10,9,8,1
  parameter [10:0] pol1 =11'b001_0001_1010;//8,4,3,1
  parameter [10:0] pol2 =11'b010_0010_0001;//9,5,0
  parameter [10:0] pol3 =11'b101_1111_0101;//10,8,7,6,5,4,2,0
  parameter  [9:0]  init_pol = 10'b10_1011_0101;
  //parameter [30:0] init_pattern_p = 31'b1010_1010_1100_1100_1010_1010_1100_110;
  parameter [30:0] init_pattern_p = 31'b011_0011_0101_0101_0011_0011_0101_0101;
  
  //parameter [30:0] init_pattern_n = 31'b1010_1010_0110_0110_1010_1010_0110_011;
  parameter [30:0] init_pattern_n = 31'b110_0110_0101_0101_0110_0110_0101_0101;
  wire [3:0]  clock_adj_done;
  wire [39:0]  signal_adj_done;
  
  // SAMPLING CLOCK adjustment
  // For channel 0:
    idelay_impl_v2 #(
      .IODELAY_GROUP_NAME("SO0")
    ) u_idelay_impl_SO0 (
      .clk(clk),
      .reset(reset),
      .init(clk_adj_start),
      .pol(pol0[10]),
      .data_in_p(SO0_p[10]),
      .data_in_n(SO0_n[10]),
      .data_out(SO0_out[10]),
      .adjust_done(clock_adj_done[0])
    );
  // For channel 1:
    idelay_impl_v2 #(
      .IODELAY_GROUP_NAME("SO1_2")
    ) u_idelay_impl_SO1 (
      .clk(clk),
      .reset(reset),
      .init(clk_adj_start),
      .pol(pol1[10]),
      .data_in_p(SO1_p[10]),
      .data_in_n(SO1_n[10]),
      .data_out(SO1_out[10]),
      .adjust_done(clock_adj_done[1])
    );
  // For channel 2:
    idelay_impl_v2 #(
      .IODELAY_GROUP_NAME("SO1_2")
    ) u_idelay_impl_SO2 (
      .clk(clk),
      .reset(reset),
      .init(clk_adj_start),
      .pol(pol2[10]),
      .data_in_p(SO2_p[10]),
      .data_in_n(SO2_n[10]),
      .data_out(SO2_out[10]),
      .adjust_done(clock_adj_done[2])
    );
  // For channel 3:
    idelay_impl_v2 #(
      .IODELAY_GROUP_NAME("SO3")
    ) u_idelay_impl_SO3 (
      .clk(clk),
      .reset(reset),
      .init(clk_adj_start),
      .pol(pol3[10]),
      .data_in_p(SO3_p[10]),
      .data_in_n(SO3_n[10]),
      .data_out(SO3_out[10]),
      .adjust_done(clock_adj_done[3])
    );
  
  wire [3:0] allzero;
  wire [3:0] clock_edge;
  reg  [3:0] clk_prev;
  assign allzero[0] =  ~(&SO0_out[9:0]);
  assign allzero[1] =  ~(&SO1_out[9:0]);
  assign allzero[2] =  ~(&SO2_out[9:0]);
  assign allzero[3] =  ~(&SO3_out[9:0]);
  
  assign clock_edge[0] = SO0_out[10]&(~clk_prev[0]);
  assign clock_edge[1] = SO1_out[10]&(~clk_prev[1]);
  assign clock_edge[2] = SO2_out[10]&(~clk_prev[2]);
  assign clock_edge[3] = SO3_out[10]&(~clk_prev[3]);
  
  always @(posedge clk or posedge reset) begin
    if (reset) 
        begin
            clk_prev <= 4'b0000;
        end else 
        begin
            clk_prev[0] <= SO0_out[10];
            clk_prev[1] <= SO1_out[10];
            clk_prev[2] <= SO2_out[10];
            clk_prev[3] <= SO3_out[10];
        end
    end
  genvar i;
  generate
    for (i = 0; i < 10; i = i + 1) begin : gen_SO0
    
      begin : signal_inst
      if(init_pol[i]==1'b1)
        begin
            idelay_impl_v2_normal #(
          .IODELAY_GROUP_NAME("SO0"),
          .EXPECTED_PATTERN(init_pattern_p)
        ) 
            u_idelay_impl_SO0 (
              .clk(clk),
              .reset(reset),
              .start(signal_adj_start),
              .clock_edge(clock_edge[0]),
              .pol(pol0[i]),
              .all_zero(all_zero0),
              .raw_signal_p(SO0_p[i]),
              .raw_signal_n(SO0_n[i]),
//              .clk_edge(SO0_out[i]),
//              .init_pattern(init_pattern_p),
              .done(signal_adj_done[i+10*0]),
              .delayed_signal(SO0_out[i])
            );
            end else begin
            idelay_impl_v2_normal #(
          .IODELAY_GROUP_NAME("SO0"),
          .EXPECTED_PATTERN(init_pattern_n)
        ) 
            u_idelay_impl_SO0 (
              .clk(clk),
              .reset(reset),
              .start(signal_adj_start),
              .clock_edge(clock_edge[0]),
              .pol(pol0[i]),
              .all_zero(all_zero0),
              .raw_signal_p(SO0_p[i]),
              .raw_signal_n(SO0_n[i]),
//              .init_pattern(init_pattern_n),
              .done(signal_adj_done[i+10*0]),
              .delayed_signal(SO0_out[i])
            );
            end
      end
    end
  endgenerate

  // For channel 1:
  generate
    for (i = 0; i < 10; i = i + 1) begin : gen_SO1
      begin : signal_inst
      if(init_pol[i]==1'b1)
        begin
            idelay_impl_v2_normal #(
          .IODELAY_GROUP_NAME("SO1_2"),
          .EXPECTED_PATTERN(init_pattern_p)
        ) 
            u_idelay_impl_SO1 (
              .clk(clk),
              .reset(reset),
              .start(signal_adj_start),
              .clock_edge(clock_edge[1]),
              .pol(pol1[i]),
              .all_zero(all_zero1),
              .raw_signal_p(SO1_p[i]),
              .raw_signal_n(SO1_n[i]),
//              .clk_edge(SO1_out[i]),
//              .init_pattern(init_pattern_p),
              .done(signal_adj_done[i+10*1]),
              .delayed_signal(SO1_out[i])
            );
            end else begin
            idelay_impl_v2_normal #(
          .IODELAY_GROUP_NAME("SO1_2"),
          .EXPECTED_PATTERN(init_pattern_n)
        ) 
            u_idelay_impl_SO1 (
              .clk(clk),
              .reset(reset),
              .start(signal_adj_start),
              .clock_edge(clock_edge[1]),
              .pol(pol1[i]),
              .all_zero(all_zero1),
              .raw_signal_p(SO1_p[i]),
              .raw_signal_n(SO1_n[i]),
//              .init_pattern(init_pattern_n),
              .done(signal_adj_done[i+10*1]),
              .delayed_signal(SO1_out[i])
            );
            end
      end
    end
  endgenerate

  // For channel 2:
  generate
    for (i = 0; i < 10; i = i + 1) begin : gen_SO2
      begin : signal_inst
      if(init_pol[i]==1'b1)
        begin
            idelay_impl_v2_normal #(
          .IODELAY_GROUP_NAME("SO1_2"),
          .EXPECTED_PATTERN(init_pattern_p)
        ) 
            u_idelay_impl_SO2 (
              .clk(clk),
              .reset(reset),
              .start(signal_adj_start),
              .clock_edge(clock_edge[1]),
              .pol(pol2[i]),
              .all_zero(all_zero2),
              .raw_signal_p(SO2_p[i]),
              .raw_signal_n(SO2_n[i]),
//              .clk_edge(SO2_out[i]),
//              .init_pattern(init_pattern_p),
              .done(signal_adj_done[i+10*2]),
              .delayed_signal(SO2_out[i])
            );
            end else begin
            idelay_impl_v2_normal #(
          .IODELAY_GROUP_NAME("SO1_2"),
          .EXPECTED_PATTERN(init_pattern_n)
        ) 
            u_idelay_impl_SO2 (
              .clk(clk),
              .reset(reset),
              .start(signal_adj_start),
              .clock_edge(clock_edge[2]),
              .pol(pol2[i]),
              .all_zero(all_zero1),
              .raw_signal_p(SO2_p[i]),
              .raw_signal_n(SO2_n[i]),
//              .init_pattern(init_pattern_n),
              .done(signal_adj_done[i+10*2]),
              .delayed_signal(SO2_out[i])
            );
            end
      end
    end
  endgenerate

  // For channel 3:  generate
  generate
    for (i = 0; i < 10; i = i + 1) begin : gen_SO3
      begin : signal_inst
      if(init_pol[i]==1'b1)
        begin
            idelay_impl_v2_normal #(
          .IODELAY_GROUP_NAME("SO3"),
          .EXPECTED_PATTERN(init_pattern_p)
        ) 
            u_idelay_impl_SO3 (
              .clk(clk),
              .reset(reset),
              .start(signal_adj_start),
              .clock_edge(clock_edge[3]),
              .pol(pol3[i]),
              .all_zero(all_zero3),
              .raw_signal_p(SO3_p[i]),
              .raw_signal_n(SO3_n[i]),
//              .clk_edge(SO3_out[i]),
//              .init_pattern(init_pattern_p),
              .done(signal_adj_done[i+10*3]),
              .delayed_signal(SO3_out[i])
            );
            end else begin
            idelay_impl_v2_normal #(
          .IODELAY_GROUP_NAME("SO3"),
          .EXPECTED_PATTERN(init_pattern_n)
        ) 
            u_idelay_impl_SO3 (
              .clk(clk),
              .reset(reset),
              .start(signal_adj_start),
              .clock_edge(clock_edge[3]),
              .pol(pol3[i]),
              .all_zero(all_zero3),
              .raw_signal_p(SO3_p[i]),
              .raw_signal_n(SO3_n[i]),
//              .init_pattern(init_pattern_n),
              .done(signal_adj_done[i+10*3]),
              .delayed_signal(SO3_out[i])
            );
            end
      end
    end
  endgenerate
        assign all_zero0 = !(&SO0_out[9:0]);
        assign all_zero1 = !(&SO1_out[9:0]);
        assign all_zero2 = !(&SO2_out[9:0]);
        assign all_zero3 = !(&SO3_out[9:0]);

   
   wire done;
   assign done = &signal_adj_done;
   idelay_controller_v2 controller_inst (
         .clk              (clk),
         .reset            (reset),
         .init             (init_r),
         .clock_adj_start  (clock_adj_start),
         .clock_adj_done   (clock_adj_done),
         .signal_adj_start (signal_adj_start),
         .signal_adj_done  (signal_adj_done),
         .trg_en           (trg_en),
         .done             (done)
       );
*/
endmodule
