library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity pipe is
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
end entity;

architecture rtl of pipe is
begin
    process (clk) begin
        if rising_edge(clk) then
          if reset = '1' then
            dout <= (others => '0');
          elsif enable_n = '0' then
            dout <= din;
          end if;
        end if;
      end process;
end architecture;