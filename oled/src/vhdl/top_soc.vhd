library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
  port
  (
    -- Global Interface
    i_reset : in std_logic;
    i_clock : in std_logic;
    -- OLED Interface
    oled_spi_clk  : out std_logic;
    oled_spi_data : out std_logic;
    oled_vdd      : out std_logic;
    oled_vbat     : out std_logic;
    oled_reset_n  : out std_logic;
    oled_dc_n     : out std_logic;
    -- User Interface
    i_data           : in std_logic_vector(7 downto 0);
    i_dvalid         : in std_logic;
    i_data_command_n : in std_logic;
    o_done           : out std_logic
  );
end entity top;

architecture structure of top is
  -- Signal Declaration
  signal oled_rst : std_logic;
  -- Component Declaration
  component oled_cntrl
    port
    (
      clk            : in std_logic;
      arst_n         : in std_logic;
      data           : in std_logic_vector(6 downto 0);
      dvalid         : in std_logic;
      data_command_n : in std_logic;
      o_done         : out std_logic;
      oled_vdd       : out std_logic;
      oled_vbat      : out std_logic;
      oled_rst_n     : out std_logic;
      oled_dc_n      : out std_logic;
      oled_sclk      : out std_logic;
      oled_sdin      : out std_logic
    );
  end component;

begin
  oled_cntrl_inst : oled_cntrl
  port map
  (
    clk            => i_clock,
    arst_n         => oled_rst,
    data           => i_data(6 downto 0),
    dvalid         => i_dvalid,
    data_command_n => i_data_command_n;
    o_done         => o_done,
    oled_vdd       => oled_vdd,
    oled_vbat      => oled_vbat,
    oled_rst_n     => oled_reset_n,
    oled_dc_n      => oled_dc_n,
    oled_sclk      => oled_spi_clk,
    oled_sdin      => oled_spi_data
  );

  oled_rst <= not i_reset;

end architecture;