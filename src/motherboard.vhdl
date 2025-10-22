library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.types.all;

entity Motherboard is
  port (
    clk : in std_logic;
    reset: in std_logic;
    debug_port: out word_t;
    kill_me: out std_logic
  );
end entity Motherboard;

architecture Beh of Motherboard is
  constant rom_size : natural := 256;
  signal mother_pc: unsigned(11 downto 0);
  signal rom_word: word_t;
  signal cpu_off: std_logic;

  type BootStage is (MapRom, CPU);
 
  signal curr_stage: BootStage;
  signal insn: word_t;
  signal cpu_pc: addr_t;
  signal pc: addr_t;
  signal mem_data: word_t;

  signal cpu_iface: MemDataInterface_t;
  signal mem_iface: MemDataInterface_t;
  signal rom_iface: MemDataInterface_t;
begin
  rom_iface <= (
      mode => Word,
      addr => pc,
      sign_extend => '0',
      write_enable => '1',
      inword => rom_word
  );

  riscv: entity work.RiscV port map (
    clk => clk,
    reset => reset,
    disable => cpu_off,
    pc => cpu_pc,
    insn => insn,
    mem_iface => cpu_iface,
    kill_me => kill_me
  );

  -- TODO: replace with an MMU to be able to abstract things and make life easier later
  -- 1kiB ought to be enough for anybody am i right?
  memory: entity work.Mem generic map (BYTES => 1024) port map (
    clk => clk,
    insn_addr => pc,
    insn => insn,
    outword => mem_data,
    data_iface => mem_iface
  );

  rom: entity work.Rom generic map (rom_size => rom_size) port map (
    addr => mother_pc,
    outword => rom_word
  );

  cpu_off <= '1' when curr_stage /= CPU else '0';

  with curr_stage select
    pc <= cpu_pc                              when CPU,
          resize(mother_pc & "00", pc'length) when MapRom;

  with curr_stage select
    mem_iface <= cpu_iface  when CPU,
                 rom_iface  when MapRom;

  debug_port <= insn;
  fsm: process (clk, reset) is
  begin
    if reset = '1' then
      curr_stage <= MapRom;
      mother_pc <= to_unsigned(0, mother_pc'length);
    elsif rising_edge(clk) then
      case curr_stage is
      when MapRom => 
        if mother_pc = rom_size - 1 then
          curr_stage <= CPU;
          mother_pc <= mother_pc;
        else
          curr_stage <= MapRom;
          mother_pc <= mother_pc + 1;
        end if;
      when CPU => null;
      end case;
    end if;
  end process fsm;
end architecture Beh;

