library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity ControlUnit is
  port (
    insn: in word_t;
    control: out control_t
  );
end entity ControlUnit;

architecture Beh of ControlUnit is
  signal alu_op: std_logic_vector(2 downto 0) := "000";
  signal funct3 : std_logic_vector(2 downto 0) := "000";
  signal add_sig: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(AluOP'pos(Add), 3));
  signal opcode: std_logic_vector(6 downto 0) := (others => '0');
begin
  funct3 <= insn(14 downto 12);
  opcode <= insn(6 downto 0);

  with opcode select
    alu_op <= funct3 when "0010011", -- I type arithmetic logic insns
              funct3 when "0110011", -- R type arithmetic logic insns
              add_sig when "1100011", -- branch instructions
              add_sig when "0000011", -- lw, lh, lb, lhu, lbu
              add_sig when "0100011", -- sw, sh, sb
              add_sig when "1100111", -- jal
              add_sig when others;


  -- TODO: srai srli needs to be handled separately
  control.c_in <= insn(30) when opcode = "0110011" else  -- handle subtraction for R instructions
                  '1' when opcode = "1100011" else '0'; -- handle subtraction for Branch instructions
  control.alu_op <= vec_to_alu_op(alu_op);

  with opcode select
    control.alu_src <= Reg when "0110011", -- R type instructions
                       Reg when "1100011", -- branch instructions
                       Imm when others;

  control.mem_write <= '1' when opcode = "0100011" else '0'; -- only write to memory when the instruction is a sw/sh/sb, otherwise read
  control.mem_read <= '1' when opcode = "000011" else '0'; -- only write to memory when the instruction is a sw/sh/sb, otherwise read
  control.to_write <= Memory when opcode = "00000011" else AluRes;

  -- TODO: this is not correct as we need to handle jumps which store the program counter to a register
  control.reg_write <= '1' when opcode /= "1100011" and opcode /= "0100011" else '0'; -- all instructions except branch, jumps and sw/sh/sb write back to a register
end architecture Beh;
