	.file	1 "upstream/projects/demo-rom/src/main.c"
gcc2_compiled.:
__gnu_compiled_c:
	.rdata
	.align	2
save_magic:
	.ascii	"DEMOQUEST-SAVE\000"
	.text
	.align	2
	.globl	save_game
	.text
	.ent	save_game
save_game:
	.frame	$sp,40,$31		# vars= 8, regs= 3/0, args= 16, extra= 0
	.mask	0x80030000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,40
	li	$2,640			# 0x00000280
	move	$4,$0
	sw	$2,16($sp)
	lui	$2,%hi(save_buffer) # high
	addiu	$6,$2,%lo(save_buffer) # low
	lui	$2,%hi(save_magic) # high
	addiu	$5,$2,%lo(save_magic) # low
	sw	$31,32($sp)
	sw	$17,28($sp)
	sw	$16,24($sp)
	addu	$3,$4,$6
$L7:
	addu	$2,$4,$5
	lbu	$2,0($2)
	addu	$4,$4,1
	sb	$2,0($3)
	slt	$2,$4,14
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L7
	addu	$3,$4,$6
	.set	macro
	.set	reorder

	lui	$16,%hi(packed_buffer) # high
	addiu	$16,$16,%lo(packed_buffer) # low
	move	$4,$16
	addu	$5,$sp,16
	lui	$7,%hi(save_buffer+16) # high
	addiu	$8,$7,%lo(save_buffer+16) # low
	lui	$2,%hi(g_player+28) # high
	addu	$17,$8,-16
	lw	$3,g_score
	lw	$2,%lo(g_player+28)($2)
	move	$6,$17
	sw	$3,%lo(save_buffer+16)($7)
	li	$7,512			# 0x00000200
	.set	noreorder
	.set	nomacro
	jal	compress
	sw	$2,4($8)
	.set	macro
	.set	reorder

	move	$4,$0
	lw	$6,16($sp)
	move	$5,$16
	#.set	volatile
	sw	$2,debug_status
	#.set	novolatile
	jal	crc32
	li	$4,1			# 0x00000001
	move	$5,$17
	li	$6,512			# 0x00000200
	.set	noreorder
	.set	nomacro
	jal	adler32
	move	$16,$2
	.set	macro
	.set	reorder

	lw	$31,32($sp)
	lw	$17,28($sp)
	xor	$16,$16,$2
	#.set	volatile
	sw	$16,debug_crc
	#.set	novolatile
	lw	$16,24($sp)
	#nop
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$sp,$sp,40
	.set	macro
	.set	reorder

	.end	save_game
	.align	2
	.globl	load_game
	.text
	.ent	load_game
load_game:
	.frame	$sp,32,$31		# vars= 8, regs= 2/0, args= 16, extra= 0
	.mask	0x80010000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,32
	li	$2,512			# 0x00000200
	sw	$2,16($sp)
	lui	$2,%hi(save_buffer) # high
	sw	$16,24($sp)
	addiu	$16,$2,%lo(save_buffer) # low
	move	$4,$16
	addu	$5,$sp,16
	lui	$6,%hi(packed_buffer) # high
	addiu	$6,$6,%lo(packed_buffer) # low
	sw	$31,28($sp)
	.set	noreorder
	.set	nomacro
	jal	uncompress
	li	$7,640			# 0x00000280
	.set	macro
	.set	reorder

	bne	$2,$0,$L9
	lw	$5,16($sp)
	lw	$2,16($16)
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
	j	$L10
	sltu	$2,$0,$2
	.set	macro
	.set	reorder

$L9:
	move	$2,$0
$L10:
	lw	$31,28($sp)
	lw	$16,24($sp)
	#nop
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$sp,$sp,32
	.set	macro
	.set	reorder

	.end	load_game
	.align	2
	.globl	main
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

	li	$4,1			# 0x00000001
	li	$5,32			# 0x00000020
	.set	noreorder
	.set	nomacro
	jal	entity_spawn
	move	$6,$0
	.set	macro
	.set	reorder

	li	$4,2			# 0x00000002
	li	$5,96			# 0x00000060
	.set	noreorder
	.set	nomacro
	jal	entity_spawn
	li	$6,64			# 0x00000040
	.set	macro
	.set	reorder

	li	$4,5			# 0x00000005
	li	$5,160			# 0x000000a0
	.set	noreorder
	.set	nomacro
	jal	entity_spawn
	li	$6,400			# 0x00000190
	.set	macro
	.set	reorder

	li	$16,49			# 0x00000031
$L12:
	jal	game_tick
	lbu	$2,g_frame_count
	#nop
	bne	$2,$0,$L12
	jal	save_game
	jal	zlibVersion
	lbu	$2,0($2)
	#nop
	bne	$2,$16,$L12
	jal	load_game
	j	$L12
	.end	main

	.comm	save_buffer,512

	.comm	packed_buffer,640

	.comm	debug_crc,4

	.comm	debug_status,4

	.extern	g_frame_count, 4
	.extern	g_player, 40
	.extern	g_score, 4
