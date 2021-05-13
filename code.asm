.data
reservedspace: .space 1024
stringspace: .space 1024
_newline: .asciiz "\n"

.text
main:
	
	# 1 :  =  func f begin: 

f:
	sub $sp, $sp, 72
	sw $ra, 0($sp)
	sw $fp, 4($sp)
	la $fp, 72($sp)
	sw $t0, 12($sp)
	sw $t1, 16($sp)
	sw $t2, 20($sp)
	sw $t3, 24($sp)
	sw $t4, 28($sp)
	sw $t5, 32($sp)
	sw $t6, 36($sp)
	sw $t7, 40($sp)
	sw $t8, 44($sp)
	sw $t9, 48($sp)
	sw $s0, 52($sp)
	sw $s1, 56($sp)
	sw $s2, 60($sp)
	sw $s3, 64($sp)
	sw $s4, 68($sp)
	li $v0, 4
	sub $sp, $sp, $v0
	li $s6, 76
	sub $s7, $fp, $s6
	sw $a0, 0($s7)
	li $s6, 80
	sub $s7, $fp, $s6
	sw $a1, 0($s7)
	li $s6, 84
	sub $s7, $fp, $s6
	sw $a2, 0($s7)
	li $s6, 88
	sub $s7, $fp, $s6
	sw $a3, 0($s7)
	# 2 :  =  param 
	addi $a0,$0, 
	# 3 : __t1__ =  refParam 
	# 4 : __t1__ = printf CALL 2
	mov $f12, $a0
	li $v0, 2
	syscall

