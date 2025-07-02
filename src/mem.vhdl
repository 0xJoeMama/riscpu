library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity Mem is
  generic(BYTES: integer := 1024);
  port (
    -- TODO: perhaps move away from synchronous ram?
    clk: in std_logic;
    write: in std_logic;
    read_addr: in addr_t;
    insn_addr: in addr_t;
    write_addr: in addr_t;
    inword: in word_t;
    outinsn: out word_t;
    outword: out word_t
  );
end entity Mem;

architecture Beh of Mem is
  type mem_array is array(natural range <>) of word_t;
  signal ram: mem_array(0 to BYTES / 4 - 1) := (others => (others => '0'));

  signal real_read_addr: addr_t;
  signal real_write_addr: addr_t;
  signal real_insn_addr: addr_t;

  -- used to bring the addresses given to us within the address range we can query
  -- basically performs a % BYTES operation
  constant normalization_mask : addr_t := to_unsigned(BYTES, 32) - 1;

  -- the following 2 functions implement little-endianness for the CPU
  function flip_endianess(
    word: word_t
  ) return word_t is
  begin
    -- lower address will be lower bytes
    return word(7 downto 0) & word(15 downto 8) & word(23 downto 16) & word(31 downto 24);
  end function;
begin
  -- we trash the bottom 2 bytes
  real_read_addr  <= shift_right(read_addr and normalization_mask, 2);
  real_insn_addr  <= shift_right(insn_addr and normalization_mask, 2);
  real_write_addr <= shift_right(write_addr and normalization_mask, 2);

  process (clk) is
  begin
    if rising_edge(clk) then
      if write = '1' then
        ram(to_integer(real_write_addr)) <= flip_endianess(inword);
      end if;
    end if;
  end process;

  outword <= flip_endianess(ram(to_integer(real_read_addr)));
  outinsn <= flip_endianess(ram(to_integer(real_insn_addr)));
end architecture Beh;
