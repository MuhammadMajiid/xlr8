library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity regfile is
  port
  (
    clk        : in std_logic;
    we3        : in std_logic;
    a1, a2, a3 : in std_logic_vector(4 downto 0);
    wd3        : in std_logic_vector(31 downto 0);
    rd1, rd2   : out std_logic_vector(31 downto 0));
end;

architecture behave of regfile is
  type ramtype is array (0 to 31) of std_logic_vector(31 downto 0);
  signal mem : ramtype := (0 => x"00000000", others => x"00000000");
begin
  -- three ported register file
  -- read two ports combinationally (A1/RD1, A2/RD2)
  -- write third port on rising edge of clock (A3/WD3/WE3)
  -- register 0 hardwired to 0
  process (clk) begin
    if falling_edge(clk) then
      if (we3 = '1' ) and (to_integer(unsigned(a3)) /= 0) then
        mem(to_integer(unsigned(a3))) <= wd3;
      end if;
    end if;
  end process;
  rd1 <= mem(to_integer(unsigned(a1)));
  rd2 <= mem(to_integer(unsigned(a2)));
end;