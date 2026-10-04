module riscv 
import bitsize::*;
import constants::*;
(
  input logic clk,
  input logic rst,
  output word_t out_pc
);
  word_t pc;

  always_ff @(posedge clk or negedge rst) begin
    if (!rst) 
      pc <= INITIAL_PC;
    else 
      pc <= pc + 4;
  end

  assign out_pc = pc;
endmodule
