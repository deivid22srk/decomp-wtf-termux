	.file	1 "upstream/projects/demo-rom/src/libc.c"
gcc2_compiled.:
__gnu_compiled_c:
	.text
	.align	2
	.globl	malloc
	.text
	.ent	malloc
malloc:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	addu	$4,$4,7
	li	$2,-8			# 0xfffffff8
	lw	$5,heap_used
	and	$4,$4,$2
	li	$2,262144			# 0x00040000
	addu	$3,$5,$4
	sltu	$2,$2,$3
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L2
	lui	$2,%hi(heap) # high
	.set	macro
	.set	reorder

	sw	$3,heap_used
	addiu	$2,$2,%lo(heap) # low
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$2,$5,$2
	.set	macro
	.set	reorder

$L2:
	.set	noreorder
	.set	nomacro
	j	$31
	move	$2,$0
	.set	macro
	.set	reorder

	.end	malloc
	.align	2
	.globl	memset
	.text
	.ent	memset
memset:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	move	$2,$4
	move	$7,$2
	.set	noreorder
	.set	nomacro
	beq	$6,$0,$L9
	addu	$3,$6,-1
	.set	macro
	.set	reorder

	li	$6,-1			# 0xffffffff
$L7:
	sb	$5,0($7)
	addu	$3,$3,-1
	.set	noreorder
	.set	nomacro
	bne	$3,$6,$L7
	addu	$7,$7,1
	.set	macro
	.set	reorder

$L9:
	j	$31
	.end	memset
	.align	2
	.globl	calloc
	.text
	.ent	calloc
calloc:
	.frame	$sp,32,$31		# vars= 0, regs= 3/0, args= 16, extra= 0
	.mask	0x80030000,-8
	.fmask	0x00000000,0
	mult	$4,$5
	subu	$sp,$sp,32
	sw	$31,24($sp)
	sw	$17,20($sp)
	sw	$16,16($sp)
	mflo	$17
	#nop
	.set	noreorder
	.set	nomacro
	jal	malloc
	move	$4,$17
	.set	macro
	.set	reorder

	move	$16,$2
	.set	noreorder
	.set	nomacro
	beq	$16,$0,$L11
	move	$4,$16
	.set	macro
	.set	reorder

	move	$5,$0
	.set	noreorder
	.set	nomacro
	jal	memset
	move	$6,$17
	.set	macro
	.set	reorder

$L11:
	move	$2,$16
	lw	$31,24($sp)
	lw	$17,20($sp)
	lw	$16,16($sp)
	#nop
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$sp,$sp,32
	.set	macro
	.set	reorder

	.end	calloc
	.align	2
	.globl	free
	.text
	.ent	free
free:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	j	$31
	.end	free
	.align	2
	.globl	memcpy
	.text
	.ent	memcpy
memcpy:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	move	$7,$4
	.set	noreorder
	.set	nomacro
	beq	$6,$0,$L15
	addu	$3,$6,-1
	.set	macro
	.set	reorder

	li	$6,-1			# 0xffffffff
$L16:
	lbu	$2,0($5)
	addu	$5,$5,1
	addu	$3,$3,-1
	sb	$2,0($7)
	.set	noreorder
	.set	nomacro
	bne	$3,$6,$L16
	addu	$7,$7,1
	.set	macro
	.set	reorder

$L15:
	.set	noreorder
	.set	nomacro
	j	$31
	move	$2,$4
	.set	macro
	.set	reorder

	.end	memcpy
	.align	2
	.globl	memcmp
	.text
	.ent	memcmp
memcmp:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	beq	$6,$0,$L20
$L22:
	lbu	$3,0($4)
	lbu	$2,0($5)
	#nop
	.set	noreorder
	.set	nomacro
	beq	$3,$2,$L21
	addu	$6,$6,-1
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	j	$31
	subu	$2,$3,$2
	.set	macro
	.set	reorder

$L21:
	addu	$4,$4,1
	.set	noreorder
	.set	nomacro
	bne	$6,$0,$L22
	addu	$5,$5,1
	.set	macro
	.set	reorder

$L20:
	.set	noreorder
	.set	nomacro
	j	$31
	move	$2,$0
	.set	macro
	.set	reorder

	.end	memcmp
	.align	2
	.globl	strlen
	.text
	.ent	strlen
strlen:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	lbu	$2,0($4)
	#nop
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L28
	move	$3,$4
	.set	macro
	.set	reorder

	addu	$3,$3,1
$L31:
	lbu	$2,0($3)
	#nop
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L31
	addu	$3,$3,1
	.set	macro
	.set	reorder

	addu	$3,$3,-1
$L28:
	.set	noreorder
	.set	nomacro
	j	$31
	subu	$2,$3,$4
	.set	macro
	.set	reorder

	.end	strlen
	.align	2
	.globl	strcpy
	.text
	.ent	strcpy
strcpy:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	lbu	$2,0($5)
	addu	$5,$5,1
	sb	$2,0($4)
	andi	$2,$2,0x00ff
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L34
	addu	$3,$4,1
	.set	macro
	.set	reorder

$L33:
	lbu	$2,0($5)
	addu	$5,$5,1
	sb	$2,0($3)
	andi	$2,$2,0x00ff
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L33
	addu	$3,$3,1
	.set	macro
	.set	reorder

$L34:
	.set	noreorder
	.set	nomacro
	j	$31
	move	$2,$4
	.set	macro
	.set	reorder

	.end	strcpy
	.align	2
	.globl	exit
	.text
	.ent	exit
exit:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
$L40:
	j	$L40
	.end	exit

	.lcomm	heap,262144

	.lcomm	heap_used,4

	.comm	errno,4
