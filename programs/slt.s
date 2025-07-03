.text
.globl _start

_start:
  # Setup test values
  li t0, -1          # t0 = 0xFFFFFFFF (signed: -1, unsigned: 4294967295)
  li t1, 1           # t1 = 1
  li t2, 0           # t2 = 0
  li t3, 0xFFFFFFFF  # t3 = -1 (same as t0)

  # --- SLT (signed) ---
  slt t4, t0, t1     # t4 = (t0 < t1) => (-1 < 1) => 1
  slt t5, t1, t0     # t5 = (1 < -1) => 0

  # --- SLTU (unsigned) ---
  sltu t6, t2, t0    # t6 = (0 < 0xFFFFFFFF) => 1
  sltu a0, t0, t2    # a0 = (0xFFFFFFFF < 0) => 0

  # --- SLTI (signed immediate) ---
  li s0, -5          # s0 = -5
  slti s1, s0, 0     # s1 = (-5 < 0) => 1
  slti s2, s0, -10   # s2 = (-5 < -10) => 0

  # --- SLTIU (unsigned immediate) ---
  li s3, 5           # s3 = 5
  sltiu s4, s3, 10   # s4 = (5 < 10) => 1
  sltiu s5, s3, 3    # s5 = (5 < 3) => 0

    # Infinite loop to halt
.word 0

