library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package types is
  constant WORD_SIZE : integer := 32;
  subtype word_t is std_logic_vector(WORD_SIZE - 1 downto 0);
  subtype addr_t is unsigned(WORD_SIZE - 1 downto 0);

  type register_t is (
    zero, -- x0
    ra, -- x1
    sp, -- x2
    gp, -- x3
    tp, -- x4
    t0, t1, t2, -- x5-x7
    s0, -- x8 or fp
    s1, -- x9
    a0, a1, -- x10-x11
    a2,a3, a4, a5, a6, a7, -- x12-x17
    s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, -- x18-x27
    t3, t4, t5, t6 -- x28-x31
  );

  type cpu_state_t is record
    pc: addr_t;
    curr_insn: word_t;
    rs1: register_t;
    rs2: register_t;
    rd: register_t;
    rs1_content: word_t;
    rs2_content: word_t;
  end record;
end package types;

package body types is
end package body types;
