library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity image_inv is
  port
  (
    -- Global Signals
    i_clk : in std_logic;
    -- i_reset_n : in std_logic; -- not used currently
    -- Slave Interface
    s_axis_data  : in std_logic_vector(31 downto 0);
    s_axis_valid : in std_logic;
    s_axis_ready : out std_logic;
    -- Master Interface
    m_axis_data  : out std_logic_vector(31 downto 0);
    m_axis_valid : out std_logic;
    m_axis_ready : in std_logic
  );
end entity;

architecture rtl of image_inv is
    signal mdata_uns, sdata_uns : unsigned(31 downto 0) := (others => '0');
begin
  process (i_clk)
  begin
    if rising_edge(i_clk) then
      if (s_axis_valid and s_axis_ready) = '1' then
        mdata_uns(7 downto 0)   <= x"FF" - sdata_uns(7 downto 0);
        mdata_uns(15 downto 8)  <= x"FF" - sdata_uns(15 downto 8);
        mdata_uns(23 downto 16) <= x"FF" - sdata_uns(23 downto 16);
        mdata_uns(31 downto 24) <= x"FF" - sdata_uns(31 downto 24);
      end if;
    end if;
  end process;

  process (i_clk)
  begin
    if rising_edge(i_clk) then
      m_axis_valid <= s_axis_valid;
    end if;
  end process;

  s_axis_ready <= m_axis_ready;
end architecture;