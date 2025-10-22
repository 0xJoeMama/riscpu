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
  type ALUSrc is (Reg, Imm, UpperImm);
  type WriteBackValue is (Memory, NextPC, UpperImm, AluRes);

  type BranchType is (Beq, Bne, Blt, Bge, Bltu, Bgeu);
  type JumpType is (Jal, Jalr);

  type MemMode_t is (Non, Byte, Half, Word);

  type MemDataInterface_t is record
    mode: MemMode_t;
    addr: addr_t;
    sign_extend: std_logic;
    write_enable: std_logic;
    inword: word_t;
  end record;

  type BranchMode is (Non, Branch, Jal, Jalr);
  type control_t is record
    alu_op: ALUOp;
    C_in: std_logic;
    alu_src: ALUSrc;
    mem_write: std_logic;
    to_write: WriteBackValue;
    reg_write : std_logic;
    branch_mode : BranchMode;
    branch_type: BranchType;
    auipc: std_logic;
    mem_mode: MemMode_t;
    sign_extend: std_logic;
  end record;

  constant ZEROED_CONTROL : control_t := (
    alu_op => Add,
    c_in => '0',
    alu_src => Imm,
    mem_write => '0',
    to_write => AluRes,
    reg_write => '0',
    branch_mode => Non,
    branch_type => Beq,
    auipc => '0',
    sign_extend => '0',
    mem_mode => Non
  );

  function vec_to_alu_op(
  vec: std_logic_vector(2 downto 0)
  ) return ALUOp;

  function is_zero(
    vec: std_logic_vector
  ) return std_logic;

  -- pipeline stage states
  type if_state_t is record
    insn: word_t;
    pc: addr_t;
  end record;

  constant ZERO_IF_STATE : if_state_t := (
    insn => (others => '0'),
    pc => (others => '0')
  );

  type decode_state_t is record
    pc : addr_t;
    control: control_t;
    immediate: word_t;
    upper_immediate: word_t;
    rs1_value: word_t;
    rs2_value: word_t;
    rd: register_t;
  end record;

  constant ZERO_DECODE_STATE : decode_state_t := (
    pc => (others => '0'),
    control => ZEROED_CONTROL,
    immediate => (others => '0'),
    upper_immediate => (others => '0'),
    rs1_value => (others => '0'),
    rs2_value => (others => '0'),
    rd => zero
  );

  -- TODO: this currently holds wayyy to much information because we delegate the previous state
  -- we can save a lot of connections by removing things we do not need on the phase we stop needing them
  type execute_state_t is record
    decode_state: decode_state_t;
    alu_res: word_t;
    c_out : std_logic;
    zero: std_logic;
    next_pc: addr_t;
  end record;

  constant ZERO_EX_STATE : execute_state_t := (
    decode_state => ZERO_DECODE_STATE,
    alu_res => (others => '0'),
    c_out => '0',
    zero => '0',
    next_pc => (others => '0')
  );

  type mem_state_t is record
     -- we need ex_state here because we may want to write the result of a computation to a register instead of using it to write to memory
    ex_state: execute_state_t;
    read_value: word_t;
    branch_taken: std_logic;
    next_pc : addr_t;
  end record;

  constant ZERO_MEM_STATE : mem_state_t := (
    ex_state => ZERO_EX_STATE,
    read_value => (others => '0'),
    branch_taken => '0',
    next_pc => (others => '-')
  );

  constant DIE_VECTOR : word_t := x"00100000";
  -- TODO: initial address is 0 by default
  constant INITIAL_ADDRESS: addr_t := x"000F0000";
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

  function is_non_zero(
    vec: std_logic_vector
  ) return std_logic is
    variable median : integer;
  begin 
    if vec'left = vec'right then
      return vec(vec'left);
    end if;

    median := vec'right + (vec'length - 1) / 2;
    return is_non_zero(vec(median downto vec'right)) or is_non_zero(vec(vec'left downto median + 1));
  end function;

  function is_zero(
    vec: std_logic_vector
  ) return std_logic is
  begin
    return not is_non_zero(vec);
  end function;
end package body types;

