/*
    Author: Mohamed Maged
    Date: 20/5/2024
    Version: v1.0
    Description: OLED Cotroller for ZedBoard
*/

/*
    OLED Power Up Sequence:
        1. Power up VDD
        2. Send Display off command (0xAE)
        3. Initialization
        4. Clear Screen
        5. Power up VCC
        6. Delay 100ms
        (When VCC is stable)
        7. Send Display on command (0xAF)
    
    OLED Power Down Sequence:
        1. Send Display off command (0xAE)
        2. Power down VCC
        3. Delay 100ms
        (When VCC is reach 0 and panel
        is completely discharges)
        4. Power down VDD
 
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
    output reg done,

    // Oled Interface
    output reg o_oled_vdd,
    output reg o_oled_vbat,
    output reg o_oled_rst_n,
    output reg o_oled_dc_n,
    output wire o_oled_sclk,
    output wire o_oled_sdin
  );

  wire spi_done;
  reg [7:0] spi_data;
  reg spi_vdata;
  reg del_en;
  wire delay;
  reg [1:0] pg_no;
  wire [63:0] oled_data;
  reg [3:0] byte_cnt;
  reg [7:0] colmn_addr;
  reg [4:0] state, state_nxt;
  localparam IDLE = 'd0,
             DISP_OFF = 'd1,
             DELAY = 'd2,
             RM_RESET = 'd3,
             CHARGE_PUMP0 = 'd4,
             CHARGE_PUMP1 = 'd5,
             PRE_CHARGE0 = 'd6,
             PRE_CHARGE1 = 'd7,
             SPI_DEL = 'd8,
             VBAT_ON = 'd9,
             CONTRAST0 = 'd10,
             CONTRAST1 = 'd11,
             SEG_REMAP = 'd12,
             SCAN_DIR = 'd13,
             COM0 = 'd14,
             COM1 = 'd15,
             DISP_ON = 'd16,
             PG_ADDR0 = 'd17,
             PG_ADDR1 = 'd18,
             PG_ADDR2 = 'd19,
             COL_ADDR = 'd20,
             DONE = 'd21,
             SEND = 'd22;

  /*
            - Remove Reset & VBAT = 1;
            - wait for 2ms
            - send display off command (0xAE)
            -
  */
  always @(posedge i_clk, negedge i_arst_n)
  begin
    if (!i_arst_n)
    begin
      state <= IDLE;
      state_nxt <= IDLE;
      o_oled_vdd <= 1'b0;
      o_oled_vbat <= 1'b0;
      o_oled_rst_n <= 1'b1;
      o_oled_dc_n <= 1'b1;
      del_en <= 1'b0;
      spi_data <= 8'h00;
      spi_vdata <= 1'b0;
      pg_no     <= 2'b0;
      done <= 1'b0;
      colmn_addr <= 8'b0;
      byte_cnt <= 4'd0;
    end
    else
    begin
      case (state)
        IDLE :
        begin
          o_oled_vdd <= 1'b1;
          o_oled_vbat <= 1'b1;
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
            state_nxt <= CONTRAST0;
          end
        end

        // VBAT_ON :
        // begin
        //   o_oled_vbat <= 1'b1;
        //   state <= DELAY;
        //   state_nxt <= CONTRAST0;
        // end

        CONTRAST0 :
        begin
          spi_data <= 8'h81;
          spi_vdata <= 1'b1;
          if (spi_done)
          begin
            spi_vdata <= 1'b0;
            state <= SPI_DEL;
            state_nxt <= CONTRAST1;
          end
        end

        CONTRAST1 :
        begin
          spi_data <= 8'hFF;
          spi_vdata <= 1'b1;
          if (spi_done)
          begin
            spi_vdata <= 1'b0;
            state <= SPI_DEL;
            state_nxt <= SEG_REMAP;
          end
        end

        SEG_REMAP :
        begin
          spi_data <= 8'hA0;
          spi_vdata <= 1'b1;
          if (spi_done)
          begin
            spi_vdata <= 1'b0;
            state <= SPI_DEL;
            state_nxt <= SCAN_DIR;
          end
        end
        SCAN_DIR :
        begin
          spi_data <= 8'hC0;
          spi_vdata <= 1'b1;
          if (spi_done)
          begin
            spi_vdata <= 1'b0;
            state <= SPI_DEL;
            state_nxt <= COM0;
          end
        end
        COM0 :
        begin
          spi_data <= 8'hDA;
          spi_vdata <= 1'b1;
          if (spi_done)
          begin
            spi_vdata <= 1'b0;
            state <= SPI_DEL;
            state_nxt <= COM1;
          end
        end
        COM1 :
        begin
          spi_data <= 8'h00; // Set Vertical Shift Starts from 0
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
            state_nxt <= PG_ADDR0;
          end
        end

        // Initialization ENDs

        PG_ADDR0 :
        begin
          spi_data <= 8'h22; // Setup Start & End Page Addresses >> One page at a time: Page Addressing Mode
          spi_vdata <= 1'b1;
          o_oled_dc_n <= 1'b0;
          if (spi_done)
          begin
            spi_vdata <= 1'b0;
            state <= SPI_DEL;
            state_nxt <= PG_ADDR1;
          end
        end

        PG_ADDR1 :
        begin
          spi_data <= pg_no; // Start Address
          spi_vdata <= 1'b1;
          if (spi_done)
          begin
            spi_vdata <= 1'b0;
            state <= SPI_DEL;
            pg_no <= pg_no + 1;
            state_nxt <= PG_ADDR2;
          end
        end

        PG_ADDR2 :
        begin
          spi_data <= pg_no; // End Address
          spi_vdata <= 1'b1;
          if (spi_done)
          begin
            spi_vdata <= 1'b0;
            state <= SPI_DEL;
            state_nxt <= COL_ADDR;
          end
        end

        COL_ADDR :
        begin
          spi_data <= 8'h10; // Start Coloumn Address is 0
          spi_vdata <= 1'b1;
          if (spi_done)
          begin
            spi_vdata <= 1'b0;
            state <= SPI_DEL;
            state_nxt <= DONE;
          end
        end

        DONE :
        begin
          done <= 1'b0;
          if (data_valid && (colmn_addr != 128) && (!done))
          begin
            state <= SEND;
            byte_cnt <= 4'd8;
          end
          else if (data_valid && (colmn_addr == 128) && (!done))
          begin
            state <= PG_ADDR0;
            colmn_addr <= 8'b0;
            byte_cnt <= 4'd8;
          end
        end

        SEND :
        begin
          spi_data <= oled_data[(byte_cnt*8-1)-:8];
          spi_vdata <= 1'b1;
          o_oled_dc_n <= 1'b1;
          if(spi_done)
          begin
            colmn_addr <= colmn_addr + 1;
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

      endcase
    end
  end

  delay_gen # (
              .CLK_FREQ(CLK_FREQ),
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

