library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity conv is
  generic (
    KERNEL_SIZE : integer := 3; -- 3x3 Kernel
    LINE_LENGTH : integer := 512; -- 512x512 Image
    PIXEL_SIZE  : integer := 8; -- 8-bit Pixel
    DIV_BY      : integer := 9 -- Denominator
  );
  port (
    clk              : in std_logic;
    reset_n          : in std_logic;
    pixel_buff       : in std_logic_vector(((KERNEL_SIZE ** 2) * PIXEL_SIZE) - 1 downto 0);
    pixel_buff_valid : in std_logic;
    pixel_out        : out std_logic_vector(PIXEL_SIZE - 1 downto 0);
    pixel_out_valid  : out std_logic
  );
end entity;

architecture rtl of conv is
  type FSM is (IDLE, MUL, ACC, DIV);
  signal state : FSM;
  type KERNEL_TYPE is array ((KERNEL_SIZE ** 2) - 1 downto 0) of unsigned(PIXEL_SIZE - 1 downto 0);
  constant kernel : KERNEL_TYPE := (
  0 => x"01",
  1 => x"01",
  2 => x"01",
  3 => x"01",
  4 => x"01",
  5 => x"01",
  6 => x"01",
  7 => x"01",
  8 => x"01"
  -- (others => to_unsigned(1, PIXEL_SIZE))
  );
  type MUL_MEM is array ((KERNEL_SIZE ** 2) - 1 downto 0) of unsigned((PIXEL_SIZE * 2) - 1 downto 0);
  signal pixel_mul_reg                                     : MUL_MEM                                 := (others => to_unsigned(0, PIXEL_SIZE * 2));
  signal pixel_acc_reg                                     : unsigned((PIXEL_SIZE * 2) - 1 downto 0) := (others => '0');
  signal pixel_div_reg                                     : unsigned((PIXEL_SIZE * 2) - 1 downto 0) := (others => '0');
  signal pixel_mul_valid, pixel_acc_valid, pixel_div_valid : std_logic                               := '0';
begin
  -- Multiplication
  process (clk)
  begin
    if rising_edge(clk) then
      for i in 0 to (KERNEL_SIZE ** 2) - 1 loop
        pixel_mul_reg(i) <= kernel(i) * unsigned(pixel_buff((i * 8) + 7 downto i * 8));
      end loop;
      pixel_mul_valid <= pixel_buff_valid;
    end if;
  end process;
  -- Accumulation
  process (clk)
    variable pixel_acc_var : unsigned((PIXEL_SIZE * 2) - 1 downto 0);
  begin
    if rising_edge(clk) then
      pixel_acc_var := to_unsigned(0, pixel_acc_var'length);
      for i in 0 to (KERNEL_SIZE ** 2) - 1 loop
        pixel_acc_var := pixel_acc_var + pixel_mul_reg(i);
      end loop;
      pixel_acc_reg   <= pixel_acc_var;
      pixel_acc_valid <= pixel_mul_valid;
    end if;
  end process;
  --   Division
  process (clk)
  begin
    if rising_edge(clk) then
      pixel_div_reg   <= pixel_acc_reg/DIV_BY;
      pixel_div_valid <= pixel_acc_valid;
    end if;
  end process;
  --   Output
  pixel_out       <= std_logic_vector(pixel_div_reg(PIXEL_SIZE - 1 downto 0));
  pixel_out_valid <= pixel_div_valid;

end architecture;