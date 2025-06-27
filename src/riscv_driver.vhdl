library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity RiscVDriver is
end entity RiscVDriver;

architecture Beh of RiscvDriver is
  signal clk : std_logic;
  signal reset: std_logic;
  signal outword: std_logic_vector(31 downto 0);
begin
  cpu: entity work.RiscV port map (
    clk => clk,
    reset => reset,
    outword => outword
  );

  test: process is
    variable outline: line;
  begin
    reset <= '1';
    wait for 10 ns;
    reset <= '0';
    wait for 10 ns;

    for i in 0 to 100 loop
      clk <= '1';
      wait for 10 ns;
      write(outline, "0x" & to_hstring(unsigned(outword)));
      writeline(output, outline);
      clk <= '0';
      wait for 10 ns;
    end loop;
    wait;
  end process test;
end architecture Beh;
