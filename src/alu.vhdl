library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity ALU is
  port (
    a: in word_t;
    b: in word_t;
    C_in: in std_logic;
    op: in ALUOp;
    s: out word_t;
    zero: out std_logic;
    C_out : out std_logic
  );
end entity ALU;

architecture Beh of ALU is
  signal c_in_word : std_logic_vector(32 downto 0) := (others => '0');
  signal right_shift_res : word_t;
  signal c_in_mask : std_logic_vector(32 downto 0) := (others => '0');
  signal s_internal : word_t := (others => '0');

  signal slt_res : word_t := (others => '0');
  signal shift_amt : unsigned(4 downto 0) := (others => '0');
  signal add_res : std_logic_vector(32 downto 0);
begin
  c_in_word(0) <= C_in;
  c_in_mask <= (others => C_in);
  shift_amt <= unsigned(b(4 downto 0));

  add_res <= std_logic_vector(unsigned("0" & a) + unsigned(("0" & b) xor c_in_mask) + unsigned(c_in_word));

  with op select
    -- this is used to support subtraction and division in the same branch in the ALU
    s_internal <= add_res(31 downto 0) when Add,
                  slt_res when Slt,
                  slt_res when Sltu,
                  std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(b)))) when Sl,
                  right_shift_res when Sr,
                  a xor b when LXor,
                  a or b when LOr,
                  a and b when LAnd,
                  (others => '0') when others;

  C_out <= add_res(32);

  slt_res(0) <= add_res(31) when op = Slt else add_res(32);

  with C_in select
    right_shift_res <= std_logic_vector(shift_right(unsigned(a), to_integer(shift_amt))) when '0',
                       std_logic_vector(shift_right(signed(a), to_integer(shift_amt))) when others;

  zero <= is_zero(s_internal);
  s <= s_internal;
end architecture Beh;

