library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity core_cntrl is
  generic (
    KERNEL_SIZE : integer := 3; -- 3x3 Kernel
    LINE_LENGTH : integer := 512; -- 512x512 Image
    PIXEL_SIZE  : integer := 8 -- 8-bit Pixel
  );
  port (
    clk              : in std_logic;
    reset_n          : in std_logic;
    pixel_in         : in std_logic_vector(PIXEL_SIZE - 1 downto 0);
    pixel_valid      : in std_logic;
    pixel_buff       : out std_logic_vector(((KERNEL_SIZE ** 2) * PIXEL_SIZE) - 1 downto 0);
    pixel_buff_valid : out std_logic;
    intr             : out std_logic
  );
end entity;

architecture rtl of core_cntrl is
  -- Components
  component line_buffer
    generic (
      KERNEL_SIZE : integer;
      LINE_LENGTH : integer;
      PIXEL_SIZE  : integer
    );
    port (
      clk               : in std_logic;
      reset_n           : in std_logic;
      pixel_in          : in std_logic_vector(PIXEL_SIZE - 1 downto 0);
      pixel_valid       : in std_logic;
      read_pixel_vector : in std_logic;
      pixel_vector      : out std_logic_vector((KERNEL_SIZE * PIXEL_SIZE) - 1 downto 0)
    );
  end component;
  --   Signals
  signal pixel_counter, rd_counter                                              : unsigned(integer(ceil(log2(real(LINE_LENGTH)))) - 1 downto 0);
  signal tot_pix_count                                                          : unsigned(integer(ceil(log2(real(5 * LINE_LENGTH)))) - 1 downto 0);
  signal line_valid, line_rd                                                    : unsigned(KERNEL_SIZE downto 0); -- 4 Lines for the 3x3 kernel
  signal current_wrline, current_rdline                                         : unsigned(integer(ceil(log2(real(KERNEL_SIZE + 1)))) - 1 downto 0);
  signal pixel_vector_ln0, pixel_vector_ln1, pixel_vector_ln2, pixel_vector_ln3 : std_logic_vector((KERNEL_SIZE * PIXEL_SIZE) - 1 downto 0);
  signal rd_line_en                                                             : std_logic;
  type FSM is (IDLE, RDBUFF);
  signal state            : FSM;
  attribute keep          : boolean;
  attribute keep of state : signal is true;
begin
  --   -------------------  Writing -----------------
  -- Pixel Counter
  process (clk)
  begin
    if rising_edge(clk) then
      if reset_n = '0' then
        pixel_counter <= to_unsigned(0, pixel_counter'length);
      elsif pixel_valid = '1' then
        pixel_counter <= pixel_counter + to_unsigned(1, pixel_counter'length);
      end if;
    end if;
  end process;
  -- Current Write Line
  process (clk)
  begin
    if rising_edge(clk) then
      if reset_n = '0' then
        current_wrline <= to_unsigned(0, current_wrline'length);
      elsif (pixel_counter = to_unsigned(511, pixel_counter'length) and pixel_valid = '1') then
        current_wrline <= current_wrline + to_unsigned(1, current_wrline'length);
      end if;
    end if;
  end process;
  -- Line Valid
  process (current_wrline, pixel_valid)
  begin
    if pixel_valid = '1' then
      line_valid                             <= to_unsigned(0, line_valid'length);
      line_valid(to_integer(current_wrline)) <= '1';
    else
      line_valid <= to_unsigned(0, line_valid'length);
    end if;
  end process;

  --   -------------------  Reading -----------------
  -- Total Pixel Counter
  process (clk)
  begin
    if rising_edge(clk) then
      if reset_n = '0' then
        tot_pix_count <= to_unsigned(0, tot_pix_count'length);
      elsif (pixel_valid = '1' and rd_line_en = '0') then
        tot_pix_count <= tot_pix_count + to_unsigned(1, tot_pix_count'length);
      elsif (pixel_valid = '0' and rd_line_en = '1') then
        tot_pix_count <= tot_pix_count - to_unsigned(1, tot_pix_count'length);
      end if;
    end if;
  end process;
  -- Read Line Enable
  process (clk)
  begin
    if rising_edge(clk) then
      if reset_n = '0' then
        state      <= IDLE;
        rd_line_en <= '0';
        intr       <= '0';
      else
        case state is
          when IDLE =>
            intr <= '0';
            if (tot_pix_count >= to_unsigned((LINE_LENGTH * KERNEL_SIZE), tot_pix_count'length)) then
              rd_line_en <= '1';
              state      <= RDBUFF;
            end if;
          when RDBUFF =>
            if (rd_counter = to_unsigned((LINE_LENGTH - 1), rd_counter'length)) then
              state      <= IDLE;
              rd_line_en <= '0';
              intr       <= '1';
            end if;

          when others =>
            state <= IDLE;
        end case;
      end if;
    end if;
  end process;

  process (clk)
  begin
    if rising_edge(clk) then
      pixel_buff_valid <= rd_line_en;
    end if;
  end process;
  -- pixel_buff_valid <= rd_line_en;
  -- Read Counter
  process (clk)
  begin
    if rising_edge(clk) then
      if reset_n = '0' then
        rd_counter <= to_unsigned(0, rd_counter'length);
      elsif rd_line_en = '1' then
        rd_counter <= rd_counter + to_unsigned(1, rd_counter'length);
      end if;
    end if;
  end process;
  -- Current Read Line
  process (clk)
  begin
    if rising_edge(clk) then
      if reset_n = '0' then
        current_rdline <= to_unsigned(0, current_rdline'length);
      elsif (rd_counter = to_unsigned(511, rd_counter'length) and rd_line_en = '1') then
        current_rdline <= current_rdline + to_unsigned(1, current_rdline'length);
      end if;
    end if;
  end process;
  --   Reading Buffer
  process (current_rdline, pixel_vector_ln3, pixel_vector_ln2, pixel_vector_ln1, pixel_vector_ln0)
  begin
    case current_rdline is
      when "00" =>
        pixel_buff <= pixel_vector_ln2 & pixel_vector_ln1 & pixel_vector_ln0;
      when "01" =>
        pixel_buff <= pixel_vector_ln3 & pixel_vector_ln2 & pixel_vector_ln1;
      when "10" =>
        pixel_buff <= pixel_vector_ln0 & pixel_vector_ln3 & pixel_vector_ln2;
      when "11" =>
        pixel_buff <= pixel_vector_ln1 & pixel_vector_ln0 & pixel_vector_ln3;

      when others =>
        pixel_buff <= pixel_vector_ln2 & pixel_vector_ln1 & pixel_vector_ln0;
    end case;
  end process;
  --   Reading Buffer Enable
  process (current_rdline, rd_line_en)
  begin
    case current_rdline is
      when "00" =>
        line_rd(0) <= rd_line_en;
        line_rd(1) <= rd_line_en;
        line_rd(2) <= rd_line_en;
        line_rd(3) <= '0';
      when "01" =>
        line_rd(0) <= '0';
        line_rd(1) <= rd_line_en;
        line_rd(2) <= rd_line_en;
        line_rd(3) <= rd_line_en;
      when "10" =>
        line_rd(0) <= rd_line_en;
        line_rd(1) <= '0';
        line_rd(2) <= rd_line_en;
        line_rd(3) <= rd_line_en;
      when "11" =>
        line_rd(0) <= rd_line_en;
        line_rd(1) <= rd_line_en;
        line_rd(2) <= '0';
        line_rd(3) <= rd_line_en;

      when others =>
        line_rd(0) <= rd_line_en;
        line_rd(1) <= rd_line_en;
        line_rd(2) <= rd_line_en;
        line_rd(3) <= '0';
    end case;
  end process;

  -- Component Mapping
  line_buff_0 : line_buffer
  generic map(
    KERNEL_SIZE => KERNEL_SIZE,
    LINE_LENGTH => LINE_LENGTH,
    PIXEL_SIZE  => PIXEL_SIZE
  )
  port map
  (
    clk               => clk,
    reset_n           => reset_n,
    pixel_in          => pixel_in,
    pixel_valid       => line_valid(0),
    read_pixel_vector => line_rd(0),
    pixel_vector      => pixel_vector_ln0
  );

  line_buff_1 : line_buffer
  generic map(
    KERNEL_SIZE => KERNEL_SIZE,
    LINE_LENGTH => LINE_LENGTH,
    PIXEL_SIZE  => PIXEL_SIZE
  )
  port map
  (
    clk               => clk,
    reset_n           => reset_n,
    pixel_in          => pixel_in,
    pixel_valid       => line_valid(1),
    read_pixel_vector => line_rd(1),
    pixel_vector      => pixel_vector_ln1
  );

  line_buff_2 : line_buffer
  generic map(
    KERNEL_SIZE => KERNEL_SIZE,
    LINE_LENGTH => LINE_LENGTH,
    PIXEL_SIZE  => PIXEL_SIZE
  )
  port map
  (
    clk               => clk,
    reset_n           => reset_n,
    pixel_in          => pixel_in,
    pixel_valid       => line_valid(2),
    read_pixel_vector => line_rd(2),
    pixel_vector      => pixel_vector_ln2
  );

  line_buff_3 : line_buffer
  generic map(
    KERNEL_SIZE => KERNEL_SIZE,
    LINE_LENGTH => LINE_LENGTH,
    PIXEL_SIZE  => PIXEL_SIZE
  )
  port map
  (
    clk               => clk,
    reset_n           => reset_n,
    pixel_in          => pixel_in,
    pixel_valid       => line_valid(3),
    read_pixel_vector => line_rd(3),
    pixel_vector      => pixel_vector_ln3
  );
end architecture;