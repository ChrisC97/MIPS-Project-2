.data
	base: .word 33
	sr1: .asciiz "Enter up to 1000 characters: "
	sr2: .asciiz "Invalid Input"
	newLine: .asciiz "\n"
	userString: .space 1001 #1000 characters
	charCount: .word 0
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
	jal removeTrailing
	la $s0, userString # message address.
	jal calcResult

	lw $s0, charCount
	slt $t0, $s0, 5 # characterCount < 5?
	beq $t0, 0, printInvalid # characterCount >= 5, invalid.
	slt $t0, $s0, 1 # characterCount < 1?
	beq $t0, 1, printInvalid # characterCount < 1, invalid.
	
	# PRINT RESULT
	li $v0, 1 # Printing result
	add $a0, $zero, $s5 # Set a0 to the result.
	syscall 
	j endProgram
	
	# PRINT INVALID #
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
	
# CALCULATE RESULT #
calcResult:	
	addiu $sp, $sp, -4
	sw $ra, ($sp) # Save $ra on the stack for when we want to return.
	add $t0, $zero, $zero # i.
	lw $t6, base # base.
	add $s5, $s5, $zero # result = 0.
cRLoop:
	add $s1, $s0, $t0 # mesage[i] address.
	lb $s2, 0($s1) # Load the character into $s2.
	beq $s2, 0, cREnd # End of string, exit out.
	jal toUppercase # Convert the character to uppercase. 
	jal isCharInRange # Is the character in our range? (0-9 and A-Z)
	bgt $s2, $t6, cRErrorEnd # If the number is larger than our base, Print an error.
	add $s5, $s5, $s2 # result += value.
cRLoopEnd:
	addi $t0, $t0, 1 # i++
	j cRLoop # Check the next character.
cRErrorEnd:
	addi $t7, $zero, -1 # Any error we get sets the character count to -1.
	sw $t7, charCount
cREnd:
	lw $ra, ($sp) # Load the address from the stack.
	addiu $sp, $sp, 4
	jr $ra
	
# CHECK IF CHAR IN RANGE #
isCharInRange:
	blt $s2, 48, cRLoopEnd # Value is less that '0', ignore it.
	bgt $s2, 90, cRLoopEnd # Value is more than 'Z', ignore it.
	bgt $s2, 57, checkIfIgnore # Value is more than '9', but it could still be a character.
	sub $s2, $s2, 48 # The value is between '0' and '9', make it values 0-9.
	j endCharCheck
checkIfIgnore:
	blt $s2, 65, messageLoopEnd # Value is between '9' and 'A', ignore it.
	sub $s2, $s2, 55 # The value is between 'A' and 'Z', make it values 10-35.
endCharCheck:
	jr $ra
	
# CONVERT TO UPPERCASE #
toUppercase: # Convert characters to their uppercase version.
	blt $s2, 'a', toUppercaseEnd  # If less than a, return. No change needed.
	bgt $s2, 'z', toUppercaseEnd  # If more than z, return. No change needed.
	sub $s2, $s2, 32  # Lowercase characters are offset from uppercase by 32.
toUppercaseEnd:
	jr $ra

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
	add $s7, $zero, $zero # charCount = 0.
fCLoop:
	add $t2, $t0, $t1 # message[i].
	lb $t3, 0($t2) # The character at message[i].
	beq $t1, 1002, fCEnd # i == 1002, end of string.
	slt $t4, $t3, 33 # message[i] < '!'?
	beq $t4, 1, fCLoopEnd # message[i] <= ' ', loop again.
	add $s7, $zero, $t1 # charCount = i.
fCLoopEnd:
	addi $t1, $t1, 1 # i++.
	j fCLoop
fCEnd:
	addi $s7, $s7, 1 # the number of characters is i+1.
	sw $s7, charCount # set charCount.
	jr $ra
	
# REMOVE TRAILING SPACES #
removeTrailing:
	la $t0, userString # message address.
	add $t1, $zero, $zero # 0, null/the end of a string.
	lw $t7, charCount # lastCharacterIndex.
	beq $t7, 1001, rTEnd # lastCharacterIndex == 1001, end of string.
rTLoop:
	add $t1, $t0, $t7 # message[lastCharacterIndex] address.
	sb $t2, 0($t1) # message[lastCharacterIndex] = null.
	addi $t7, $t7, 1 # lastCharacterIndex++.
	beq $t7, 1001, rTEnd # lastCharacterIndex == 1001, end of string.
	j rTLoop
rTEnd:
	jr $ra