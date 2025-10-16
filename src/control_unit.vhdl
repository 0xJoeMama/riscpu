library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity ControlUnit is
  port (
    opcode : in std_logic_vector(6 downto 0);
    funct3 : in std_logic_vector(2 downto 0);
    funct7 : in std_logic_vector(6 downto 0);
    control: out control_t
  );
end entity ControlUnit;

architecture Beh of ControlUnit is
  signal alu_op: std_logic_vector(2 downto 0) := "000";
  signal add_sig: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(AluOP'pos(Add), 3));
begin
  with opcode select
    alu_op <= funct3  when "0010011", -- I type arithmetic logic insns
              funct3  when "0110011", -- R type arithmetic logic insns
              add_sig when "1100011", -- branch instructions
              add_sig when "0000011", -- lw, lh, lb, lhu, lbu
              add_sig when "0100011", -- sw, sh, sb
              add_sig when "1100111", -- jal
              add_sig when others;


  control.c_in <= '1'       when opcode = "0110011" and (funct3 = "010" or funct3 = "011") else -- R type slt and sltu
                  funct7(5) when opcode = "0110011" else  -- handle subtraction for R instructions
                  '1'       when opcode = "0010011" and (funct3 = "010" or funct3 = "011") else -- I type stli sltui
                  funct7(5) when opcode = "0010011" and funct3 = "101" else -- handle srai srli
                  '1'       when opcode = "1100011" else '0'; -- handle subtraction for Branch instructions

  control.alu_op <= vec_to_alu_op(alu_op);

  with opcode select
    control.alu_src <= Reg      when "0110011", -- R type instructions
                       Reg      when "1100011", -- branch instructions
                       UpperImm when "0010111", -- AUIPC
                       Imm      when others;

  control.mem_write <= '1' when opcode = "0100011" else '0'; -- only write to memory when the instruction is a sw/sh/sb, otherwise read
  with opcode select
    control.to_write <= Memory   when "0000011",
                        NextPC   when "1100111",
                        NextPC   when "1101111",
                        UpperImm when "0110111",
                        AluRes   when others;

  control.reg_write <= '1' when opcode /= "1100011" and opcode /= "0100011" else '0'; -- all instructions except branch and sw/sh/sb write back to a register

  with opcode select
  control.branch_mode <= Branch when "1100011",
                         Jal when "1101111",
                         Jalr when "1100111",
                         Non when others;
  with funct3 select
    control.branch_type <= Beq  when "000",
                           Bne  when "001",
                           Blt  when "100",
                           Bge  when "101",
                           Bltu when "110",
                           Bgeu when "111",
                           Beq  when others;

  control.auipc <= '1' when opcode = "0010111" else '0';

  control.sign_extend <= not funct3(2);
  with funct3(1 downto 0) select
    control.mem_mode <= Byte when "00",
                        Half when "01",
                        Word when "10",
                        Non when others;
end architecture Beh;
