/* link.ld */
ENTRY(_start)
SECTIONS
{
    . = 0x00000000;   /* match your CPU's reset vector */
    .text : { *(.text) }
    .data : { *(.data) }
    .bss  : { *(.bss) }
}