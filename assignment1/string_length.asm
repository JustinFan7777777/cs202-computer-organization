.data
	buffer: .space 258
	# allocate 258 bytes as input buffer
	# 256 ASCII chars + 1 newline '\n' + 1 null terminator '\0'
	
.text
main:
	# ------- step 1: Read the input string -------
	la a0, buffer
	# a0 = starting address of buffer
	li a1, 258
	# a1 = max bytes to read
	
	li a7, 8
	# system call: 8 = read string
	ecall
	# now buffer holds the input string
	# RARS automatically appends '\n' & '\0' at the end
	
	# ------- step 2: traverse the string and count length -------
	la t0, buffer
	# t0 = current character pointer, starts at the buffer head
	li t1, 0
	# t1 = length counter, initialized to 0
	
count_loop:
	lb t2, 0(t0)
	# load 1 byte from address t0 -> t2
	
	# ------- end-of-string is detected! -------
	beqz t2, print
	# beqz: branch if equal zero
	# if (t2 = '\0' (null terminator)), jump to print
	
	li t3, 10
	# t3 = 10, which is the ASCII code of '\n'
	beq t2, t3, print
	# if (t2 == '\n' (newline)), jump to print
	
	# ------- count the length -------
	addi t1, t1, 1
	# current character is valid, increment coounter
	addi t0, t0, 1
	# advance pointer to the next character
	j count_loop
	# continue looping

# ------- step 3: print the length -------
print:
	mv a0, t1
	# a0 = string length
	li a7, 1
	# system call: 1 = print integer
	ecall
	# output the final result