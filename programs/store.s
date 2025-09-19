    .section .text
    .global _start
_start:
    # ---------- Test sb ----------
    la   t0, buffer      # t0 -> buffer
    li   t1, 0x5A        # test byte
    sb   t1, 0(t0)
    lb   t2, 0(t0)
    li   t3, 0x5A
    bne  t2, t3, fail

    # ---------- Test sh ----------
    li   t1, 0xC0DE
    sh   t1, 0(t0)
    lhu   t2, 0(t0)
    li   t3, 0xC0DE
    bne  t2, t3, fail

    # ---------- Test sw ----------
    li   t1, 0x12345678
    sw   t1, 0(t0)
    lw   t2, 0(t0)
    li   t3, 0x12345678
    bne  t2, t3, fail

success:
    # All tests passed → jump to the memory location "zero_word"
    jal   zero_word              # jump to address of word 0

fail:
    # Loop forever on failure
    j fail

    .section .data
buffer:
    .word 0              # scratch buffer for tests
zero_word:
    .word 0              # this word is 0; we’ll jump here on success

