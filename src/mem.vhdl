library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mem is
  generic(
    ADDRESS_BITS : integer := 32;
    WORDS: integer := 1024
  );
  port (
  -- TODO: perhaps move away from synchronous ram?
  clk: in std_logic;
  reset: in std_logic;
  read: in std_logic;
  write: in std_logic;
  addr: in unsigned(ADDRESS_BITS - 1 downto 0);
  inword: in std_logic_vector(ADDRESS_BITS - 1 downto 0);
  outword: out std_logic_vector(ADDRESS_BITS - 1 downto 0)
  );
end entity Mem;

architecture Beh of Mem is
  type mem_array is array(0 to WORDS - 1) of std_logic_vector(ADDRESS_BITS - 1 downto 0);
  signal cells: mem_array;
begin
  process (reset) is
  begin
    if rising_edge(clk) then
      if reset /= '1' then
        if read = '1' then
          outword <= cells(to_integer(addr));
        elsif write = '1' then
          cells(to_integer(addr)) <= inword;
        end if;
      else
        outword <= (others => '0');
      end if;
    end if;
  end process;
end architecture Beh;
