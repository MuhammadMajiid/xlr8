library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity line_buffer is
  generic (
    KERNEL_SIZE : integer := 3; -- 3x3 Kernel
    LINE_LENGTH : integer := 512; -- 512x512 Image
    PIXEL_SIZE  : integer := 8 -- 8-bit Pixel
  );
  port (
    clk               : in std_logic;
    reset_n           : in std_logic;
    pixel_in          : in std_logic_vector(PIXEL_SIZE - 1 downto 0);
    pixel_valid       : in std_logic;
    read_pixel_vector : in std_logic;
    pixel_vector      : out std_logic_vector((KERNEL_SIZE * PIXEL_SIZE) - 1 downto 0)
  );
end entity;

architecture rtl of line_buffer is
  type RAM is array (0 to LINE_LENGTH - 1) of std_logic_vector(PIXEL_SIZE - 1 downto 0);
  signal pixel_ram : RAM;
  signal wr_ptr    : unsigned(integer(ceil(log2(real(LINE_LENGTH)))) - 1 downto 0);
  signal rd_ptr    : unsigned(integer(ceil(log2(real(LINE_LENGTH)))) - 1 downto 0);
begin
  --   Writing Counter 
  process (clk)
  begin
    if rising_edge(clk) then
      if reset_n = '0' then
        wr_ptr <= to_unsigned(0, wr_ptr'length);
      elsif pixel_valid = '1' then
        wr_ptr <= wr_ptr + to_unsigned(1, wr_ptr'length);
      end if;
    end if;
  end process;
  --   Writing to the line buffer
  process (clk)
  begin
    if rising_edge(clk) then
      if pixel_valid = '1' then
        pixel_ram(to_integer(wr_ptr)) <= pixel_in;
      end if;
    end if;
  end process;
  -- Reading Counter
  process (clk)
  begin
    if rising_edge(clk) then
      if reset_n = '0' then
        rd_ptr <= to_unsigned(0, rd_ptr'length);
      elsif read_pixel_vector = '1' then
        rd_ptr <= rd_ptr + to_unsigned(1, rd_ptr'length);
      end if;
    end if;
  end process;
  -- Reading from the line buffer
  process (rd_ptr)
  begin
    -- pixel_vector <= pixel_ram(to_integer(rd_ptr)) & pixel_ram(to_integer(rd_ptr + 1)) & pixel_ram(to_integer(rd_ptr + 2)); --....etc
    for i in 0 to KERNEL_SIZE - 1 loop
      pixel_vector((8 * i) + 7 downto 8 * i) <= pixel_ram(to_integer(rd_ptr + (KERNEL_SIZE - i - 1)));
    end loop;
  end process;
end architecture;