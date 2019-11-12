.data
	base: .word 33
	sr1: .asciiz "Enter up to 1000 characters: "
	newLine: .asciiz "\n"
	userNumber: .space 1001 #1000 characters
	
.text # Instructions section, goes in text segment.

main:
	lw $t9, base # Store our base in $t9
	# PRINT PROMPT #
	li $v0, 4 # System call to print a string.
	la $a0, sr1 # Load string to be printed.
	syscall # Print string.