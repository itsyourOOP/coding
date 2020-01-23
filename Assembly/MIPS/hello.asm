#MIPS Program
.include "macros.asm"

.data #data goes here, like strings and such
string:.asciiz "Okay Okay Okay\n"

.globl main

.text #actual program starts here
main:
	print_s (string)
	print_i (12)
