module data_receiver_v1_0 #(
    parameter DATA_W           = 32,
    parameter PAGE_SIZE        = 100,   // words per page
    parameter INACT_TIMEOUT    = 100,   // cycles without data => commit
    parameter PAGE_SIZE_LOG2   = 7      // ceil(log2(PAGE_SIZE))  (100→7)
)(
    // -------------------------------------------------------------------------
    //  Clock / reset
    // -------------------------------------------------------------------------
    input  wire                     clk,
    input  wire                     rst,        // synchronous, active-high
    // -------------------------------------------------------------------------
    //  AXI-Stream FROM FIFO
    // -------------------------------------------------------------------------
    input  wire [DATA_W-1:0]        m_axis_tdata,
    input  wire                     m_axis_tvalid,
    output wire                     m_axis_tready,
    // -------------------------------------------------------------------------
    //  Fakernet ports
    // -------------------------------------------------------------------------
    output reg  [DATA_W-1:0]        event_word,
    output reg  [9:0]               event_offset,
    output reg                      event_write,
    output reg                      event_commit,
    output reg  [10:0]              event_commit_len,
    input  wire                     event_free  
);
    reg busy;
    reg page_open;
    //==========================================================================
    //  Internal registers
    //==========================================================================
    reg  [PAGE_SIZE_LOG2:0] offset_cnt;       // counts written words (0-99)
    reg  [6:0]              idle_cnt;         // inactivity counter 0-99 (fits 7 bits)
    //==========================================================================
    //  AXIS handshake
    //==========================================================================
    //  Ready when Fakernet is not busy and we are NOT committing this cycle
    wire commit_now  = (offset_cnt == PAGE_SIZE) ||
                       (offset_cnt != 0 && idle_cnt == INACT_TIMEOUT);
    assign m_axis_tready = !busy && !commit_now;
    //==========================================================================
    //  Main sequential block
    //==========================================================================
    always @(posedge clk) begin
        if (rst) begin
            // reset everything
            event_word        <= 'b0;
            event_offset      <= 'b0;
            event_write       <= 1'b0;
            event_commit      <= 1'b0;
            event_commit_len  <= 'b0;
            offset_cnt        <= 0;
            idle_cnt          <= 0;
            busy <= 1'b0;
            page_open <= 1'b0;
        end
        else begin
        busy <= !page_open;// to be modified?
            //------------------------------------------------------------------
            //  Default: de-assert strobes
            //------------------------------------------------------------------
            event_write  <= 1'b0;
            event_commit <= 1'b0;
            //------------------------------------------------------------------
            //  Receive a word?
            //------------------------------------------------------------------
            if (m_axis_tvalid && m_axis_tready) begin
                // push word to Fakernet
                event_word   <= m_axis_tdata;
                event_offset <= offset_cnt;
                event_write  <= 1'b1;
                offset_cnt   <= offset_cnt + 1'b1;
                idle_cnt     <= 0;                // reset inactivity counter
            end
            else if (offset_cnt != 0) begin
                // no word but page in progress -> count idle cycles
                idle_cnt <= idle_cnt + 1'b1;
            end
            else begin
                idle_cnt <= 0;
            end
            //------------------------------------------------------------------
            //  Commit page?
            //------------------------------------------------------------------
            if (commit_now) begin
                page_open <= event_free;
                event_commit     <= 1'b1;
                event_commit_len <= offset_cnt;   // 1-based length
                offset_cnt       <= 0;            // start a new page
                idle_cnt         <= 0;
            end else if(event_free == 1)begin
                page_open <= 1'b1;
            end
        end
    end
endmodule