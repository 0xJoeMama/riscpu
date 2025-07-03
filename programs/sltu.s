.section .text
.globl _start

_start:
  # Initialize registers with unsigned values
  li t0, 5            # t0 = 5
  li t1, 10           # t1 = 10
  li t2, 0xFFFFFFFF   # t2 = 4294967295 (max unsigned)
  li t3, 0            # t3 = 0

  # ---- SLTU Tests ----

  # Compare: t0 < t1 ? (5 < 10) => should be true => result = 1
  sltu t4, t0, t1     # t4 = 1

  # Compare: t2 < t3 ? (0xFFFFFFFF < 0) => false => result = 0
  sltu t5, t2, t3     # t5 = 0

  # Compare: t3 < t2 ? (0 < 0xFFFFFFFF) => true => result = 1
  sltu t6, t3, t2     # t6 = 1

  # ---- SLTIU Tests ----

  # Compare: t0 < 8 ? (5 < 8) => true => result = 1
  sltiu a0, t0, 8     # a0 = 1

  # Compare: t1 < 8 ? (10 < 8) => false => result = 0
  sltiu a1, t1, 8     # a1 = 0

  # Compare: t2 < 0 ? (0xFFFFFFFF < 0) => false => result = 0
  sltiu a2, t2, 0     # a2 = 0

  # ---- Use result in branch ----

  # if (t4 == 1) go to label pass1
  li a3, 1
  bne t4, a3, fail1

pass1:
  # if (t5 == 0) continue, else fail
  beq t5, x0, pass2

fail1:
  j halt

pass2:
  # if (a0 == 1 && a1 == 0)
  bne a0, a3, fail2
  beq a1, x0, done

fail2:
  j halt

done:
# success
.word 0

halt:
  # error halt loop
  j halt
