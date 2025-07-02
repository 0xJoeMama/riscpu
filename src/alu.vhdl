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
    zero: out std_logic
  );
end entity ALU;

architecture Beh of ALU is
  signal c_in_word : word_t := (others => '0');
  signal right_shift_res : word_t;
  signal c_in_mask : word_t := (others => '0');
  signal s_internal : word_t := (others => '0');
  signal shift_amt : unsigned(4 downto 0) := (others => '0');
  signal unsigned_diff: unsigned(32 downto 0);
  signal signed_diff : signed(31 downto 0);
begin
  c_in_word(0) <= C_in;
  c_in_mask <= (others => C_in);
  shift_amt <= unsigned(b(4 downto 0));

  with op select
                  -- this is used to support subtraction and division in the same branch in the ALU
    s_internal <= std_logic_vector(signed(a) + signed(b xor c_in_mask) + signed(c_in_word)) when Add, 
                  std_logic_vector(resize(unsigned(signed_diff(31 downto 31)), s_internal'length)) when Slt,
                  std_logic_vector(resize(unsigned_diff(32 downto 31), s_internal'length)) when Sltu,
                  std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(b)))) when Sl,
                  right_shift_res when Sr,
                  a xor b when LXor,
                  a or b when LOr,
                  a and b when LAnd,
                  (others => '0') when others;

  unsigned_diff <= resize(unsigned(a), 33) - resize(unsigned(b), 33);
  signed_diff <= signed(a) - signed(b);

  with C_in select
    right_shift_res <= std_logic_vector(shift_right(unsigned(a), to_integer(shift_amt))) when '0',
                       std_logic_vector(shift_right(signed(a), to_integer(shift_amt))) when others;

  zero <= is_zero(s_internal);
  s <= s_internal;
end architecture Beh;
