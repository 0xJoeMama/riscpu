.text

.global __start

__start:
  addi t0, zero, 5
  addi t1, zero, 6
  blt t0, t1, out
out:
