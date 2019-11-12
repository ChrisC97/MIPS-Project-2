.data
	base: .word 33
	sr1: .asciiz "Enter up to 1000 characters: "
	newLine: .asciiz "\n"
	userString: .space 1001 #1000 characters
	newString: .space 1001 
	
.text # Instructions section, goes in text segment.

main:
	lw $t9, base # Store our base in $t9
	
	# PRINT PROMPT #
	li $v0, 4 # System call to print a string.
	la $a0, sr1 # Load string to be printed.
	syscall # Print string.
	
	# READ USER INPUT #
	li $v0, 8 # System call for taking in input.
	la $a0, userString # Where the string is saved.
	li $a1, 1001 # Max number of characters to read.
	syscall
	
	jal removeLeading
	
	# END OF PROGRAM #
endProgram:
	li $v0, 4 # Printing new line.
	la $a0, newLine
	syscall 
	li $v0, 10 # Exit program system call.
	syscall
	

# REMOVE LEADING SPACES #
removeLeading:
	la $s0, userString # The address of the string the user entered.
	la $s7, newString # The address of our new string.
	add $t0, $zero, $zero # $t0 will iterate over each character (message[i]).
	add $t1, $zero, $zero # $ t1 is our current position in the new string (newMessage[j]).
	add $t2, $zero, $zero # $t2 is if we hit a character other than space.
rLLoop:
	add $s1, $s0, $t0 # message[i]
	add $s6, $s7, $t1 # newMessage[i]
	lb $s2, 0($s1) # Load the character at message[i] into $s2.
	beq $s2, 0, rLLoopEnd # End of string, exit out.
	beq $t2, 1, rLLoopOther # Skip space logic if we're done with it.
	bne $s2, 32, rLLoopOther # It's not a space, skip the space logic.
rLLoopSpace:
	addi $t0, $t0, 1 # i++
	j rLLoop
rLLoopOther:
	addi $t2, $zero, 1 # We hit a character.
	sb $s2, 0($s6) # newMessage[j] = message[i]
	addi $t1, $t1, 1 # j++
	addi $t0, $t0, 1 # i++
	j rLLoop
rLLoopEnd:
	li $v0, 4 # Printing new line.
	la $a0, newLine
	syscall 
	li $v0, 4 # Printing the new string
	la $a0, newString
	syscall 
	jr $ra # Return to where we were in the main loop.