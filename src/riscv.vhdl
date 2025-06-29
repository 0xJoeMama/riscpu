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
  signal pc_internal : addr_t := (others => '0');
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
    reg_write => '0'
  );
  signal immediate: word_t := (others => '0');
  signal alu_in_2: word_t := (others => '0');
  signal mem_out: word_t := (others => '0'); 
  signal write_back: word_t := (others => '0'); 
begin
  instruction_memory: entity work.Mem generic map (BYTES => 512) port map(
    clk => clk,
    reset => reset,
    read => not write_enable,
    write => write_enable,
    write_addr => pc_internal,
    read_addr => pc_internal,
    inword => inword,
    outword => curr_insn
  );

  registers: entity work.RegisterFile port map(
    clk => clk,
    reset => reset,
    rd => rd,
    rs1 => rs1,
    rs2 => rs2,
    outword1 => reg1_value,
    outword2 => reg2_value,
    inword => write_back,
    write_enable => control.reg_write
  );

  control_unit : entity work.ControlUnit port map(
    insn => curr_insn,
    control => control
  );

  alu: entity work.ALU port map(
    a => reg1_value,
    b => alu_in_2,
    s => alu_res,
    op => control.alu_op,
    C_in => control.C_in
  );

  immediate_unit: entity work.ImmediateUnit port map(
    insn => curr_insn,
    immediate => immediate
  );

  data_mem: entity work.Mem port map (
    clk => clk,
    reset => reset,
    inword => reg2_value,
    read_addr => unsigned(alu_res),
    write_addr => unsigned(alu_res),
    write => control.mem_write,
    read => control.mem_read,
    outword => mem_out
  );

  rd <= register_t'val(to_integer(unsigned(curr_insn(11 downto 7))));
  rs1 <= register_t'val(to_integer(unsigned(curr_insn(19 downto 15))));
  rs2 <= register_t'val(to_integer(unsigned(curr_insn(24 downto 20))));

  with control.to_write select
    write_back <= alu_res when AluRes,
                  mem_out when Memory;

  with control.alu_src select
    alu_in_2 <= reg2_value when Reg,
                immediate when Imm;

  pc_update: process (clk, reset) is
  begin
    if reset = '1' then
      pc_internal <= INITIAL_ADDRESS;
    elsif rising_edge(clk) then
      pc_internal <= pc_internal + 4;
    end if;
  end process pc_update;

  -- TODO: currently the only result we produce is the program counter
  state <= (
    pc => pc_internal,
    curr_insn => curr_insn,
    rd => rd,
    rs1 => rs1,
    rs2 => rs2,
    rs1_content => reg1_value,
    rs2_content => reg2_value,
    alu_res => alu_res,
    imm => immediate,
    alu_src => control.alu_src
  );
end architecture Beh;
