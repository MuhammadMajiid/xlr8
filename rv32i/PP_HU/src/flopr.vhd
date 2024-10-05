library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity flopr is
  port
  (
    clk      : in std_logic;
    reset    : in std_logic;
    enable_n : in std_logic;
    din      : in std_logic;
    dout     : out std_logic
  );
end;
architecture rtl of flopr is
begin
  process (clk) begin
    if rising_edge(clk) then
      if reset = '1' then
        dout <= '0';
      elsif enable_n = '0' then
        dout <= din;
      end if;
    end if;
  end process;
end;