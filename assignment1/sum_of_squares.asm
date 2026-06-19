.text
main:
	# ------- step 1: read the input integer n -------
	li a7, 5
	# system call: 5 = read integer
	ecall
	# we read the input
	mv s0, a0
	# s0 = n, save input value into a preserved register
	
	# ------- step 2: initialize loop variable -------
	li s1, 1
	# s1 = i, loop counter starting from 1
	li s2, 0
	# s2 = sum, accumulator initialized to 0
	
# ------- step 3: calculate sum of squares of all integers -------
sum_loop:
	bgt s1, s0, print
	# if (i > n), loop is done, jump to print
	
	mul t0, s1, s1
	# t0 = i * i (square of current i)
	add s2, s2, t0
	# sum += i ^ 2
	
	addi s1, s1, 1
	# i++, move to next iteration
	j sum_loop
	# repeat the loop
	
# ------- step 4: print the result
print:
	mv a0, s2
	# a0 (system-call argument) = sum
	li a7, 1
	# system call: i = print integer
	ecall
	# ouput the final result

# ------- step 5: exit program -------
li a7, 10
# system call: 10 = exit program
ecall
# terminate
	