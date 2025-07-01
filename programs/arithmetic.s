.text

.global __start

__start:
  addi t0, zero, 1
  xori t1, t0, 1
  or t2, t0, t1
  and t3, t2, t0
  slli t4, t0, 5
  srai t4, t4, 5
  slli t4, t4, 5
  srli t4, t4, 5

  li s0, -8
  srai s0, s0, 1
  slli s0, s0, 1
  srai s0, s0, 3
.word 0
