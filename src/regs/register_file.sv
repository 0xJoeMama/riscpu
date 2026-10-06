module register_file
import bitsize::*;
import constants::*;
(
  input logic clk,
  input reg_t rs1,
  input reg_t rs2,
  input reg_t rd,
  input word_t rd_word,
  input logic reg_write,
  output word_t rs1_word,
  output word_t rs2_word
);
  word_t regs [0:REG_COUNT - 1];

  always_ff @(posedge clk) begin
    if (reg_write == '1 && rd != '0) begin
      regs[rd] <= rd_word;
    end
  end

  assign rs1_word = (rs1 != '0 ) ? regs[rs1] : '0;
  assign rs2_word = (rs2 != '0 ) ? regs[rs2] : '0;
endmodule
