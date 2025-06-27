library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity RiscV is
  generic(BITS : integer := 32);
  port(
    clk: in std_logic;
    reset: in std_logic;
    outword: out std_logic_vector(BITS - 1 downto 0)
  );
end entity RiscV;

architecture Beh of RiscV is
  -- TODO: THE INITIAL ADDRESS OF EXECUTION IS FFFF0(I randomly chose this, in the future it should be turned into something standard)
  constant INITIAL_ADDRESS: unsigned(BITS - 1 downto 0) := resize(x"FFFFF", BITS);
  signal pc: unsigned(BITS - 1 downto 0) := INITIAL_ADDRESS;
begin
  pc_update: process (clk, reset) is
  begin
    if rising_edge(clk) then
      if reset = '1' then
        pc <= INITIAL_ADDRESS;
      else
        pc <= pc + 4;
      end if;
    end if;
  end process pc_update;

  -- TODO: currently the only result we produce is the program counter
  outword <= std_logic_vector(pc);
end architecture Beh;
