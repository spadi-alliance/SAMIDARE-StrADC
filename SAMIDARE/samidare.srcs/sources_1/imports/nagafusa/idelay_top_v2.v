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
  (*mark_debug = "true"*) output wire [10:0] SO0_out, // Channel 0 delayed output
  (*mark_debug = "true"*) output wire [10:0] SO1_out, // Channel 1 delayed output
  (*mark_debug = "true"*) output wire [10:0] SO2_out, // Channel 2 delayed output
  (*mark_debug = "true"*) output wire [10:0] SO3_out, // Channel 3 delayed output
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



  wire [10:0]out_buf0;
  wire [10:0]out_buf1;
  wire [10:0]out_buf2;
  wire [10:0]out_buf3;

//  assign ready = 1'b1;
assign ready = done;
//  assign trg_en = 1'b0;

  
///*
  reg init_r;
  
  always @(posedge clk ) begin
    init_r <= init;
  end
  wire reset;
  wire reset_ref;
  wire reset_ref2;
  assign reset = !areset;
  assign reset_ref = !areset_ref;
  assign reset_ref2 = !areset_ref2;

  
// IDELAYCTRL should be set with "TIME" mode.
// it is not necessary when using "COUNT" mode, using TAP value 
//  (* IODELAY_GROUP="SO0", SIM_DEVICE="ULTRASCALE" *)//BANK66
//  IDELAYCTRL IDELAYCTRL_inst0(
//    .RDY(idelay_rdy0),
//    .REFCLK(idelay_refclk),
//    .RST(reset_ref)
//  );

//  (* IODELAY_GROUP="SO1_2", SIM_DEVICE="ULTRASCALE" *)//BANK65
//  IDELAYCTRL IDELAYCTRL_inst1_2(
//    .RDY(idelay_rdy1_2),
//    .REFCLK(idelay_refclk2),
//    .RST(reset_ref2)
//  );


//  (* IODELAY_GROUP="SO3", SIM_DEVICE="ULTRASCALE" *)//BANK64
//  IDELAYCTRL IDELAYCTRL_inst3(
//    .RDY(idelay_rdy3),
//    .REFCLK(idelay_refclk2),
//    .RST(reset_ref2) //active high
//  );


  // Instantiate idelay_impl modules for each channel.W
  
  //pol: reversed channel
  parameter [10:0] pol0 =11'b111_0000_0010;//10,9,8,1
  parameter [10:0] pol1 =11'b001_0001_1010;//8,4,3,1
  parameter [10:0] pol2 =11'b010_0010_0001;//9,5,0
  parameter [10:0] pol3 =11'b101_1111_0101;//10,8,7,6,5,4,2,0
  parameter [43:0] pol = {pol3, pol2, pol1, pol0};
  
  parameter  [9:0]  init_pol = 10'b10_1011_0101;
  parameter [30:0] init_pattern_p = 31'b1010_1010_1100_1100_1010_1010_1100_110;
//  parameter [30:0] init_pattern_p = 31'b011_0011_0101_0101_0011_0011_0101_0101;
  
  parameter [30:0] init_pattern_n = 31'b1010_1010_0110_0110_1010_1010_0110_011;
//  parameter [30:0] init_pattern_n = 31'b110_0110_0101_0101_0110_0110_0101_0101;
  wire [3:0]  clock_adj_done;
  wire clock_adj_start;
  wire signal_adj_start;
  wire [39:0]  signal_adj_done;
  
  wire[10:0] SO_bus_p[3:0];
  wire[10:0] SO_bus_n[3:0];
  wire[10:0] SO_bus_out[3:0];
  
  
  (*mark_debug = "true"*)reg  [3:0] allzero;
  wire [3:0] clock_edge;
  reg  [3:0] clk_prev;
  
  
  assign clock_edge[0] = SO_bus_out[0][10]&(~clk_prev[0]);
  assign clock_edge[1] = SO_bus_out[1][10]&(~clk_prev[1]);
  assign clock_edge[2] = SO_bus_out[2][10]&(~clk_prev[2]);
  assign clock_edge[3] = SO_bus_out[3][10]&(~clk_prev[3]);
  
  assign SO0_out = SO_bus_out[0][10:0];
  assign SO1_out = SO_bus_out[1][10:0];
  assign SO2_out = SO_bus_out[2][10:0];
  assign SO3_out = SO_bus_out[3][10:0];
  always @(posedge clk or posedge reset) begin
    if (reset) 
        begin
            clk_prev <= 4'b0000;
            allzero <= 4'b0000;
        end else 
        begin
            clk_prev[0] <= SO_bus_out[0][10];
            clk_prev[1] <= SO_bus_out[1][10];
            clk_prev[2] <= SO_bus_out[2][10];
            clk_prev[3] <= SO_bus_out[3][10];
            
            
            allzero[0] <=  &(~SO_bus_out[0][9:0]);
            allzero[1] <=  &(~SO_bus_out[1][9:0]);
            allzero[2] <=  &(~SO_bus_out[2][9:0]);
            allzero[3] <=  &(~SO_bus_out[3][9:0]);
  
        end
    end
    
    
    
  
  assign SO_bus_p[0] = SO0_p;
  assign SO_bus_p[1] = SO1_p;
  assign SO_bus_p[2] = SO2_p;
  assign SO_bus_p[3] = SO3_p;
  assign SO_bus_n[0] = SO0_n;
  assign SO_bus_n[1] = SO1_n;
  assign SO_bus_n[2] = SO2_n;
  assign SO_bus_n[3] = SO3_n;
  
  
  parameter [1:0] IODELAY_GROUP_BUS ={2'b0,2'b01,2'b01,2'b10};
  genvar i,sampaID;
  generate

    for(sampaID = 0; sampaID < 4;sampaID = sampaID + 1)begin : gen_SAMPAx
      
        // SAMPLING CLOCK adjustment
        idelay_impl_v2 #(
          .IODELAY_GROUP_NAME(IODELAY_GROUP_BUS[sampaID]),
          .IODELAY_GROUP_ID(IODELAY_GROUP_BUS[sampaID])
        ) u_idelay_impl_clock (
          .clk(clk),
          .reset(reset),
          .init(clock_adj_start),
          .pol(pol[sampaID*11 + 10]),
          .data_in_p(SO_bus_p[sampaID][10]),
          .data_in_n(SO_bus_n[sampaID][10]),
          .data_out(SO_bus_out[sampaID][10]),
          .adjust_done(clock_adj_done[sampaID])
        );

        for (i = 0; i < 10; i = i + 1) begin : gen_signal
            if(init_pol[i])begin
                idelay_impl_v2_normal #(
                  .IODELAY_GROUP_NAME(IODELAY_GROUP_BUS[sampaID]),
                  .IODELAY_GROUP_ID(IODELAY_GROUP_BUS[sampaID]),
                  .EXPECTED_PATTERN(init_pattern_p)//pos init pattern
                ) 
                    u_idelay_impl_signal (
                      .clk(clk),
                      .reset(reset),
                      .start(signal_adj_start),
                      .clock_edge(clock_edge[sampaID]),
                      .pol(pol[sampaID * 11 + i]),
                      .all_zero(allzero[sampaID]),
                      .raw_signal_p(SO_bus_p[sampaID][i]),
                      .raw_signal_n(SO_bus_n[sampaID][i]),
                      .done(signal_adj_done[sampaID*10 + i]),
                      .delayed_signal(SO_bus_out[sampaID][i])
                    );
                end else begin
                    idelay_impl_v2_normal #(
                      .IODELAY_GROUP_NAME(IODELAY_GROUP_BUS[sampaID]),
                      .IODELAY_GROUP_ID(IODELAY_GROUP_BUS[sampaID]),
                      .EXPECTED_PATTERN(init_pattern_n) // neg init pattern
                    ) 
                    u_idelay_impl_signal (
                      .clk(clk),
                      .reset(reset),
                      .start(signal_adj_start),
                      .clock_edge(clock_edge[sampaID]),
                      .pol(pol[sampaID * 11 + i]),
                      .all_zero(allzero[sampaID]),
                      .raw_signal_p(SO_bus_p[sampaID][i]),
                      .raw_signal_n(SO_bus_n[sampaID][i]),
                      .done(signal_adj_done[sampaID*10 + i]),
                      .delayed_signal(SO_bus_out[sampaID][i])
                    );
                end//init_pol
          end // for i
      end// for sampaID
    endgenerate

   wire done;
//   assign done = &signal_adj_done;
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
//*/
endmodule
