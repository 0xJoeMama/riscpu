library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.types.all;

entity RiscV is
  port(
    clk: in std_logic;
    reset: in std_logic;
    curr_insn: in word_t;
    pc: out addr_t;
    outword: out word_t
  );
end entity RiscV;

architecture Beh of RiscV is
  -- TODO: initial address is 0 by default
  constant INITIAL_ADDRESS: addr_t := resize(x"0", WORD_SIZE);
  signal pc_internal: addr_t := INITIAL_ADDRESS;
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
