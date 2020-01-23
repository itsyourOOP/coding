
#given the address of a string, prints that string. 
.macro print_s (%str)
push v0
push a0
li v0, 4
la a0, %str
syscall
pop a0
pop v0
.end_macro

#given an integer, prints that integer
.macro print_i (%int)
push v0
push a0
li v0, 1
li a0, %int
syscall
pop a0
pop v0
.end_macro

