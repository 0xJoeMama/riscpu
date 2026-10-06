interface MemIf
import bitsize::*;
#(
  parameter WORD_LEN, 
  parameter WORD_COUNT
) (
  input word_t addr
);
  word_t word;

  modport read_end (
    input addr, 
    output word
  );

  modport write_end (
    input addr, word
  );
endinterface
