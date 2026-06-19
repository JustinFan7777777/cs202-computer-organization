.data
	prompt_dividend: .asciz "Enter dividend (32-bit signed integer): "
	prompt_divisor: .asciz "Enter divisor (16-bit signed integer): "
	prompt_quotient: .asciz "The quotient (17-bit signed integer) is: "
	prompt_remainder: .asciz "The remainder (32-bit signed integer) is: "
	error_message: .asciz "Error: Division by zero!\n"
	
.text
	# ======= step 1: read and process two numbers =======
	la a0, prompt_dividend
	li a7, 4
	ecall
	# print prompt for the first number (dividend)
	
	li a7, 5
	ecall
	mv t0, a0
	# t0 = dividend, already full 32-bit signed integer
	
	la a0, prompt_divisor
	li a7, 4
	ecall
	# print prompt for the second number (divisor)
	
	li a7, 5
	ecall
	mv t1, a0
	# t1 = divisor (16-bit signed)
	
	# ======= check for division-by-zero exception =======
	beq t1, zero, div_by_zero
	# if (divisor == 0), jump to error handling
	
	# ======= step 3: extract sign bits =======
	srai s3, t0, 31
	# s3 = sign bit of dividend (0 / -1)
	# shift right arithmetically by 31-bit
	# if positive: s3 = 00...0 = 0
	# if negative: s3 = 11...1 = -1
	
	srai s4, t1, 31
	# s4 = sign bit of divisor (0 / -1)
	
	xor s5, s3, s4
	# s5 = quotient sign, xor = bit-wise xor operation
	# if signs agree, 00...0 xor 00...0 / 11...1 xor 11...1, then s5 = 00...0 = 0
	# if signs disagree, 00...0 xor 11...1, then s5 = 11...1 = -1
	
	mv s6, s3
	# s6 = remainder sign = dividend sign = s3
	# by convention, dividend & remainder have same sign
	
	# ======= step 4: compute absolute values =======
	bgez t0, abs_dividend_done
	# if (dividend >= 0), skip negation
	
	sub t0, zero, t0
	# dividend = -dividend (get absolute value)
	
abs_dividend_done:
	bgez t1, abs_divisor_done
	# if (divisor >= 0), skip negation
	
	sub t1, zero, t1
	# divisor = -divisor (get absolute value)
	
abs_divisor_done:
	# ======= step 5: unsigned division =======
	li t2, 0
	# t2 = quotient (17-bit), initialized to 0
	
	mv t3, t0
	# t3 = remainder (32-bit), initialized to |dividend|
	
	slli t1, t1, 16
	# shift left logically by 16 bits to a 32-bit register
	# upper 16 bits = |divisor|, lower 16 bits = 0
	# e.g. divisor = 2 -> t1 = 0x0002_0000 (32-bit)
	# this step is used to align divisor to high 16 bits of 32-bit remainder
	
	li a0, 17
	# a0 = loop counter = 17
	# loop counter = number of bits in quotient
	# 17-bit quotient = 32-bit dividend - 16-bit divisor + 1
	
div_loop:
	sub t3, t3, t1
	# remainder = remainder - divisor
	
	bgez t3, valid_subtraction
	# branch if greater than or equal to zero operation
	# if (remainder >= 0), jump to 'valid_subtraction'
	
	# ======= remainder < 0 after subtraction =======
	# ======= undo to restore back to remainder =======
	# ======= left shift Quotient, set new LSB to 0 =======
	add t3, t3, t1
	# remainder = remainder + divisor
	
	slli t2, t2, 1
	# quotient <<= 1, with new LSB = 0 implicitly
	
	j shift_divisor
	# skip 'valid_subtraction', and proceed to 'shift_divisor'
	
# ======= remainder >= 0 after subtraction =======
# ======= left shift Quotient, set new LSB to 1 =======
valid_subtraction:
	slli t2, t2, 1
	# Quotient <<= 1, with new LSB = 0
	
	addi t2, t2, 1
	# set new LSB to 1
	# this bit is actually the MSB in final form of quotient
	
# ======= right shift divisor by 1 bit =======
shift_divisor:
	srli t1, t1, 1
	# divisor =>> 1, with new MSB = 0 (not sign-extended)
	# this correctly aligns divisor with next lower quotient bit
	
# ======= check if done 17rd repetition? =======
addi a0, a0 , -1
# decrement loop counter (initially 17)

bnez a0, div_loop
# branch if not equal 0, if (counter != 0), keep looping
# if done 17-th repetition, break loop

# ======= step 6: sign correction to quotient & remainder =======
beq s5, zero, quot_pos
# s5 = quotient sign, 0 => signs agree, -1 => signs disagree
# if (s5 == 0), quotient should be positive, no need to adjust, skip

sub t2, zero, t2
# otherwise (s5 == -1), negate quotient: t2 = -t2

quot_pos:
	beq s6, zero, rem_pos
	# s6 = remainder sign = dividend sign (by convention, dividend & remainder have same sign)
	# if (s6 == 0), remainder should be positive, no need to adjust, skip
		
	sub t3, zero, t3
	# otherwise (s6 == -1), negate remainder: t3 = -t3

# ======= print results to console =======
# ======= output format: <prompt3><quotient><newline><prompt4><remainder> =======
rem_pos:
	la a0, prompt_quotient
	li a7, 4
	ecall
	# print prompt for the result (quotient)

	mv a0, t2
	li a7, 1
	ecall
	# print quotient (signed integer)
	
	li a0, 10
	li a7, 11
	ecall
	# print newline character (ASCII 10 = '\n')
	
	la a0, prompt_remainder
	li a7, 4
	ecall
	# print prompt for the result (remainder)
	
	mv a0, t3
	li a7, 1
	ecall
	# print remainder (signed integer)
	
	li a7, 10
	ecall
	# terminate the program 
	
# ======= division-by-zero handling =======
div_by_zero:
	li a7, 4
	la a0, error_message
	ecall
	# print the message of division-by-zero exception
	
	li a7, 10
	ecall
	# terminate the program
