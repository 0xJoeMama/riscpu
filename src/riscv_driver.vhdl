library ieee;
library std;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.types.all;

entity RiscVDriver is
end entity RiscVDriver;

architecture Beh of RiscvDriver is
  signal clk: std_logic := '0';
  signal reset : std_logic := '0';

  signal debug_port: word_t;
  signal kill_cpu : std_logic;
begin
  mommy: entity work.Motherboard port map (
    clk => clk,
    reset => reset,
    debug_port => debug_port,
    kill_me => kill_cpu
  );

  clk_stim: process is
    variable continue: boolean := true;
    variable outline: line;
  begin
    reset <= '1';
    wait for 20 ns;

    clk <= '1';
    wait for 20 ns;
    clk <= '0';
    wait for 20 ns;

    reset <= '0';
    wait for 20 ns;

    -- run for at least 256 cycles to make sure all of ROM is mapped into RAM
    for i in 0 to 255 loop
      clk <= '1';
      wait for 20 ns;
      clk <= '0';
      wait for 20 ns;
    end loop;

    while continue loop
      write(outline, "0x" & to_hstring(debug_port));
      writeline(output, outline);

      if kill_cpu = '1' then
        continue := false;
      else
        clk <= '1';
        wait for 20 ns;
        clk <= '0';
        wait for 20 ns;
      end if;
    end loop;

    report "Exiting system as die vector was written to";
    wait;
  end process clk_stim;
end architecture Beh;

