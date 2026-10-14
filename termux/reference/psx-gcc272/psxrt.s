	.file	1 "/home/z/my-project/work/upstream/projects/demo-psx/psxrt.c"

 # GNU C 2.7.2 [AL 1.1, MM 40] Sony Playstation compiled by GNU C

 # Cc1 defaults:
 # -mgas -msoft-float

 # Cc1 arguments (-G value = 8, Cpu = R3000, ISA = 1):
 # -quiet -O2 -o

gcc2_compiled.:
__gnu_compiled_c:
	.text
	.align	2
	.globl	__main
	.align	2
	.globl	__addsf3
	.align	2
	.globl	__subsf3
	.align	2
	.globl	__mulsf3

	.text
	.text
	.ent	__main
__main:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	j	$31
	.end	__main
	.text
	.ent	__addsf3
__addsf3:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$2,$4,$5
	.set	macro
	.set	reorder

	.end	__addsf3
	.text
	.ent	__subsf3
__subsf3:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	j	$31
	subu	$2,$4,$5
	.set	macro
	.set	reorder

	.end	__subsf3
	.text
	.ent	__mulsf3
__mulsf3:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	sra	$4,$4,1
	sra	$2,$5,1
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$2,$4,$2
	.set	macro
	.set	reorder

	.end	__mulsf3
