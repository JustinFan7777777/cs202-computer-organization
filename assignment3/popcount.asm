.text
.global _start

_start:
# ======= step 1: check if test case becomes 7 =======
wait_for_case_7:
	lw t0, 0(gp)
	# load word from address (0 + gp) into t0
	# t0 = case number
	
	li t1, 7
	# load immediate value 7 into t1 for comparison
	# t1 = target case number (7)
	
	bne t0, t1, wait_for_case_7
	# if (case number != 7) -> continue looping
	
	# ======= step 2: read test data & initialize registers =======
	lw t0, 4(gp)
	# load the word from address (4 + gp) into t0
	# this time t0 = test data
	
	andi t0, t0, 0xFF
	# we only handle all 8-bit data
	# so mask out high bits, keeping only the low 8-bit unsigned data
	# 0xFF = 0000...00_1111_1111
	# after bit-wise and operation:
	# all higher bits are forced to 0
	# lowest 8 bits remains the same as before
	
	li t1, 0
	# ti = (bit == 1) counter
	
	li t2, 8
	# t2 = loop counter
	# since data is 8-bit wide, we only loop 8 times
	
# ======= step 3: loop to count number of 1s =======
count_loop:
	andi t3, t0, 1
	# extract the lowest bit of t0 (current data)
	# t3 = LSB of data
	
	add t1, t1, t3
	# update counter for (b == 1)
	# if t3 = 1, counter++
	# if t3 = 0, counter no change
	
	srli t0, t0, 1
	# shift t0 right logically by 1 bit
	# complement new MSB with 0
	# remove current LSB, as we have done with it
	# make current 2nd lowest bit as new LSB
	
	addi t2, t2, -1
	# decrement loop counter by 1
	
	bnez t2, count_loop
	# branch if not equal to 0
	# if (loop counter != 0) -> continue looping
	# if loop counter becomes 0, it means that we have done loop with 8 times
	# that is, we have done with all 8 bits of data -> over
	
	# ======= step 4: write result back tp specified data memory =======
	sw t1, 12(gp)
	# store result from t1 (1s counter) into the word at address (12 + gp)
	
	# ======= step 5: end of program =======
	ebreak