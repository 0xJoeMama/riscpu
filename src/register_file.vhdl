library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.types.all;

entity RegisterFile is
  port (
    clk: in std_logic;
    reset: in std_logic;
    rs1: in register_t;
    rs2: in register_t;
    rd: in register_t;
    write_enable: in std_logic;
    inword: in word_t;
    outword1: out word_t;
    outword2: out word_t
  );
end entity RegisterFile;

architecture Beh of RegisterFile is
  type registers is array(register_t'left to register_t'right) of word_t;
  signal regs: registers;
begin
  process (clk) is
  begin
    if rising_edge(clk) and write_enable = '1' then
      if reset = '1' then
        for i in register_t'left to register_t'right loop
          regs(i) <= (others => '0');
        end loop;
      else
        -- write on rising edge on all registers except zero
        if rd /= zero then
          regs(rd) <= inword;
        end if;
      end if;
    end if;
  end process;

  outword1 <= regs(rs1);
  outword2 <= regs(rs2);
  -- hardwire zero to ground
  regs(zero) <= (others => '0');
end architecture Beh;
