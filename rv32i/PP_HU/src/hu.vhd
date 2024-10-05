library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hu is
  port
  (
    rs1_d         : in std_logic_vector(4 downto 0);
    rs2_d         : in std_logic_vector(4 downto 0);
    rs1_ex        : in std_logic_vector(4 downto 0);
    rs2_ex        : in std_logic_vector(4 downto 0);
    rd_ex         : in std_logic_vector(4 downto 0);
    rd_mem        : in std_logic_vector(4 downto 0);
    rd_wb         : in std_logic_vector(4 downto 0);
    regwrite_mem  : in std_logic;
    regwrite_wb   : in std_logic;
    pcsrc_ex      : in std_logic;
    resultsrc_ex  : in std_logic;
    forwarda_ex   : out std_logic_vector(1 downto 0);
    forwardb_ex   : out std_logic_vector(1 downto 0);
    stall_f       : out std_logic;
    stall_d       : out std_logic;
    flush_d       : out std_logic;
    flush_ex      : out std_logic
  );
end entity;

architecture rtl of hu is
signal lw_detection : std_logic;
begin

  -- Forwarding
  forwarda_ex <= "10" when (((rs1_ex = rd_mem) and (regwrite_mem = '1')) and (rs1_ex /= "00000")) else
                  "01" when (((rs1_ex = rd_wb) and (regwrite_wb = '1')) and (rs1_ex /= "00000")) else
                  "00";
  forwardb_ex <= "10" when (((rs2_ex = rd_mem) and (regwrite_mem = '1')) and (rs2_ex /= "00000")) else
                  "01" when (((rs2_ex = rd_wb) and (regwrite_wb = '1')) and (rs2_ex /= "00000")) else
                  "00";
  
  -- Stalling
  lw_detection <= '1' when ((resultsrc_ex = '1') and ((rs1_d = rd_ex) or (rs2_d = rd_ex))) else '0';
  stall_f <= lw_detection;
  stall_d <= lw_detection;

  -- Flushing
  flush_d <= pcsrc_ex;
  flush_ex <= (pcsrc_ex or lw_detection);

end architecture;