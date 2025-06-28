library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package types is
  constant WORD_SIZE : integer := 32;
  subtype word_t is std_logic_vector(WORD_SIZE - 1 downto 0);
  subtype addr_t is unsigned(WORD_SIZE - 1 downto 0);
end package types;

package body types is
end package body types;
