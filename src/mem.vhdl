library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity Mem is
  generic(BYTES: integer := 1024);
  port (
  -- TODO: perhaps move away from synchronous ram?
  clk: in std_logic;
  reset: in std_logic;
  read: in std_logic;
  write: in std_logic;
  read_addr: in addr_t;
  write_addr: in addr_t;
  inword: in word_t;
  outword: out word_t
  );
end entity Mem;

architecture Beh of Mem is
  type mem_array is array(0 to BYTES - 1) of std_logic_vector(7 downto 0);
  signal cells: mem_array;
begin
  process (clk) is
  begin
    if rising_edge(clk) and write = '1' then
      cells(to_integer(write_addr)) <= inword(7 downto 0);
      cells(to_integer(write_addr) + 1) <= inword(15 downto 8);
      cells(to_integer(write_addr) + 2) <= inword(23 downto 16);
      cells(to_integer(write_addr) + 3) <= inword(31 downto 24);
    elsif falling_edge(clk) then
      if reset = '1' then
        outword <= (others => '0');
      elsif read = '1' then
        outword(7 downto 0) <= cells(to_integer(read_addr));
        outword(15 downto 8) <= cells(to_integer(read_addr) + 1);
        outword(23 downto 16) <= cells(to_integer(read_addr) + 2);
        outword(31 downto 24) <= cells(to_integer(read_addr) + 3);
      end if;
    end if;
  end process;
end architecture Beh;
