library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.types.all;

entity RiscV is
  port (
    clk: in std_logic;
    reset: in std_logic;
    disable: in std_logic;
    insn : in word_t;
    pc : inout addr_t;
    mem_iface : out MemDataInterface_t;
    mem_word: in word_t;
    kill_me : out std_logic
  );
end entity RiscV;

architecture Beh of RiscV is
  -- IF state
  signal if_out: if_state_t := ZERO_IF_STATE;

  -- ID state
  signal rs1: register_t := zero;
  signal rs2: register_t := zero;
  signal reg1_value: word_t := (others => '0');
  signal reg2_value: word_t := (others => '0');
  signal decode_state: decode_state_t := ZERO_DECODE_STATE;

  -- MEM state
  signal mem_state: mem_state_t := ZERO_MEM_STATE;
  signal ex_state: execute_state_t := ZERO_EX_STATE;

  -- WB state
  signal write_back: word_t := (others => '0'); 
  signal reg_write: std_logic := '0';
  signal rd: register_t := zero;
begin
  ifetch: entity work.InstructionFetch port map(
    clk => clk,
    reset => reset,
    pc => pc,
    ininsn => insn,
    insn => if_out
  );

  id: entity work.InstructionDecode port map(
    clk => clk,
    clear => reset,
    if_state => if_out,
    rs1_value => reg1_value,
    rs2_value => reg2_value,
    rs1 => rs1,
    rs2 => rs2,
    decode_state => decode_state
  );

  ex: entity work.Execute port map (
    clk => clk,
    clear => reset,
    decode_state => decode_state,
    ex_state => ex_state
  );

  mem: entity work.Memory port map (
    clk => clk,
    clear => reset,
    ex_state => ex_state,
    mem_state => mem_state,
    read_word => mem_word,
    mem_iface => mem_iface,
    kill_me => kill_me
  );

  wb: entity work.WriteBack port map (
    mem_state => mem_state,
    rd => rd,
    write_back => write_back,
    reg_write => reg_write
  );

  registers: entity work.RegisterFile port map(
    clk => clk,
    rs1 => rs1,
    rs2 => rs2,
    outword1 => reg1_value,
    outword2 => reg2_value,
    rd => rd,
    inword => write_back,
    write_enable => reg_write
  );

  pc_update: process (clk, reset, disable, pc) is
  begin
    if reset = '1' then
      pc <= INITIAL_ADDRESS;
    elsif disable = '1' then
      null;
    elsif rising_edge(clk) then
      if mem_state.branch_taken = '1' then
        pc <= mem_state.next_pc;
      else
        pc <= pc + 4;
      end if;
    end if;
  end process pc_update;
end architecture Beh;

