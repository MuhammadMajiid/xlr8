library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity rv32ipp is
  port
  (
    clk                  : in std_logic;
    reset                : in std_logic;
    PC                   : out std_logic_vector(31 downto 0);
    Instr                : in std_logic_vector(31 downto 0);
    MemWrite             : out std_logic;
    ALUResult, WriteData : out std_logic_vector(31 downto 0);
    ReadData             : in std_logic_vector(31 downto 0));
end;

architecture struct of rv32ipp is
  -- Components Declaration
  component controller
    port
    (
      op         : in std_logic_vector(6 downto 0);
      funct3     : in std_logic_vector(2 downto 0);
      funct7b5   : in std_logic;
      ResultSrc  : out std_logic_vector(1 downto 0);
      MemWrite   : out std_logic;
      ALUSrc     : out std_logic;
      RegWrite   : out std_logic;
      Branch     : out std_logic;
      Jump       : out std_logic;
      ImmSrc     : out std_logic_vector(1 downto 0);
      ALUControl : out std_logic_vector(2 downto 0));
  end component;
  component hu
    port
    (
      rs1_d        : in std_logic_vector(4 downto 0);
      rs2_d        : in std_logic_vector(4 downto 0);
      rs1_ex       : in std_logic_vector(4 downto 0);
      rs2_ex       : in std_logic_vector(4 downto 0);
      rd_ex        : in std_logic_vector(4 downto 0);
      rd_mem       : in std_logic_vector(4 downto 0);
      rd_wb        : in std_logic_vector(4 downto 0);
      regwrite_mem : in std_logic;
      regwrite_wb  : in std_logic;
      pcsrc_ex     : in std_logic;
      resultsrc_ex : in std_logic;
      forwarda_ex  : out std_logic_vector(1 downto 0);
      forwardb_ex  : out std_logic_vector(1 downto 0);
      stall_f      : out std_logic;
      stall_d      : out std_logic;
      flush_d      : out std_logic;
      flush_ex     : out std_logic
    );
  end component;
  component pipe
    generic
    (
      width : integer
    );
    port
    (
      clk      : in std_logic;
      reset    : in std_logic;
      enable_n : in std_logic;
      din      : in std_logic_vector(width - 1 downto 0);
      dout     : out std_logic_vector(width - 1 downto 0)
    );
  end component;
  component flopr
    port
    (
      clk      : in std_logic;
      reset    : in std_logic;
      enable_n : in std_logic;
      din      : in std_logic;
      dout     : out std_logic
    );
  end component;
  component adder
    port
    (
      a, b : in std_logic_vector(31 downto 0);
      y    : out std_logic_vector(31 downto 0));
  end component;
  component mux2 generic
    (width : integer);
    port
    (
      d0, d1 : in std_logic_vector(width - 1 downto 0);
      s      : in std_logic;
      y      : out std_logic_vector(width - 1 downto 0));
  end component;
  component mux3 generic
    (width : integer);
    port
    (
      d0, d1, d2 : in std_logic_vector(width - 1 downto 0);
      s          : in std_logic_vector(1 downto 0);
      y          : out std_logic_vector(width - 1 downto 0));
  end component;
  component regfile
    port
    (
      clk        : in std_logic;
      we3        : in std_logic;
      a1, a2, a3 : in std_logic_vector(4 downto 0);
      wd3        : in std_logic_vector(31 downto 0);
      rd1, rd2   : out std_logic_vector(31 downto 0));
  end component;
  component extend
    port
    (
      instr  : in std_logic_vector(31 downto 7);
      immsrc : in std_logic_vector(1 downto 0);
      immext : out std_logic_vector(31 downto 0));
  end component;
  component alu
    port
    (
      a, b       : in std_logic_vector(31 downto 0);
      ALUControl : in std_logic_vector(2 downto 0);
      ALUResult  : out std_logic_vector(31 downto 0);
      Zero       : out std_logic);
  end component;
  component async_pipe
    generic
    (
      width : integer
    );
    port
    (
      clk      : in std_logic;
      a_reset  : in std_logic;
      enable_n : in std_logic;
      din      : in std_logic_vector(width - 1 downto 0);
      dout     : out std_logic_vector(width - 1 downto 0)
    );
  end component;
  --   Signal Declaration

  -- FETCH STAGE
  signal PC_w          : std_logic_vector(31 downto 0);
  signal PCPlus4       : std_logic_vector(31 downto 0);

  -- DECODE STAGE
  signal PC_w_d        : std_logic_vector(31 downto 0);
  signal PCPlus4_d     : std_logic_vector(31 downto 0);
  signal instr_d       : std_logic_vector(31 downto 0);
  signal rd1           : std_logic_vector(31 downto 0);
  signal rd2           : std_logic_vector(31 downto 0);
  signal RegWrite      : std_logic;
  signal Jump          : std_logic;
  signal Branch        : std_logic;
  signal ImmSrc        : std_logic_vector(1 downto 0);
  signal ImmExt        : std_logic_vector(31 downto 0);
  signal ResultSrc     : std_logic_vector(1 downto 0);
  signal ALUControl    : std_logic_vector(2 downto 0);
  signal ALUSrc        : std_logic;

  -- EXCUTE STAGE
  signal PCPlus4_ex    : std_logic_vector(31 downto 0);
  signal PCTarget      : std_logic_vector(31 downto 0);
  signal PC_w_ex       : std_logic_vector(31 downto 0);
  signal PCSrc         : std_logic;
  signal RegWrite_ex   : std_logic;
  signal Jump_ex       : std_logic;
  signal Branch_ex     : std_logic;
  signal Zero          : std_logic;
  signal rs1_ex        : std_logic_vector(4 downto 0);
  signal rs2_ex        : std_logic_vector(4 downto 0);
  signal rd_ex         : std_logic_vector(4 downto 0);
  signal rd1_ex        : std_logic_vector(31 downto 0);
  signal rd2_ex        : std_logic_vector(31 downto 0);
  signal ImmExt_ex     : std_logic_vector(31 downto 0);
  signal ResultSrc_ex  : std_logic_vector(1 downto 0);
  signal ALUControl_ex : std_logic_vector(2 downto 0);
  signal ALUSrc_ex     : std_logic;
  signal MemWrite_ex   : std_logic;
  signal ALUResult_ex  : std_logic_vector(31 downto 0);
  signal SrcA          : std_logic_vector(31 downto 0);
  signal SrcB          : std_logic_vector(31 downto 0);
  signal srcB_mid      : std_logic_vector(31 downto 0);
  
  -- MEMROY STAGE
  signal PCPlus4_mem   : std_logic_vector(31 downto 0);
  signal RegWrite_mem  : std_logic;
  signal rd_mem        : std_logic_vector(4 downto 0);
  signal ResultSrc_mem : std_logic_vector(1 downto 0);
  signal ResultSrc_wb  : std_logic_vector(1 downto 0);
  signal MemWrite_mem  : std_logic;
  signal ALUResult_mem : std_logic_vector(31 downto 0);
  signal WriteData_mem : std_logic_vector(31 downto 0);

  -- WRITEBACK STAGE
  signal PCPlus4_wb    : std_logic_vector(31 downto 0);
  signal PCNext        : std_logic_vector(31 downto 0);
  signal Result        : std_logic_vector(31 downto 0);
  signal RegWrite_wb   : std_logic;
  signal rd_wb         : std_logic_vector(4 downto 0);
  signal MemWrite_d    : std_logic;
  signal ALUResult_wb  : std_logic_vector(31 downto 0);
  signal ReadData_wb   : std_logic_vector(31 downto 0);

  -- HAZARD UNIT
  signal stall_f       : std_logic;
  signal stall_d       : std_logic;
  signal flush_d       : std_logic;
  signal flush_ex      : std_logic;
  signal forwarda_ex   : std_logic_vector(1 downto 0);
  signal forwardb_ex   : std_logic_vector(1 downto 0);

begin
  -- Fetch Stage
  -- next PC logic
  pp_pcf : async_pipe
  generic
  map (
  width => 32
  )
  port map
  (
    clk      => clk,
    a_reset  => reset,
    enable_n => stall_f,
    din      => PCNext,
    dout     => PC_W
  );
  PC <= PC_W;
  pcadd4 : adder
  port
  map (
  a => PC_W,
  b => X"00000004",
  y => PCPlus4
  );
  pcmux : mux2
  generic
  map (
  width => 32
  )
  port
  map (
  d0 => PCPlus4,
  d1 => PCTarget,
  s  => PCSrc,
  y  => PCNext
  );
  -- Decode Stage
  pp_instr : pipe
  generic
  map (
  width => 32
  )
  port
  map
  (
  clk      => clk,
  reset    => flush_d,
  enable_n => stall_d,
  din      => Instr,
  dout     => instr_d
  );
  pp_pcd : pipe
  generic
  map (
  width => 32
  )
  port
  map (
  clk      => clk,
  reset    => flush_d,
  enable_n => stall_d,
  din      => PC_W,
  dout     => PC_W_d
  );
  pp_pc4 : pipe
  generic
  map (
  width => 32
  )
  port
  map (
  clk      => clk,
  reset    => flush_d,
  enable_n => stall_d,
  din      => PCPlus4,
  dout     => PCPlus4_d
  );
  -- register file logic
  cntrl : controller
  port
  map
  (
  op         => instr_d(6 downto 0),
  funct3     => instr_d(14 downto 12),
  funct7b5   => instr_d(30),
  ResultSrc  => ResultSrc,
  MemWrite   => MemWrite_d,
  ALUSrc     => ALUSrc,
  RegWrite   => RegWrite,
  Jump       => Jump,
  Branch     => Branch,
  ImmSrc     => ImmSrc,
  ALUControl => ALUControl
  );
  rf : regfile
  port
  map (
  clk => clk,
  we3 => RegWrite_wb,
  a1  => instr_d(19 downto 15),
  a2  => instr_d(24 downto 20),
  a3  => rd_wb,
  wd3 => Result,
  rd1 => rd1,
  rd2 => rd2
  );
  ext : extend
  port
  map (
  instr  => instr_d(31 downto 7),
  immsrc => ImmSrc,
  immext => ImmExt
  );
  -- Excute Stage
  pp_srca : pipe
  generic
  map (
  width => 32
  )
  port
  map (
  clk      => clk,
  reset    => flush_ex,
  enable_n => '0',
  din      => rd1,
  dout     => rd1_ex
  );
  pp_srcb : pipe
  generic
  map (
  width => 32
  )
  port
  map (
  clk      => clk,
  reset    => flush_ex,
  enable_n => '0',
  din      => rd2,
  dout     => rd2_ex
  );
  pp_rs1 : pipe
  generic
  map (
  width => 5
  )
  port
  map (
  clk      => clk,
  reset    => flush_ex,
  enable_n => '0',
  din      => instr_d(19 downto 15),
  dout     => rs1_ex
  );
  pp_rs2 : pipe
  generic
  map (
  width => 5
  )
  port
  map (
  clk      => clk,
  reset    => flush_ex,
  enable_n => '0',
  din      => instr_d(24 downto 20),
  dout     => rs2_ex
  );
  pp_rd : pipe
  generic
  map (
  width => 5
  )
  port
  map (
  clk      => clk,
  reset    => flush_ex,
  enable_n => '0',
  din      => instr_d(11 downto 7),
  dout     => rd_ex
  );
  pp_extimm : pipe
  generic
  map (
  width => 32
  )
  port
  map (
  clk      => clk,
  reset    => flush_ex,
  enable_n => '0',
  din      => ImmExt,
  dout     => ImmExt_ex
  );
  pp_pcex : pipe
  generic
  map (
  width => 32
  )
  port
  map (
  clk      => clk,
  reset    => flush_ex,
  enable_n => '0',
  din      => PC_W_d,
  dout     => PC_W_ex
  );
  pp_pc4ex : pipe
  generic
  map (
  width => 32
  )
  port
  map (
  clk      => clk,
  reset    => flush_ex,
  enable_n => '0',
  din      => PCPlus4_d,
  dout     => PCPlus4_ex
  );
  flopr_RegWrite_ex : flopr
  port
  map (
  clk      => clk,
  reset    => flush_ex,
  enable_n => '0',
  din      => RegWrite,
  dout     => RegWrite_ex
  );
  pp_ResultSrc : pipe
  generic
  map (
  width => 2
  )
  port
  map (
  clk      => clk,
  reset    => flush_ex,
  enable_n => '0',
  din      => ResultSrc,
  dout     => ResultSrc_ex
  );
  pp_memwrite : flopr
  port
  map (
  clk      => clk,
  reset    => flush_ex,
  enable_n => '0',
  din      => MemWrite_d,
  dout     => MemWrite_ex
  );
  pp_jump : flopr
  port
  map (
  clk      => clk,
  reset    => flush_ex,
  enable_n => '0',
  din      => Jump,
  dout     => Jump_ex
  );
  pp_branch : flopr
  port
  map (
  clk      => clk,
  reset    => flush_ex,
  enable_n => '0',
  din      => Branch,
  dout     => Branch_ex
  );
  pp_alucntrl : pipe
  generic
  map (
  width => 3
  )
  port
  map (
  clk      => clk,
  reset    => flush_ex,
  enable_n => '0',
  din      => ALUControl,
  dout     => ALUControl_ex
  );
  pp_alusrc : flopr
  port
  map (
  clk      => clk,
  reset    => flush_ex,
  enable_n => '0',
  din      => ALUSrc,
  dout     => ALUSrc_ex
  );
  -- ALU logic
  srcaE : mux3
  generic
  map (
  width => 32
  )
  port
  map (
  d0 => rd1_ex,
  d1 => Result,
  d2 => ALUResult_mem,
  s  => forwarda_ex,
  y  => SrcA
  );
  srcbE : mux3
  generic
  map (
  width => 32
  )
  port
  map (
  d0 => rd2_ex,
  d1 => Result,
  d2 => ALUResult_mem,
  s  => forwardb_ex,
  y  => srcB_mid
  );
  srcbmux : mux2
  generic
  map (
  width => 32
  )
  port
  map (
  d0 => srcB_mid,
  d1 => ImmExt_ex,
  s  => ALUSrc_ex,
  y  => SrcB
  );
  mainalu : alu
  port
  map (
  a          => SrcA,
  b          => SrcB,
  ALUControl => ALUControl_ex,
  ALUResult  => ALUResult_ex,
  Zero       => Zero
  );
  PCSrc <= '1' when ((Zero and Branch_ex) or Jump_ex) = '1' else
    '0';
  pcaddbranch : adder
  port
  map (
  a => PC_W_ex,
  b => ImmExt_ex,
  y => PCTarget
  );
  -- Memory Stage
  pp_wrdata : pipe
  generic
  map (
  width => 32
  )
  port
  map (
  clk      => clk,
  reset    => '0',
  enable_n => '0',
  din      => srcB_mid,
  dout     => WriteData_mem
  );
  pp_aluresmem : pipe
  generic
  map (
  width => 32
  )
  port
  map (
  clk      => clk,
  reset    => '0',
  enable_n => '0',
  din      => ALUResult_ex,
  dout     => ALUResult_mem
  );
  pp_pc4mem : pipe
  generic
  map (
  width => 32
  )
  port
  map (
  clk      => clk,
  reset    => '0',
  enable_n => '0',
  din      => PCPlus4_ex,
  dout     => PCPlus4_mem
  );
  pp_rdmem : pipe
  generic
  map (
  width => 5
  )
  port
  map (
  clk      => clk,
  reset    => '0',
  enable_n => '0',
  din      => rd_ex,
  dout     => rd_mem
  );
  pp_regwritemem : flopr
  port
  map (
  clk      => clk,
  reset    => '0',
  enable_n => '0',
  din      => RegWrite_ex,
  dout     => RegWrite_mem
  );
  pp_ResultSrcmem : pipe
  generic
  map (
  width => 2
  )
  port
  map (
  clk      => clk,
  reset    => '0',
  enable_n => '0',
  din      => ResultSrc_ex,
  dout     => ResultSrc_mem
  );
  pp_memwrite_mem : flopr
  port
  map (
  clk      => clk,
  reset    => '0',
  enable_n => '0',
  din      => MemWrite_ex,
  dout     => MemWrite_mem
  );

  ALUResult <= ALUResult_mem;
  WriteData <= WriteData_mem;
  MemWrite  <= MemWrite_mem;

  -- Writeback Stage
  pp_rdwb : pipe
  generic
  map (
  width => 5
  )
  port
  map (
  clk      => clk,
  reset    => '0',
  enable_n => '0',
  din      => rd_mem,
  dout     => rd_wb
  );
  pp_rddatawb : pipe
  generic
  map (
  width => 32
  )
  port
  map (
  clk      => clk,
  reset    => '0',
  enable_n => '0',
  din      => ReadData,
  dout     => ReadData_wb
  );
  pp_regwritewb : flopr
  port
  map (
  clk      => clk,
  reset    => '0',
  enable_n => '0',
  din      => RegWrite_mem,
  dout     => RegWrite_wb
  );
  pp_alureswb : pipe
  generic
  map (
  width => 32
  )
  port
  map (
  clk      => clk,
  reset    => '0',
  enable_n => '0',
  din      => ALUResult_mem,
  dout     => ALUResult_wb
  );
  pp_pc4wb : pipe
  generic
  map (
  width => 32
  )
  port
  map (
  clk      => clk,
  reset    => '0',
  enable_n => '0',
  din      => PCPlus4_mem,
  dout     => PCPlus4_wb
  );
  pp_ResultSrcwb : pipe
  generic
  map (
  width => 2
  )
  port
  map (
  clk      => clk,
  reset    => '0',
  enable_n => '0',
  din      => ResultSrc_mem,
  dout     => ResultSrc_wb
  );
  resultmux : mux3
  generic
  map (
  width => 32
  )
  port
  map (
  d0 => ALUResult_wb,
  d1 => ReadData_wb,
  d2 => PCPlus4_wb,
  s  => ResultSrc_wb,
  y  => Result
  );
  -- Hazard Unit
  hu_inst : hu
  port
  map (
  rs1_d        => instr_d(19 downto 15),
  rs2_d        => instr_d(24 downto 20),
  rs1_ex       => rs1_ex,
  rs2_ex       => rs2_ex,
  rd_ex        => rd_ex,
  rd_mem       => rd_mem,
  rd_wb        => rd_wb,
  regwrite_mem => regwrite_mem,
  regwrite_wb  => regwrite_wb,
  pcsrc_ex     => PCSrc,
  resultsrc_ex => ResultSrc_ex(0),
  forwarda_ex  => forwarda_ex,
  forwardb_ex  => forwardb_ex,
  stall_f      => stall_f,
  stall_d      => stall_d,
  flush_d      => flush_d,
  flush_ex     => flush_ex
  );
end;