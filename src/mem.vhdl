library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity Mem is
  generic(WORDS: integer := 1024);
  port (
  -- TODO: perhaps move away from synchronous ram?
  clk: in std_logic;
  reset: in std_logic;
  read: in std_logic;
  write: in std_logic;
  addr: in addr_t;
  inword: in word_t;
  outword: out word_t
  );
end entity Mem;

architecture Beh of Mem is
  type mem_array is array(0 to WORDS - 1) of word_t;
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
