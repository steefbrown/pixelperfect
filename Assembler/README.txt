
Assembler README

CS3710 Project - PixelPerfect


Launch /Assembler/bin/debug/Assembler.exe

See Assembler.cs for instruction encoding implementation.
See Pseudo.cs for pseudo instructions and decomposition.


Rules for assembly:

	- Every token must be separated by whitespace
	- Instructions must have leading whitespace
	- The first operand may have a comma

	- Labels must not have any leading whitespace
	- Labels must be on their own line (not with instructions)
	- Labels are case-sensitive ("start" != "Start")

	- Registers are "$r0" through "$r15"
	- $r15 == $pc, a read only register that holds the current pc value
	- $r14 == $bp, a register dedicated to holding the frame pointer
	- $r13 == $sp, a register dedicated to holding the stack pointer
	- $r10-$r12 are volitile registers that are used in pseudo instructions

	- Supported pseudo instructions are call, ret, push, pop, stord, loadd
	- push and pop are relative to the stack pointer and work with the full 32-bit register
	- stord and loadd are like stor and load, except they are for 32-bit values
		
	- Immediates can come in the form of base16 by "0x" or base10 without "0x"

	- Comments can go on empty lines or anywhere after tokens. No block comments (/* */)

