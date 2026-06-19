.data
	newline: .asciz "\n"
	# string constant for newline output
	
.text
	# ======= step 1: read n (array length) =======
	li a7, 5
	ecall
	# read integer, place it in a0
	
	mv s0, a0
	# copy n from a0 -> s0
	# in case that a0 will be overwritten by next ecal
	
	fcvt.s.w fs3, s0
	# convert integer n to float, and stored in fs3
	# we pre-convert once here for later devision
	
	# ======= step 2: key initialization =======
	fmv.w.x fs0, zero
	# fmv.w.x: float move word from integer register
	# fs0 (sum of absolute) = 0x0000_0000 -> 0.0
	
	fmv.w.x fs1, zero
	# fs1 (sum of squaring) = 0.0
	
	mv t0, zero
	# t0 (loop index) = 0 initially (starts from index 0)
	# use t0 to traverse through all inputs later
	
# ======= step 3: loop, one (x_i, y_i) pair per iteration ======
loop_start:
	# ======= loop condition =======
	bge t0, s0, loop_end
	# branch if greater than or equal
	# if (index >= n) -> exit loop
	# once index reaches n, all pairs (index from 0 -> (n - 1)) are processed
	
	# ======= read x_i first =======
	li a7, 6
	# syscall 6 = "read float (singl precision)"
	ecall
	# x_i stored in fa0
	
	fmv.s fs4, fa0
	# fmv.s: move value from fa0 -> fs4
	# now fs4 = x_i, since it will be overwritten by next ecall
	# so we preserve x_i in fs4 in advance
	
	# ======= then read y_i  =======
	li a7, 6
	ecall
	fmv.s fs5, fa0
	# read y_i, store in fa0, move to fs5
	
	# ======= compute x_i ^ 3 =======
	fmul.s ft0, fs4, fs4
	# fmul.s: single-precicion float multiply
	# ft0 = x_i * x_i
	
	fmul.s ft0, ft0, fs4
	# multiply one more time, as we want the cube of x_i
	# ft0 = x_i * x_i * x_i = x_i ^ 3
	
	# ======= compute e_i = y_i - (x_i ^ 3 + x_i) =======
	fadd.s ft0, ft0, fs4
	# fadd.s: single-precision float add
	# ft0 = x_i ^ 3 + x_i
	
	fsub.s ft1, fs5, ft0
	# fsnb.s: single-precison float subtract
	# ft1 (e_i) = y_i - (x_i ^ 3 + x_i)

	# ======= compute |e_i| for E1 =======
	# note that ft1 (e_i) can be positive or negative
	# so we need to take absolute value of e_i
	
	fabs.s ft2, ft1
	# fabs.s: float absolute value (clears sign bit)
	# ft2 = |e_i|
	
	fadd.s fs0, fs0, ft2
	# fs0 (sum of absolute) += |e_i|
	
	# ======= compute (e_i) ^ 2 for E2 =======
	# note that squaring is always non-negative
	# so no need to take absolute value
	
	fmul.s ft3, ft1, ft1
	# ft3 = e_i * e_i = (e_i) ^ 2
	
	fadd.s fs1, fs1, ft3
	# ft1 (sum of squaring) += (e_i) ^ 2
	
	# ======= increment index for next iteration =======
	addi t0, t0, 1
	# index += 1
	# indicating that we have done with current (x_i, y_i) pair
	# it's time to go to next iteration to deal with pair (x_(i + 1), y_(i + 1))
	
	j loop_start
	# unconditional jump back to loop, for next process
	
loop_end:
	# ======= step 4: compute E1 & E2 and output results =======
	# ======= first compute & output E1 =======
	fdiv.s fa0, fs0, fs3
	# fdiv.s: single-precision float divide
	# fa0 (E1) = (sum of absolute) / float (n)
	# we place the E1 directly into fa0 (argument register for syscall 2)
	
	li a7, 2
	# syscall 2 = "print float (single-precisiion)"
	ecall
	# print E1 in fa0 in the first line
	
	# ======= then output a newline after E1 =======
	la a0, newline
	# load address of "\n" string into a0
	
	li a7, 4
	# syscall 4 = "print string"
	ecall
	# print "\n", after E1, and before E2
	
	# ======= finally compute & output E2 =======
	fdiv.s fa0, fs1, fs3
	# fa0 (E2) = (sum of squaring) / float (n)
	
	li a7, 2
	ecall
	# print E2 in the second line
	
	li a7, 10
	ecall
	# terminate the program