library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity InstructionDecode is
  port (
    clk: in std_logic;
    clear: in std_logic;
    if_state: in if_state_t;
    rs1_value: in word_t;
    rs2_value: in word_t;
    decode_state: out decode_state_t;
    rs1: out register_t;
    rs2: out register_t
  );
end entity InstructionDecode;

architecture Beh of InstructionDecode is
  signal insn: word_t;

  signal control: control_t := ZEROED_CONTROL;
  signal immediate: word_t := (others => '0');
  signal upper_immediate : word_t := (others => '0');
  signal rd: register_t := zero;
begin
  insn <= if_state.insn;

  control_unit : entity work.ControlUnit port map(
    opcode => insn(6 downto 0),
    funct3 => insn(14 downto 12),
    funct7 => insn(31 downto 25),
    control => control
  );

  immediate_unit: entity work.ImmediateUnit port map(
    insn => insn,
    immediate => immediate,
    upper_immediate => upper_immediate
  );

  rs1 <= register_t'val(to_integer(unsigned(insn(19 downto 15))));
  rs2 <= register_t'val(to_integer(unsigned(insn(24 downto 20))));
  rd  <= register_t'val(to_integer(unsigned(insn(11 downto 7))));

  id_ex: process (clk, clear) is
  begin
    if clear = '1' then
      decode_state <= ZERO_DECODE_STATE;
    elsif rising_edge(clk) then
      decode_state.control <= control;
      decode_state.immediate <= immediate;
      decode_state.upper_immediate <= upper_immediate;
      decode_state.rs1 <= rs1;
      decode_state.rs2 <= rs2;
      decode_state.rs1_value <= rs1_value;
      decode_state.rs2_value <= rs2_value;
      decode_state.rd <= rd;
      decode_state.pc <= if_state.pc;
    end if;
  end process id_ex;
end architecture Beh;

