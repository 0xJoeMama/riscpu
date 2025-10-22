library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity BranchController is
  port(
    btype: in BranchType;
    sign_bit : in std_logic;
    c_out : in std_logic;
    zero: in std_logic;
    taken: out std_logic
  );
end entity BranchController;

architecture Beh of BranchController is
begin
  with btype select
    taken <= zero         when Beq,
             not zero     when Bne,
             sign_bit     when Blt,
             not sign_bit when Bge,
             c_out        when Bltu,
             not c_out    when Bgeu;
end architecture Beh;

