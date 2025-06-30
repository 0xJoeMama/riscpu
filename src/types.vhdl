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

  type ALUOp is (Add, Sl, Slt, Sltu, LXor, Sr, LOr, LAnd);
  type ALUSrc is (Reg, Imm);
  type WriteBackValue is (Memory, AluRes);

  type cpu_state_t is record
    pc: addr_t;
    curr_insn: word_t;
    rs1: register_t;
    rs2: register_t;
    rd: register_t;
    rs1_content: word_t;
    rs2_content: word_t;
    alu_res : word_t;
    imm: word_t;
    alu_src: ALUSrc;
  end record;

  type control_t is record
    alu_op: ALUOp;
    C_in: std_logic;
    alu_src: ALUSrc;
    mem_write: std_logic;
    mem_read: std_logic;
    to_write: WriteBackValue;
    reg_write : std_logic;
  end record;

  function vec_to_alu_op(
  vec: std_logic_vector(2 downto 0)
  ) return ALUOp;

  function is_zero(
    vec: std_logic_vector
  ) return std_logic;
end package types;

package body types is
  function vec_to_alu_op(
    vec: std_logic_vector(2 downto 0)
  ) return ALUOp is
  begin
    case vec is
      when "000" => return Add;
      when "001" => return Sl;
      when "010" => return Slt;
      when "011" => return Sltu;
      when "100" => return LXor;
      when "101" => return Sr;
      when "110" => return LOr;
      when "111" => return LAnd;
      when others => return Add;
    end case;
  end function;

  function is_zero(
    vec: std_logic_vector
  ) return std_logic is
    variable median : integer;
  begin 
    if vec'left = vec'right then
      return not vec(vec'left);
    end if;

    median := vec'right + (vec'length - 1) / 2;
    return is_zero(vec(median downto vec'right)) and is_zero(vec(vec'left downto median + 1));
  end function;
end package body types;
