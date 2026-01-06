
`timescale 1 ns / 1 ps
//I2C controller for SAMPA
// BRAM <-> I2C Controller <-> SAMPA register
// users should set the all write addresses before init write
// write: all data written to BRAM is read, and written send to SAMPA
//      bram -- bram_rdata --> -- i2c_wdata --> SAMPA
// read:  all data is read from SAMPA and written to BRAM
//      SAMPA --> i2c_rdata --> -- bram_wdata --> bram
// BRAM address usage: 
// write address: write_bit| SAMPA HADD | SAMPA ADDRESS (ex.) 
// read  address: read_bit | SAMPA HADD | SAMPA ADDRESS (ex.)
	module I2C_Controller_v1_0 #
	(
		// Users to add parameters here
		parameter  C_SAMPA_REG_TEST	= 32'hAA000001,

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Master Bus Interface M00_AXI
		parameter  C_M00_AXI_START_DATA_VALUE	= 32'hAA000000,
		parameter  C_M00_AXI_TARGET_SLAVE_BASE_ADDR	= 32'hC0000000,
		parameter integer C_M00_AXI_ADDR_WIDTH	= 32,
		parameter integer C_M00_AXI_DATA_WIDTH	= 32,
		parameter integer C_M00_AXI_TRANSACTIONS_NUM	= 1,

		// Parameters of Axi Master Bus Interface M01_AXI
		parameter  C_M01_AXI_START_DATA_VALUE	= 32'hAA000000,
		parameter  C_M01_AXI_TARGET_SLAVE_BASE_ADDR	= 32'hC0000000,
		parameter integer C_M01_AXI_ADDR_WIDTH	= 32,
		parameter integer C_M01_AXI_DATA_WIDTH	= 32,
		parameter integer C_M01_AXI_TRANSACTIONS_NUM	= 1
	)
	(
		// Users to add ports here
        input wire start_i2c_read,
        input wire start_i2c_write,
//        input wire [31:0] i2c_waddr_i,
//        input wire [31:0] i2c_raddr_i,

//        output wire [31:0] i2c_rdata_o,
//        output wire i2c_done,
        output wire i2c_busy,

		// User ports ends
		// Do not modify the ports beyond this line

		// Ports of Axi Master Bus Interface M00_AXI
		input wire  m00_axi_init_axi_txn,
		output wire  m00_axi_error,
		output wire  m00_axi_txn_done,
		input wire  m00_axi_aclk,
		input wire  m00_axi_aresetn,
		output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_awaddr,
		output wire [2 : 0] m00_axi_awprot,
		output wire  m00_axi_awvalid,
		input wire  m00_axi_awready,
		output wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_wdata,
		output wire [C_M00_AXI_DATA_WIDTH/8-1 : 0] m00_axi_wstrb,
		output wire  m00_axi_wvalid,
		input wire  m00_axi_wready,
		input wire [1 : 0] m00_axi_bresp,
		input wire  m00_axi_bvalid,
		output wire  m00_axi_bready,
		output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_araddr,
		output wire [2 : 0] m00_axi_arprot,
		output wire  m00_axi_arvalid,
		input wire  m00_axi_arready,
		input wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_rdata,
		input wire [1 : 0] m00_axi_rresp,
		input wire  m00_axi_rvalid,
		output wire  m00_axi_rready,

		// Ports of Axi Master Bus Interface M01_AXI
		input wire  m01_axi_init_axi_txn,
		output wire  m01_axi_error,
		output wire  m01_axi_txn_done,
		input wire  m01_axi_aclk,
		input wire  m01_axi_aresetn,
		output wire [C_M01_AXI_ADDR_WIDTH-1 : 0] m01_axi_awaddr,
		output wire [2 : 0] m01_axi_awprot,
		output wire  m01_axi_awvalid,
		input wire  m01_axi_awready,
		output wire [C_M01_AXI_DATA_WIDTH-1 : 0] m01_axi_wdata,
		output wire [C_M01_AXI_DATA_WIDTH/8-1 : 0] m01_axi_wstrb,
		output wire  m01_axi_wvalid,
		input wire  m01_axi_wready,
		input wire [1 : 0] m01_axi_bresp,
		input wire  m01_axi_bvalid,
		output wire  m01_axi_bready,
		output wire [C_M01_AXI_ADDR_WIDTH-1 : 0] m01_axi_araddr,
		output wire [2 : 0] m01_axi_arprot,
		output wire  m01_axi_arvalid,
		input wire  m01_axi_arready,
		input wire [C_M01_AXI_DATA_WIDTH-1 : 0] m01_axi_rdata,
		input wire [1 : 0] m01_axi_rresp,
		input wire  m01_axi_rvalid,
		output wire  m01_axi_rready
	);
    // Instantiation of Axi Bus Interface M00_AXI
    wire [31:0] regacc_addr;
    reg  [31:0] regacc_addr_r;
    wire [31:0] bram_rdata;
    wire [31:0] bram_wdata;
    reg  [31:0] bram_rdata_r;
    reg  [31:0] bram_wdata_r;
    reg  regacc_write_r;
    reg  regacc_read_r;
    wire regacc_write;
    wire regacc_read;
    wire regacc_done;
    assign bram_wdata   = bram_wdata_r;
    assign regacc_addr  = regacc_addr_r; 
    assign regacc_write = regacc_write_r;
    assign regacc_read  = regacc_read_r;
	I2C_Controller_v1_0_M00_AXI # ( 
		.C_M_START_DATA_VALUE(C_M00_AXI_START_DATA_VALUE),
		.C_M_TARGET_SLAVE_BASE_ADDR(C_M00_AXI_TARGET_SLAVE_BASE_ADDR),
		.C_M_AXI_ADDR_WIDTH(C_M00_AXI_ADDR_WIDTH),
		.C_M_AXI_DATA_WIDTH(C_M00_AXI_DATA_WIDTH),
		.C_M_TRANSACTIONS_NUM(C_M00_AXI_TRANSACTIONS_NUM)
	) I2C_Controller_v1_0_M00_AXI_inst (
	   
//	    .bram_waddr(bram_waddr),//to be confirmed. not correct
//	    .bram_wdata(bram_wdata),
//	    .bram_raddr(bram_raddr),
//	    .bram_txn(init_txn_bram),//to be confirmed. not correct
//        .regacc_addr(regacc_addr),   //register access
        .regacc_addr        ({5'b00000,regacc_addr,2'b00}),// to be modified. address usage is not straightforward
        .regacc_data_rd(bram_rdata),
        .regacc_data_wr(bram_wdata),
        .regacc_write(regacc_write),
        .regacc_read(regacc_read),
        .regacc_done(regacc_done),
//        input wire [31:0] regacc_addr,
//        output wire [31:0] regacc_data_rd,
//        input wire [31:0] regacc_data_wr,
//        input wire regacc_write,
//        input wire regacc_read,
//        output wire regacc_done,
		.INIT_AXI_TXN(m00_axi_init_axi_txn),
		.ERROR(m00_axi_error),
		.TXN_DONE(m00_axi_txn_done),
		.M_AXI_ACLK(m00_axi_aclk),
		.M_AXI_ARESETN(m00_axi_aresetn),
		.M_AXI_AWADDR(m00_axi_awaddr),
		.M_AXI_AWPROT(m00_axi_awprot),
		.M_AXI_AWVALID(m00_axi_awvalid),
		.M_AXI_AWREADY(m00_axi_awready),
		.M_AXI_WDATA(m00_axi_wdata),
		.M_AXI_WSTRB(m00_axi_wstrb),
		.M_AXI_WVALID(m00_axi_wvalid),
		.M_AXI_WREADY(m00_axi_wready),
		.M_AXI_BRESP(m00_axi_bresp),
		.M_AXI_BVALID(m00_axi_bvalid),
		.M_AXI_BREADY(m00_axi_bready),
		.M_AXI_ARADDR(m00_axi_araddr),
		.M_AXI_ARPROT(m00_axi_arprot),
		.M_AXI_ARVALID(m00_axi_arvalid),
		.M_AXI_ARREADY(m00_axi_arready),
		.M_AXI_RDATA(m00_axi_rdata),
		.M_AXI_RRESP(m00_axi_rresp),
		.M_AXI_RVALID(m00_axi_rvalid),
		.M_AXI_RREADY(m00_axi_rready)
	);
wire [31:0] rdata;
// Instantiation of Axi Bus Interface M01_AXI
	I2C_Controller_v1_0_M01_AXI # ( 
		.C_M_START_DATA_VALUE(C_M01_AXI_START_DATA_VALUE),
		.C_M_TARGET_SLAVE_BASE_ADDR(C_M01_AXI_TARGET_SLAVE_BASE_ADDR),
		.C_M_AXI_ADDR_WIDTH(C_M01_AXI_ADDR_WIDTH),
		.C_M_AXI_DATA_WIDTH(C_M01_AXI_DATA_WIDTH),
		.C_M_TRANSACTIONS_NUM(C_M01_AXI_TRANSACTIONS_NUM)
	) I2C_Controller_v1_0_M01_AXI_inst (
		.I2C_WR(i2c_wr),
		.I2C_RD(i2c_rd),
		.WADDR(i2c_waddr),
		.RADDR(i2c_raddr),
		.WDATA(i2c_wdata),
		.RDATA(rdata),
		
		.INIT_AXI_TXN(m01_axi_init_axi_txn),//not used
		.ERROR(m01_axi_error),
		.TXN_DONE(m01_axi_txn_done),
		.M_AXI_ACLK(m01_axi_aclk),
		.M_AXI_ARESETN(m01_axi_aresetn),
		.M_AXI_AWADDR(m01_axi_awaddr),
		.M_AXI_AWPROT(m01_axi_awprot),
		.M_AXI_AWVALID(m01_axi_awvalid),
		.M_AXI_AWREADY(m01_axi_awready),
		.M_AXI_WDATA(m01_axi_wdata),
		.M_AXI_WSTRB(m01_axi_wstrb),
		.M_AXI_WVALID(m01_axi_wvalid),
		.M_AXI_WREADY(m01_axi_wready),
		.M_AXI_BRESP(m01_axi_bresp),
		.M_AXI_BVALID(m01_axi_bvalid),
		.M_AXI_BREADY(m01_axi_bready),
		.M_AXI_ARADDR(m01_axi_araddr),
		.M_AXI_ARPROT(m01_axi_arprot),
		.M_AXI_ARVALID(m01_axi_arvalid),
		.M_AXI_ARREADY(m01_axi_arready),
		.M_AXI_RDATA(m01_axi_rdata),
		.M_AXI_RRESP(m01_axi_rresp),
		.M_AXI_RVALID(m01_axi_rvalid),
		.M_AXI_RREADY(m01_axi_rready)
	);

	// Add user logic here
	
	//read sequence
//	parameter STATE_R_IDLE           = 5'd2;
	parameter STATE_R_RESET_TX_FIFO0 = 5'd3; //reset by setting status register. addr0x100, 02
	parameter STATE_R_RESET_TX_FIFO1 = 5'd4; //addr0x100, 04
	parameter STATE_R_WRITE_FIFO0    = 5'd5; //header
	parameter STATE_R_WRITE_FIFO1    = 5'd6; //body
	parameter STATE_R_WRITE_FIFO2    = 5'd7; //footer0
	parameter STATE_R_WRITE_FIFO3    = 5'd8; //footer1
	parameter STATE_R_SEND           = 5'd9; //status register
	parameter STATE_R_READ_STATUS    = 5'd10; //
	parameter STATE_R_READ_FIFO0     = 5'd11; //
	parameter STATE_R_WRITE_BRAM     = 5'd12; //
	parameter STATE_R_END            = 5'd13;
	//write sequence
//	parameter STATE_W_IDLE           = 5'd2;
	parameter STATE_W_RESET_TX_FIFO0 = 5'd14; //reset by setting status register
	parameter STATE_W_RESET_TX_FIFO1 = 5'd15;
	parameter STATE_W_WRITE_FIFO0    = 5'd16; //header
	parameter STATE_W_WRITE_FIFO1    = 5'd17; //address
	parameter STATE_W_READ_BRAM      = 5'd18; //address
	parameter STATE_W_WRITE_FIFO2    = 5'd19; //body
	parameter STATE_W_WRITE_FIFO3    = 5'd20; //footer
	parameter STATE_W_SEND           = 5'd21; //set status register
	parameter STATE_W_END            = 5'd22;
	
//	parameter STATE_WRITE_FIFO3    = 8'd9; //footer1
    parameter STATE_INIT      = 4'b0001;
    parameter STATE_IDLE      = 4'b0010;
    parameter STATE_WAIT_NEXT = 4'b0100;
    parameter STATE_READ      = 4'b1000;
    parameter STATE_WRITE     = 4'b1001;
    parameter STATE_READ_DONE = 4'b1010;
    parameter STATE_WRITE_DONE= 4'b1011;
    parameter STATE_CLEAR     = 4'b1100;
    
    parameter WCNT_MAX = 8'h2F;
    parameter RCNT_MAX = 8'h2F;
    parameter SCNT_MAX = 2'h03;
    
    (*mark_debug = "true"*) reg [3:0] state_bram;
    reg [31:0] timeout_cnt;
    reg end_read;
    reg can_read;
    reg start_bram_read;
    reg start_bram_write;
    reg start_reg_read_r;
    reg start_reg_write_r;
    reg start_reg_write_all_r;
    
    reg i2c_done_r;
    
    reg ack_data;
    
    wire i2c_txn_done;
    reg  i2c_txn_done_r;
    assign i2c_txn_done = !i2c_txn_done_r && m01_axi_txn_done;
    
    (*mark_debug = "true"*) reg [3:0] state_i2c;
//    (*mark_debug = "true"*) reg [3:0] state_write;
//    (*mark_debug = "true"*) reg [3:0] state_read;
    (*mark_debug = "true"*) reg [4:0] state_w_r;
    
    reg init_txn_bram;
    (*mark_debug = "true"*) reg i2c_wr;
    (*mark_debug = "true"*) reg i2c_rd;
//    (*mark_debug = "true"*) reg bram_read_done;
//    (*mark_debug = "true"*) reg bram_write_done;
    reg all_write_end;
    
    reg [31:0] bram_raddr; //bram read address. to be confirmed: the same with i2c_waddr?
    reg [31:0] i2c_waddr;  //bram write address, set by fnet
    reg [31:0] i2c_wdata;  // bram write data, set by bram
    reg [23:0] i2c_raddr;  // bram read address, set by fnet
    reg [7:0] bram_waddr_r;  // bram write data, set by bram
    reg [7:0] bram_raddr_r;  // bram read address, set by fnet
    reg [31:0] i2c_rdata;  // bram read data, read from SAMPA
    
    assign i2c_rdata_o = i2c_rdata;
    reg busy;
    reg [3:0] cnt;
    (*mark_debug = "true"*)reg [7:0] wcnt;// write address
    (*mark_debug = "true"*)reg [7:0] rcnt;// read  address
    (*mark_debug = "true"*)reg [1:0] scnt;// SAMPA number
    (*mark_debug = "true"*)reg [31:0] wait_cnt;
    (*mark_debug = "true"*)reg [3:0] trans_cnt;
    
    
    assign i2c_busy = busy;
    assign i2c_done = i2c_done_r;
    
    //assign m00_axi_init_axi_txn = init_txn_bram;
    
    //assign m01_axi_init_axi_txn = init_txn_i2c;
//    assign m01_axi_wdata = i2c_wdata;
//    assign m01_axi_awaddr = i2c_waddr;
    
//    assign m01_axi_araddr = i2c_raddr;
    
    //state machine
    // main
    //   |---subread (loop, include bram state)
    //    ---subwrite(loop, include bram state)
	  always @(posedge m00_axi_aclk)										      
	  begin                                                                        
//	    if (m00_axi_aresetn == 1'b0 || start_i2c_read == 1'b1)                                                   
	    if (m00_axi_aresetn == 1'b0)                                                   
	      begin                                            
	           // reset signals          
	           state_bram <= STATE_INIT;              
	           state_i2c  <= STATE_INIT;      
//	           state_read <= STATE_INIT;      
//	           state_write <= STATE_INIT;        
               state_w_r  <= STATE_INIT;
	           start_reg_read_r <= 1'b0;
               init_txn_bram <= 1'b0;
	      end                                                                       
	    else                                                                       
	      begin                                                                    

	        i2c_txn_done_r <= m01_axi_txn_done;
	                                
	                                             
	        case (state_i2c)//state machine for I2C                                                     
	          STATE_INIT:
	               begin
	                   state_i2c <= STATE_IDLE;
	                   start_bram_read <= 1'b0;
	                   ack_data <= 1'b0;
	                   i2c_done_r <= 1'b0;
	                   busy <= 1'b0;
	               end
	           STATE_IDLE:
	               begin
	                   if(start_i2c_write == 1'b1)// when start_reg_write == 1, start to write
	                       begin
	                           state_i2c <= STATE_WRITE;
                               wcnt <= 'b0;
                               scnt <= 'b0;
	                           busy <= 1'b1;
//	                           start_bram_read <= 1'b1;
//	                           bram_raddr <= i2c_waddr_i;
	                       end else
	                   if(start_i2c_read  == 1'b1)// when start_reg_read == 1, start to read
	                       begin
	                           state_i2c <= STATE_READ;
                               rcnt <= 'b0;
                               scnt <= 'b0;
	                           busy <= 1'b1;
	                           //start_bram_read <= 1'b1;
//	                           i2c_raddr <= i2c_raddr_i;
//	                           cnt <= 4'b1000;
	                       end 
	               end                                                                
	          STATE_WRITE:         
                   begin
                        if(state_w_r == STATE_W_WRITE_FIFO2 && i2c_txn_done==1'b1)
                            begin
                                wcnt <= wcnt + 1;
                            end
                            
                        if(wcnt==WCNT_MAX + 1 && scnt == SCNT_MAX)
                            begin
                               wcnt <= 'b0;
                               scnt <= 'b0;
                               state_i2c <= STATE_IDLE;
                            end else 
                        if(wcnt==WCNT_MAX + 1)
                            begin
                                scnt <= scnt + 1;
                                wcnt <= 'b0;
                            end
                   end                                          
	          STATE_READ:
                   begin
                        if(state_w_r == STATE_R_WRITE_FIFO2 && i2c_txn_done==1'b1)
                            begin
                                rcnt <= rcnt + 1;
                            end
                            
                        if(rcnt==RCNT_MAX + 1 && scnt == SCNT_MAX)
                            begin
                               rcnt <= 'b0;
                               scnt <= 'b0;
                               state_i2c <= STATE_IDLE;
                            end else 
                        if(rcnt==RCNT_MAX + 1)
                            begin
                                scnt <= scnt + 1;
                                rcnt <= 'b0;
                            end
                   end               
	        endcase//state_i2c
	        
	           
	        case (state_w_r) 
	        // i2c_wr, i2c_rd, state_w_r, cnt, start_bramr_read, start_bram_write
	             STATE_INIT:
	               begin
	                   state_w_r <= STATE_IDLE;
	                   i2c_wr  <= 1'b0;
	                   i2c_rd  <= 1'b0;
	                   cnt     <= 'b0;
	               end
                 STATE_IDLE           :
	               begin
	                   if(state_i2c == STATE_WRITE)
	                       begin
	                           i2c_wr    <= 1'b0;
	                           i2c_rd <= 1'b0;
	                           trans_cnt <= 4'd10;
	                           state_w_r <= STATE_W_RESET_TX_FIFO0;
	                   end else 
	                   if(state_i2c == STATE_READ)
	                       begin
	                           i2c_wr <= 1'b0;
	                           i2c_rd <= 1'b0;
	                           trans_cnt <= 4'd10;
	                           state_w_r <= STATE_R_RESET_TX_FIFO0;
	                   end
	               end
                 STATE_W_RESET_TX_FIFO0 : //reset by setting status register
	               begin
	                   if(trans_cnt!=4'd0)
	                       begin
	                           trans_cnt <= trans_cnt -4'd1;
	                       end else
	                   if(i2c_txn_done == 1'b1)
	                       begin
                               i2c_wr    <= 1'b0;
                               trans_cnt <= 4'd10;
                               state_w_r <= STATE_W_RESET_TX_FIFO1;
                           end else begin
	                           i2c_wr    <= 1'b1;
	                           i2c_waddr <= 32'h0100;
	                           i2c_wdata <= 32'h0002;
                           end
	               end
                 STATE_W_RESET_TX_FIFO1 :
	               begin
	                   if(trans_cnt!=4'd0)
	                       begin
	                           trans_cnt <= trans_cnt -4'd1;
	                       end else
	                   if(i2c_txn_done == 1'b1)
	                       begin
                               i2c_wr    <= 1'b0;
                               trans_cnt <= 4'd10;
                               state_w_r <= STATE_W_WRITE_FIFO0;
                           end else begin
                               i2c_wr <= 1'b1;
                               i2c_waddr <= 32'h0100;
                               i2c_wdata <= 32'h0004;
                           end
	               end
                 STATE_W_WRITE_FIFO0    : //header
	               begin
	                   if(trans_cnt!=4'd0)
	                       begin
	                           trans_cnt <= trans_cnt -4'd1;
	                       end else
	                   if(i2c_txn_done == 1'b1)
	                       begin
                               i2c_wr    <= 1'b0;
                               trans_cnt <= 4'd10;
                               start_bram_read <= 1'b0;
                               bram_raddr_r <= {scnt, wcnt[5:0]};
                               state_w_r <= STATE_W_READ_BRAM;
                           end else begin
                               i2c_wr <= 1'b1;
                               i2c_waddr <= 32'h0108;
                               i2c_wdata <= 32'h01f0;
                           end
	               end
	             STATE_W_READ_BRAM:
	               begin 
	               
	                   if(regacc_done == 1'b1)
	                       begin
	                           i2c_wr    <= 1'b0;
	                           regacc_read_r <= 1'b0;
                               trans_cnt <= 4'd10;
	                           state_w_r <= STATE_W_WRITE_FIFO1;//body
	                       end else
//	                   if(m00_axi_rvalid)
//	                       begin
//	                           regacc_rdata_r <= regacc_rdata;
//	                       end else
	                       begin
	                           regacc_read_r <= 1'b1;
	                           regacc_addr_r <= {2'b01,bram_raddr_r[7:0]};
	                           i2c_wr    <= 1'b0;
	                       end
	               end
                 STATE_W_WRITE_FIFO1    : //address
	               begin
	                   if(trans_cnt!=4'd0)
	                       begin
	                           trans_cnt <= trans_cnt -4'd1;
	                       end else
	                   if(i2c_txn_done == 1'b1)
	                       begin
//                               start_bram_read <= 1'b0;
	                           i2c_wr    <= 1'b0;
                               trans_cnt <= 4'd10;
	                           state_w_r <= STATE_W_WRITE_FIFO2;
	                       end else begin
                               i2c_wr    <= 1'b1;
                               i2c_waddr <= 32'h0108;
                               i2c_wdata <= {scnt, wcnt[5:0]};//some address should be skipped
//                               i2c_wdata <= bram_rdata;
	                       end
	                       
	               end
                 STATE_W_WRITE_FIFO2    : //body
	               begin
	                   if(trans_cnt!=4'd0)
	                       begin
	                           trans_cnt <= trans_cnt -4'd1;
	                       end else
	                   if(i2c_txn_done == 1'b1)
	                       begin
//                               start_bram_read <= 1'b0;
	                           i2c_wr    <= 1'b0;
                               trans_cnt <= 4'd10;
	                           state_w_r <= STATE_W_WRITE_FIFO3;
	                       end else begin
                               i2c_wr    <= 1'b1;
                               i2c_waddr <= 32'h0108;
                               i2c_wdata <= bram_rdata;
	                       end
	                   //write to FIFO
	               end
                 STATE_W_WRITE_FIFO3    : //footer
	               begin
	                   if(trans_cnt!=4'd0)
	                       begin
	                           trans_cnt <= trans_cnt -4'd1;
	                       end else
	                   if(i2c_txn_done == 1'b1)
	                       begin
                               i2c_wr    <= 1'b0;
                               trans_cnt <= 4'd10;
                               state_w_r <= STATE_W_SEND;
	                       end else begin
                               i2c_wr    <= 1'b1;
                               i2c_waddr <= 32'h0108;
                               i2c_wdata <= 32'h0200;
	                       end
	               end
                 STATE_W_SEND           : //set status register
	               begin
	                   if(trans_cnt!=4'd0)
	                       begin
	                           trans_cnt <= trans_cnt -4'd1;
	                       end else
	                   if(i2c_txn_done == 1'b1)
	                       begin
                               i2c_wr    <= 1'b0;
                               wait_cnt <= 'b0;
                               state_w_r <= STATE_W_END;
                           end else begin
                               i2c_wr <= 1'b1;
                               i2c_waddr <= 32'h0100;
                               i2c_wdata <= 32'h0005;
                           end
	               end
                 STATE_W_END            :
	               begin
	                   if(wait_cnt <= 32'd100000)
	                       begin
	                           wait_cnt <= wait_cnt+1;
                           end else
                           begin
                               i2c_wr <= 1'b0;
                               state_w_r <= STATE_IDLE;
                           end
	               end
	               
	               
                 STATE_R_RESET_TX_FIFO0 : //reset by setting control register
	               begin
	                   if(trans_cnt!=4'd0)
	                       begin
	                           trans_cnt <= trans_cnt -4'd1;
	                       end else
	                   if(i2c_txn_done == 1'b1)
	                       begin
	                           i2c_wr <= 1'b0;
                               trans_cnt <= 4'd10;
	                           state_w_r <= STATE_R_RESET_TX_FIFO1;
                           end else begin
                               i2c_wr    <= 1'b1;
                               i2c_waddr <= 32'h0100;
                               i2c_wdata <= 32'h0002;
                           end
	               end
                 STATE_R_RESET_TX_FIFO1 :
	               begin
	                   if(trans_cnt!=4'd0)
	                       begin
	                           trans_cnt <= trans_cnt -4'd1;
	                       end else
	                   if(i2c_txn_done == 1'b1)
	                       begin
	                           i2c_wr <= 1'b0;
                               trans_cnt <= 4'd10;
                               state_w_r <= STATE_R_WRITE_FIFO0;
	                       end else begin
                               i2c_wr    <= 1'b1;
                               i2c_waddr <= 32'h0100;
                               i2c_wdata <= 32'h0004;
	                       end
	               end
                 STATE_R_WRITE_FIFO0    : //header
	               begin
	                   if(trans_cnt!=4'd0)
	                       begin
	                           trans_cnt <= trans_cnt -4'd1;
	                       end else
	                   if(i2c_txn_done == 1'b1)
	                       begin
	                           i2c_wr <= 1'b0;
                               trans_cnt <= 4'd10;
                               state_w_r <= STATE_R_WRITE_FIFO1;
	                       end else begin
                               i2c_wr    <= 1'b1;
                               i2c_waddr <= 32'h0108;
                               i2c_wdata <= 32'h01f0;
	                       end
	               end
                 STATE_R_WRITE_FIFO1    : //address
	               begin
	                   if(trans_cnt!=4'd0)
	                       begin
	                           trans_cnt <= trans_cnt -4'd1;
	                       end else
	                   if(i2c_txn_done == 1'b1)
	                       begin
	                           i2c_wr <= 1'b0;
                               trans_cnt <= 4'd10;
                               state_w_r <= STATE_R_WRITE_FIFO2;
                           end else begin
                               i2c_wr    <= 1'b1;
                               i2c_waddr <= 32'h0108;
                               i2c_wdata <= {scnt, rcnt[5:0]};//address
                               bram_waddr_r <= {scnt, rcnt[5:0]};
                           end
	               end
                 STATE_R_WRITE_FIFO2    : //body
	               begin
	                   if(trans_cnt!=4'd0)
	                       begin
	                           trans_cnt <= trans_cnt -4'd1;
	                       end else
	                   if(i2c_txn_done == 1'b1)
	                       begin
	                           i2c_wr <= 1'b0;
                               trans_cnt <= 4'd10;
                               state_w_r <= STATE_R_WRITE_FIFO3;
                           end else begin
                               i2c_wr    <= 1'b1;
                               i2c_waddr <= 32'h0108;
                               i2c_wdata <= 32'h01f1;
                           end
	               end
                 STATE_R_WRITE_FIFO3    : //footer
	               begin
	                   if(trans_cnt!=4'd0)
	                       begin
	                           trans_cnt <= trans_cnt -4'd1;
	                       end else
	                   if(i2c_txn_done == 1'b1)
	                       begin
	                           i2c_wr <= 1'b0;
                               trans_cnt <= 4'd10;
                               state_w_r <= STATE_R_SEND;
                           end else begin
                               i2c_wr    <= 1'b1;
                               i2c_waddr <= 32'h0108;
                               i2c_wdata <= 32'h0201;
                           end
	               end
                 STATE_R_SEND           : 
	               begin
	                   if(trans_cnt!=4'd0)
	                       begin
	                           trans_cnt <= trans_cnt -4'd1;
	                       end else
	                   if(i2c_txn_done == 1'b1)
	                       begin
	                           i2c_wr <= 1'b0;
                               wait_cnt <= 'b0;
                               trans_cnt <= 4'd10;
                               state_w_r <= STATE_R_READ_FIFO0;
                           end else begin
                               i2c_wr    <= 1'b1;
                               i2c_waddr <= 32'h0100;
                               i2c_wdata <= 32'h0005;
                           end
	               end
                 STATE_R_READ_FIFO0    : 
	               begin
	                   if(wait_cnt <= 32'd100000)
	                       begin
	                           wait_cnt <= wait_cnt+1;
                           end else
                       if(m01_axi_rvalid == 1'b1)
                           begin
                                i2c_rd <= 1'b0;
                                i2c_rdata <= rdata;
                                bram_wdata_r <= rdata;
                                state_w_r <= STATE_R_WRITE_BRAM;
                           end else begin
                                i2c_rd <= 1'b1;
                                i2c_raddr <= 32'h010c;
                           end  
	               end
	             STATE_R_WRITE_BRAM://wait bram write done
	               begin
	                   if(regacc_done == 1'b1)
	                       begin
	                           regacc_write_r <= 1'b0;
	                           state_w_r <= STATE_R_END;
	                       end else
	                       begin
	                            regacc_write_r <= 1'b1;
 	                            regacc_addr_r <= {2'b10,bram_waddr_r[7:0]};
	                       end
	                   
	               end
                 STATE_R_END            :
	               begin
	                   state_w_r <= STATE_IDLE;
	               end
	             default:
	               begin
	                   state_w_r <= STATE_INIT;
	               end
	        endcase        
	        
	        
	        
//	        case (state_bram)//state machine for w/r reg from bram                                                  
//	          STATE_INIT:
//	               begin
//	                   state_bram <= STATE_IDLE;
//	                   regacc_read_r <= 1'b0;
//	                   regacc_write_r <= 1'b0;
//	               end
//	          STATE_IDLE://set read addr from bram
//	               begin
//	                   if(start_bram_read == 1'b1)// start reading from bram to send data to SAMPA
//	                       begin
//	                           regacc_read_r <= 1'b1;
//	                           regacc_addr_r <= {2'b01,bram_raddr_r[7:0]};
//	                           state_bram <= STATE_READ;
//	                       end 
//	                   if(start_bram_write == 1'b1)
//	                       begin
//	                           regacc_write_r <= 1'b1;
//	                           regacc_addr_r <= {2'b10,bram_waddr_r[7:0]};
//	                           state_bram <= STATE_WRITE;
//	                       end 
//	               end                                                               
//	          STATE_READ:// SAMPA <-- data <-- BRAM
//	               begin
//	                           regacc_read_r <= 1'b0;
//	                   if(regacc_done == 1'b1)//end of read
//	                       begin
//	                           state_bram <= STATE_READ_DONE;
//	                       end else 
//	                   if(m00_axi_rvalid==1'b1)
//	                       begin
////	                           bram_read_done <= 1'b1;
//	                       end
//	               end
//	           STATE_READ_DONE: 
//	               begin
//	                   if(state_w_r == STATE_W_WRITE_FIFO2) 
//	                       begin
//	                           state_bram <= STATE_IDLE;
//	                       end
//	               end
//	           STATE_WRITE:// SAMPA --> data --> BRAM
//	               begin
//	                   regacc_write_r <= 1'b0;
//	                   if(regacc_done == 1'b1)
//	                       begin
//	                           state_bram <= STATE_WRITE_DONE;
//	                       end 
//	               end
//               STATE_WRITE_DONE:
//                   begin
//	                   if(state_w_r == STATE_R_END) 
//	                       begin
//	                           state_bram <= STATE_IDLE;
//	                       end
//                   end
//               STATE_CLEAR:
//                    begin
//	                   regacc_write_r <= 1'b0;
//	                   if(regacc_done == 1'b1)
//	                       begin
//	                           state_bram <= STATE_WRITE_DONE;
//	                       end 
                        
//                    end
//	        endcase//state_read    
	                                       
	      end                                                        
	  end                                        
    
	// User logic ends

	endmodule
