library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity merge_top is
  port
  (
    clk              : in std_logic;
    reset            : in std_logic;
    start            : in std_logic;
    fifo_wrdata       : in std_logic_vector(31 downto 0);
    fifo1_wren        : in std_logic;
    fifo2_wren        : in std_logic;
    merged_rden   : in std_logic;
    merged_dout : out std_logic_vector(31 downto 0);
    done             : out std_logic
  );
end entity;

architecture struct of merge_top is
    component merge_fsm
        port (
          clk : in std_logic;
          reset : in std_logic;
          start : in std_logic;
          fifo1_data : in std_logic_vector(31 downto 0);
          fifo2_data : in std_logic_vector(31 downto 0);
          fifo1_empty : in std_logic;
          fifo2_empty : in std_logic;
          fifo1_rden : out std_logic;
          fifo2_rden : out std_logic;
          merged_wren : out std_logic;
          merged_rddata : out std_logic_vector(31 downto 0);
          done : out std_logic
        );
      end component;

      component array_fifo
        port (
          clk : in std_logic;
          srst : in std_logic;
          din : in std_logic_vector(31 downto 0);
          wr_en : in std_logic;
          rd_en : in std_logic;
          dout : out std_logic_vector(31 downto 0);
          empty : out std_logic;
          full : out std_logic
        );
      end component;

      component merge_fifo
        port (
          clk : in std_logic;
          srst : in std_logic;
          din : in std_logic_vector(31 downto 0);
          wr_en : in std_logic;
          rd_en : in std_logic;
          dout : out std_logic_vector(31 downto 0);
          empty : out std_logic;
          full : out std_logic
        );
      end component;
begin

 merge_fsm_inst : merge_fsm
  port map (
    clk => clk,
    reset => reset,
    start => start,
    fifo1_data => fifo1_data,
    fifo2_data => fifo2_data,
    fifo1_empty => fifo1_empty,
    fifo2_empty => fifo2_empty,
    fifo1_rden => fifo1_rden,
    fifo2_rden => fifo2_rden,
    merged_wren => merged_wren,
    merged_rddata => merged_rddata,
    done => done
  );

  arr1 : array_fifo
  port map (
    clk => clk,
    srst => reset,
    din => fifo_wrdata,
    wr_en => fifo1_wren,
    rd_en => fifo1_rden,
    dout => fifo1_data,
    empty => fifo1_empty,
    full => open,
  );

  arr2 : array_fifo
  port map (
    clk => clk,
    srst => reset,
    din => fifo_wrdata,
    wr_en => fifo2_wren,
    rd_en => fifo2_rden,
    dout => fifo2_data,
    empty => fifo2_empty,
    full => open,
  );

  arr1 : merge_fifo
  port map (
    clk => clk,
    srst => reset,
    din => merged_rddata,
    wr_en => merged_wren,
    rd_en => merged_rden,
    dout => merged_dout,
    empty => open,
    full => open,
  );

end architecture;