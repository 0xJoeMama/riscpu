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
  type initial_insns is array(0 to 127) of word_t;
  signal insns: initial_insns;

  signal pc: addr_t := (others => '0');
  signal curr_insn : word_t := (others => '0');
  type insn_file is file of integer;
begin
  cpu: entity work.RiscV port map (
    clk => clk,
    curr_insn => curr_insn,
    reset => reset,
    outword => outword,
    pc => pc
  );

  test: process is
    file infile: insn_file;
    variable j : integer := 0;
    variable insn: integer;
    variable outline: line;
  begin
    file_open(infile, "insns.bin", read_mode);

    while not endfile(infile) and j < 128 loop
      read(infile, insn);
      insns(j) <= std_logic_vector(to_signed(insn, insns(j)'length));
      j := j + 1;
    end loop;

    file_close(infile);

    reset <= '1';
    wait for 10 ns;
    reset <= '0';
    wait for 10 ns;

    clk <= '1';
    wait for 10 ns;
    clk <= '0';
    wait for 10 ns;

    for i in 0 to 100 loop
      write(outline, "0x" & to_hstring(unsigned(outword)));
      writeline(output, outline);
      clk <= '1';
      wait for 10 ns;
      clk <= '0';
      wait for 10 ns;
    end loop;
    wait;
  end process test;

  process (clk) is
  begin
    if falling_edge(clk) then
      curr_insn <= insns(to_integer(shift_right(pc, 2)));
    end if;
  end process;
end architecture Beh;
