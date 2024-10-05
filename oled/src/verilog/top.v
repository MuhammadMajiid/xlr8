`timescale 1ns / 1ps

module top(
    input  clock, //100MHz onboard clock
    input  reset,
    //oled interface
    output oled_spi_clk,
    output oled_spi_data,
    output oled_vdd,
    output oled_vbat,
    output oled_reset_n,
    output oled_dc_n
  );


  localparam myString = "Hello THERE     I AM MOHAMED    ITS OLED DEMO   WITH VERILOG HDL";
  localparam StringLen = 64;

  reg [1:0] state;
  reg [7:0] sendData;
  reg sendDataValid;
  integer byteCounter;
  wire sendDone;

  localparam IDLE = 'd0,
             SEND = 'd1,
             DONE = 'd2;

  always @(posedge clock)
  begin
    if(reset)
    begin
      state <= IDLE;
      byteCounter <= StringLen;
      sendDataValid <= 1'b0;
    end
    else
    begin
      case(state)
        IDLE:
        begin
          if(!sendDone)
          begin
            sendData <= myString[(byteCounter*8-1)-:8];
            sendDataValid <= 1'b1;
            state <= SEND;
          end
        end
        SEND:
        begin
          if(sendDone)
          begin
            sendDataValid <= 1'b0;
            byteCounter <= byteCounter-1;
            if(byteCounter != 1)
              state <= IDLE;
            else
              state <= DONE;
          end
        end
        DONE:
        begin
          state <= DONE;
        end
      endcase
    end
  end


  oled_cntrl # (
    .CLK_FREQ(100_000_000),
    .NEW_FREQ(500)
  )
  oled_cntrl_inst (
    .i_clk(clock),
    .i_arst_n(!reset),
    .data(sendData),
    .data_valid(sendDataValid),
    .done(sendDone),
    .o_oled_vdd(oled_vdd),
    .o_oled_vbat(oled_vbat),
    .o_oled_rst_n(oled_reset_n),
    .o_oled_dc_n(oled_dc_n),
    .o_oled_sclk(oled_spi_clk),
    .o_oled_sdin(oled_spi_data)
  );

endmodule