/*
	NOTE(Daniel Bokser): It seems that due to the way the Zig now invokes the linker, 
	the entry point name must be specified in build.zig. Thus, the ENTRY() call here is no longer needed. 

	ENTRY(eventHandler)
*/

/*
	NOTE(Daniel Bokser): This GROUP line is from the PlaydateSDK.  This doesn't seem to be required for Zig.
	But, leaving it here just in case...

	GROUP(libgcc.a libc.a libm.a)
*/

/*
	NOTE(Daniel Bokser): Had to add this PHDRS contstruct in to force however Zig invokes the linker 
	to make sure there is only one combined ELF segment, which is what PDC seems to expect.
*/
PHDRS
{
   global_segment PT_LOAD;
}
SECTIONS
{
	/*
		NOTE(Daniel Bokser): Had to add this in to force however Zig now invokes the linker 
		to make sure everything starts at address 0, which is what PDC seems to expect.
	*/
	. = 0;

	.text :
	{
		*(.text)
		*(.text.*)

		KEEP(*(.init))
		KEEP(*(.fini))

		/* .ctors */
		*crtbegin.o(.ctors)
		*crtbegin?.o(.ctors)
		*(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
		*(SORT(.ctors.*))
		*(.ctors)

		/* .dtors */
 		*crtbegin.o(.dtors)
 		*crtbegin?.o(.dtors)
 		*(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
 		*(SORT(.dtors.*))
 		*(.dtors)

		*(.rodata*)

		KEEP(*(.eh_frame*))

	}: global_segment

	.data :
	{
		__etext = .;

		__data_start__ = .;
		*(vtable)
		*(.data*)

		. = ALIGN(4);
		/* preinit data */
		PROVIDE_HIDDEN (__preinit_array_start = .);
		KEEP(*(.preinit_array))
		PROVIDE_HIDDEN (__preinit_array_end = .);

		. = ALIGN(4);
		/* init data */
		PROVIDE_HIDDEN (__init_array_start = .);
		KEEP(*(SORT(.init_array.*)))
		KEEP(*(.init_array))
		PROVIDE_HIDDEN (__init_array_end = .);

		. = ALIGN(4);
		/* finit data */
		PROVIDE_HIDDEN (__fini_array_start = .);
		KEEP(*(SORT(.fini_array.*)))
		KEEP(*(.fini_array))
		PROVIDE_HIDDEN (__fini_array_end = .);

		. = ALIGN(4);
		/* All data end */
		__data_end__ = .;

	}: global_segment

	.bss :
	{
		. = ALIGN(4);
		__bss_start__ = .;
		*(.bss*)
		*(COMMON)
		*(COM)
		. = ALIGN(4);
		__bss_end__ = .;

	}: global_segment

  /DISCARD/ :
  {
		*(.ARM.exidx)
  }

}
