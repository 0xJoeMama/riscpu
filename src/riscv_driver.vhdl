library ieee;
library std;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.types.all;

entity RiscVDriver is
end entity RiscVDriver;

architecture Beh of RiscvDriver is
  signal clk : std_logic;
  signal reset: std_logic;
  signal outword: word_t;
  signal write_enable : std_logic;
  signal curr_insn : word_t := (others => '0');
  signal pc : addr_t;

  type insn_file is file of integer;
begin
  cpu: entity work.RiscV port map (
    clk => clk,
    reset => reset,
    inword => curr_insn,
    outword => outword,
    write_enable => write_enable,
    pc => pc
  );

  test: process is
    file infile: insn_file;
    variable j : integer := 0;
    variable insn: integer;
    variable outline: line;
  begin
    file_open(infile, "insns.bin", read_mode);
    report "Reset CPU state";
    reset <= '1';
    wait for 10 ns;

    reset <= '0';
    write_enable <= '1';
    clk <= '1';
    wait for 10 ns;

    report "Enabled write mode to map instructions to memory";
    clk <= '0';
    wait for 10 ns;

    while not endfile(infile) and j < 128 loop
      read(infile, insn);
      curr_insn <= std_logic_vector(to_signed(insn, curr_insn'length));
      wait for 10 ns;
      clk <= '1';
      wait for 10 ns;
      clk <= '0';
      wait for 10 ns;
      j := j + 1;
    end loop;

    file_close(infile);
    write_enable <= '0';
    report "Instructions written, disabling write mode";

    report "Resetting CPU state";

    clk <= '1';
    reset <= '1';
    wait for 10 ns;
    reset <= '0';
    wait for 10 ns;
    
    report "Start execution";

    for i in 0 to 100 loop
      clk <= '0';
      wait for 10 ns;
      write(outline, "0x" & to_hstring(unsigned(outword)));
      writeline(output, outline);
      clk <= '1';
      wait for 10 ns;
    end loop;
    wait;
  end process test;
end architecture Beh;
