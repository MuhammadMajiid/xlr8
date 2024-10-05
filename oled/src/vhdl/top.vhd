library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port (
    	reset : in std_logic;
        clock   : in std_logic;
        oled_spi_clk : out std_logic;
        oled_spi_data : out std_logic;
        oled_vdd : out std_logic;
        oled_vbat : out std_logic;
        oled_reset_n : out std_logic;
        oled_dc_n : out std_logic
    );
end entity top;

architecture structure of top is
type STR is array (0 to 63) of std_logic_vector (7 downto 0);
--(Hello THERE     I AM MOHAMED    ITS OLED DEMO   WITH VHDL HDL   )
constant myString : STR := (
	0 => x"48",
	1 => x"45",
    2 => x"4C",
    3 => x"4C",
    4 => x"4F",
    5 => x"20",
    6 => x"54",
    7 => x"48",
    8 => x"45",
    9 => x"52",
    10 => x"45",
    11 => x"20",
    12 => x"20",
    13 => x"20",
    14 => x"20",
    15 => x"20",
    16 => x"49",
    17 => x"20",
    18 => x"41",
    19 => x"4D",
    20 => x"20",
    21 => x"4D",
    22 => x"4F",
    23 => x"48",
    24 => x"41",
    25 => x"4D",
    26 => x"45",
    27 => x"44",
    28 => x"20",
    29 => x"20",
    30 => x"20",
    31 => x"20",
    32 => x"48",
    33 => x"54",
    34 => x"53",
    35 => x"20",
    36 => x"4F",
    37 => x"4C",
    38 => x"45",
    39 => x"44",
    40 => x"20",
    41 => x"44",
    42 => x"45",
    43 => x"4D",
    44 => x"4F",
    45 => x"20",
    46 => x"20",
    47 => x"20",
    48 => x"57",
    49 => x"49",
    50 => x"54",
    51 => x"48",
    52 => x"20",
    53 => x"56",
    54 => x"48",
    55 => x"44",
    56 => x"4C",
    57 => x"20",
    58 => x"48",
    59 => x"44",
    60 => x"4C",
    61 => x"20",
    62 => x"20",
    63 => x"20"
);
constant StringLen : integer range 0 to 64 := 64;
type STATE_TYPE is (IDLE, SEND, DONE);
signal state : STATE_TYPE;
signal sendData : std_logic_vector(7 downto 0);
signal sendDataValid : std_logic;
signal byteCounter : integer:=0;
signal sendDone : std_logic;
signal oled_rst : std_logic;

component oled_cntrl
    port (
      clk : in std_logic;
      arst_n : in std_logic;
      data : in std_logic_vector(6 downto 0);
      dvalid : in std_logic;
      o_done : out std_logic;
      oled_vdd : out std_logic;
      oled_vbat : out std_logic;
      oled_rst_n : out std_logic;
      oled_dc_n : out std_logic;
      oled_sclk : out std_logic;
      oled_sdin : out std_logic
    );
  end component;

begin
    oled_cntrl_inst : oled_cntrl
    port map (
      clk => clock,
      arst_n => oled_rst,
      data => sendData(6 downto 0),
      dvalid => sendDataValid,
      o_done => sendDone,
      oled_vdd => oled_vdd,
      oled_vbat => oled_vbat,
      oled_rst_n => oled_reset_n,
      oled_dc_n => oled_dc_n,
      oled_sclk => oled_spi_clk,
      oled_sdin => oled_spi_data
    );
  
    oled_rst <= not reset;

    process (clock, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            byteCounter <= 0;
--            myString_reg <= myString;
            sendDataValid <= '0';
        elsif rising_edge(clock) then
            case state is
                when IDLE =>
                if sendDone = '0' then
                    sendData <= myString(byteCounter);
                    -- sendData <= myString_reg(((StringLen*8)-1) downto (((StringLen*8)-1)-8));
                    -- sendData <= myString_reg sll 8 ;
                    sendDataValid <= '1';
                    state <= SEND;
                end if;
                when SEND =>
                if sendDone = '1' then
                    sendDataValid <= '1';
                    byteCounter <= byteCounter + 1;
                    if byteCounter /= StringLen-1 then
                        state <= IDLE;
                    else
                        state <= DONE;
                    end if;
                end if;
                when DONE =>
                state <= DONE;
            
                when others =>
                    null;
            end case;
        end if;
    end process;

end architecture;