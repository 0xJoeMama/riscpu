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
    state: out cpu_state_t
  );
end entity RiscV;

architecture Beh of RiscV is
  -- TODO: initial address is 0 by default
  constant INITIAL_ADDRESS: addr_t := resize(x"0", WORD_SIZE);
  signal pc_internal : addr_t := (others => '0');
  signal curr_insn: word_t;

  signal rd: register_t;
  signal rs1: register_t;
  signal rs2: register_t;
  signal reg1_value: word_t;
  signal reg2_value: word_t;
  signal res : word_t;
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
  rd <= register_t'val(to_integer(unsigned(curr_insn(11 downto 7))));
  rs1 <= register_t'val(to_integer(unsigned(curr_insn(19 downto 15))));
  rs2 <= register_t'val(to_integer(unsigned(curr_insn(24 downto 20))));

  registers: entity work.RegisterFile port map(
    clk => clk,
    reset => reset,
    rd => rd,
    rs1 => rs1,
    rs2 => rs2,
    outword1 => reg1_value,
    outword2 => reg2_value,
    inword => res,
    write_enable => '0' -- TODO: currently hardwired to 0
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
  state <= (
    pc => pc_internal,
    curr_insn => curr_insn,
    rd => rd,
    rs1 => rs1,
    rs2 => rs2,
    rs1_content => reg1_value,
    rs2_content => reg2_value
  );
end architecture Beh;
