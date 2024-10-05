library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_cntrl is
  port
  (
    clk       : in std_logic; 
    arst_n    : in std_logic;
    din       : in std_logic_vector (7 downto 0);
    din_valid : in std_logic;

    sdin  : out std_logic;
    sclk  : out std_logic;
    sdone : out std_logic
  );
end entity;

architecture rtl of spi_cntrl is
  -- Signal Declaration
  type state_t is (IDLE, SEND, DONE);
  signal state    : state_t;
  signal tck_cnt  : integer range 0 to 4 := 0;
  signal ser_cnt  : integer range 0 to 7 := 0;
  signal shft_reg : std_logic_vector(7 downto 0);
  signal spi_clk  : std_logic := '1';
  signal clk_en   : std_logic := '0';

begin

  -- SPI Clock Generation
  process (clk, arst_n)
  begin
    if arst_n = '0' then
      tck_cnt <= 0;
      spi_clk <= '1';
    elsif rising_edge(clk) then
      if tck_cnt = 4 then
        spi_clk <= not spi_clk;
        tck_cnt <= 0;
      else
        tck_cnt <= tck_cnt + 1;
      end if;
    end if;
  end process;

  sclk <= spi_clk when clk_en = '1' else
    '1';

  -- SPI Transmission FSM
  process (spi_clk, arst_n)
  begin
    if arst_n = '0' then
      state    <= IDLE;
      ser_cnt  <= 0;
      shft_reg <= x"00";
      clk_en   <= '0';
      sdin     <= '1';
      sdone    <= '0';
    elsif falling_edge(spi_clk) then
      case state is
        when IDLE =>
          sdone <= '0';
          if din_valid = '1' then
            shft_reg <= din;
            state    <= SEND;
          end if;
        when SEND =>
          clk_en   <= '1';
          sdin     <= shft_reg(7);
          shft_reg <= shft_reg(6 downto 0) & '0';
          if ser_cnt = 7 then
            state   <= DONE;
            ser_cnt <= 0;
          else
            ser_cnt <= ser_cnt + 1;
          end if;
        when DONE =>
          sdone  <= '1';
          clk_en <= '0';
          if din_valid = '0' then
            state <= IDLE;
            sdone <= '0';
          else
            state <= DONE;
          end if;

        when others => state <= IDLE;
          null;
      end case;
    end if;
  end process;

end architecture;