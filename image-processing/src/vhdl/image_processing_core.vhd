library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity image_processing_core is
  generic
  (
    KERNEL_SIZE : integer := 3; -- 3x3 Kernel
    LINE_LENGTH : integer := 512; -- 512x512 Image
    PIXEL_SIZE  : integer := 8; -- 8-bit Pixel
    DIV_BY      : integer := 9 -- Denominator
  );
  port
  (
    -- Global Signal
    axi_clk   : in std_logic;
    axi_rst_n : in std_logic;
    -- Slave Interface
    pixel_in   : in std_logic_vector(PIXEL_SIZE - 1 downto 0);
    pixel_vin  : in std_logic;
    core_ready : out std_logic;
    -- Master Interface
    pixel_out  : out std_logic_vector(PIXEL_SIZE - 1 downto 0);
    pixel_vout : out std_logic;
    src_ready  : in std_logic;
    -- Interrupt Signal
    intr : out std_logic
  );
end entity;

architecture structure of image_processing_core is
  -- Components
  component core_cntrl
    generic
    (
      KERNEL_SIZE : integer;
      LINE_LENGTH : integer;
      PIXEL_SIZE  : integer
    );
    port
    (
      clk              : in std_logic;
      reset_n          : in std_logic;
      pixel_in         : in std_logic_vector(PIXEL_SIZE - 1 downto 0);
      pixel_valid      : in std_logic;
      pixel_buff       : out std_logic_vector(((KERNEL_SIZE ** 2) * PIXEL_SIZE) - 1 downto 0);
      pixel_buff_valid : out std_logic;
      intr             : out std_logic
    );
  end component;

  component conv
    generic
    (
      KERNEL_SIZE : integer;
      LINE_LENGTH : integer;
      PIXEL_SIZE  : integer;
      DIV_BY      : integer
    );
    port
    (
      clk              : in std_logic;
      reset_n          : in std_logic;
      pixel_buff       : in std_logic_vector(((KERNEL_SIZE ** 2) * PIXEL_SIZE) - 1 downto 0);
      pixel_buff_valid : in std_logic;
      pixel_out        : out std_logic_vector(PIXEL_SIZE - 1 downto 0);
      pixel_out_valid  : out std_logic
    );
  end component;

--   --   XILINX COMPONENT START
--   component out_buffer
--     port
--     (
--       wr_rst_busy    : out std_logic;
--       rd_rst_busy    : out std_logic;
--       s_aclk         : in std_logic;
--       s_aresetn      : in std_logic;
--       s_axis_tvalid  : in std_logic;
--       s_axis_tready  : out std_logic;
--       s_axis_tdata   : in std_logic_vector(7 downto 0);
--       m_axis_tvalid  : out std_logic;
--       m_axis_tready  : in std_logic;
--       m_axis_tdata   : out std_logic_vector(7 downto 0);
--       axis_prog_full : out std_logic
--     );
--   end component;
--   signal axis_prog_full : std_logic;
--   --   XILINX COMPONENT END

  --   Signals
  signal pixel_buff       : std_logic_vector(((KERNEL_SIZE ** 2) * PIXEL_SIZE) - 1 downto 0);
  signal pixel_buff_valid : std_logic;
  signal conv_out         : std_logic_vector(PIXEL_SIZE - 1 downto 0);
  signal conv_vout        : std_logic;
begin
  -- Components Mapping
  core_cntrl_inst : core_cntrl
  generic
  map (
  KERNEL_SIZE => KERNEL_SIZE,
  LINE_LENGTH => LINE_LENGTH,
  PIXEL_SIZE  => PIXEL_SIZE
  )
  port map
  (
    clk              => axi_clk,
    reset_n          => axi_rst_n,
    pixel_in         => pixel_in,
    pixel_valid      => pixel_vin,
    pixel_buff       => pixel_buff,
    pixel_buff_valid => pixel_buff_valid,
    intr             => intr
  );

  conv_inst : conv
  generic
  map (
  KERNEL_SIZE => KERNEL_SIZE,
  LINE_LENGTH => LINE_LENGTH,
  PIXEL_SIZE  => PIXEL_SIZE,
  DIV_BY      => DIV_BY
  )
  port
  map (
  clk              => axi_clk,
  reset_n          => axi_rst_n,
  pixel_buff       => pixel_buff,
  pixel_buff_valid => pixel_buff_valid,
  pixel_out        => pixel_out,
  pixel_out_valid  => pixel_vout
  );


--   conv_inst : conv
--   generic
--   map (
--   KERNEL_SIZE => KERNEL_SIZE,
--   LINE_LENGTH => LINE_LENGTH,
--   PIXEL_SIZE  => PIXEL_SIZE,
--   DIV_BY      => DIV_BY
--   )
--   port
--   map (
--   clk              => axi_clk,
--   reset_n          => axi_rst_n,
--   pixel_buff       => pixel_buff,
--   pixel_buff_valid => pixel_buff_valid,
--   pixel_out        => conv_out,
--   pixel_out_valid  => conv_vout
--   );

--   --   XILINX INST START
--   obuff : out_buffer
--   port
--   map (
--   wr_rst_busy    => open,
--   rd_rst_busy    => open,
--   s_aclk         => axi_clk,
--   s_aresetn      => axi_rst_n,
--   s_axis_tvalid  => conv_vout,
--   s_axis_tready  => open,
--   s_axis_tdata   => conv_out,
--   m_axis_tvalid  => pixel_vout,
--   m_axis_tready  => src_ready,
--   m_axis_tdata   => pixel_out,
--   axis_prog_full => axis_prog_full
--   );
--   --   XILINX INST END

--   core_ready <= not axis_prog_full;

end architecture;