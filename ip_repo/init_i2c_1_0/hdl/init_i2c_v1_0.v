
`timescale 1 ns / 1 ps

	module init_i2c_v1_0 #
	(
		// Users to add parameters here
        parameter  TARGET_ADDRESS = 32'h00005000,
        parameter  TXN_TIMING     = 28'h000_0000,
        
		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Master Bus Interface M00_AXI
		parameter  C_M00_AXI_START_DATA_VALUE	= 32'hAA000000,
		parameter  C_M00_AXI_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,
		parameter integer C_M00_AXI_ADDR_WIDTH	= 32,
		parameter integer C_M00_AXI_DATA_WIDTH	= 32,
		parameter integer C_M00_AXI_TRANSACTIONS_NUM	= 4
	)
	(
		// Users to add ports here
        (*mark_debug = "true"*) output wire init_i2c_wr,
        (*mark_debug = "true"*) output wire init_i2c_rd,

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
		(*mark_debug = "true"*)output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_araddr,
		output wire [2 : 0] m00_axi_arprot,
		output wire  m00_axi_arvalid,
		input wire  m00_axi_arready,
		input wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_rdata,
		input wire [1 : 0] m00_axi_rresp,
		input wire  m00_axi_rvalid,
		output wire  m00_axi_rready
	);
	(*mark_debug = "true"*)wire[31:0] init_i2c;
//	(*mark_debug = "true"*)reg [31:0] init_i2c_reg;
//	assign init_i2c = init_i2c_reg;
// Instantiation of Axi Bus Interface M00_AXI
	SAMPA_REGREAD_v1_0_M00_AXI # ( 
	    .TARGET_ADDRESS(TARGET_ADDRESS),
		.C_M_START_DATA_VALUE(C_M00_AXI_START_DATA_VALUE),
		.C_M_TARGET_SLAVE_BASE_ADDR(C_M00_AXI_TARGET_SLAVE_BASE_ADDR),
		.C_M_AXI_ADDR_WIDTH(C_M00_AXI_ADDR_WIDTH),
		.C_M_AXI_DATA_WIDTH(C_M00_AXI_DATA_WIDTH),
		.C_M_TRANSACTIONS_NUM(C_M00_AXI_TRANSACTIONS_NUM)
	) SAMPA_REGREAD_v1_0_M00_AXI_inst (
	    .REGVAL(init_i2c),
//		.INIT_AXI_TXN(m00_axi_init_axi_txn),
		.INIT_AXI_TXN(txn),
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

	// Add user logic here

	reg [31:0] cnt;
	(*mark_debug = "true"*) reg txn;
	always @(posedge m00_axi_aclk)                                                      
	  begin
	    cnt <= cnt+1;                                                                             
	    if (cnt[27:0]==TXN_TIMING)
	       txn <= 1'b1;
	    else
	       txn <= 1'b0;   
	    end  
	    
	(*mark_debug = "true"*)reg init_i2c_wr_r;
	(*mark_debug = "true"*)reg init_i2c_wr_rr;
	(*mark_debug = "true"*)reg init_i2c_rd_r;
	(*mark_debug = "true"*)reg init_i2c_rd_rr;
	always @(posedge m00_axi_aclk)                                                      
	  begin                 
//	    init_i2c_reg <= init_i2c;
	    init_i2c_wr_r  <= init_i2c[0];
	    init_i2c_wr_rr <= init_i2c_wr_r;
	    init_i2c_rd_r  <= init_i2c[1];
	    init_i2c_rd_rr <= init_i2c_rd_r;   
	  end
	assign init_i2c_wr = init_i2c_wr_r && !init_i2c_wr_rr;
	assign init_i2c_rd = init_i2c_rd_r && !init_i2c_rd_rr;
	// User logic ends

	endmodule
