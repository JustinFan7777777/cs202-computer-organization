# data section:
# define all static strings used in the program
.data
	# .asicz automatically appends a null terminator '\0'
	# at the end of each string
	str_mul: .asciz "x" 
	# multiplication sign
	
	str_eq: .asciz "=" 
	# equal sign
	
	str_nl: .asciz "\n" 
	# newline charactor
	
	str_sp2: .asciz "  " 
	# 2 spaces, used when c >= 10
	# only 2 bits left in this case
	
	str_sp3: .asciz "   "
	# 3 spaces, used when c < 9
	# the result only occupies one bit
	# so 3 bits left in this case
	
# text section: 
# all program instructions are placed here
.text 
main:
	li s0, 1 
	# s0 stores a, a = 1
	
outer_loop:
	li s1, 1 
	# s1 stores b, b = 1
	
inner_loop:
	mv t0, s0 
	# s0 -> t0, to = a
	mv t1, s1 
	# s1 -> t1, t1 = b
	
	jal ra, print_entry 
	# call print_entry
	# and save return address into ra
	
	addi s1, s1, 1 
	# b's update: b++
	
	ble s1, s0, inner_loop 
	# if (b <= a) continue inner loop
	
	la a0, str_nl
	# current row complete, print new line
	li a7, 4 
	# system call: 4 = print string
	ecall 
	# we print the newline charactor
	
	addi s0, s0, 1 # a++
	# meaning that we move to next row
	
	li t0, 9 
	# load upper bound '9' for comparison
	ble s0, t0, outer_loop 
	# if (a <= 9), go back to outer loop
	# after a's increment, we should reset b as 1
	
	li a7, 10 
	# system call: 10 = exit program
	ecall 
	# terminate the program
	
print_entry:
	mul t2, t0, t1 # t2 = a * b
	# pre-calculate c before ecall overwrites a
	
	mv a0, t0
	# a0 = a, prepare integer argument to print
	li a7, 1
	# system call: 1 = print integer
	ecall 
	# print a
	
	la a0, str_mul
	li a7, 4
	ecall
	# print x
	
	mv a0, t1 
	# a0 = b
	li a7, 1
	ecall
	# print b
	
	la a0, str_eq
	li a7, 4
	ecall
	# print =
	
	mv a0, t2 
	# a0 = c
	li a7, 1
	ecall
	
	li t3, 10
	# load 10 for comparison
	# we need to judge whether print 2 spaces or 3 spaces
	blt t2, t3, pad_three
	# if (c < 10), pad 3 spaces
	# otherwise, pad 2 spaces
	
pad_two:
	la a0, str_sp2
	# a0 = address of 2-space string
	li a7, 4
	# system call: 4 = print string
	ecall
	# we print 2 spaces: "  "

	ret 
	# return back to main
	# by jumping to the address stored in ra
	
pad_three:
	la a0, str_sp3
	# a0 = address of 3-space string
	li a7, 4
	# system call: 4 = print string
	ecall
	# we print 3 spaces: "   "
	
	ret 
	# return back to main
	# by jumping to the address stored in ra
