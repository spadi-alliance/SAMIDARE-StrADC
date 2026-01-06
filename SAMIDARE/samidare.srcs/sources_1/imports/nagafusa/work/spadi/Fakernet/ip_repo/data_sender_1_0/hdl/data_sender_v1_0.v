module data_sender_v1_0 #(
    parameter DATA_W = 32
)(
    // -------------------------------------------------------------------------
    //  Clock / reset
    // -------------------------------------------------------------------------
    input  wire                 clk,
    input  wire                 rst,             // synchronous, active-high
    // -------------------------------------------------------------------------
    //  Upstream write request (single-cycle pulse)
    // -------------------------------------------------------------------------
    input  wire [DATA_W-1:0]    wr_data,
    input  wire                 wr_en,
    // -------------------------------------------------------------------------
    //  AXI-Stream *slave* side  (connect to FIFO.s_axis_*)
    // -------------------------------------------------------------------------
    output wire [DATA_W-1:0]    s_axis_tdata,
    output wire                 s_axis_tvalid,
    input  wire                 s_axis_tready,   // from FIFO
    // -------------------------------------------------------------------------
    //  Flow-control back to upstream
    // -------------------------------------------------------------------------
    input wire                  full,
    output wire                 busy             // 1 = cannot accept wr_en
);
    //============================================================================
    //  One-word buffer
    //============================================================================
    reg                 buf_valid;   // 1 = buffer holds unsent word
    reg [DATA_W-1:0]    buf_data;
    //--------------------------------------------------------------------------
    //  Write-side logic
    //--------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            buf_valid <= 1'b0;
            buf_data  <= {DATA_W{1'b0}};
        end
        else begin
            // Word transferred to FIFO this cycle?
            if (buf_valid && s_axis_tready)
                buf_valid <= 1'b0;
            // New write request?
            if (wr_en && !busy) begin
                buf_data  <= wr_data;
                buf_valid <= 1'b1;
            end
        end
    end
    //--------------------------------------------------------------------------
    //  AXI-Stream outputs
    //--------------------------------------------------------------------------
    assign s_axis_tdata  = buf_data;
    assign s_axis_tvalid = buf_valid;
    //--------------------------------------------------------------------------
    //  Upstream back-pressure
    //      busy = buffer already full
    //--------------------------------------------------------------------------
    assign busy = full;
endmodule