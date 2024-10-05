module top_soc 
    (
      // Global Interface
      input  i_clk,         // 100MHz clock
      input  i_reset_n,     // Active Low

      // Oled Interface
      output oled_spi_clk,
      output oled_spi_data,
      output oled_vdd,
      output oled_vbat,
      output oled_reset_n,
      output oled_dc_n,

      // User Interface
      input  [7:0] i_data,     // Data to be sent
      input  i_data_valid,     // Valid Data to be sent
      input  i_data_command_n, // Data "1" Command "0"
      output o_done            // Ready for new data to be sent
    );

localparam CLK_FREQ = 100_000_000;
localparam NEW_FREQ = 500;        // For Delay generation of 2ms
  oled_cntrl # (
               .CLK_FREQ(CLK_FREQ),
               .NEW_FREQ(NEW_FREQ)
             )
             oled_cntrl_inst (
               .i_clk(i_clk),
               .i_arst_n(i_reset_n), // the controller works with active low reset

               .data(i_data),
               .data_valid(i_data_valid),
               .data_command_n(i_data_command_n),
               .done(o_done),
               
               .o_oled_vdd(oled_vdd),
               .o_oled_vbat(oled_vbat),
               .o_oled_rst_n(oled_reset_n),
               .o_oled_dc_n(oled_dc_n),
               .o_oled_sclk(oled_spi_clk),
               .o_oled_sdin(oled_spi_data)
             );
endmodule
