    .section .text
    .global _start
_start:
    la   t0, test_data

    # ---------- Test lb ----------
    lb   t1, 0(t0)       # load first byte (0x7F)
    li   t2, 0x7F        # expect +127
    bne  t1, t2, fail

    lb   t1, 1(t0)       # load second byte (0x80)
    li   t2, -128        # expect -128 sign-extended
    bne  t1, t2, fail

    # ---------- Test lbu ----------
    lbu  t1, 0(t0)       # load first byte
    li   t2, 0x7F
    bne  t1, t2, fail

    lbu  t1, 1(t0)       # load second byte (0x80)
    li   t2, 128         # expect 128 zero-extended
    bne  t1, t2, fail

    # ---------- Test lh ----------
    lh   t1, 2(t0)       # load halfword at offset 2 → 0x1234
    li   t2, 0x1234
    bne  t1, t2, fail

    # Also test negative halfword
    li   t3, -1
    sh   t3, 0(t0)       # overwrite with 0xFFFF
    lh   t1, 0(t0)
    li   t2, -1
    bne  t1, t2, fail

    # ---------- Test lhu ----------
    # Use the same -1 halfword at offset 0 → 0xFFFF
    lhu  t1, 0(t0)
    li   t2, 0xFFFF
    bne  t1, t2, fail

    # Restore for clean test
    li   t3, 0x1234
    sh   t3, 2(t0)
    lhu  t1, 2(t0)
    li   t2, 0x1234
    bne  t1, t2, fail

success:
    # All tests passed → jump to the word containing 0
    j   zero_word

fail:
    # Loop forever
    j fail

    .section .data
test_data:
    .byte 0x7F          # +127, fits in signed byte
    .byte 0x80          # -128 if sign-extended, 128 if zero-extended
    .byte 0x34          # low byte of halfword
    .byte 0x12          # high byte of halfword (0x1234)
zero_word:
    .word 0             # jump target on success

