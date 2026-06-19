# ------- macro: print a string literal -------
.macro print_string(%str)
    .data 
        pstr:   .asciz   %str
        # define the string in data segment
        
    .text
        la a0,pstr
        # load address of string into a0
        li a7,4
        # system call: 4 = print string
        ecall
        # we print the string
.end_macro

# ------- macro: exit the program -------
.macro end
    li a7,10
    # system call: 10 = exit progeam
    ecall
    # terminate
.end_macro       

.data
    min_value: .word 0
    # reserve one word in memory to store the current minimum
    
.text
    print_string("please input the number: ")    
    
    li a7, 5   
    # system call: 5 = read integer        
    ecall
    # we read n (number of integers), result in a0
    
    mv t0, a0
    # to = n, save this count for later use
    slli a0, t0, 2
    # a0 = n * (2 ^ 2) = n * 4
    # calculate total bytes needed
    # as each int-number is of 32 bits = 4 bytes
    
    li a7, 9    
    # system call: 9 = allocate heap memory
    ecall
    # allocate (n * 4) bytes
    # with base address returned in a0
    
    mv t1, a0       
    # t1 = base address of the allocated array
    mv t2, a0       
    # t2 = current write pointer, starts at base
    
    print_string("please input the array\n")    
    
    add t3, zero, zero    
    # t3 = i = 0, loop counter for reading input
    
# ------- input integer on by one, read it, and store it -------
loop_read:                   
    li a7, 5      
    # system call: 5 = read integer
    ecall
    # we read one integer, result in a0
    sw a0, (t2)   
    # store the integer at current pointeraddress   
    
    addi t2, t2, 4
    # advance pointer to next word (4 bytes each update)
    
    addi t3, t3, 1
    # i++
    
    bne t3, t0, loop_read
    # if (i != n) keep reading
    # the length of the array is n
    # so we should guarantee n input integers in total
    
# ------- initialize min_value with the first element -------
    lw a0, (t1)       
    # t1 stores the base address of the array
    # load first element of the array
    la t4, min_value
    # load address of min_value
    sw a0, (t4)
    # store first element as initial minimum
    
    add t3, zero, zero
    # before, i = n, when we count the number of input integer
    # then we need to use i again to traverse through the array
    # so reset i = 0
    add t2, t1, zero    
    # before, t2 points to the address of array[n]
    # then we should visit every element in array form the beginning
    # s0 reset pointer t2 back to start of array
    
loop_find_min:
    lw a0, min_value
    # a0 = current minimum value
    lw a1, 0(t2)
    # a1 = current array element
    
    jal find_min
    # call find_min(a0, a1)
    # result returned in a0
    
    la t4, min_value
    # load address of min_value 
    sw a0, 0(t4)
    # update min_value with the returned result
    
    addi t2, t2, 4                    
    # advance pointer to next element
    addi t3, t3, 1
    # i++
    
    bne t3, t0, loop_find_min  
    # if i != n, contimue loop
    # we need to traverse through every element in the array
    # to guarantee that the min_val we get after the termination
    # is indeed the minimum of the whole array
    
    print_string("the min value is: ")
    
    li a7, 1
    # system call: 1 = print integer
    la t4, min_value
    # load the address of min_value
    lw a0, (t4)
    # load the final minimum into a0
    ecall
    # then we print the minimum value
    
    end
    # exit the program
    
find_min:    
    blt a0, a1, not_update
    # if (a0 = aurrent minimum value < a1 = current array element)
    # no update needed!
    
    mv a0, a1
    # otherwise we shall update out minimum
    # a0 (current minimum value) = a1 (new minimum found)
    
not_update:
    jr ra  
    # directly return to caller 
