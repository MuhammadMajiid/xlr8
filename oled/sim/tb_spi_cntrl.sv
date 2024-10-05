`timescale 1ns/1ns;
module tb_spi_cntrl();

// Parameters
parameter CLKPER = 10;
// Interface
logic arst_n;    // Active Low Reset
logic clk;       // System Clock 100MHz
logic [7:0] din; // Data to be sent
logic din_valid; // Valid Flag

logic sclk;      // SPI Clock 10MHz MAX
logic sdin;      // Serial SPI 
logic sdone;     // Done Flag

// DUT
spi_cntrl dut (.*);

// initialization
initial begin
    arst_n    = 1'b0;
    clk       = 1'b0;
    din_valid = 1'b0;
    din       = 8'b0;
end

// Clock Generation
always #(CLKPER/2) clk = ~clk; 

// Test
initial begin
    @(negedge clk);
    arst_n    = 1'b1;
    din       = 8'hAB;
    din_valid = 1'b1;
    @(posedge sdone) begin
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);

        @(negedge clk);
        @(negedge clk);
        din_valid = 1'b0;
        #(10*CLKPER);
        @(negedge clk);
        din       = 8'hCD;
        din_valid = 1'b1;
    end
end

endmodule