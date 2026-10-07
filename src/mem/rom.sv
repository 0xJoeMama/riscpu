module Rom
#(
  parameter WORD_SIZE = 8,
  parameter ADDR_BITS = 10 // 1kiB ought to be enough for anyone right?
) (
  input logic clk,
  input RomAddr addr,
  output RomWord word
);
  typedef logic [ADDR_BITS - 1: 0] RomAddr;
  typedef logic[WORD_SIZE - 1 : 0] RomWord;

  RomWord rom[0:(1 << ADDR_BITS) - 1];

  int fd;
  initial $readmemh("insns.txt", rom);

  always_ff @(posedge clk) begin
    word <= rom[addr];
  end
endmodule

