module Memory
#(
  parameter WORD_SIZE = 32,
  parameter ADDR_BITS = 5
)
(
  input logic clk,
  input logic [ADDR_BITS - 1:0] addr,
  MemMode mode,
  inout logic [WORD_SIZE - 1 : 0] word
);
  typedef enum logic {
    Read,
    Write
  } MemMode;

  typedef logic[WORD_SIZE - 1 : 0] MemWord;
  MemWord mem [0:(1 << ADDR_BITS) - 1];

  always_ff @(posedge clk) begin
    case (mode)
      Write: begin
        mem[addr] <= word;
      end
      Read : word <= mem[addr];
      default: word <= '0;
    endcase
  end
endmodule
