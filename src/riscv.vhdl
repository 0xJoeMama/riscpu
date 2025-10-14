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
  -- When a termination word is found (aka 0x00000000), we stop the processor
  signal terminate: std_logic := '0';

  -- IF state
  signal if_in: word_t := (others => '0');
  signal if_out: if_state_t;

  -- ID state
  signal rs1: register_t := zero;
  signal rs2: register_t := zero;
  signal reg1_value: word_t := (others => '0');
  signal reg2_value: word_t := (others => '0');
  signal decode_state : decode_state_t;

  signal taken_status : std_logic := '0';

  -- MEM state
  signal write_word : word_t := (others => '0');
  signal write_addr : addr_t := (others => '0');
  signal mem_mode : MemMode_t := Non; 
  signal mem_write : std_logic := '0';
  signal mem_out: word_t := (others => '0'); 

  -- WB state
  signal write_back: word_t := (others => '0'); 
begin
  fetch: entity work.InstructionFetch port map(
    clk => clk,
    clear => reset,
    pc => pc,
    ininsn => if_in,
    insn => if_out
  );

  decode: entity work.InstructionDecode port map(
    clk => clk,
    clear => reset,
    if_state => if_out,
    rs1_value => reg1_value,
    rs2_value => reg2_value,
    rs1 => rs1,
    rs2 => rs2,
    decode_state => decode_state
  );

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

  mem_write <= control.mem_write or write_enable;
  mem: entity work.Mem generic map (BYTES => 4096) port map (
    clk => clk,
    write_enable => mem_write,
    read_addr => unsigned(alu_res),
    insn_addr => pc,
    write_addr => write_addr,
    inword => write_word,
    outword => mem_out,
    insn => if_in,
    sign_extend => control.sign_extend,
    mem_mode => mem_mode
  );

  write_addr <= unsigned(alu_res) when write_enable = '0' else pc;

  mem_mode <= control.mem_mode when write_enable = '0' else Word;

  with control.to_write select
    write_back <= alu_res when AluRes,
                  std_logic_vector(pc + 4) when NextPC,
                  upper_immediate when UpperImm,
                  mem_out when Memory;

  pc_update: process (clk, reset) is
  begin
    if reset = '1' then
      pc <= INITIAL_ADDRESS;
    elsif rising_edge(clk) then
      -- if we are in privilaged write mode, we just go to the next address by default
      if write_enable = '1' then
        pc <= pc + 4;
      elsif control.jal = '1' then
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
  end process pc_update;

  terminate <= not write_enable when (curr_insn = x"00000000") else '0';

  taken_status <= (branch_taken and control.branch) or control.jal or control.jalr;

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
    branch_taken => taken_status,
    terminate => terminate,
    mem_out => mem_out,
    mem_write => control.mem_write
  );
end architecture Beh;
