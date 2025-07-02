.text
.globl __start

__start:
  la sp, stack_end
.word 0

.data
stack: .space 4096
stack_end: 
