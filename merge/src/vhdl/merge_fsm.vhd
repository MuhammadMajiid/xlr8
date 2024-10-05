library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity merge_fsm is
  port
  (
    clk           : in std_logic;
    reset         : in std_logic;
    start         : in std_logic;
    fifo1_data    : in std_logic_vector(31 downto 0);
    fifo2_data    : in std_logic_vector(31 downto 0);
    fifo1_empty   : in std_logic;
    fifo2_empty   : in std_logic;
    fifo1_rden    : out std_logic;
    fifo2_rden    : out std_logic;
    merged_wren   : out std_logic;
    merged_rddata : out std_logic_vector(31 downto 0);
    done          : out std_logic
  );
end entity;

architecture rtl of merge_fsm is
  type STATE_TYPE is (IDLE, COMPARE, FLUSH_FIFO, WRITE, DONE);
  signal state : STATE_TYPE;
begin

  process (clk)
  begin
    if reset = '1' then
      state <= IDLE;
    elsif rising_edge(clk) then
      case state is

        when IDLE =>
          if start = '1' then
            state <= COMPARE;
          end if;

        when COMPARE =>
          if (fifo1_empty = '0') and (fifo2_empty = '0') then
            if (fifo1_data > fifo2_data) then
              merged_rddata <= fifo1_data;
              merged_wren   <= '1';
              fifo1_rden    <= '1';
            else
              merged_rddata <= fifo2_data;
              merged_wren   <= '1';
              fifo2_rden    <= '1';
            end if;
            state <= WRITE;
          elsif (fifo1_empty = '1') then
            state      <= FLUSH_FIFO;
            fifo2_rden <= '1';
          elsif (fifo2_empty = '1') then
            state      <= FLUSH_FIFO;
            fifo1_rden <= '1';
          else
            state <= DONE;
          end if;

        when FLUSH_FIFO =>
          if (fifo1_empty = '1') then
            merged_rddata <= fifo2_data;
            merged_wren   <= '1';
            fifo2_rden    <= '1';
          elsif (fifo2_empty = '1') then
            merged_rddata <= fifo1_data;
            merged_wren   <= '1';
            fifo1_rden    <= '1';
          else
            state       <= DONE;
            fifo1_rden  <= '0';
            fifo2_rden  <= '0';
            merged_wren <= '0';
          end if;

        when WRITE =>
          fifo1_rden  <= '0';
          fifo2_rden  <= '0';
          merged_wren <= '0';
          state       <= COMPARE;

        when DONE =>
          done <= '1';
          if start = '0' then
            done  <= '0';
            state <= IDLE;
          end if;

        when others =>
          null;
      end case;
    end if;
  end process;
end architecture;