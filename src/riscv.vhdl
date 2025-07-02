library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.types.all;

entity RiscV is
  port(
    clk: in std_logic;
    reset: in std_logic;
    inword: in word_t;
    write_enable: in std_logic;
    state: out cpu_state_t
  );
end entity RiscV;

architecture Beh of RiscV is
  -- TODO: initial address is 0 by default
  constant INITIAL_ADDRESS: addr_t := resize(x"0", WORD_SIZE);
  signal pc : addr_t := (others => '0');
  signal curr_insn: word_t := (others => '0');

  signal rd: register_t := zero;
  signal rs1: register_t := zero;
  signal rs2: register_t := zero;
  signal reg1_value: word_t := (others => '0');
  signal reg2_value: word_t := (others => '0');
  signal alu_res : word_t := (others => '0');
  signal control: control_t := (
    alu_op => Add,
    c_in => '0',
    alu_src => Imm,
    mem_write => '0',
    mem_read => '0',
    to_write => AluRes,
    reg_write => '0',
    branch => '0',
    jal => '0',
    jalr => '0',
    branch_type => Beq,
    auipc => '0'
  );
  signal immediate: word_t := (others => '0');
  signal upper_immediate : word_t := (others => '0');
  signal alu_in_1: word_t := (others => '0');
  signal alu_in_2: word_t := (others => '0');
  signal mem_out: word_t := (others => '0'); 
  signal write_back: word_t := (others => '0'); 
  signal branch_taken: std_logic := '0';
  signal zero: std_logic := '0';
  signal write_word : word_t := (others => '0');
  signal write_addr : addr_t := (others => '0');
begin
  registers: entity work.RegisterFile port map(
    clk => clk,
    rd => rd,
    rs1 => rs1,
    rs2 => rs2,
    outword1 => reg1_value,
    outword2 => reg2_value,
    inword => write_back,
    write_enable => control.reg_write
  );

  control_unit : entity work.ControlUnit port map(
    opcode => curr_insn(6 downto 0),
    funct3 => curr_insn(14 downto 12),
    funct7 => curr_insn(31 downto 25),
    control => control
  );

  alu: entity work.ALU port map(
    a => alu_in_1,
    b => alu_in_2,
    s => alu_res,
    op => control.alu_op,
    zero => zero,
    C_in => control.C_in
  );

  immediate_unit: entity work.ImmediateUnit port map(
    insn => curr_insn,
    immediate => immediate,
    upper_immediate => upper_immediate
  );

  mem: entity work.Mem generic map (BYTES => 4096) port map (
    clk => clk,
    write => control.mem_write or write_enable,
    read => control.mem_read and not write_enable,
    read_addr => unsigned(alu_res),
    insn_addr => pc,
    write_addr => write_addr,
    inword => write_word,
    outword => mem_out,
    outinsn => curr_insn
  );

  branch_controller: entity work.BranchController port map(
    btype => control.branch_type,
    alu_res => alu_res,
    zero => zero,
    taken => branch_taken
  );

  write_word <= reg2_value when write_enable = '0' else inword;
  write_addr <= unsigned(alu_res) when write_enable = '0' else pc;

  rd <= register_t'val(to_integer(unsigned(curr_insn(11 downto 7))));
  rs1 <= register_t'val(to_integer(unsigned(curr_insn(19 downto 15))));
  rs2 <= register_t'val(to_integer(unsigned(curr_insn(24 downto 20))));

  with control.to_write select
    write_back <= alu_res when AluRes,
                  std_logic_vector(pc + 4) when NextPC,
                  upper_immediate when UpperImm,
                  mem_out when Memory;

  with control.alu_src select
    alu_in_2 <= reg2_value when Reg,
                upper_immediate when UpperImm,
                immediate when Imm;

  alu_in_1 <= reg1_value when control.auipc = '0' else std_logic_vector(pc);

  pc_update: process (clk, reset) is
  begin
    if reset = '1' then
      pc <= INITIAL_ADDRESS;
    elsif rising_edge(clk) then
      -- if we are in privilaged write mode, we just go to the next address by default
      if write_enable = '1' then
        pc <= pc + 4;
      else
        if control.jal = '1' then
          -- PC relative addressing for jal(uses immediate)
          pc <= pc + unsigned(immediate);
        elsif control.jalr = '1' then
          -- absolute addressing with ALU result
          pc <= unsigned(alu_res);
        elsif (control.branch and branch_taken) = '1' then
          -- PC relative addressing for successful branching
          pc <= pc + unsigned(immediate);
        else
          pc <= pc + 4;
        end if;
      end if;
    end if;
  end process pc_update;

  state <= (
    pc => pc,
    curr_insn => curr_insn,
    rd => rd,
    rs1 => rs1,
    rs2 => rs2,
    rs1_content => reg1_value,
    rs2_content => reg2_value,
    alu_res => alu_res,
    imm => immediate,
    alu_src => control.alu_src,
    branch_taken => (branch_taken and control.branch) or control.jal or control.jalr,
    terminate => is_zero(curr_insn) and not write_enable
  );
end architecture Beh;
