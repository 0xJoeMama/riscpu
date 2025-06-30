.text

.global __start

__start:
  jal ra, func
# currently we use null to terminate the program so this needs to be here otherwise we will be looping infinitely...
.word 0

func:
  jalr zero, 0(ra)
