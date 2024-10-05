library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity tb_ln_buff is
end entity;

architecture tb of tb_ln_buff is
  -- Signals
  signal KERNEL_SIZE_TB    : integer   := 3; -- 3x3 Kernel
  signal LINE_LENGTH_TB    : integer   := 512; -- 512x512 Image
  signal PIXEL_SIZE_TB     : integer   := 8; -- 8-bit Pixel
  signal clk, reset_n      : std_logic := '0';
  signal pixel_in          : std_logic_vector(PIXEL_SIZE_TB - 1 downto 0);
  signal pixel_valid       : std_logic;
  signal read_pixel_vector : std_logic;
  signal pixel_vector      : std_logic_vector((KERNEL_SIZE_TB * PIXEL_SIZE_TB) - 1 downto 0);
  -- Component
  component line_buffer is
    generic
    (
      KERNEL_SIZE : integer; -- 3x3 Kernel
      LINE_LENGTH : integer; -- 512x512 Image
      PIXEL_SIZE  : integer -- 8-bit Pixel
    );
    port
    (
      clk               : in std_logic;
      reset_n           : in std_logic;
      pixel_in          : in std_logic_vector(PIXEL_SIZE - 1 downto 0);
      pixel_valid       : in std_logic;
      read_pixel_vector : in std_logic;
      pixel_vector      : out std_logic_vector((KERNEL_SIZE * PIXEL_SIZE) - 1 downto 0)
    );
  end component;
begin
  -- Mapping
  line_buffer_inst : line_buffer
  generic
  map (
  KERNEL_SIZE => KERNEL_SIZE_TB,
  LINE_LENGTH => LINE_LENGTH_TB,
  PIXEL_SIZE  => PIXEL_SIZE_TB
  )
  port map
  (
    clk               => clk,
    reset_n           => reset_n,
    pixel_in          => pixel_in,
    pixel_valid       => pixel_valid,
    read_pixel_vector => read_pixel_vector,
    pixel_vector      => pixel_vector
  );
  --   Test
  process
  begin
    wait for 10 ns;
    clk <= not clk;
  end process;

  process
  begin
    reset_n           <= '0';
    pixel_valid       <= '0';
    read_pixel_vector <= '0';
    wait for 50 ns;
    reset_n <= '1';
    wait for 10 ns;
    for i in 0 to 15 loop
      wait on clk;
      wait until rising_edge(clk);
      pixel_valid <= '1';
      pixel_in    <= std_logic_vector(to_unsigned(i, pixel_in'length));
      report "Input pixel in is " & integer'image(i);
    end loop;
    pixel_valid <= '0';
    for i in 0 to 3 loop
      read_pixel_vector <= '1';
      wait on clk;
      wait until rising_edge(clk);
      report "Output pixel vector in is " & integer'image(to_integer(unsigned(pixel_vector)));
      --   wait for 30 ns;
    end loop;
    read_pixel_vector <= '0';
    wait;
  end process;

end architecture;