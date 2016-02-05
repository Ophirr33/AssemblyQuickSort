.data 
        .align 5
array:  .asciiz "Joe"
	.align 5
	.asciiz "Jenny"
	.align 5
	.asciiz "Jill"
	.align 5
	.asciiz "John"
	.align 5
	.asciiz "Jeff"
	.align 5
	.asciiz "Joyce"
	.align 5
	.asciiz "Jerry"
	.align 5
	.asciiz "Janice"
	.align 5
	.asciiz "Jake"
	.align 5
	.asciiz "Jonna"
	.align 5
	.asciiz "Jack"
	.align 5
	.asciiz "Jocelyn"
	.align 5
	.asciiz "Jessie"
	.align 5
	.asciiz "Jess"
	.align 5
	.asciiz "Janet"
	.align 5
	.asciiz "Jane"

size: 	.word 16
	.align 2
data:	.space 64 			#16 pointers
space:  .asciiz "  "
openbr: .asciiz "["
closbr: .asciiz "]\n"
init:	.asciiz "Initial array is:\n"
finito: .asciiz "Quick sort is finished!\n"

.text

main: 

setdata:				# simple loop to initialize char * data
  li $t0, 0 				# i = 0
  lw $t1, size				# set t1 to 16
data_loop: 
  beq $t0, $t1, continue_main		# for (i = 0; i < size; i++)
    li $t2, 4				# Offset for data, j = 4
    li $t3, 32				# Offset for array, k = 32
    mul $t2, $t2, $t0			# j *= i
    mul $t3, $t3, $t0			# k *= i
    la $t4, array			# array address
    la $t5, data			# data address
    add $t4, $t4, $t3			# array + k
    add $t5, $t5, $t2			# data + j
    sw $t4, ($t5)			# data[i * 4] = array + 32 * i
    addi $t0, $t0, 1			# i += 1
  j data_loop

continue_main:

  li $v0, 4				# set Syscall to print string
  la $a0, init
  # printf("Initial array is:\n");
  syscall				# print init
  la $a0, data
  lw $a1, size
  # print_array(data, size);
  jal print_array			# print array
  la $a0, finito
  # printf("Quick sort is finished!\n")
  syscall				# print finito
 
  la $a0, data
  li $a1, 0
  li $a2, 15
  # quicksort(data, 0, size - 1
  jal quicksort
  
  la $a0, data
  lw $a1, size
  # print_array(data, size);
  jal print_array			# print array

  li $v0, 10				# end
  # exit(0)
  syscall


print_array: 				# prints an array of strings
  move $t2, $a0				# address of array
  move $t1, $a1				# size of array
  li $v0, 4				# set syscall to print string
  la $a0, openbr
  #printf("[  ");
  syscall				# print open-bracket
  la $a0, space
  syscall				# print string
  # i = 0
  li $t0, 0				
  # while (i < size) printf ("  %s", a[i++]);
print_loop:
  beq $t0, $t1, end_print		# for (i = 0; i < size, i++)
    li $t3, 4				# j = 4
    mul $t3, $t3, $t0			# j *= i
    add $t3, $t3, $t2			# j += address of array
    lw $a0, ($t3)			# load address of array[i] into syscall
    syscall				# print array[i]
    la $a0, space			# load print address into syscall
    syscall				# print string
    addi $t0, $t0, 1			# i += 1
  j print_loop    
end_print:
  la $a0, closbr
  # printf("]\n")
  syscall				# print close bracket
  jr $ra				# exit print_array

str_compare:				# takes the address of two strings (less than 10 characters) and returns -1, 0, or 1 
					# -1 if second is less than first, 0 if equal, 1 if greater
  move $t2, $a0				# loads the address of the first string
  move $t3, $a1				# loads the address of the second string
  li $t0, 0				# i = 0
  li $t1, 10				# i < 10, 10 is the maximum length of the string
# for(; *x!='\0' && *y!='\0; x++, y++)
str_loop:		
  beq $t0, $t1, end_str_equal		# for (i = 0; i < 10; i++)
    add $t4, $t2, $t0			# load the address for the bit of the first string
    add $t5, $t3, $t0			# load the address for the bit of the second string
    lb $t4, ($t4)                       # load the byte/char
    lb $t5, ($t5)			# load the byte/char
    
    beq $t4, 0, is_second_null		# if (first is null, check whether second is null as well)
    beq $t5, 0, end_str_greater		# otherwise, return 1 if second is null
    blt $t4, $t5, end_str_less		# return -1 if first bit is less than second bit
    bgt $t4, $t5, end_str_greater	# return 1 if first bit is greater than second bit
    addi $t0, $t0, 1			# i += 1
  j str_loop				# loop again, since both bits were equal
is_second_null:				# returns -1 or 0 depending on whether the second bit is null
  beq $t5, 0, end_str_equal
  j end_str_less
# if (*y < *x)
end_str_greater:			# return -1
  li $v0, -1
  jr $ra
# if (*y == *x)
end_str_equal:				# return 0
  li $v0, 0
  jr $ra
# if (*x < *x)
end_str_less:				# return 1
  li $v0, 1
  jr $ra
  
swap:					# takes an address of an arary and two positions to swap
  move $t0, $a0				
  move $t1, $a1				# j = index 1
  move $t2, $a2				# k = index 2
  li $t3, 4				# 4 is the size of the array item slot
  
  mul $t1, $t1, $t3			# j *= 4
  mul $t2, $t2, $t3			# k *= 4
  add $t1, $t1, $t0			# j += array address
  add $t2, $t2, $t0			# k += array address
  
  lw $t8, ($t2)				# grab string a[j]
  lw $t9, ($t1)				# grab string a[k]

  sw $t9, ($t2)				# a[k] = a[j]
  sw $t8, ($t1)				# a[j] = a[k]    		
  jr $ra
  
quicksort:
  addi $sp, $sp, -28 			# preserve the save registers and return address I'll be altering
  sw $s0, ($sp)
  sw $s1, 4($sp)
  sw $ra, 8($sp)
  sw $s2, 12($sp)
  sw $s3, 16($sp)
  sw $s4, 20($sp)
  sw $s5, 24($sp)
  
  move $s0, $a1				# lo
  move $s1, $a2				# hi
  move $s2, $a0				# data
  
  # i = start
  move $s4, $s0
  # j = end				
  move $s5, $s1				
  
  add $t0, $s0, $s1			# lo + hi 
  div $t0, $t0, 2			# (lo + hi) / 2. pivot
  sub $t1, $s1, $s0			# hi - lo
    mul $t2, $t0, 4			# pivot = start * 4
    add $t2, $t2, $s2			# add pivot to data
  # x = a[(first + last) / 2]
    lw $s3, ($t2)			# grab string at pivot
    
# for(;;)
partition:
  
i_loop:
    mul $t5, $s4, 4			# i1 = i * 4
    add $t5, $t5, $s2			# add i1 to data
    lw $t5, ($t5)			# array[i1]
    move $a0, $t5                       # str_compare(i1, pivot)
    move $a1, $s3
    jal str_compare
    # while (str_lt(a[i], x) ) i++
    beq $v0, 1, add_i			# if(array[i] <= pivot, break
    j j_loop
add_i:
      addi $s4, $s4, 1			# i++
    j i_loop

j_loop:
    mul $t6, $s5, 4			# j1 = j * 4
    add $t6, $t6, $s2			# add j1 to data
    lw $t6, ($t6)			# array[j1]
    move $a0, $s3			# str_compare(j, pivot)
    move $a1, $t6
    jal str_compare
    # while (str_lt(x, a[j]) ) j--
    beq $v0, 1, add_j			# if(pivot <= array[j], break)
    j post_j
add_j:
      addi $s5, $s5, -1			# j--
    j j_loop
post_j:
  # if(i >= j) break;
   bge $s4, $s5, nexter			# if(i >= j) break;
   move $a0, $s2
   move $a1, $s4
   move $a2, $s5
   # t = a[i]; a[i] = a[j]; a[j] = t;
   jal swap				# swap a[i] with a[j]
   addi $s4, $s4, 1			# i++
   addi $s5, $s5, -1			# i--
   j partition
   
nexter:
  sub $t7, $s4, 1                       # i - 1
  blt $s0, $t7, quicksort_l		# if (first < i-1) quick-sort-l
    j next				# skip
quicksort_l:				# quicksort(a, first, i - 1)
  move $a0, $s2
  move $a1, $s0
  move $a2, $t7
  jal quicksort
next:
  add $t8, $s5, 1			# j + 1
  blt $t8, $s1 quick_sort_r		# if (j+1 < last) quick-sort-r
    j quick_sort_end			# skip
quick_sort_r:				# quicksort(a, j+1, last)
  move $a0, $s2
  move $a1, $t8
  move $a2, $s1
  jal quicksort

quick_sort_end:  			# reset the original stack save values
  lw $s0, ($sp)
  lw $s1, 4($sp)
  lw $ra, 8($sp)
  lw $s2, 12($sp)
  lw $s3, 16($sp)
  lw $s4, 20($sp)
  lw $s5, 24($sp)
  addi $sp, $sp, 28
  jr $ra				# return out of the function! we made it!
 
