`timescale 1ns / 1ps
`define headerSize 1080
`define imageSize 512*512

module tb();

  reg clk;
  reg reset;
  reg [7:0] imgData;
  integer file,file1,i,tmp;
  reg imgDataValid;
  integer sentSize;
  wire intr;
  wire [7:0] outData;
  wire outDataValid;
  integer receivedData=0;

  initial
  begin
    clk = 1'b0;
    forever
    begin
      #5 clk = ~clk;
    end
  end

  initial
  begin
    reset = 0;
    sentSize = 0;
    imgDataValid = 0;
    #100;
    reset = 1;
    #100;
    file = $fopen("lena_gray.bmp","rb");
    file1 = $fopen("blurred_lena.bmp","wb");
    for(i=0;i<(`headerSize);i=i+1)
    begin
      tmp = $fscanf(file,"%c",imgData);
      $fwrite(file1,"%c",imgData);
    end

    for(i=0;i<4*512;i=i+1)
    begin
      @(posedge clk);
      tmp= $fscanf(file,"%c",imgData);
      imgDataValid <= 1'b1;
    end
    sentSize = 4*512;
    @(posedge clk);
    imgDataValid <= 1'b0;
    while(sentSize < `imageSize)
    begin
      @(posedge intr);
      for(i=0;i<512;i=i+1)
      begin
        @(posedge clk);
        tmp= $fscanf(file,"%c",imgData);
        imgDataValid <= 1'b1;
      end
      @(posedge clk);
      imgDataValid <= 1'b0;
      sentSize = sentSize+512;
    end
    @(posedge clk);
    imgDataValid <= 1'b0;
    @(posedge intr);
    for(i=0;i<512;i=i+1)
    begin
      @(posedge clk);
      imgData <= 0;
      imgDataValid <= 1'b1;
    end
    @(posedge clk);
    imgDataValid <= 1'b0;
    @(posedge intr);
    for(i=0;i<512;i=i+1)
    begin
      @(posedge clk);
      imgData <= 0;
      imgDataValid <= 1'b1;
    end
    @(posedge clk);
    imgDataValid <= 1'b0;
    $fclose(file);
  end

  always @(posedge clk)
  begin
    if(outDataValid)
    begin
      $fwrite(file1,"%c",outData);
      receivedData = receivedData+1;
    end
    if(receivedData == `imageSize)
    begin
      $fclose(file1);
      $stop;
    end
  end

  image_processing_core # (
    .KERNEL_SIZE(3),
    .LINE_LENGTH(512),
    .PIXEL_SIZE(8),
    .DIV_BY(9)
  )
  dut (
    .axi_clk(clk),
    .axi_rst_n(reset),
    //slave interface
    .pixel_in(imgData),
    .pixel_vin(imgDataValid),
    .core_ready(),
    //master interface
    .pixel_out(outData),
    .pixel_vout(outDataValid),
    .src_ready(1'b1),
    //interrupt
    .intr(intr)
  );

endmodule