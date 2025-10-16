library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity WriteBack is
  port (
    mem_state: in mem_state_t;
    rd : out register_t;
    write_back : out word_t;
    reg_write : out std_logic
  );
end entity WriteBack;

architecture Beh of WriteBack is
  signal decode_state : decode_state_t := mem_state.ex_state.decode_state;
  signal control : control_t := decode_state.control;
begin
  with control.to_write select
    write_back <= mem_state.ex_state.alu_res             when AluRes,
                  std_logic_vector(decode_state.pc + 4)  when NextPC,
                  decode_state.upper_immediate           when UpperImm,
                  mem_state.read_value                   when Memory;

  reg_write <= control.reg_write;
  rd <= decode_state.rd;
end architecture Beh;
