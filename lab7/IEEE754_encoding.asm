.text
	# ======= step 1: read the single-precision & convert to integer register =======
	li a7, 6
	ecall
	# read single-precision float
	# result is placed in fa0
	
	li a7, 11
	# 11 = print single character
	# after reading the input, all we need is the same
	# so we just set a7 once before output, which saves lots of lines
	
	fmv.x.w t0, fa0
	# float move: .w (float) -> .x (integer)
	# now t0 holds the exact 32-bit encoding
	# [31] = sign (1-bit)
	# [30:23] = exponent (8-bit, as single-precision)
	# [22:0] = mantissa （23-bit, 32 - 1 - 8 = 23）
	
	# ======= step 2: print the sig bit =======
	# ======= sign bit locates in [31] =======
	srli t1, t0, 31
	# shift right logically by 31-bit
	# [31] -> [0], with [31]~[1] all 0
	# t1 can only be 0 / 1
	
	addi a0, t1, '0'
	# convert 0 / 1 -> ASCII '0' / '1' ('0' = 48 in ASCII)
	ecall
	
	li a0, 10
	ecall
	# print: ASCII 10 = newline ('\n')
	# as a7 = 11 already, no need to change
	
	# ======= step 3: print the exponent =======
	# ======= exponent part is placed in [30] ~ [23] =======
	srli t2, t0, 23
	# shift right logically by 23-bit
	# [30] ~ [23] -> [7] ~ [0], lower 8 bits
	# with [8] = 0 / 1 (sign bit), and [31] ~ [9] all 0
	
	slli t2, t2, 24
	# shift left logically by 24 bits
	# after this, [7] ~ [0] -> [31] ~ [24], upper 8 bits
	# with original [8] moved out, and [23] ~ [0] all 0
	
	li t4, 8
	# loop counter = 8, as we need to extract exactly 8 bits
	
exp_loop:
	# we should extract & print bits in left -> right order
	# start from MSB [31] first, and move to next, ...
	srli t5, t2, 31
	# extract current MSB ([31]) to t5
	# [31] -> [0], with other bits = 0
	
	addi a0, t5, '0'
	# convert to ASCII '0' / '1'
	# if t5 = 0, a0 = 48 -> represent '0'
	# if t5 = 1, a0 = 49 -> represent '1'
	ecall
	
	slli t2, t2, 1
	# after finishing current MSB, we need to squeeze it out
	# current [30] becomes new [31] (MSB)
	
	addi t4, t4, -1
	# decrement loop counter
	# meaning that we've done with 1 more bit now
	# still have 'loop counter' numbers to extract
	
	bnez t4, exp_loop
	# branch if not equal zero
	# if (loop counter != 0) -> continue looping
	
	# after extracting & printing all 8 bits
	# we end with 'exponential' part, and prepare for new part
	li a0, 10
	# ASCII 10 = newline '\n'
	ecall
	# print newline for next part (mantissa)
	
	# ======= step 4: print mantissa =======
	# ======= mantissa is in bits [22] ~ [0], 23 bits in total =======
	slli t3, t0, 9
	# shift left logically by 9 bits
	# [22] ~ [0] -> [31] -> [9], upper 23 bits
	# with all [8] ~ [0] equal to 0
	
	# the below is just the same as we do in step 3
	# the only difference is: loop counter: 8 -> 23
	li t4, 23
	
mant_loop:
	srli t5, t3, 31
	# t5 = current MSB [31], 0 / 1
	
	addi a0, t5, '0'
	# convert to ASCII '0' / '1'
	li a7, 11
	# 11 = print single character
	ecall
	
	slli t3, t3, 1
	# shift next bit into MSB, to process in next loop
	addi t4, t4, -1
	# decrement loop counter
	bnez t4, mant_loop
	# if t4 != 0 -> continue looping
	
	li a0, 10
	# ASCII 10 = newline '\n'
	ecall
	
	li a7, 10
	# system call 10 = exit
	ecall
	# terminate the program