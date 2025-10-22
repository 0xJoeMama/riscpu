library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity ImmediateUnit is
  port (
  insn: in word_t;
  immediate: out word_t;
  upper_immediate: out word_t
  );
end entity ImmediateUnit;

architecture Beh of ImmediateUnit is
  signal i_immediate: std_logic_vector(11 downto 0) := (others => '0');
  signal s_immediate: std_logic_vector(11 downto 0) := (others => '0');
  signal sb_immediate: std_logic_vector(12 downto 0) := (others => '0');
  signal u_immediate: std_logic_vector(19 downto 0) := (others => '0');
  signal uj_immediate: std_logic_vector(20 downto 0) := (others => '0');
  signal immediate_signed: signed(WORD_SIZE - 1 downto 0) := (others => '0');
begin
  i_immediate <= insn(31 downto 20);
  s_immediate <= insn(31 downto 25) & insn(11 downto 7);
  -- [imm[12|10:5]][rs2][rs1][funct3][imm[4:1|11]]
  sb_immediate <= insn(31 downto 31) & insn(7 downto 7) & insn(30 downto 25) & insn(11 downto 8) & '0';
  u_immediate <= insn(31 downto 12);
  -- [20| 10:1 |11|19:12]
  --  31 30-20  19 18-12
  uj_immediate <= insn(31 downto 31) & insn(19 downto 12) & insn(20 downto 20) & insn(30 downto 21) & '0';

  with insn(6 downto 0) select
    immediate_signed <= resize(signed(i_immediate), immediate'length)  when "0010011",
                        resize(signed(i_immediate), immediate'length)  when "0000011",
                        resize(signed(i_immediate), immediate'length)  when "0001111",
                        resize(signed(i_immediate), immediate'length)  when "1100111",
                        resize(signed(i_immediate), immediate'length)  when "1110011",
                        resize(signed(s_immediate), immediate'length)  when "0100011",
                        resize(signed(sb_immediate), immediate'length) when "1100011",
                        resize(signed(u_immediate), immediate'length)  when "0010111",
                        resize(signed(u_immediate), immediate'length)  when "0110111",
                        resize(signed(uj_immediate), immediate'length) when "1101111",
                        (others => '0') when others;

  immediate <= std_logic_vector(immediate_signed);
  upper_immediate <= std_logic_vector(shift_left(immediate_signed, 12));
end architecture Beh;

