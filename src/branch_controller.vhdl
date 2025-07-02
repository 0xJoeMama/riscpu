library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity BranchController is
  port(
  btype: in BranchType;
  alu_res: in word_t;
  zero: in std_logic;
  taken: out std_logic
  );
end entity BranchController;

architecture Beh of BranchController is
begin
  with btype select
    taken <= zero            when Beq,
             not zero        when Bne,
             alu_res(31)     when Blt,
             not alu_res(31) when Bge,
             -- TODO: this has to use carry out instead of alu_res(31) however the ALU does not produce a carry out currently(whoopsies...)
             alu_res(31)     when Bltu,
             not alu_res(31) when Bgeu;
end architecture Beh;
