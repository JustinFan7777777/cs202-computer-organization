# encoding consists of the following three parts:
# 1. sign bit (1 bit)
# 2. exponent field (11 bits)
# 3. fraction field (52 bits)

# classification rules:
# 1. exponent field = 0 & fraction field = 0 -> type = 'Zero'
# 2. exponent field = 0 & fraction field is not all 0 -> type = 'Denormal'
# 3. in all other cases -> type = 'Normal'

.data
	double_buf: .space 8
	# memory buffer to hold the 64-bit double
	# 8 bytes aligned for double-precision storage
	
	zero_str: .asciz "Zero"
	denormal_str: .asciz "Denormal"
	normal_str: .asciz "Normal"
	# strings for classification, three types in total
	
.text
	# ======= step 1: read double-precision input =======
	li a7, 7
	ecall
	# syscall 7 = read a double-precision floating-point number
	# the 64-bit value is placed into fa0
	
	# ======= step 2: store double to memory =======
	la t0, double_buf
	fsd fa0, 0(t0)
	# fsd: store the 64-bit double from fa0 into memory
	
	lw s0, 0(t0)
	# s0 = low 32 bits = fraction[31 : 0]
	lw s1, 4(t0)
	# s1 = high 32 bits = sign[63] + exponent[62 : 52] + fraction[51 : 32]
	
	# ======= step 3: output sign bit (1 bit) =======
	srli t0, s1, 31
	# now sign bit is in LSB of t0
	andi t0, t0, 1
	# [others, LSB (sign bit)] & 0000...0001
	# if (t0 == 1) -> sign bit = 1
	# if (t0 == 0) -> sign bit = 0
	addi a0, t0, '0'
	# convert 0 / 1 to ASCII '0' / '1'
	# if (sign bit == 0) -> a0 = 0 + '0' = '0'
	# if (sign bit == 1) -> a0 = 1 + '0' = '1'
	
	li a7, 11
	ecall
	# syscall 11 = print character, print sign bit
	
	li a0, 10
	ecall
	# 10 = ASCII newline, print new line
	
	# ======= step 4: output exponent field (11 bits) =======
	# ======= initialize loop counter & index pointer =======
	li t1, 11
	# loop counter = 11 (we need to output 11 bits one by one)
	li t2, 30
	# t2 is a pointer, pointing to indices of MSB -> LSB of exponent field 
	# starting bit position is MSB of exponent lays
	 
exp_loop:
	# ======= get current bit to print =======
	srl t3, s1, t2
	# now current bit is in LSB of t3
	andi t3, t3, 1
	# if (current bit == 1) -> t3 = 1, otherwise = 0
	addi a0, t3, '0'
	# convert t3 0 / 1 to ASCII '0' / '1'
	
	# ======= print current character =======
	li a7, 11
	ecall
	# print out single character = current bit
	
	# ======= update loop counter & index pointer =======
	addi t2, t2, -1
	# pointer move right to point the next position
	addi t1, t1, -1
	# decrement loop counter, meaning that we've stil got 't1' bits to print
	
	# ======= loop condition =======
	bnez t1, exp_loop
	# bnez: branch if not equal zero
	# if (loop counter != 0) -> still have bits waiting for us to print -> continue looping
	
	li a0, 10
	ecall
	# exponent field finished, print newline
	
	# ======= step 5: output fraction field (52 bits) =======
	# fraction[51 : 0] = fraction[51 : 32] (high 20 bits) + fraction[31 : 0] (low 32 bits)
	
	# ======= first solve with high 20 bits
	li t1, 20
	# t1 = loop counter
	li t2, 19
	# t2 = index pointer, starting at [19] in s1
	
frac_high_loop:
	srl t3, s1, t2
	# current bit is in LSB of t3
	andi t3, t3, 1
	# if (current bit == 1) -> t3 = 1, otherwise 0
	addi, a0, t3, '0'
	# convert 0 / 1 -> '0' / '1'
	
	li a7, 11
	ecall
	# print out current bit
	
	addi t2, t2, -1
	# decrement index pointer, move right to next position
	addi t1, t1, -1
	# decrement loop counter, meaning that we still have 't1' bits to print
	
	bnez t1, frac_high_loop
	# if (loop counter != 0) -> continue looping
	
	# ======= next solve with low 32 bits =======
	li t1, 32
	# loop counter = 32
	li t2, 31
	# index pointer, starting at bit [31]
	
frac_low_loop:
	srl t3, s0, t2
	# now current bit = LSB of t3
	andi t3, t3, 1
	# clear all bits (to 0), only retain LSB
	addi a0, t3, '0'
	# convert 0 / 1 -> '0' / '1'
	
	li a7, 11
	ecall
	# print current bit
	
	addi t2, t2, -1
	# decrement index pointer
	addi t1, t1, -1
	# decrement loop counter
	
	bnez t1, frac_low_loop
	# if (loop counter != 0) -> jump back to loop
	
	li a0, 10
	ecall
	# fraction field completed, print newline
	
	# ======= step 6: determine floating-point type =======
	# ======= extract exponent value =======
	li t0, 0x7FF
	slli t0, t0, 20
	# t0 = 0x7FF00000 = 0111_1111_1111_0000...0000
	# with [30 : 20] = 1 & others = 0, aligning with exponent field
	
	and t1, s1, t0
	# bitwise and operation
	srli t1, t1, 20
	# now t1 has [10 : 0] = exponent, and others = 0
	
	# ======= check if fraction is zero =======
	li t0, 0x000FFFFF
	and t2, s1, t0
	# t2 = high 20 bits of fraction
	or t3, t2, s0
	# t2 = 0000_0000_0000_[high 20 bits of fraction]
	# s0 = [low 32 bits of fraction]
	# if (t3 == 0) -> all 52 bits of fraction = 0
	# otherwise there exists some '1' in fraction -> not all zero
	
	# ======= classification =======
	bnez t1, is_normal
	# if (exponent != 0) -> other cases -> type = 'Normal'
	
	# exponent = 0 for the following statements
	beqz t3, is_zero
	# if (t3 == 0) -> exponent & fraction both = 0 -> type = 'Zero'
	
	# exponent = 0 & fraction != 0 -> type = 'Denormal'
	la a0, denormal_str
	j print_type
	
is_zero:
	la a0, zero_str
	j print_type
	
is_normal:
	la a0, normal_str
	
print_type:
	li a7, 4
	# system call 4 = print string
	ecall
	# print classification type
	
	li a0, 10
	li a7, 11
	ecall
	# print newline
	
	li a7, 10
	ecall
	# exit the program
	