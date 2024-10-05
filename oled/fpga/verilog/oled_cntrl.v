/*
    Author: @MuhammadMajiid
    Date: 20/5/2024
    Version: v1.0
    Description: OLED Cotroller for ZedBoard
*/

module oled_cntrl #(
    parameter CLK_FREQ = 100_000_000,
    parameter NEW_FREQ = 500
  )
  (
    input wire i_clk,
    input wire i_arst_n,
    input wire [6:0] data,
    input wire data_valid,
    input wire data_command_n,
    output reg done,

    // Oled Interface
    output reg o_oled_vdd,
    output reg o_oled_vbat,
    output reg o_oled_rst_n,
    output reg o_oled_dc_n,
    output wire o_oled_sclk,
    output wire o_oled_sdin
  );

  wire [63:0] oled_data;
  wire delay;
  wire spi_done;
  reg spi_vdata;
  reg [7:0] spi_data;
  reg [3:0] byte_cnt;
  reg del_en;
  reg [3:0] state, state_nxt;
  localparam IDLE = 'd0,
             DISP_OFF = 'd1,
             DELAY = 'd2,
             RM_RESET = 'd3,
             CHARGE_PUMP0 = 'd4,
             CHARGE_PUMP1 = 'd5,
             PRE_CHARGE0 = 'd6,
             PRE_CHARGE1 = 'd7,
             SPI_DEL = 'd8,
             DISP_ON = 'd9,
             DONE = 'd10,
             SEND = 'd11;

/* 
    Power Up Sequence:
      - Power up Vdd & Vbat
      - Delay
      - Send Display OFF Command
      - Reset the Circuit
      - Delay
      - Set Charge Pump & Pre Charge to the right values
      - Send Display ON Command
    Power Down Sequence:
      - Send Display OFF Command
      - Power OFF the circuit.
*/

  always @(posedge i_clk, negedge i_arst_n)
  begin
    if (!i_arst_n)
    begin
      state <= IDLE;
      state_nxt <= IDLE;
      o_oled_vdd <= 1'b1;
      o_oled_vbat <= 1'b1;
      o_oled_rst_n <= 1'b1;
      o_oled_dc_n <= 1'b1;
      del_en <= 1'b0;
      spi_data <= 8'h00;
      spi_vdata <= 1'b0;
      done <= 1'b0;
      byte_cnt <= 4'd0;
    end
    else
    begin
      case (state)
        IDLE :
        begin
          o_oled_vdd <= 1'b0;
          o_oled_vbat <= 1'b0;
          o_oled_rst_n <= 1'b1;
          o_oled_dc_n <= 1'b0;
          del_en <= 1'b0;
          state <= DELAY;
          state_nxt <= DISP_OFF;
        end

        DELAY :
        begin
          del_en <= 1'b1;
          if (delay)
          begin
            state  <= state_nxt;
            del_en <= 1'b0;
          end
        end

        DISP_OFF :
        begin
          spi_data <= 8'hAE;
          spi_vdata <= 1'b1;
          if (spi_done)
          begin
            spi_vdata <= 1'b0;
            o_oled_rst_n <= 1'b0;
            state <= DELAY;
            state_nxt <= RM_RESET;
          end
        end

        RM_RESET :
        begin
          o_oled_rst_n <= 1'b1;
          state <= DELAY;
          state_nxt <= CHARGE_PUMP0;
        end

        CHARGE_PUMP0 :
        begin
          spi_data <= 8'h8D;
          spi_vdata <= 1'b1;
          if (spi_done)
          begin
            spi_vdata <= 1'b0;
            state <= SPI_DEL;
            state_nxt <= CHARGE_PUMP1;
          end
        end

        CHARGE_PUMP1 :
        begin
          spi_data <= 8'h14;
          spi_vdata <= 1'b1;
          if (spi_done)
          begin
            spi_vdata <= 1'b0;
            state <= SPI_DEL;
            state_nxt <= PRE_CHARGE0;
          end
        end

        SPI_DEL :
        begin
          if (!spi_done)
          begin
            state <= state_nxt;
          end
        end

        PRE_CHARGE0 :
        begin
          spi_data <= 8'hD9;
          spi_vdata <= 1'b1;
          if (spi_done)
          begin
            spi_vdata <= 1'b0;
            state <= SPI_DEL;
            state_nxt <= PRE_CHARGE1;
          end
        end

        PRE_CHARGE1 :
        begin
          spi_data <= 8'hF1;
          spi_vdata <= 1'b1;
          if (spi_done)
          begin
            spi_vdata <= 1'b0;
            state <= SPI_DEL;
            state_nxt <= DISP_ON;
          end
        end

        DISP_ON :
        begin
          spi_data <= 8'hAF;
          spi_vdata <= 1'b1;
          if (spi_done)
          begin
            spi_vdata <= 1'b0;
            state <= SPI_DEL;
            state_nxt <= DONE;
          end
        end

        /*
          -------- Initialization Ends --------
        */

        /* 
            External Control: SW Drivers or another top module...
        */

        DONE :
        begin
          done <= 1'b0;
          spi_vdata <= data_valid;
          o_oled_dc_n <= data_command_n;
          if (data_valid)
          begin
            state <= SEND;
          end
          byte_cnt <= 4'd8;
        end

        SEND :
        begin
          if (o_oled_dc_n)
          begin
            spi_data <= oled_data[(byte_cnt*8-1)-:8];
            spi_vdata <= data_valid;
            o_oled_dc_n <= 1'b1;
            if(spi_done)
            begin
              spi_vdata <= 1'b0;
              state <= SPI_DEL;
              if(byte_cnt != 1)
              begin
                byte_cnt <= byte_cnt - 1;
                state_nxt <= SEND;
              end
              else
              begin
                state_nxt <= DONE;
                done <= 1'b1;
              end
            end
          end
          else
          begin
            spi_data <= data;
            spi_vdata <= data_valid;
            o_oled_dc_n <= 1'b0;
            if (spi_done)
            begin
              spi_vdata <= 1'b0;
              state <= SPI_DEL;
              state_nxt <= DONE;
              done <= 1'b1;
            end
          end
        end

      endcase
    end
  end

  delay_gen # (
              .CLK_FREQ(CLK_FREQ),
              // 2ms Delay
              .NEW_FREQ(NEW_FREQ)
            )
            delay_gen_inst (
              .clk(i_clk),
              .arst_n(i_arst_n),
              .del_en(del_en),
              .delay(delay)
            );

  spi_cntrl  spi_cntrl_inst (
               .clk(i_clk)
               ,.arst_n(i_arst_n)
               ,.din(spi_data)
               ,.din_valid(spi_vdata)
               ,.sclk(o_oled_sclk)
               ,.sdin(o_oled_sdin)
               ,.sdone(spi_done)
             );

  char_rom  char_rom_inst (
              .ascii_char(data),
              .gdram_char(oled_data)
            );

endmodule