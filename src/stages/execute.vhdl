library ieee;
use ieee.std_logic_1164.all;
use work.types.all;

entity Execute is
  port (
    clk: in std_logic;
    clear: in std_logic;
    decode_state: in decode_state_t;
    ex_state: out execute_state_t
  );
end entity Execute;

architecture Beh of Execute is
  signal control : control_t := decode_state.control;
  signal alu_in_1: word_t := (others => '0');
  signal alu_in_2: word_t := (others => '0');

  signal alu_res : word_t := (others => '0');
  signal zero: std_logic := '0';
  signal c_out : std_logic := '0';

  signal branch_taken: std_logic := '0';
begin
  with control.alu_src select
    alu_in_2 <= decode_state.rs2_value when Reg,
                decode_state.upper_immediate when UpperImm,
                decode_state.immediate when Imm;


  alu_in_1 <= decode_state.rs1_value when control.auipc = '0' else std_logic_vector(decode_state.pc);

  alu: entity work.ALU port map(
    a => alu_in_1,
    b => alu_in_2,
    C_in => control.C_in,
    s => alu_res,
    op => control.alu_op,
    zero => zero,
    C_out => c_out
  );

  branch_controller: entity work.BranchController port map(
    btype => control.branch_type,
    sign_bit => alu_res(31),
    c_out => c_out,
    zero => zero,
    taken => branch_taken
  );

  ex_mem: process (clk, clear) is
  begin
    if clear = '1' then
      ex_state.alu_res <= (others => '0');
      ex_state.decode_state <= decode_state;
      ex_state.branch_taken <= '0';
    elsif rising_edge(clk) then
      ex_state.alu_res <= alu_res;
      ex_state.decode_state <= decode_state;
      ex_state.branch_taken <= branch_taken;
    end if;
  end process ex_mem;
end architecture Beh;
