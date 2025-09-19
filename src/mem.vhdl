library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity Mem is
  generic(BYTES: integer := 1024);
  port (
    clk: in std_logic;
    mem_mode: in MemMode_t;
    read_addr: in addr_t;
    sign_extend: in std_logic;
    write_addr: in addr_t;
    write_enable: in std_logic;
    inword: in word_t;
    outword: out word_t;
    insn_addr: in addr_t;
    insn: out word_t
  );
end entity Mem;

architecture Beh of Mem is
  type mem_array is array(natural range <>) of word_t;
  signal ram: mem_array(0 to BYTES / 4 - 1) := (others => (others => '0'));

  signal aligned_read_addr: addr_t := (others => '0');
  signal aligned_write_addr: addr_t := (others => '0');
  signal aligned_insn_addr: addr_t := (others => '0');

  -- used to bring the addresses given to us within the address range we can query
  -- basically performs a % BYTES operation
  constant normalization_mask : addr_t := to_unsigned(BYTES, 32) - 1;

  signal old_write_cell_contents: word_t := (others => '0');
  signal full_outword: word_t := (others => '0');

  type outwords_t is array(3 downto 0) of std_logic_vector(31 downto 0);
  signal outwords : outwords_t := (others => (others => '0'));

  signal read_wordbyte_idx : unsigned(1 downto 0);
  signal read_wordhalf_idx : unsigned(0 downto 0);
  signal read_byte : std_logic_vector(7 downto 0);
  signal read_half : std_logic_vector(15 downto 0);

  -- the following 2 functions implement little-endianness for the CPU
  function flip_endianess(
    word: word_t
  ) return word_t is
  begin
    -- lower address will be lower bytes
    return word(7 downto 0) & word(15 downto 8) & word(23 downto 16) & word(31 downto 24);
  end function;
begin
  -- we trash the bottom 2 bits
  aligned_read_addr  <= shift_right(read_addr and normalization_mask, 2);
  aligned_insn_addr  <= shift_right(insn_addr and normalization_mask, 2);
  aligned_write_addr <= shift_right(write_addr and normalization_mask, 2);

  read_wordbyte_idx <= unsigned(read_addr(1 downto 0));
  read_wordhalf_idx <= unsigned(read_addr(1 downto 1));

  write: process (clk, write_addr, old_write_cell_contents, mem_mode, inword, write_enable) is
    variable addr: natural;
    variable to_write : std_logic_vector(31 downto 0);
    variable wordbyte_idx : natural;
    variable wordhalf_idx : natural;
  begin
    addr := to_integer(write_addr and normalization_mask);
    wordbyte_idx := addr mod 4;
    wordhalf_idx := (wordbyte_idx) / 2;

    if mem_mode /= Non and write_enable = '1' then
      to_write := old_write_cell_contents;
      case mem_mode is
        when Byte => 
          to_write(wordbyte_idx + 7 downto wordbyte_idx) := inword(7 downto 0);
        when Half =>
          to_write(15 + 16 * wordhalf_idx downto 16 * wordhalf_idx) := inword(15 downto 0);
        when others => 
          to_write := inword; -- save the whole word
      end case;

      if rising_edge(clk) then
        ram(to_integer(aligned_write_addr)) <= flip_endianess(to_write);
      end if;
    end if;
  end process;

  insn <= flip_endianess(ram(to_integer(aligned_insn_addr)));
  full_outword <= flip_endianess(ram(to_integer(aligned_read_addr)));
  old_write_cell_contents <= flip_endianess(ram(to_integer(aligned_write_addr)));

  read_byte <= full_outword(to_integer(read_wordbyte_idx) * 8 + 7 downto to_integer(read_wordbyte_idx) * 8);
  read_half <= full_outword(to_integer(read_wordhalf_idx) * 16 + 15 downto to_integer(read_wordhalf_idx) * 16);

  outwords(MemMode_t'pos(Non)) <= (others => '0');
  outwords(MemMode_t'pos(Byte)) <= std_logic_vector(resize(unsigned(read_byte), 32)) when sign_extend = '0' else
                                   std_logic_vector(resize(signed(read_byte), 32));
  outwords(MemMode_t'pos(Half)) <= std_logic_vector(resize(unsigned(read_half), 32)) when sign_extend = '0' else
                                   std_logic_vector(resize(signed(read_half), 32));
  outwords(MemMode_t'pos(Word)) <= full_outword;

  outword <= outwords(MemMode_t'pos(mem_mode));
end architecture Beh;
