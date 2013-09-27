
Application README

CS3710 Project - PixelPerfect


See main_app.cr16 for final application code. 

Note that other .cr16 files may be out of date, may not follow the conventions,
may not compile, may have incorrect memory map addresses, etc.

Save assembled file to app.dat (this is where synthesis looks for it).


Assembly code conventions:

	- All registers are callee saved
	- All function labels should be prefixed by "f_" (eg. "f_write_led")
	- All labels inside a function should be prefixed by the name of the function (without "f_")
	- Call a function using "call" (eg. "call f_write_led")
	- Supply arguments to a function using register $r0 for the first arg, and so on
	- Return from a function using "ret"
	- Use conditional branch instructions to jump to non-function labels
	- Do not use registers $r15-$r13
	- Assume registers $r10-$r12 are corrupted by pseudo instructions
	- Use registers $r0-$r9 judiciously
	- Comment liberally


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
	- $r10-$r12 are volitile registers used in pseudo instructions

	- Supported pseudo instructions are call, ret, push, pop, stord, loadd
	- push and pop are relative to the stack pointer and work with the full 32-bit register
	- stord and loadd are like stor and load, except they are for 32-bit values
		
	- Immediates can come in the form of base16 by "0x" or base10 without "0x"

	- Comments can go on empty lines or anywhere after tokens. No block comments (/* */)



