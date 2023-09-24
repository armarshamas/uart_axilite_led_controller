library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_uartlite_tb is
end entity;

architecture tb of axi_uartlite_tb is

  component top_wrapper 
    port (
      i_clk_in1_p    : in std_logic;
      i_clk_in1_n    : in std_logic;
      i_rx           : in std_logic;
      o_tx           : out std_logic;
      o_led          : out std_logic_vector(3 downto 0);
      i_dip_switches : in std_logic_vector(3 downto 0);
      clk_out        : out std_logic;
      lck_out        : out std_logic
    );
  end component;

  constant clk_per : time := 5 ns;
  signal clock    : std_logic := '0';
  signal clock_n  : std_logic := '1';
  signal rx       : std_logic := '1';
  signal tx       : std_logic := '0';
  signal tx_reg   : std_logic_vector(8 - 1 downto 0) := (others => '0');
  signal count    : natural range 0 to RATIO - 1;
  signal count_16 : std_logic_vector(3 downto 0) := "0000";
  signal count_8  : std_logic_vector(4 downto 0) := "00000";
  signal o_led_out : std_logic_vector(3 downto 0) := "0000";
  signal i_dip_switches : std_logic_vector(3 downto 0) := "0101";
  signal EN_16x_Baud : std_logic := '0';
  signal div      : std_logic := '0';
  signal clock_lite : std_logic := '0';
  signal locked   : std_logic := '0';
  signal rx_reg   : std_logic_vector(10 - 1 downto 0) := "0100011001";

begin

  process
  begin
    wait for (clk_per / 2);
    clock <= not clock;
    clock_n <= not clock_n;
  end process;

  DUT_TB: top_wrapper
    port map (
      i_clk_in1_p     => clock,
      i_clk_in1_n     => clock_n,
      i_rx            => rx,
      o_tx            => tx,
      o_led           => o_led_out,
      i_dip_switches  => i_dip_switches,
      clk_out         => clock_lite,
      lck_out         => locked
    );

  process (done)
    procedure simtimeprint is
      variable outline : line;
    begin
      write(outline, string'("## SYSTEM_CYCLE_COUNTER "));
      write(outline, NOW / clk_per);
      write(outline, string'(" ns"));
      writeline(output, outline);
    end simtimeprint;
  begin
    if (status = '1' and done = '1') then
      simtimeprint;
      report "Test Completed Successfully" severity failure;
    elsif (status = '0' and done = '1') then
      simtimeprint;
      report "Test Failed !!!" severity failure;
    end if;
  end process;

  process (div) is
  begin
    if (rising_edge(div) and div = '1') then
      tx_reg <= tx & tx_reg(8 - 1 downto 1);
      count_8 <= count_8 + '1';
    end if;
  end process;

  process (clock_lite) is
  begin
    if rising_edge(clock_lite) then
      if (locked = '0') then
        count <= 0;
        EN_16x_Baud <= '0';
      else
        if (count = 0) then
          count <= RATIO - 1;
          EN_16x_Baud <= '1';
        else
          count <= count - 1;
          EN_16x_Baud <= '0';
        end if;
      end if;
      if EN_16x_Baud = '1' then
        if count_16 = "1111" then
          count_16 <= "0000";
        else
          count_16 <= count_16 + '1';
        end if;
      end if;
    end if;
  end process COUNTER_PROCESS;

  process (count_16) is 
  begin
    if count_16 = "1111" then
      div <= '1';
    else 
      div <= '0';
    end if;
  end process;

end tb;
