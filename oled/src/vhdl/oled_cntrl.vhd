library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity oled_cntrl is
  port
  (
    clk    : in std_logic;
    arst_n : in std_logic;
    data   : in std_logic_vector(6 downto 0);
    dvalid : in std_logic;
    data_command_n : in std_logic;
    o_done   : out std_logic;

    oled_vdd   : out std_logic;
    oled_vbat  : out std_logic;
    oled_rst_n : out std_logic;
    oled_dc_n  : out std_logic;
    oled_sclk  : out std_logic;
    oled_sdin  : out std_logic
  );
end entity;

architecture rtl of oled_cntrl is
  type STATE_TYPE is (IDLE, DISP_OFF, DELAY, RM_RESET, CHARGE_PUMP0, CHARGE_PUMP1, PRE_CHARGE0,
    PRE_CHARGE1, SPI_DEL, VBAT_ON, CONTRAST0, CONTRAST1, SEG_REMAP, SCAN_DIR, COM0, COM1, DISP_ON,
    PG_ADDR0, PG_ADDR1, PG_ADDR2, COL_ADDR, DONE, SEND);
  signal state, state_nxt : STATE_TYPE;
  signal oled_vdd_reg     : std_logic := '1';
  signal oled_vbat_reg    : std_logic := '1';
  signal oled_dc_n_reg    : std_logic := '1';
  signal oled_rst_n_reg   : std_logic := '1';
  -- signal oled_sclk_reg : std_logic := '0';
  -- signal oled_sdin_reg : std_logic := '1';
  signal done_reg       : std_logic := '0';
  signal del_en         : std_logic := '0';
  signal delay_w          : std_logic;
  signal spi_done       : std_logic;
  signal spi_vdata      : std_logic                     := '0';
  signal spi_data       : std_logic_vector (7 downto 0) := x"00";
  signal colmn_addr     : integer range 0 to 128        := 0;
  signal byte_cnt       : integer range 0 to 8          := 8;
  signal pg_no          : integer range 0 to 3          := 0;
--  signal ascii_char     : std_logic_vector(6 downto 0);
  signal gdram_char     : std_logic_vector(63 downto 0);
  signal gdram_char_reg : std_logic_vector(63 downto 0);

  -- Components
  component spi_cntrl is
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
  end component;
  component delay_gen is
    port
    (
      clk    : in std_logic;
      arst_n : in std_logic;
      del_en : in std_logic;
       delay  : out std_logic -- Delay pulse each 2ms 
    );
  end component;
  component char_rom is
    port
    (
      ascii_char : in std_logic_vector (6 downto 0);
      gdram_char : out std_logic_vector (63 downto 0)
    );
  end component;
begin
  spi_cntrl_inst : spi_cntrl
  port map
  (
    clk       => clk,
    arst_n    => arst_n,
    din       => spi_data,
    din_valid => spi_vdata,
    sdin      => oled_sdin,
    sclk      => oled_sclk,
    sdone     => spi_done
  );

  delay_gen_inst : delay_gen
  port
  map (
  clk    => clk,
  arst_n => arst_n,
  del_en => del_en,
   delay  =>  delay_w
  );

  char_rom_inst : char_rom
  port
  map (
  ascii_char => data,
  gdram_char => gdram_char
  );
  process (clk, arst_n)
  begin
    if arst_n = '0' then
      state          <= IDLE;
      state_nxt      <= IDLE;
      oled_vdd_reg   <= '1';
      oled_vbat_reg  <= '1';
      oled_rst_n_reg <= '1';
      oled_dc_n_reg  <= '1';
      done_reg       <= '0';
      del_en         <= '0';
      spi_data       <= x"00";
      spi_vdata      <= '0';
      pg_no          <= 0;
      colmn_addr     <= 0;
      byte_cnt       <= 8;
      gdram_char_reg <= x"0000000000000000";
    elsif rising_edge(clk) then
      case state is
        when IDLE =>
          oled_vdd_reg   <= '0';
          oled_vbat_reg  <= '1';
          oled_rst_n_reg <= '1';
          oled_dc_n_reg  <= '0';
          del_en         <= '0';
          state          <= DELAY;
          state_nxt      <= DISP_OFF;
          gdram_char_reg <= gdram_char;
        when DELAY =>
          del_en <= '1';
          if  delay_w = '1' then
            state  <= state_nxt;
            del_en <= '0';
          end if;
        when DISP_OFF =>
          spi_data  <= x"AE";
          spi_vdata <= '1';
          if spi_done = '1' then
            spi_vdata      <= '0';
            oled_rst_n_reg <= '0';
            state          <= DELAY;
            state_nxt      <= RM_RESET;
          end if;
        when RM_RESET =>
          oled_rst_n_reg <= '1';
          state          <= DELAY;
          state_nxt      <= CHARGE_PUMP0;
        when CHARGE_PUMP0 =>
          spi_data  <= x"8D";
          spi_vdata <= '1';
          if spi_done = '1' then
            spi_vdata <= '0';
            state     <= SPI_DEL;
            state_nxt <= CHARGE_PUMP1;
          end if;
        when CHARGE_PUMP1 =>
          spi_data  <= x"14";
          spi_vdata <= '1';
          if spi_done = '1' then
            spi_vdata <= '0';
            state     <= SPI_DEL;
            state_nxt <= PRE_CHARGE0;
          end if;
        when SPI_DEL =>
          if spi_done = '1' then
            state <= state_nxt;
          end if;
        when PRE_CHARGE0 =>
          spi_data  <= x"D9";
          spi_vdata <= '1';
          if spi_done = '1' then
            spi_vdata <= '0';
            state     <= SPI_DEL;
            state_nxt <= PRE_CHARGE1;
          end if;
        when PRE_CHARGE1 =>
          spi_data  <= x"F1";
          spi_vdata <= '1';
          if spi_done = '1' then
            spi_vdata <= '0';
            state     <= SPI_DEL;
            state_nxt <= VBAT_ON;
          end if;
        when VBAT_ON =>
          oled_vbat_reg <= '0';
          state         <= DELAY;
          state_nxt     <= CONTRAST0;
        when CONTRAST0 =>
          spi_data  <= x"81";
          spi_vdata <= '1';
          if spi_done = '1' then
            spi_vdata <= '0';
            state     <= SPI_DEL;
            state_nxt <= CONTRAST1;
          end if;
        when CONTRAST1 =>
          spi_data  <= x"FF";
          spi_vdata <= '1';
          if spi_done = '1' then
            spi_vdata <= '0';
            state     <= SPI_DEL;
            state_nxt <= SEG_REMAP;
          end if;
        when SEG_REMAP =>
          spi_data  <= x"A0";
          spi_vdata <= '1';
          if spi_done = '1' then
            spi_vdata <= '0';
            state     <= SPI_DEL;
            state_nxt <= SCAN_DIR;
          end if;
        when SCAN_DIR =>
          spi_data  <= x"C0";
          spi_vdata <= '1';
          if spi_done = '1' then
            spi_vdata <= '0';
            state     <= SPI_DEL;
            state_nxt <= COM0;
          end if;
        when COM0 =>
          spi_data  <= x"DA";
          spi_vdata <= '1';
          if spi_done = '1' then
            spi_vdata <= '0';
            state     <= SPI_DEL;
            state_nxt <= COM1;
          end if;
        when COM1 =>
          spi_data  <= x"00";
          spi_vdata <= '1';
          if spi_done = '1' then
            spi_vdata <= '0';
            state     <= SPI_DEL;
            state_nxt <= DISP_ON;
          end if;
        when DISP_ON =>
          spi_data  <= x"AF";
          spi_vdata <= '1';
          if spi_done = '1' then
            spi_vdata <= '0';
            state     <= SPI_DEL;
            state_nxt <= PG_ADDR0;
          end if;
        when PG_ADDR0 =>
          spi_data  <= x"22";
          spi_vdata <= '1';
          if spi_done = '1' then
            spi_vdata <= '0';
            state     <= SPI_DEL;
            state_nxt <= PG_ADDR1;
          end if;
        when PG_ADDR1 =>
          spi_data  <= std_logic_vector(to_unsigned(pg_no, spi_data'length));
          spi_vdata <= '1';
          if spi_done = '1' then
            spi_vdata <= '0';
            state     <= SPI_DEL;
            pg_no     <= pg_no + 1;
            state_nxt <= PG_ADDR2;
          end if;
        when PG_ADDR2 =>
          spi_data  <= std_logic_vector(to_unsigned(pg_no, spi_data'length));
          spi_vdata <= '1';
          if spi_done = '1' then
            spi_vdata <= '0';
            state     <= SPI_DEL;
            state_nxt <= COL_ADDR;
          end if;
        when COL_ADDR =>
          spi_data  <= x"10";
          spi_vdata <= '1';
          if spi_done = '1' then
            spi_vdata <= '0';
            state     <= SPI_DEL;
            state_nxt <= DONE;
          end if;
          -- Initialia=zation is done
        when DONE =>
          done_reg <= '0';
          if ((dvalid = '1') and (colmn_addr /= 128) and (done_reg = '0')) then
            state    <= SEND;
            byte_cnt <= 8;
          elsif ((dvalid = '1') and (colmn_addr = 128) and (done_reg = '0')) then
            state      <= PG_ADDR0;
            colmn_addr <= 0;
            byte_cnt   <= 8;
          end if;
        when SEND =>
--          spi_data       <= gdram_char(((byte_cnt*8)-1) downto (((byte_cnt*8)-1)-8));
           spi_data       <= gdram_char_reg(63 downto 56);
           gdram_char_reg(63 downto 0) <= gdram_char_reg(55 downto 0) & gdram_char_reg(63 downto 56);
          spi_vdata      <= '1';
          oled_dc_n_reg  <= '1';
          if spi_done = '1' then
            colmn_addr <= colmn_addr + 1;
            spi_vdata  <= '0';
            state      <= SPI_DEL;
            if byte_cnt /= 1 then
              byte_cnt  <= byte_cnt - 1;
              state_nxt <= SEND;
            else
              state_nxt <= DONE;
              done_reg  <= '1';
            end if;
          end if;
        when others =>
          null;
      end case;
    end if;
  end process;

  -- Output 
  oled_vdd   <= oled_vdd_reg;
  oled_vbat  <= oled_vbat_reg;
  oled_rst_n <= oled_rst_n_reg;
  oled_dc_n  <= oled_dc_n_reg;
  o_done       <= done_reg;

end architecture;