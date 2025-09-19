library ieee;
library std;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.types.all;

entity RiscVDriver is
end entity RiscVDriver;

architecture Beh of RiscvDriver is
  signal clk : std_logic := '0';
  signal reset: std_logic := '0';
  signal write_enable : std_logic := '0';
  signal curr_insn : word_t := (others => '0');

  signal state: cpu_state_t;

  type insn_file is file of integer;
begin
  cpu: entity work.RiscV port map (
    clk => clk,
    reset => reset,
    inword => curr_insn,
    write_enable => write_enable,
    state => state
  );

  test: process is
    file infile: insn_file;
    variable insn: integer;
    variable outline: line;
  begin
    file_open(infile, "insns.bin", read_mode);
    report "Reset CPU state";
    reset <= '1';
    wait for 10 ns;

    reset <= '0';
    write_enable <= '1';
    report "Enabled write mode to map instructions to memory";

    while not endfile(infile) loop
      read(infile, insn);
      curr_insn <= std_logic_vector(to_signed(insn, curr_insn'length));
      wait for 10 ns;
      clk <= '1';
      wait for 10 ns;
      clk <= '0';
      wait for 10 ns;
    end loop;

    file_close(infile);
    write_enable <= '0';
    report "Instructions written, disabling write mode";
    wait for 10 ns;

    report "Resetting CPU state";

    clk <= '1';
    reset <= '1';
    wait for 10 ns;
    reset <= '0';
    wait for 10 ns;
    
    report "Start execution";

    while state.terminate /= '1' loop
      clk <= '0';
      wait for 10 ns;
      write(outline, "pc : " & integer'image(to_integer(state.pc)) & " 0x" & to_hstring(unsigned(state.curr_insn)));
      write(outline, " -- rs1 : " & integer'image(register_t'pos(state.rs1)) & ", rs2: " & integer'image(register_t'pos(state.rs2)));
      write(outline, " .. rd = " & integer'image(register_t'pos(state.rd)));
      write(outline, " alu: " & integer'image(to_integer(signed(state.alu_res))));
      write(outline, " imm: " & integer'image(to_integer(signed(state.imm))));
      write(outline, " mem: " & to_hstring(state.mem_out));
      write(outline, " take branch?: " & std_logic'image(state.branch_taken));
      writeline(output, outline);
      clk <= '1';
      wait for 10 ns;
    end loop;

    wait;
  end process test;
end architecture Beh;
