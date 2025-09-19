library ieee;
library std;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.types.all;

entity MemTb is
end entity MemTb;

architecture Beh of MemTb is
  signal clk : std_logic := '0';
  signal write_enable : std_logic := '0';
  signal curr_insn : word_t := (others => '0');

  signal addr: addr_t;
  signal outinsn: word_t;
  signal mem_mode: MemMode_t;
  signal sign: std_logic;
  type insn_file is file of integer;
begin
  cpu: entity work.Mem port map (
    clk => clk,
    inword => curr_insn,
    write_enable => write_enable,
    read_addr => addr,
    write_addr => addr,
    insn_addr => addr,
    insn => outinsn,
    mem_mode => mem_mode,
    sign_extend => sign
  );

  test: process is
    file infile: insn_file;
    variable insn: integer;
    variable outline: line;
  begin
    addr <= (others => '0');
    file_open(infile, "insns.bin", read_mode);
    wait for 10 ns;
    mem_mode <= Word;
    write_enable <= '1';
    report "Writing data to memory";

    while not endfile(infile) loop
      read(infile, insn);
      curr_insn <= std_logic_vector(to_signed(insn, curr_insn'length));
      wait for 10 ns;
      clk <= '1';
      wait for 10 ns;
      addr <= addr + 4;
      write(outline, "addr : " & integer'image(to_integer(addr)));
      writeline(output, outline);
      clk <= '0';
      wait for 10 ns;
    end loop;

    file_close(infile);
    addr <= (others => '0');
    write_enable <= '0';
    report "Instructions written, disabling write mode";

    clk <= '1';
    wait for 10 ns;
    
    report "Iterating memory word by word";

    while outinsn /= x"00000000" loop
      clk <= '0';
      wait for 10 ns;
      write(outline, "0x" & to_hstring(unsigned(outinsn)));
      writeline(output, outline);
      clk <= '1';
      wait for 10 ns;
      addr <= addr + 4;
    end loop;

    wait;
  end process test;
end architecture Beh;
