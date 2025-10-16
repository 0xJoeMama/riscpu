library ieee;
use ieee.std_logic_1164.all;
use work.types.all;

entity InstructionFetch is
  port (
  clk: in std_logic;
  clear: in std_logic;
  pc : in addr_t;
  ininsn: in word_t;
  insn: out if_state_t
  );
end entity InstructionFetch;

architecture Beh of InstructionFetch is
begin
  if_id: process (clk, clear) is
  begin
    if clear = '1' then
      insn <= ZERO_IF_STATE;
    elsif rising_edge(clk) then
      insn.insn <= ininsn;
      insn.pc <= pc;
    end if;
  end process if_id;
end architecture Beh;
