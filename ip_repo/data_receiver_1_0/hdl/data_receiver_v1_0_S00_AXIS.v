
`timescale 1 ns / 1 ps

	module data_receiver_v1_0_S00_AXIS #
	(
		// Users to add parameters here
		parameter integer C_S_AXIS_TDATA_DEPTH	= 32,

		// User parameters ends
		// Do not modify the parameters beyond this line

		// AXI4Stream sink: Data Width
		parameter integer C_S_AXIS_TDATA_WIDTH	= 32
	)
	(
		// Users to add ports here
        output wire event_commit,
        output wire [10:0] event_commit_len,
        output wire event_write,
        output wire [9:0] event_offset,
        output wire [31:0] event_word,
        input wire event_free,

		// User ports ends
		// Do not modify the ports beyond this line

		// AXI4Stream sink: Clock
		input wire  S_AXIS_ACLK,
		// AXI4Stream sink: Reset
		input wire  S_AXIS_ARESETN,
		// Ready to accept data in
		output wire  S_AXIS_TREADY,
		// Data in
		input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
		// Byte qualifier
		input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB,
		// Indicates boundary of last packet
		input wire  S_AXIS_TLAST,
		// Data is in valid
		input wire  S_AXIS_TVALID
	);
	// function called clogb2 that returns an integer which has the 
	// value of the ceiling of the log base 2.
	function integer clogb2 (input integer bit_depth);
	  begin
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
	      bit_depth = bit_depth >> 1;
	  end
	endfunction

	// Total number of input data.
	localparam NUMBER_OF_INPUT_WORDS  = C_S_AXIS_TDATA_DEPTH;
	// bit_num gives the minimum number of bits needed to address 'NUMBER_OF_INPUT_WORDS' size of FIFO.
	localparam bit_num  = clogb2(NUMBER_OF_INPUT_WORDS-1);
	// Define the states of state machine
	// The control state machine oversees the writing of input streaming data to the FIFO,
	// and outputs the streaming data from the FIFO
	parameter [1:0] IDLE = 1'b0,        // This is the initial/idle state 

	                WRITE  = 1'b1; // In this state 
	                               // input stream data S_AXIS_TDATA 
	wire  	axis_tready;
	// State variable
	reg mst_exec_state;  
	// FIFO implementation signals
	genvar byte_index;     
	// FIFO write enable
	wire wren;
	// FIFO full flag
	reg fifo_full_flag;
	// FIFO write pointer
	reg [bit_num-1:0] write_pointer;
	// sink has accepted all the streaming data and stored in FIFO
	  reg writes_done;
	// I/O Connections assignments

	assign S_AXIS_TREADY	= axis_tready;
	// Control state machine implementation
	always @(posedge S_AXIS_ACLK) 
	begin  
	  if (!S_AXIS_ARESETN) 
	  // Synchronous reset (active low)
	    begin
	      mst_exec_state <= IDLE;
	    end  
	  else
	    case (mst_exec_state)
	      IDLE: 
	        // The sink starts accepting tdata when 
	        // there tvalid is asserted to mark the
	        // presence of valid streaming data 
	          if (S_AXIS_TVALID)
	            begin
	              mst_exec_state <= WRITE;
	            end
	          else
	            begin
	              mst_exec_state <= IDLE;
	            end
	      WRITE: 
	        // When the sink has accepted all the streaming input data,
	        // the interface swiches functionality to a streaming master
	        if (writes_done)
	          begin
	            mst_exec_state <= IDLE;
	          end
	        else
	          begin
	            // The sink accepts and stores tdata 
	            // into FIFO
	            mst_exec_state <= WRITE;
	          end

	    endcase
	end
	// AXI Streaming Sink 
	// 
	// The example design sink is always ready to accept the S_AXIS_TDATA  until
	// the FIFO is not filled with NUMBER_OF_INPUT_WORDS number of input words.
//	assign axis_tready = ((mst_exec_state == WRITE_FIFO) && (write_pointer <= NUMBER_OF_INPUT_WORDS-1));
	assign axis_tready = ((mst_exec_state == WRITE)&&event_free==1);

	always@(posedge S_AXIS_ACLK)
	begin
	  if(!S_AXIS_ARESETN)
	    begin
	      write_pointer <= 0;
	      writes_done <= 1'b0;
	    end  
	  else
	    if (write_pointer <= NUMBER_OF_INPUT_WORDS-1)
	      begin
	        if (wren)
	          begin
	            // write pointer is incremented after every write to the FIFO
	            // when FIFO write signal is enabled.
	            write_pointer <= write_pointer + 1;
	            writes_done <= 1'b0;
	          end
	          if ((write_pointer == NUMBER_OF_INPUT_WORDS-1)|| S_AXIS_TLAST)
	            begin
	              // reads_done is asserted when NUMBER_OF_INPUT_WORDS numbers of streaming data 
	              // has been written to the FIFO which is also marked by S_AXIS_TLAST(kept for optional usage).
	              writes_done <= 1'b1;
	            end
	      end  
	end

	// FIFO write enable generation
	assign wren = S_AXIS_TVALID && axis_tready;

//	// FIFO Implementation
//	generate 
//	  for(byte_index=0; byte_index<= (C_S_AXIS_TDATA_WIDTH/8-1); byte_index=byte_index+1)
//	  begin:FIFO_GEN

//	    reg  [(C_S_AXIS_TDATA_WIDTH/4)-1:0] stream_data_fifo [0 : NUMBER_OF_INPUT_WORDS-1];

//	    // Streaming input data is stored in FIFO

//	    always @( posedge S_AXIS_ACLK )
//	    begin
//	      if (wren)// && S_AXIS_TSTRB[byte_index])
//	        begin
//	          stream_data_fifo[write_pointer] <= S_AXIS_TDATA[(byte_index*8+7) -: 8];
//	        end  
//	    end  
//	  end		
//	endgenerate




	// Add user logic here
	
	parameter [1:0] STATE_IDLE = 2'b00;        // This is the initial/idle state 
	parameter [1:0] STATE_SEND = 2'b01;        // This is the initial/idle state 
	parameter [1:0] STATE_REST = 2'b10;        // This is the initial/idle state 

    reg [1:0] bus_sel;                        // sel index of bus0 to bus3
    reg [10:0] data_length;                   // data length
    reg [3:0] sample_cnt;                   // data length
    (*mark_debuig = "true"*)reg [2:0] state;            
    
    wire bus_ready;   
    reg rd_en_r;
    reg data_ack_r;
    reg last_ack_r;
    reg busy_r;
    reg event_commit_r;
    reg [10:0] event_commit_len_r;
    reg event_write_r;
    reg [9:0] event_offset_r;
    reg [31:0] event_word_r;
    
    assign event_commit     = event_commit_r;
    assign event_commit_len = event_commit_len_r;
    assign event_write      = event_write_r;
    assign event_offset     = event_offset_r;
    assign event_word       = event_word_r;
    assign data_ack = data_ack_r;
    assign last_ack = last_ack_r;
    assign busy = busy_r;
    reg last_data_r;
    (*mark_debug = "true"*)reg [9:0] rest_counter;
    assign rd_en = rd_en_r;
    // init
    initial begin
        state = IDLE;
        data_length = 11'd0;
        rd_en_r = 1'b0;
            busy_r <= 1'b0;
    end
    reg [15:0]send_counter;
    wire clk = S_AXIS_ACLK;
    wire rstn = S_AXIS_ARESETN;
    always @(posedge clk) begin
        if (!rstn) begin
            state <= STATE_IDLE;
            data_length <= 11'd0;
        end else begin
//            event_commit <= 1'b0;
            case (state)
                STATE_IDLE: begin
//                    if (event_free & bus_ready) begin
//                    if (event_free & data_wr) begin
                        send_counter <= 'b0;
                        rest_counter <= 'b0;
                    if (wren) begin
                        state <= STATE_SEND;
                        data_length <= data_length + 11'd1;
                        event_offset_r <= data_length[9:0] + 10'd1;      // 
                        event_write_r <= 1'b1;
                        event_commit_r <= 1'b0;
                        event_commit_len_r <= 11'b0;
                        event_word_r <= S_AXIS_TDATA;
                        
                    end else begin
                        state <= STATE_IDLE;
                        data_length <= 11'd0;
                        event_offset_r <= 11'd0;      // 
                        event_write_r <= 1'b0;
                        event_commit_r <= 1'b0;
                        event_commit_len_r <= 11'b0;
                        
                    end
                end
                STATE_SEND: begin
                        rest_counter <= 'b0;
                   if(writes_done)begin
                        state <= STATE_REST;
                        send_counter <= 'b0;
                        data_length <= data_length + 11'd1;
                        event_offset_r <= data_length[9:0] + 10'd1;      // 
                        event_write_r <= 1'b1;
                        event_commit_r <= 1'b1;
                        event_commit_len_r <= data_length;
                        event_word_r <= S_AXIS_TDATA;
                    end else begin
                        if(send_counter<31) begin
                            state <= STATE_SEND;
                            send_counter <= send_counter+1;
                            data_length <= data_length + 11'd1;
                            event_offset_r <= data_length[9:0] + 10'd1;      // 
                            event_write_r <= 1'b1;
                            event_commit_r <= 1'b0;
                            event_commit_len_r <= 11'b0;
                            event_word_r <= S_AXIS_TDATA;
                        end else if(send_counter==31) begin
                            state <= STATE_REST;
                            send_counter <= 'b0;
                            data_length <= data_length + 11'd1;
                            event_offset_r <= data_length[9:0] + 10'd1;      // 
                            event_write_r <= 1'b1;
                            event_commit_r <= 1'b1;
                            event_commit_len_r <= data_length;
                            event_word_r <= S_AXIS_TDATA;
                        end
                    end
                end
                STATE_REST: begin
                        rest_counter <= rest_counter +1;
                        send_counter <= 'b0;
                        if(rest_counter>31)begin
                            state <= STATE_IDLE;
                            rest_counter <= 'b0;
                            data_length <= 11'd0;
                            event_offset_r <= 11'd0;      // 
                            event_write_r <= 1'b0;
                            event_commit_r <= 1'b0;
                            event_commit_len_r <= 11'b0;
                        end
                    end
                default: state <= IDLE;
            endcase
        end
    end
    
    assign data_o = event_word;
	// User logic ends

	endmodule
