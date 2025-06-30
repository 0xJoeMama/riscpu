.text

.global __start

__start:
  addi t0, zero, 31
loeoep:
  beq t0, zero, out
  addi t0, t0, -1
  jal zero, loeoep
out:
  
