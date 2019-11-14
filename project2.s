.data
	base: .word 33
	sr1: .asciiz "Enter up to 1000 characters: "
	sr2: .asciiz "Invalid Input"
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
	jal findCharCount
	#jal removeTrailing

	slt $t0, $s0, 5 # characterCount < 5?
	beq $t0, 0, printInvalid # characterCount >= 5, invalid.
	slt $t0, $s0, 1 # characterCount < 1?
	beq $t0, 1, printInvalid # characterCount < 1, invalid.
	j endProgram
	
	# PRINT INVALID
printInvalid:
	li $v0, 4
	la $a0, sr2
	syscall 
	
	# END OF PROGRAM #
endProgram:
	li $v0, 4 # Printing new line.
	la $a0, newLine
	syscall 
	li $v0, 10 # Exit program system call.
	syscall
	
# REPLACE STRING #
replaceString:
	la $t0, userString # message address.
	la $t1, tempString # tempMessage address.
	add $t2, $zero, $zero # i.
rSLoop:
	add $t5, $t0, $t2 # message[i] address.
	add $t6, $t1, $t2 # tempMessage[i] address.
	lb $t7, 0($t6) # The character at tempMessage[i].
	sb $t7, 0($t5) # message[i] = tempMessage[i].
	sb $zero, 0($t6) # tempMessage[i] = 0
 	addi $t2, $t2, 1 # i++.
	beq $t2, 1002, rSLoopEnd # i == 1002, end of string.
	j rSLoop
rSLoopEnd:
	li $v0, 4 # Printing new line.
	la $a0, newLine
	syscall 
	li $v0, 4 # Printing the new string
	la $a0, userString
	syscall 
	jr $ra # Return to where we were in the main loop.
	
# REMOVE LEADING SPACES #
removeLeading:
	la $t0, userString # message address.
	la $t1, tempString # newMessage address.
	add $t2, $zero, $zero # i.
	add $t3, $zero, $zero # h.
	add $t4, $zero, $zero # hitCharacter. Defaults to false (0).
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
	j rLLoop
rLLoopEnd:
	jr $ra # Return to where we were in the main loop.
	
# FIND LAST CHARACTER INDEX #
findCharCount:
	la $t0, userString # message address.
	add $t1, $zero, $zero # i.
	add $t8, $zero, $zero # charCount = 0.
fCLoop:
	add $t2, $t0, $t1 # message[i].
	lb $t3, 0($t2) # The character at message[i].
	beq $t0, 1002, fCEnd # i == 1002, end of string.
fCLoopEnd:
	j fCLoop
fCEnd:
	jr $ra
	
# REMOVE TRAILING SPACES #
removeTrailing:
	la $t0, userString # message address.
	add $s0, $zero, $t8 # characterCount = lastCharacterIndex. Used later.
	addi $s0, $s0, -1 # lastCharacterIndex ends on a null character, which we don't want to count as a character.
	add $t2, $zero, $zero # 0, null/the end of a string.
	beq $t8, 1002, rTEnd # lastCharacterIndex == 1002, end of string.
rTLoop:
	add $t1, $t0, $t8 # message[lastCharacterIndex] address.
	sb $t2, 0($t1) # message[lastCharacterIndex] = null.
	addi $t8, $t8, 1 # lastCharacterIndex++.
	beq $t8, 1002, rTEnd # lastCharacterIndex == 1002, end of string.
	j rTLoop
rTEnd:
	jr $ra