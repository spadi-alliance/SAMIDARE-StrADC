module mii_initializer(
	// System
	CLK		,	// in : system clock (125M)
	RST		,	// in : system reset
	// PHY
	PHYAD		,	// in : [4:0] PHY address
	// MII
	MDC		,	// out: clock (1/128 system clock)
	MDIO_OUT	,	// out: connect this to "PCS/PMA + RocketIO" module .mdio?_i()
	// status
	COMPLETE		// out: initializing sequence has completed (active H)
);

	input				CLK		;
	input				RST		;
	input		[4:0]	PHYAD		;
	output			MDC		;
	output			MDIO_OUT	;
	output			COMPLETE	;

////////////////////////////////////////////////////////////////////////////////
// clock
	reg		[6:0]	cntMdc	;

`ifdef SIMULATE__
	initial begin
		cntMdc = 0;
	end
`endif

	always @ (posedge CLK) begin
		cntMdc <= cntMdc + 7'd1;
	end

	reg				MDC;
	always @ (posedge CLK) begin
		MDC <= cntMdc[6];
	end

	wire			gShiftDataEn = (cntMdc[6:0] == 7'd0);

////////////////////////////////////////////////////////////////////////////////
// reset states
	reg		[7:0]	cntResets;

	always @ (posedge CLK or posedge RST) begin
		if(RST) begin
			cntResets	<= 8'd0;
		end else if(gShiftDataEn) begin
			cntResets	<= cntResets + 8'd1;
		end
	end

	// waits 128 MDCs after RST before outputting MDIO_OUT
	reg				gWaitn;

	always @ (posedge CLK or posedge RST) begin
		if(RST) begin
			gWaitn	<= 1'd0;
		end else if(~gWaitn & cntResets[7]) begin
			gWaitn	<= 1'd1;
		end
	end

	// waits 128 (gWaitn) + 32 (MDIO_OUT) + 32 (margin) MDCs after RSTn before having COMPLETE stand
	reg				COMPLETE;

	always @ (posedge CLK or posedge RST) begin
		if(RST) begin
			COMPLETE <= 1'd0;
		end else if(~COMPLETE && (cntResets[7:5] == 3'b110)) begin
			COMPLETE <= 1'd1;
		end
	end

////////////////////////////////////////////////////////////////////////////////
// MDIO_OUT shifter
	reg		[32:0]	mdioData;

	always @ (posedge CLK or posedge RST) begin
		if(RST) begin
			mdioData[32:0] <= {
				1'b1					,// preamble
				2'b01					,// start opcode
				2'b01					,// write opcode
				PHYAD[4:0]			,// PHY address
				5'h0					,// register address
				2'b10					,// turn-around
				16'b0001_0001_0100_0000	 // control register
			};
		end else if(gWaitn & gShiftDataEn) begin
			mdioData[32:0] <= {mdioData[31:0], 1'b1};
		end
	end

	assign MDIO_OUT = mdioData[32];

endmodule
