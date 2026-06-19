.text
	# ======= step 1: input phase =======
	li.w $a7, 5
	# li.w loads an immediate (constant) value into a register
	# we load syscall number 5 (read integer) into $a7
	
	syscall 0
	# execute using the value in $a7, set immediate number as 0
	# input integer m is automatically placed in $a0
	
	addi.w $t2, $a0, 0
	# addi.w with immediate 0 = copy (move) a value between registers
	# we copy input m from $a0 into $t2
	
	# ======= step 2: special case handling =======
	# fibonacci definition: F(0) = 1, F(1) = 1
	# when encounter m == 0 / 1, handle instantly (no loop needed)
	
	li.w $t3, 0
	# li.w load the constant 0 into $t3 for future comparison
	
	beq $t2, $t3, special_case
	# branch if equal: if (m == 0), jump to label 'special_case'
	
	li.w $t3, 1
	# this time check if (m == 1)
	
	beq $t2, $t3, special_case
	# if (m == 1) -> jump to label 'special_case'
	
	# ======= step 3: loop initiation (for m >= 2) =======
	# this time we try a new way to implement fibonacci, which is 'loop'
	# instead of using recursion (memory, stack), which was done with 'RISC-V'
	# use registers to store the last two fibonacci numbers
	
	li.w $t4, 1
	# $t4 = previous = F(0) = 1 initially
	
	li.w $t5, 1
	# $t5 = current = F(1) = 1 initialy
	
	li.w $t3, 2
	# $t3 = index = 2, as we start from calculating F(2)
	
# ======= step 4: loop start -> loop end =======
loop_start:
	# ======= loop continue? =======
	blt $t2, $t3, loop_end
	# loop condition: continue while (index <= m)
	# if (m < index) -> we are done, jump out of the loop to 'loop_end'
	
	# ======= calculate the sum -> new =======
	add.w $t6, $t4, $t5
	# $t6 (temporary register)= new (F(index)) = previous (F(index - 2))+ current (F(index - 1))
	
	# ======= update previous & current for next loop =======
	# imagine that '1' second passes for each iteration (clock pulse)
	# just like 'sequential circuit' we learnt in course 'digital logic' 
	# time (t): $t4 (previous), $t5 (current), $t6 (new)
	# time (t + 1): $t4 (current), $t5 (new), $t6 (new new)
	# so we move: $t5 -> $t4, $t6 -> $t5
	
	addi.w $t4, $t5, 0
	# previous (in time (t + 1))= current (in time t)
	# as current becomes elder after one second
	
	addi.w $t5, $t6, 0
	# current (in time (t + 1))= next (in time t)
	# as next also becomes elder after one second
	
	# ======= increment index and continue =======
	addi.w $t3, $t3, 1
	# index = index + 1
	# meaning that we have completed calculating F(index)
	# whose value is stored in $t5 at this moment
	# then we are moving to calculate F(index + 1) in the next loop
	
	b loop_start
	# branch unconditionally to the beginning of our loop
	# loop condition will be triggered when started
	
loop_end:
	b print_result
	# at this point, loop ended, $t5 contains the correct F(m)
	# normal case should pass handle special case, and jump to print section
	
# ======= step 2: special case handling =======
special_case:
	li.w $t5, 1
	# for both (m == 0) & (m == 1), result = 1 the same
	# load 1 directly into $r15 (final result register)
	
# ======= step 5: output section & terminatation =======
print_result:
	li.w $a7, 1
	# load syscall number '1' (print integer) into $a7 (syscall number)
	
	addi.w $a0, $t5, 0
	# copy result (F(m)) from $t5 into $a0((standard argument register for syscall)
	
	syscall 0
	# execute the 'print integer' syscall based on instruction in $a7
	# to print out the result (F(m)) stored in $a0 (argument for output)
	
	li.w $a7, 10
	# load syscall number 10 (exit program)
	syscall 0
	# terminate the program
