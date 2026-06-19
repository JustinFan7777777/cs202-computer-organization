.data
	prompt1: .asciz "Enter first number (16-bit signed integer) : "
	prompt2: .asciz "Enter second number (16-bit signed integer) : "
	
.text
	# ======= step 1: read and process two numbers =======
	
	li a7, 4
	la a0, prompt1
	ecall
	# print prompt for the first number  (multiplicand)
	
	li a7, 5
	ecall
	mv t0, a0
	# read first signed integer
	# t0 temporarily holds raw input
	
	# originally, t0 is a 32-bit number
	slli t0, t0, 16
	# move the lower 16 bits -> upper 16 bits
	# and fill the lower 16 bits with 0 automatically
	# now, t0: [16 bits]_0000_0000_0000_0000
	
	srai t0, t0, 16
	# move the upper 16 bits -> lower 16 bits
	# fill the upper 16 bits with 0/1 (signed bit)
	# now if t0 is positive: 0000_0000_0000_0000_[16bits]
	# if negative: 1111_1111_1111_1111_[16 bits]
	
	li a7, 4
	la a0, prompt2
	ecall
	# print prompt for the second number (multiplier)
	
	li a7, 5
	ecall
	mv t1, a0
	# t1 temporarily holds raw input

	slli t1, t1, 16
	srai t1, t1, 16
	# for example, if we want it be -3 (0xFFFFFFFD)
	# if the upper 16 bits are invalid, e.g. 0x1234FFFD
	# by using the same method, we have:
	# 0x1234FFFD (incorrect) -> 0xFFFD0000 -> 0xFFFFFFFD (correct)
	
	# ======= step 2: extract sign bit =======
	srai s3, t0, 31
	srai s4, t1, 31
	# move the sign bit: [31] -> [0]
	# shift right arithmetically by 31 bits
	# if positive -> 0xFFFFFFFF
	# if negative -> 0x00000000
	# s3 (32-bit) = sign bit of first number (multiplicand)
	# s4 (32-bit) = sign bit of second number (multiplier)
	
	xor s3, s3, s4
	# if same sign (positive * positive / negative * negative)
	# result of s3 goes to 0 (0x00000000)
	# if not the same (positive * negative / negative * positive)
	# result should be -1 (0xFFFFFFFF)
	# as every bit is different, 32 '1' after xor
	
	# ======= step 3: compute absolute values =======
	bgez t0, abs1_done
	# branch is greater than or equal to:
	# if (t0 >= 0) -> positive -> skip negation
	
	sub t0, zero, t0
	# if negative -> find absolute value -> t0 = -t0
	
abs1_done:
	bgez t1, abs2_done
	# the same, (t1 >= 0) -> skip negation
	
	sub t1, zero, t1
	# (t1 < 0) -> t1 = -t1
	
abs2_done:
	# ======= step 4: 16-bit unsigned multiplication =======
        li t2, 0
        # t2 = product accumulator, start at 0
        
        li a0, 0
        # a0 = loop counter
        
        li a1, 16
        # a1 = iterations = 16, corresponding with 16-bit
        
loop:
	# ======= 4.1: multiply multiplicand by current LSB of multiplier =======
	# ======= and add the result to our product ======= 
	andi s2, t1, 1
	# bit-wise and between t1 & 0000_0000_..._0001 (32-bit)
	# s2 (0/1) = LSB of t1 (multiplier)
	
	beq s2, zero, skip_add
	# if (LSB = 0) -> 0 * anything = 0 -> skip addition
	
	add t2, t2, t0
	# (LSB = 1) -> add t0 (multiplicand) to product
	
skip_add:
	# ======= 4.2 shift multiplicand & multiplier to prepare for next iteration =======
	slli t0, t0, 1
	# shift t0 (multiplicand) left by 1 bit, and fill the LSB with 0
	# meaning that t0 * 2, to get ready for the next multiplication
	# as we move to next bit of multiplier (start from LSB)
	
	srli t1, t1, 1
	# shift t1 (multiplier) right by 1 bit, and fill the MSB with 0
	# meaning that we have already done with the current LSB
	# we can now throw it away (evict it)
	# and after shifting, the second bit becomes the LSB
	# so during the next iteration, we again extract the LSB from t1
	
	# ======= 4.3 check whether enter new iterations ======= 
	addi a0, a0, 1
	# increment loop counter
	
	blt a0, a1, loop
	# loop counter (start from 0) < a1 = 16 (iterations), continue to loop
	
	# ======= step 5: whether to add a minus sign to final result =======
	# ======= based on the sign of multiplicand & multiplier =======
	beq s3, zero, done
	# recap that s3 indicates the sign of the final result
	# if multiplicand & multiplier are of same sign
	# the final result should be positive, with s3 = 0
	# if multiplicand & multiplier are of distinct sign
	# the final result should be negative, with s3 = -1
	# if (s3 = 0) -> t2 (product) is exactly the final result
	# no need to add a minus sign, directly go to 'done'
	
	sub t2, zero, t2
	# otherwise (s3 = -1) -> add a minus sign to t2 as our final result
	
done:
	# ======= step 6: output final result =======
	mv a0, t2
	# move final result to a0 for printing
	
	li a7, 1
	# system call: 1 = print signed integer
	ecall
	
	li a7, 10
	ecall
	# terminate the program