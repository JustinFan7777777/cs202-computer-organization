.text
main:
	li a7, 5
	# system call: 5 = read integer
	ecall
	# read m, result stored in a0
	
	jal ra, fib
	# call fib(m), a0 = m is already the argument
	li a7, 1
	# system call: 1 = print integer
	ecall
	# print the result (a0)
	
	li a7, 10
	# system call: 10 = exit program
	ecall
	
fib:
	# ------- handle base case -------
	
	li t0, 1
	# load base case boundary value 1
	ble a0, t0, base_case
	# if (n <= 1), we jump to base case

	# ------- store crucial data in stack in advance -------
	
	addi sp, sp, -12
	# allocate 12 bytes on the stack for this call frame
	# that is, 3 things to store in each recursio loop
	
	sw ra, 0(sp)
	# save return address on the lower position
	# as recursive jal will overwrite ra
	# so we shall store its value in advance
	
	sw a0, 4(sp)
	# save n on the middle position
	# as recursive call will overwrite a0
	
	# ------- first recursion call: compute fib(n - 1) -------
	
	addi a0, a0, -1
	# a0 = n - 1
	
	jal ra, fib
	# call fib(n - 1): result returned in a0
	
	sw a0, 8(sp)
	# save our first result on the higher position
	
	# ------- second recursive call: compute fib(n - 2) -------
	
	lw a0, 4(sp)
	# before 'lw', a0 = fib(n - 1)
	# which is not the value we want in the second call
	# wo we reload our original n from the stack
	
	addi a0, a0, -2
	# this time we set a0 as (n - 2)
	
	jal ra, fib
	# call fib(n - 2), result returned in a0
	
	# ------- combine: fib(n) = fib(n - 1) + fib(n - 2) -------
	
	lw t0, 8(sp)
	# load saved fib(n - 1) from stack
	
	add a0, a0, t0
	# before 'add', a0 = fib(n - 2)
	# after, a0 = fib(n - 1) + fib(n - 2)
	
	# ------- current recursion loop exit -------
	
	lw ra, 0(sp)
	# restore out address to return back
	# this is just like: "find home"
	
	addi sp, sp, 12
	# free this call's stack frame
	# this is to update our stack pointer
	# meaning that this recursion loop ends, move to former one
	
	ret 
	# return back to former caller
	
base_case:
	li a0, 1
	# since both fib(0) & fib(1) are 1
	# we set our return value to 1
	
	ret 
	# ra is not overwritten, so return directly
