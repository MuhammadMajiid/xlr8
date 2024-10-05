module top_soc
  # (
      parameter CLK_FREQ = 100_000_000,
      parameter NEW_FREQ = 500
    )
    (
      // Global Interface
      input  i_clk,         // 100MHz onboard clock
      input  i_reset,       // Push-Button Active High

      // Oled Interface
      output oled_spi_clk,
      output oled_spi_data,
      output oled_vdd,
      output oled_vbat,
      output oled_reset_n,
      output oled_dc_n,

      // User Interface
      input  [7:0] i_data,
      input  i_data_valid,
      output o_done
    );


  oled_cntrl # (
               .CLK_FREQ(CLK_FREQ),
               .NEW_FREQ(NEW_FREQ)
             )
             oled_cntrl_inst (
               .i_clk(i_clk),
               .i_arst_n(!i_reset), // the controller works with active low reset

               .data(i_data),
               .data_valid(i_data_valid),
               .done(o_done),
               
               .o_oled_vdd(o_oled_vdd),
               .o_oled_vbat(o_oled_vbat),
               .o_oled_rst_n(o_oled_rst_n),
               .o_oled_dc_n(o_oled_dc_n),
               .o_oled_sclk(o_oled_sclk),
               .o_oled_sdin(o_oled_sdin)
             );
endmodule
