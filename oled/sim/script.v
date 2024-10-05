module script;

reg [63:0] mem [127:0]; //model of memory


  initial
  begin
    mem[0] = 'h0000000000000000;
    mem[1] = 'h0000000000000000;
    mem[2] = 'h0000000000000000;
    mem[3] = 'h0000000000000000;
    mem[4] = 'h0000000000000000;
    mem[5] = 'h0000000000000000;
    mem[6] = 'h0000000000000000;
    mem[7] = 'h0000000000000000;
    mem[8] = 'h0000000000000000;
    mem[9] = 'h0000000000000000;
    mem[10] = 'h0000000000000000;
    mem[11] = 'h0000000000000000;
    mem[12] = 'h0000000000000000;
    mem[13] = 'h0000000000000000;
    mem[14] = 'h0000000000000000;
    mem[15] = 'h0000000000000000;
    mem[16] = 'h0000000000000000;
    mem[17] = 'h0000000000000000;
    mem[18] = 'h0000000000000000;
    mem[19] = 'h0000000000000000;
    mem[20] = 'h0000000000000000;
    mem[21] = 'h0000000000000000;
    mem[22] = 'h0000000000000000;
    mem[23] = 'h0000000000000000;
    mem[24] = 'h0000000000000000;
    mem[25] = 'h0000000000000000;
    mem[26] = 'h0000000000000000;
    mem[27] = 'h0000000000000000;
    mem[28] = 'h0000000000000000;
    mem[29] = 'h0000000000000000;
    mem[30] = 'h0000000000000000;
    mem[31] = 'h0000000000000000;
    mem[32] = 'h0000000000000000;
    mem[33] = 'h0000005f00000000;
    mem[34] = 'h0000030003000000;
    mem[35] = 'h643c26643c262400;
    mem[36] = 'h2649497f49493200;
    mem[37] = 'h4225120824522100;
    mem[38] = 'h20504e5522582800;
    mem[39] = 'h0000000300000000;
    mem[40] = 'h00001c2241000000;
    mem[41] = 'h00000041221c0000;
    mem[42] = 'h0015150e0e151500;
    mem[43] = 'h0008083e08080000;
    mem[44] = 'h0000005030000000;
    mem[45] = 'h0008080808080000;
    mem[46] = 'h0000004000000000;
    mem[47] = 'h4020100804020100;
    mem[48] = 'h003e4141413e0000;
    mem[49] = 'h0000417f40000000;
    mem[50] = 'h00426151496e0000;
    mem[51] = 'h0022414949360000;
    mem[52] = 'h001814127f100000;
    mem[53] = 'h0027494949710000;
    mem[54] = 'h003c4a4948700000;
    mem[55] = 'h004321110d030000;
    mem[56] = 'h0036494949360000;
    mem[57] = 'h00060949291e0000;
    mem[58] = 'h0000001200000000;
    mem[59] = 'h0000005230000000;
    mem[60] = 'h0000081414220000;
    mem[61] = 'h0014141414141400;
    mem[62] = 'h0000221414080000;
    mem[63] = 'h0002015905020000;
    mem[64] = 'h3e415d554d512e00;
    mem[65] = 'h407c4a094a7c4000;//A
    mem[66] = 'h417f494949493600;//B
    mem[67] = 'h1c22414141412200;//C
    mem[68] = 'h417f414141221c00;//D
    mem[69] = 'h417f49495d416300;//E
    mem[70] = 'h417f49091d010300;//F
    mem[71] = 'h1c224149493a0800;//G
    mem[72] = 'h417f0808087f4100;//H
    mem[73] = 'h0041417F41410000;//I
    mem[74] = 'h304041413F010100;//J
    mem[75] = 'h417f080c12614100;//K
    mem[76] = 'h417f414040406000;//L
    mem[77] = 'h417f420c427f4100;//M
    mem[78] = 'h417f420c117f0100;//N
    mem[79] = 'h1c22414141221c00;//O
    mem[80] = 'h417f490909090600;//P
    mem[81] = 'h0c12212161524c00;//Q
    mem[82] = 'h417f090919694600;//R
    mem[83] = 'h6649494949493300;//S
    mem[84] = 'h0301417f41010300;//T
    mem[85] = 'h013f4140413f0100;//U
    mem[86] = 'h010f3140310f0100;//V
    mem[87] = 'h011f6114611f0100;//W
    mem[88] = 'h4141360836414100;//X
    mem[89] = 'h0103447844030100;//Y
    mem[90] = 'h4361514945436100;//Z
    mem[91] = 'h00007f4141000000;
    mem[92] = 'h0102040810204000;
    mem[93] = 'h000041417f000000;
    mem[94] = 'h0004020101020400;
    mem[95] = 'h0040404040404000;
    mem[96] = 'h0001020000000000;
    mem[97] = 'h00344a4a4a3c4000;
    mem[98] = 'h00413f4848483000;
    mem[99] = 'h003c424242240000;
    mem[100] = 'h00304848493f4000;
    mem[101] = 'h003c4a4a4a2c0000;
    mem[102] = 'h0000487e49090000;
    mem[103] = 'h00264949493f0100;
    mem[104] = 'h417f480444784000;
    mem[105] = 'h0000447d40000000;
    mem[106] = 'h000040443d000000;
    mem[107] = 'h417f101824424200;
    mem[108] = 'h0040417f40400000;
    mem[109] = 'h427e027c027e4000;
    mem[110] = 'h427e4402427c4000;
    mem[111] = 'h003c4242423c0000;
    mem[112] = 'h00417f4909090600;
    mem[113] = 'h00060909497f4100;
    mem[114] = 'h00427e4402020400;
    mem[115] = 'h00644a4a4a360000;
    mem[116] = 'h00043f4444200000;
    mem[117] = 'h00023e4040227e40;
    mem[118] = 'h020e3240320e0200;
    mem[119] = 'h021e6218621e0200;
    mem[120] = 'h4262140814624200;
    mem[121] = 'h0143453805030100;
    mem[122] = 'h004662524a466200;
    mem[123] = 'h0000083641000000;
    mem[124] = 'h0000007f00000000;
    mem[125] = 'h0000004136080000;
    mem[126] = 'h0018080810101800;
    mem[127] = 'hAA55AA55AA55AA55;
  end

integer i;
initial begin
    for ( i=0 ; i<128; i=i+1 ) begin
        $display("%d => x\"%h\",", i,mem[i]);
    end
end
    
endmodule