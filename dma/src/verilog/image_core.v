module image_core #(parameter DWIDTH = 32)
(
    /* Global Signals */
    input  wire i_arst_n,
    input  wire i_clk,

    /* Slave Interface */
    input  wire [DWIDTH-1:0] s_axis_data,
    input  wire s_axis_valid,
    output wire s_axis_ready,

    /* Master Interface */
    output reg  [DWIDTH-1:0] m_axis_data,
    output reg  m_axis_valid,
    input  wire m_axis_ready
);

integer i;

always @(posedge i_clk) begin
    if (s_axis_valid & s_axis_ready) begin
        for (i=0; i<(DWIDTH/8) ; i=i+1) begin
            m_axis_data[i*8+:8] <= 255 - s_axis_data[i*8+:8];
        end
    end
end

always @(posedge i_clk) begin
    m_axis_valid <= s_axis_valid;
end

assign s_axis_ready = m_axis_ready;

endmodule