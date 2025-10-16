library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity Memory is
  port (
    clk: in std_logic;
    clear: in std_logic;
    ex_state: in execute_state_t;
    mem_state: out mem_state_t;
    -- interfacing with memory controller
    read_word: in word_t;
    mem_iface: out MemDataInterface_t
  );
end entity Memory;

architecture Beh of Memory is
  signal control : control_t := ex_state.decode_state.control;
  signal take_branch: std_logic;

  signal branch_taken: std_logic := '0';
  signal next_pc: addr_t := (others => '-');
begin
  mem_iface.addr <= unsigned(ex_state.alu_res);
  mem_iface.sign_extend <= control.sign_extend;
  mem_iface.mode <= control.mem_mode;
  mem_iface.write_enable <= control.mem_write;
  mem_iface.inword <= ex_state.decode_state.rs2_value;

  -- we also handle branch resolution in the MEM stage
  branch_controller: entity work.BranchController port map(
    btype => control.branch_type,
    sign_bit => ex_state.alu_res(31),
    c_out => ex_state.c_out,
    zero => ex_state.zero,
    taken => take_branch
  );

  with control.branch_mode select
    branch_taken <= take_branch when Branch,
                                      '1' when Jalr,
                                      '1' when Jal,
                                      '0' when others;

  with control.branch_mode select
    next_pc <= ex_state.next_pc           when Branch,
               ex_state.next_pc           when Jalr,
               unsigned(ex_state.alu_res) when Jal,
               (others => '-')            when others;


  mem_wb: process (clk, clear) is
  begin
    if clear = '1' then
      mem_state <= ZERO_MEM_STATE;
    elsif rising_edge(clk) then
      mem_state.ex_state <= ex_state;
      mem_state.read_value <= read_word;
      mem_state.branch_taken <= branch_taken;
      mem_state.next_pc <= next_pc;
    end if;
  end process mem_wb;
end architecture Beh;
