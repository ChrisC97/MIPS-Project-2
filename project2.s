.data
	base: .word 33
	sr1: .asciiz "Enter up to 1000 characters: "
	newLine: .asciiz "\n"
	userString: .space 1001 #1000 characters
	tempString: .space 1001 
	
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
	jal replaceString
	
	# END OF PROGRAM #
endProgram:
	li $v0, 4 # Printing new line.
	la $a0, newLine
	syscall 
	li $v0, 10 # Exit program system call.
	syscall
	
# REPLACE STRING #
replaceString:
	
# REMOVE LEADING SPACES #
removeLeading:
	la $t0, userString # message address.
	la $t1, tempString # newMessage address.
	add $t2, $zero, $zero # i.
	add $t3, $zero, $zero # h.
	add $t4, $zero, $zero # hitCharacter. Defaults to false (0).
	add $t8, $zero, $zero # lastCharacterIndex. Used for remove trailing.
rLLoop:
	add $t5, $t0, $t2 # message[i].
	add $t6, $t1, $t3 # newMessage[h].
	lb $t7, 0($t5) # The character at message[i].
	beq $t7, 0, rLLoopEnd # message[i] = null, end of string.
	beq $t4, 1, rLLoopOther # hitCharacter == true, ignore our space logic.
	bne $t7, 32, rLLoopOther # message[i] != ' ', ignore our space logic.
rLLoopSpace:
	addi $t2, $t2, 1 # i++.
	j rLLoop
rLLoopOther:
	addi $t4, $zero, 1 # hitCharacter = true (1).
	sb $t7, 0($t6) # newMessage[h] = message[i]
	addi $t3, $t3, 1 # h++.
	addi $t2, $t2, 1 # i++.
	bne $t7, 32, rLLoopLCIndex # mesage[i] != ' ', need to keep track of this position.
	j rLLoop
rLLoopLCIndex:
	add $t8, $zero, $t3 # lastCharacterIndex = h.
	j rLLoop
rLLoopEnd:
	li $v0, 4 # Printing new line.
	la $a0, newLine
	syscall 
	li $v0, 4 # Printing the new string
	la $a0, tempString
	syscall 
	jr $ra # Return to where we were in the main loop.
	
# REMOVE TRAILING 