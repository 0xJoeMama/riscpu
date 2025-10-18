library ieee;
library std;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.types.all;

entity Rom is
  generic (
    rom_size: natural := 256; 
    rom_file: string := "insns.bin"
  );
  port (
    addr: in unsigned(11 downto 0);
    outword: out word_t
  );
end entity Rom;

architecture Beh of Rom is
  type Rom_t is array(0 to rom_size - 1) of word_t;

  impure function read_rom_from_file return Rom_t is
    type insns is file of integer;
    file data_file: insns open READ_MODE is rom_file;
    variable insn: integer;
    variable rom_var: Rom_t;
    variable i : natural := 0;
  begin
    while not endfile(data_file) and i < rom_size loop
      read(data_file, insn);
      rom_var(i) := std_logic_vector(to_signed(insn, word_t'length));
      i := i + 1;
    end loop;

    while i < rom_size loop
      rom_var(i) := (others => '0');
      i := i + 1;
    end loop;

    return rom_var;
  end function;

  signal rom_data: Rom_t := read_rom_from_file;
  attribute rom_style : string;
  attribute rom_style of rom_data : signal is "block";
begin
  outword <= rom_data(to_integer(unsigned(addr)));
end architecture Beh;
