.text
.global _start

_start:
# ======= step 1: wait for case number 9 =======
wait_loop:
	lw t0, 0(gp)
	# t0 = case number
	
	li t1, 9
	# t1 = target case number = 9
	
	bne t0, t1, wait_loop
	# branch if not equal
	# if (t0 != t1) -> continue looping
	
	# ======= step 2: read input data & extract IEEE754 float fields =======
	lw t0, 4(gp)
	# t0 = 32-bit test data
	
	andi t0, t0, 0xFFFF
	# mask out high 16 bits
	# keep only low 16 bits (FP16)
	
	srli t1, t0, 15
	# shift right logically by 15 bits
	# t1 = original MSB (bit 15) = sign bit
	# if (t1 = 0) -> positive, otherwise negative
	
	srli t2, t0, 10
	# extract exponent bits (bit 14 ~ 10)
	
	andi t2, t2, 0x1F
	# 0x1F = 11111, exactly 5 bits
	# only remains low 5 bit, masks out others
	
	andi t3, t0, 0x3FF
	# same method as above:
	# 0x3FF = 11_1111_1111, 10 bits in total
	# as we want to extract fraction bits (bit 9 ~ 0)
	
	li t4, 0x400
	# 0x400 = 0100_0000_0000, with bit 10 = 1
	
	or t3, t3, t4
	# restore the implicit '1' for normalized numbers
	# that is: 1.M, the 1 next to point is what we called 'implicit' 1
	# t3 contains 11-bit significand (1.M), scaled by 2 ^ 10
	
	# ======= step 3: shift operation based on net exponent =======
	# value = (1.M) * (2 ^ (E - 15))
	# where E is the biased exponent, and 15 is the bias
	# so (E - 15) is the real exponent
	
	# target = value * 16 = (1.M) * （2 ^ (E - 15)）* (2 ^ 4) = (1.M) * (2 ^ (E - 11))
	# since t3 = (1.M) * (2 ^ 10), final integer = t3 * (2 ^ (E - 21))
	
	li t5, 21
	# load value 21 into t5
	
	sub t6, t2, t5
	# t6 = E - 21 = net shift amount
	
	bltz t6, shift_right
	# branch if less than zero
	# if ((E - 21) < 0) -> jump to right shift block
	
	# case A: E - 21 >= 0
	sll t3, t3, t6
	# t3 = t3 << t6
	# shift left logically t3 by (E - 21) bits
	# which is equal to t3 * (2 ^ (E - 21))
	# now t3 = final integer
	
	j calc_sign
	# jump to sign processing
	# skip the right shift block
	
shift_right:
	# case B: E - 21 < 0
	# instead of left shift, we need right shift
	sub t6, x0, t6
	# x0 always holds 0
	# t6 = -t6
	# convert to a positive shift offset:
	# (E - 21 < 0) -> (21 - E > 0)
	
	srl t3, t3, t6
	# t3 = t3 >> t6
	# again t3 = final integer
	
# ======= step 4: sign processing =======
calc_sign:
	beqz t1, store_result
	# branch if equal zero
	# if (t1 == 0) -> positive -> skip to storing result
	
	# for negative numbers -> two's complement
	not t3, t3
	# first, bit-wise NOT invert:
	# 0 -> 1, 1 -> 0
	# this step is to get one's complement
	
	addi t3, t3, 1
	# then add 1 to get two's complement
	
store_result:
	andi t3, t3, 0xFF
	# 0xFF = 1111_1111
	# clear any upper bits, restricting final result to exactly 8 bits
	
	# ======= step 5: write final Q3.4 result back to data memory =======
	sw t3, 12(gp)
	# write result into 12(gp)
	
	ebreak
	# terminate the diff test using 'ebreak'
	