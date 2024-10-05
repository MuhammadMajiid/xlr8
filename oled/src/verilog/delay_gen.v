/*
    Author: Mohamed Maged
    Date: 20/5/2024
    Version: v1.0
    Description: Clock Divider
*/
module delay_gen
  #(
     parameter CLK_FREQ = 100_000_000,
     parameter NEW_FREQ = 500
   )
   (
     input wire clk,
     input wire arst_n,
     input wire del_en,

     output reg delay
   );

  localparam ticks = CLK_FREQ/NEW_FREQ;
  reg [($clog2(ticks)-1):0] tck_cnt;

  always @(posedge clk, negedge arst_n)
  begin
    if (!arst_n) tck_cnt <= 'd0;
    else
    begin
      if (del_en && (tck_cnt != ticks)) tck_cnt <= tck_cnt + 1;
      else tck_cnt <= 'd0;
    end
  end

  always @(posedge clk, negedge arst_n)
  begin
    if (!arst_n) delay <= 1'b0;
    else
    begin
      if (del_en && (tck_cnt == ticks)) delay <= 1'b1;
      else delay <= 1'b0;
    end
  end

endmodule
