.data 
	str_invalid: .asciz "Invalid input"
	# prompt for invalid input
	str_nl: .asciz "\n"
	# newline character
	
.text
main:
	# ------- step 1: read n -------
	li a7, 5
	# system call: 5 = read integer
	ecall
	# read the integer and store it in a0
	mv s0, a0
	# s0 = n, for later usage
	
	# ------- step 2: validate n -------
	bgt s0, zero, init
	# if (n > 0), proceed to initialization
	# otherwise, print "Invalid input"
	
	la a0, str_invalid
	# a0 = address of invalid message
	li a7, 4
	# system call: 4 = print string
	ecall
	# we print: "Invalid input"
	
	j exit
	# jump to exit, no further processing
	
# ------- step 3: read first element, init max and min -------
init:
	li, a7, 5
	# read first element in the array
	ecall
	# a0 = arr[0]
	
	mv s1, a0
	# s1 = max, initialized to first element
	mv s2, a0
	# s2 = min, initialized to first element
	
	li s3, 1
	# s3 = i, loop counter starts at 1
	# we use it to read all the elements
	# sincethe first element is read already
	# we set it as 1, instead of 0
	
# ------- step 4: loop through remaining elements -------
loop:
	bge s3, s0, print
	# if (i >= n), jump to print
	# arr[n]: arr[0], arr[1], ... , arr[n - 1]
	# if i reaches n, all the elements are read
	
	li, a7, 5
	# system call: 5 = read the current integer
	ecall
	# we read arr[i]
	mv t0, a0
	# t0 (temporary)= current element
	
	ble t0, s1, check_min
	# if (arr[i] <= max), skip max update
	# otherwise arr[i[ > max, update max
	
	mv s1, t0
	# max = arr[i], update max
	
check_min:
	bge t0, s2, increment
	# if (arr[i] >= min), skip min update
	
	mv s2, t0
	# min = arr[i], update min
	
increment:
	addi, s3, s3, 1
	# i++, increment array pointer
	j loop
	# continue our loop
	
# ------- step 5: print max and min -------
print:
	mv a0, s1
	# a0 (system call argument) = max
	li a7, 1
	# system call: 1 = print integer
	ecall
	# print max
	
	la a0, str_nl
	# a0 = address of "\n"
	li a7, 4
	# system call: 4 = print string
	ecall
	# print newline between max & min
	
	mv a0, s2
	# a0 (system call argument) = min
	li a7, 1
	# system call: 1 = print integer
	ecall
	# print min
	
# ------- step 6: exit -------
exit:
	li a7, 10
	# system call: 10 = exit program
	ecall
	# terminate
	
	
