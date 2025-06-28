library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.types.all;

entity RiscV is
  port(
    clk: in std_logic;
    reset: in std_logic;
    inword: in word_t;
    write_enable: in std_logic;
    pc : out addr_t;
    outword: out word_t
  );
end entity RiscV;

architecture Beh of RiscV is
  -- TODO: initial address is 0 by default
  constant INITIAL_ADDRESS: addr_t := resize(x"0", WORD_SIZE);
  signal pc_internal : addr_t := (others => '0');
  signal curr_insn: word_t;
begin
  instruction_memory: entity work.Mem generic map (BYTES => 512) port map(
    clk => clk,
    reset => reset,
    read => not write_enable,
    write => write_enable,
    write_addr => pc_internal,
    read_addr => pc_internal,
    inword => inword,
    outword => curr_insn
  );

  pc_update: process (clk) is
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
