`timescale 1ns/1ns;
module tb_top();

// Parameters
parameter CLKPER = 10;
// Interface
reg  clock; //100MHz onboard clock
reg  reset;
//oled interface
wire oled_spi_clk;
wire oled_spi_data;
wire oled_vdd;
wire oled_vbat;
wire oled_reset_n;
wire oled_dc_n;

// DUT
top dut (.*);

// initialization
initial begin
    reset    = 1'b1;
    clock       = 1'b0;
end

// Clock Generation
always #(CLKPER/2) clock = ~clock; 

// Test
initial begin
    @(negedge clock);
    reset    = 1'b0;
end

endmodule