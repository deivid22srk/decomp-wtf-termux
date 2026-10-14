	.file	1 "/home/z/my-project/work/upstream/projects/demo-rom/src/main.c"

 # GNU C 2.7.2 [AL 1.1, MM 40] Sony Playstation compiled by GNU C

 # Cc1 defaults:
 # -mgas -msoft-float

 # Cc1 arguments (-G value = 8, Cpu = R3000, ISA = 1):
 # -quiet -O2 -o

gcc2_compiled.:
__gnu_compiled_c:
	.rdata
	.align	2
save_magic:
	.ascii	"DEMOQUEST-SAVE\000"
	.text
	.align	2
	.globl	save_game
	.align	2
	.globl	load_game
	.align	2
	.globl	main

	.comm	save_buffer,512

	.comm	packed_buffer,640

	.comm	debug_crc,4

	.comm	debug_status,4

	.extern	g_frame_count, 4
	.extern	g_player, 40
	.extern	g_score, 4

	.text
	.text
	.ent	save_game
save_game:
	.frame	$sp,40,$31		# vars= 8, regs= 3/0, args= 16, extra= 0
	.mask	0x80030000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,40
	li	$2,0x00000280		# 640
	move	$3,$0
	sw	$31,32($sp)
	sw	$17,28($sp)
	sw	$16,24($sp)
	sw	$2,16($sp)
$L5:
	lbu	$2,save_magic($3)
	#nop
	sb	$2,save_buffer($3)
	addu	$3,$3,1
	slt	$2,$3,14
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L5
	addu	$5,$sp,16
	.set	macro
	.set	reorder

	la	$16,packed_buffer
	move	$4,$16
	la	$7,save_buffer+16
	addu	$17,$7,-16
	lw	$2,g_score
	lw	$3,g_player+28
	move	$6,$17
	sw	$2,0($7)
	sw	$3,save_buffer+20
	.set	noreorder
	.set	nomacro
	jal	compress
	li	$7,0x00000200		# 512
	.set	macro
	.set	reorder

	move	$4,$0
	lw	$6,16($sp)
	move	$5,$16
	#.set	volatile
	sw	$2,debug_status
	#.set	novolatile
	jal	crc32
	li	$4,0x00000001		# 1
	move	$5,$17
	li	$6,0x00000200		# 512
	.set	noreorder
	.set	nomacro
	jal	adler32
	move	$16,$2
	.set	macro
	.set	reorder

	xor	$16,$16,$2
	#.set	volatile
	sw	$16,debug_crc
	#.set	novolatile
	lw	$31,32($sp)
	lw	$17,28($sp)
	lw	$16,24($sp)
	addu	$sp,$sp,40
	j	$31
	.end	save_game
	.text
	.ent	load_game
load_game:
	.frame	$sp,32,$31		# vars= 8, regs= 2/0, args= 16, extra= 0
	.mask	0x80010000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,32
	li	$2,0x00000200		# 512
	sw	$16,24($sp)
	la	$16,save_buffer
	move	$4,$16
	addu	$5,$sp,16
	la	$6,packed_buffer
	li	$7,0x00000280		# 640
	sw	$31,28($sp)
	.set	noreorder
	.set	nomacro
	jal	uncompress
	sw	$2,16($sp)
	.set	macro
	.set	reorder

	bne	$2,$0,$L8
	lw	$5,16($sp)
	lw	$2,save_buffer+16
	#nop
	sw	$2,g_score
	.set	noreorder
	.set	nomacro
	jal	checksum_save
	move	$4,$16
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	j	$L9
	sltu	$2,$0,$2
	.set	macro
	.set	reorder

$L8:
	move	$2,$0
$L9:
	lw	$31,28($sp)
	lw	$16,24($sp)
	addu	$sp,$sp,32
	j	$31
	.end	load_game
	.text
	.ent	main
main:
	.frame	$sp,24,$31		# vars= 0, regs= 2/0, args= 16, extra= 0
	.mask	0x80010000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,24
	sw	$31,20($sp)
	.set	noreorder
	.set	nomacro
	jal	__main
	sw	$16,16($sp)
	.set	macro
	.set	reorder

	li	$4,0x00000001		# 1
	li	$5,0x00000020		# 32
	.set	noreorder
	.set	nomacro
	jal	entity_spawn
	move	$6,$0
	.set	macro
	.set	reorder

	li	$4,0x00000002		# 2
	li	$5,0x00000060		# 96
	.set	noreorder
	.set	nomacro
	jal	entity_spawn
	li	$6,0x00000040		# 64
	.set	macro
	.set	reorder

	li	$4,0x00000005		# 5
	li	$5,0x000000a0		# 160
	.set	noreorder
	.set	nomacro
	jal	entity_spawn
	li	$6,0x00000190		# 400
	.set	macro
	.set	reorder

	li	$16,0x00000031		# 49
$L11:
	jal	game_tick
	lbu	$2,g_frame_count
	#nop
	bne	$2,$0,$L11
	jal	save_game
	jal	zlibVersion
	lbu	$2,0($2)
	#nop
	bne	$2,$16,$L11
	jal	load_game
	j	$L11
	lw	$31,20($sp)
	lw	$16,16($sp)
	addu	$sp,$sp,24
	j	$31
	.end	main
