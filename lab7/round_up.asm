.text
	# ======= step 1: read single-precision float 'x' =======
	li a7, 6
	# system call 6 = read a float
	ecall
	# fa0 now holds the input value x (single-precision float)
	
	# ======= step 2: read positive integer 'r' =======
	li a7, 5
	# system call 5 = read an integer
	ecall
	# a0 now holds the input value r (integer)
	
	# ======= step 3: prepare two floating-point constants =======
	# fmv = float move, .d = double-precision, .s = single_precision
	# .x = integer register (integer register x: x1/a0...), .w = word (32-bit)
	# fmv.w.x fd, rs1: move rs1 (integer) -> fd (float) 
	
	li t0, 0x3f800000
	# 1.0f bit pattern = 0x3f800000
	fmv.w.x fa1, t0
	# fa1 = 1.0f (starting value for power = 10 ^ r)
	
	li t1, 0x41200000
	# 10,0f bit pattern = 0x41200000
	fmv.w.x fa2, t1
	# fa2 = 10.0f (multiplier used in the loop)
	
	# ======= step 4: special case (r = 0) =======
	beqz a0, compute_temp
	# if (r == 0) -> skip the power loop (power remains 1.0f)
	
	# ======= step 5: multiply by 10 for r times to compute power = 10 ^ r =======
	mv t0, a0
	# t0 = r (loop counter)
	
# after the loop. fa1 = 10 ^ r
# fmul.s: floating-point multiply (single-precision)
# fmul.s fd, fs1, fs2: fd (target) = fs1 (multiplicand) * fs2 (multiplier)
power_loop:
	fmul.s fa1, fa1, fa2
	# fa1 (power) = fa1 * 10.0f
	addi t0, t0, -1
	# decrement counter
	bnez t0, power_loop
	# repeat until counter reaches 0
	
compute_temp:
	# ======= step 6: compute temp = x * (10 ^ r)
	fmul.s fa3, fa0, fa1
	# fa3 = temp = x (input value) * (10 ^ r) (10 to the power of input value r)
	
	# ======= step 7: round temp to the nearest integer =======
	# fcvt.w.s: convert integer from float
	# rounding mode = round to nearest, e.g.:
	# 1.5671 * 1 = 1.5671 -> 2
	# 1.5671 * 10 = 15.671 -> 16
	# 1.5671 * 100 = 156.71 -> 157
	# 1.5671 * 1000 = 1567.1 -> 1567
	
	fcvt.w.s t1, fa3
	# t1 = round (temp) = round (x * (10 ^ r))
	
	# ======= step 8: convert the rounded integer back to a single-precision float =======
	# fcvt.s.w: convert float from integer
	fcvt.s.w fa4, t1
	# fa4 = float (round (x * (10 ^ r)))
	
	# ======= step 9: compute the final result = rounded_int / (10 ^ r) =======
	# suppose that x = 1.5671:
	# r = 1: 1.5671 * 1 = 1.5671 -> 2 -> 2 (0 bit after decimal point)
	# r = 2: 1.5671 * 10 = 15.671 -> 16 -> 1.6 (1 bit after decimal point)
	# r = 3: 1.5671 * 100 = 156.71 -> 157 -> 1.57 (2 bits after decimal point)
	# r = 4: 1.5671 * 1000 = 1567.1 -> 1567 -> 1.567 (3 bits after decimal point)
	
	fdiv.s fa0, fa4, fa1
	# fa0 = float (round (x * (10 ^ r))) / (10 ^ r)
	# after shifting back, fa0 has exactly r digits after the decimal point
	
	# ======= step 10: print the result & terminate the program =======
	li a7, 2
	# system call 2 = print single-precision float
	ecall
	# fa0 already = the final result, print it directly
	
	li a7, 10
	ecall
	# exit the program