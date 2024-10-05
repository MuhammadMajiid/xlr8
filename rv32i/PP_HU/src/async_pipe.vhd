library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity async_pipe is
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
end entity;

architecture rtl of async_pipe is
begin
  process (clk, a_reset) begin
    if a_reset = '1' then
      dout <= (others => '0');
    elsif rising_edge(clk) then
      if enable_n = '0' then
        dout <= din;
      end if;
    end if;
  end process;
end architecture;