.section .data
array:      .word 5, 10, 15, 20, 25    # Array of integers
arr_size:   .word 5                   # Array size
result:     .word 0                   # To store result

.section .text
.globl _start
_start:

    # Load base address of array
    la t0, array              # t0 = &array[0]

    # Load number of elements into t1
    la t2, arr_size
    lw t1, 0(t2)              # t1 = array size

    li t3, 0                  # t3 = index i = 0
    li t4, 0                  # t4 = sum = 0

loop:
    bge t3, t1, end           # if i >= size, break

    slli t5, t3, 2            # t5 = i * 4
    add t6, t0, t5            # t6 = &array[i]
    lw s0, 0(t6)              # s0 = array[i]
    add t4, t4, s0            # sum += array[i]

    addi t3, t3, 1            # i++
    jal zero, loop            # jump to loop

end:
    # Store the result
    la t5, result
    sw t4, 0(t5)

    # Demonstrate a few more instructions
    li s1, -1
    srai s1, s1, 1            # Arithmetic shift right
    and s1, t4, s1            # Mask sum
    or s1, s1, t3             # OR with index
    xor s1, s1, t1            # XOR with size
    slt s1, s1, t4            # Set if less than
    sltu s1, t3, t1           # Unsigned set less than

    # End of program marker
    .word 0
