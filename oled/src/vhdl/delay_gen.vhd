library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity delay_gen is
  port
  (
    clk    : in std_logic; -- 100MHz
    arst_n : in std_logic;
    del_en : in std_logic;
    delay  : out std_logic -- 500Hz - Delay pulse each 2ms 
  );
end entity;

architecture rtl of delay_gen is
  signal tck_cnt : integer := 0;

begin

  process (clk, arst_n)
  begin
    if arst_n = '0' then
      delay   <= '0';
      tck_cnt <= 0;
    elsif rising_edge(clk) then
      if ((del_en = '1') and (tck_cnt = 200000)) then
        delay <= '1';
      else
        delay <= '0';
      end if;
      if ((del_en = '1') and (tck_cnt /= 200000)) then
        tck_cnt <= tck_cnt + 1;
      else
        tck_cnt <= 0;
      end if;
    end if;
  end process;

end architecture;