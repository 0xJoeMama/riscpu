.text

.global __start

__start:
  addi t0, zero, 5
  nop
  nop
  sw t0, 0(zero)
  lw t1, 0(zero)

  li t0, 0x100000
  nop
  nop
  sw t1, 0(t0)

