# 请补全代码, 不可修改已有部分
# Please complete the code below, without modifying the existing part
.macro print_string(%str)
	.data 
		pstr:   .asciz   %str
	.text
		la a0,pstr
		li a7,4
		ecall
.end_macro

.macro end
	li a7,10
	ecall
.end_macro

.text
	li a7,5
	# system call: 5 = read integer
	ecall
	# read first integer
	# result stored in a0
	
	mv t1,a0
	# t1 = first integer
	ecall
	# read second second integer
	# a7 is still 5, we donot overwrite it
	# so no need to set it again
	mv t2,a0	
	# t2 = second integer
		
	sub t0, t1, t2		
	# t0 = t1 - t2 
	
	mv a0, t0
	# a0 = result		
	li a7, 1
	# system call: 1 = print integer
	ecall	
	# print the sum

	slti t3, t2, 0
	# t3 = 1, if t2 < 0
	# t3 = 0, if t2 >= 0
	
	sgt t4, t0, t1
	# t4 = 1, if (t1 - t2) > t1
	# t4 = 0, if (t1 - t2) <= t1
	
	bne t3, t4, overflow
	
	print_string("\nNo overflow occured.")
	# print if no overflow detected
	
	jal exit	
	# jump to exit
	# skip the overflow message
overflow:
	print_string("\nOverflow occured.")
	# print if overflow was detected
exit:	
	end
