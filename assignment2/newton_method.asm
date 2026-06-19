.data
	eps: .float 0.000001
	# convergence threshold for stopping iteration
	# as we want: |x_next - x_current| < 10 ^ (-6)
	
	three: .float 3.0
	# prepare for: f'(x) = 3 * (x ^ 2) + 1
	
	one: .float 1.0
	# used in f'(x), also for constructing absolute value via fsgnj.s
	
	
.text
	# ======= step 1: read input values =======
	li a7, 6
	ecall
	# read first float 'a' into fa0
	
	fmv.s fs0, fa0
	# fs0 permanently holds 'a' throughout
	
	li a7, 6
	ecall
	fmv.s fs1, fa0
	# fs1 holds current x (initially x_0, also x_current)
	# which will update every iteration
	
	# ======= step 2: load constants into registers =======
	la t0, eps
	flw fs2, 0(t0)
	# flw: load a float from t0
	# fs2 = 10 ^ (-6)
	
	la t0, three
	flw fs3, 0(t0)
	# fs3 = 3.0
	
	la t0, one
	flw fs4, 0(t0)
	# fs4 = 1.0
	
# ======= step 3: newton's method loop =======
loop:
	# ======= compute f(x) = x ^ 3 + x - a =======
	fmul.s ft0, fs1, fs1
	# ft0 = x ^ 2
	
	fmul.s ft1, ft0, fs1
	# ft1 = x ^ 3
	
	fadd.s ft2, ft1, fs1
	# ft2 = x ^ 3 + x
	
	fsub.s ft2, ft2, fs0
	# ft2 = x ^ 3 + x - a = f(x_current)
	
	# ======= compute f'(x) = 3 * (x ^ 2) + 1 =======
	fmul.s ft3, fs3, ft0
	# ft3 = 3.0 * (x ^ 2)
	
	fadd.s ft3, ft3, fs4
	# ft3 = 3.0 * (x ^ 2) + 1.0
	
	# ======= compute x_next = x_current - f(x_current) / f'(x_current) =======
	fdiv.s ft4, ft2, ft3
	# ft4 = f(x) / f'(x)
	
	fsub.s ft5, fs1, ft4
	# ft5 = x - f(x) / f'(x) = x_next
	
	# ======= compute |x_next - x_current| =======
	fsub.s ft6, ft5, fs1
	# ft6 = x_next - x_current
	
	fsgnj.s ft7, ft6, fs4
	# fsgnj.s: float-point sign inject, single-precision
	# copy magnitude of ft6 & sign of fs4 (1, positive)
	# ft7 = |x_next - x_current|
	
	# ======= loop condition =======
	flt.s t1, ft7, fs2
	# flt.s t1, f1, f2: float less than
	# if (|x_next - x_current| < 10 ^ (-6)) -> t1 = 1, otherwise t1 = 0
	
	bnez t1, output
	# bnez: branch if not equal zero
	# if (t1 != 0) -> t1 = 1 -> meet the requirement -> stop loop, jump to output
	# otherwise t1 = 0 -> still need to continue looping
	
	fmv.s fs1, ft5
	# x_current <- x_next
	
	j loop
	# unconditional back to loop, repeat iteration
	
# ======= step 4: output result and exit =======
output:
	fmv.s fa0, ft5
	# move converged x_next into fa0 for printing
	
	li a7, 2
	ecall
	# print float(result)
	
	li a7, 10
	ecall
	# terminate the program
	