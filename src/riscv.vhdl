library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity RiscV is
  generic(BITS : integer := 32);
  port(
    clk: in std_logic;
    reset: in std_logic;
    curr_insn: in std_logic_vector(BITS - 1 downto 0);
    pc: out unsigned(BITS - 1 downto 0);
    outword: out std_logic_vector(BITS - 1 downto 0)
  );
end entity RiscV;

architecture Beh of RiscV is
  -- TODO: initial address is 0 by default
  constant INITIAL_ADDRESS: unsigned(BITS - 1 downto 0) := resize(x"0", BITS);
  signal pc_internal: unsigned(BITS - 1 downto 0) := INITIAL_ADDRESS;
begin
  pc_update: process (clk, reset) is
  begin
    if rising_edge(clk) then
      if reset = '1' then
        pc_internal <= INITIAL_ADDRESS;
      else
        pc_internal <= pc_internal + 4;
      end if;
    end if;
  end process pc_update;

  -- TODO: currently the only result we produce is the program counter
  outword <= curr_insn;
  pc <= pc_internal;
end architecture Beh;
