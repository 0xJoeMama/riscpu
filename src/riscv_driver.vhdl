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

  signal dump : std_logic := '0';
  signal kill: std_logic;
  signal inspection_pc : addr_t;

  signal debug_port: word_t;
begin
  mommy: entity work.Motherboard port map (
    clk => clk,
    reset => reset,
    debug_port => debug_port,
    dump => dump,
    kill_me => kill,
    inspection_pc => inspection_pc
  );

  clk_stim: process is
    variable outline: line;
  begin
    reset <= '1';
    wait for 10 ns;
    reset <= '0';
    wait for 10 ns;
    for i in 0 to 256 loop
      clk <= '1';
      wait for 10 ns;
      clk <= '0';
      wait for 10 ns;
    end loop;

    reset <= '1';
    wait for 10 ns;
    reset <= '0';
    wait for 10 ns;

    loop
      if dump = '0' then
        write(outline, "0x" & to_hstring(debug_port));
        writeline(output, outline);

        if debug_port = x"00000000" then
          for i in 0 to 3 loop
            clk <= '1';
            wait for 10 ns;
            clk <= '0';
            wait for 10 ns;
          end loop;

          report "Begin RAM dump";

          inspection_pc <= to_unsigned(0, inspection_pc'length);
          dump <= '1';
        end if;
      else
        inspection_pc <= inspection_pc + 1;
        write(outline, integer'image(to_integer(inspection_pc)) & ": 0x" & to_hstring(debug_port));
        writeline(output, outline);

        if kill = '1' then
          wait;
        end if;
      end if;

      clk <= '1';
      wait for 10 ns;
      clk <= '0';
      wait for 10 ns;
    end loop;
  end process;
end architecture Beh;
