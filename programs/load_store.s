.text
.globl __start
__start:
  la t0, word1
  lw t1, 0(t0)
  sw t1, 4(t0)

  lw t2, 4(t0)

  addi t2, t2, 0
  .word 0

.data
word1: .word 12
word2: .word 0

