OUTPUT_ARCH( "riscv" )
SECTIONS
{
    /* go to address 0 */
    . = 0x0;
    /* there start placing part of the text segment */
    .text :
    {
        /* specifically all of the text segment */
        *(.text)
    }
}
