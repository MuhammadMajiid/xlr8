/*
    Author: Mohamed Maged
    Description: Simple SPI Controller for ZedBoard OLED.
    Version: v1.0
    Date: 20/5/2024
*/

module spi_cntrl (
    input wire clk,       // System Clock 100MHz
    input wire arst_n,    // Active Low Reset
    input wire [7:0] din, // Data to be sent
    input wire din_valid, // Valid Flag

    output wire sclk,     // SPI Clock 10MHz MAX
    output reg sdin,     // Serial SPI output
    output reg sdone     // Done Flag
  );

  // SPI Clock Generation
  reg [2:0] tck_cnt;
  reg spi_clk;
  always @(posedge clk, negedge arst_n)
  begin
    if (~arst_n)
    begin
      spi_clk  <= 1'b1;
      tck_cnt  <= 3'b0;
    end
    else
    begin
      if (tck_cnt == 4)
      begin
        spi_clk <= ~spi_clk;
        tck_cnt <= 3'b0;
      end
      else
      begin
        tck_cnt <= tck_cnt + 3'b1;
      end
    end
  end

  // SPI Transmission FSM
  localparam IDLE = 'd0,
             SEND = 'd1,
             DONE = 'd2;
  reg [1:0] state;
  reg [7:0] din_reg;
  reg [2:0] ser_cnt_reg;
  reg clk_en;
  always @(negedge spi_clk, negedge arst_n)
  begin
    if (~arst_n)
    begin
      state  <= IDLE;
      din_reg     <= 8'b0;
      ser_cnt_reg <= 3'b0;
      clk_en <= 1'b0;
      sdin <= 1'b1;
      sdone <= 1'b0;
    end
    else
    begin
      case (state)
        IDLE:
        begin
          if(din_valid)
          begin
            din_reg <= din;
            state <= SEND;
            ser_cnt_reg <= 3'b0;
          end
        end
        SEND:
        begin
          sdin <= din_reg[7];
          din_reg <= {din_reg[6:0],1'b0};
          clk_en <= 1;
          if(ser_cnt_reg != 7)
            ser_cnt_reg <= ser_cnt_reg + 1;
          else
          begin
            state <= DONE;
          end
        end
        DONE:
        begin
          clk_en <= 0;
          sdone <= 1'b1;
          if(!din_valid)
          begin
            sdone <= 1'b0;
            state <= IDLE;
          end
        end
      endcase
    end
  end

  // output
  assign sclk = (clk_en)? spi_clk : 1'b1;

endmodule
