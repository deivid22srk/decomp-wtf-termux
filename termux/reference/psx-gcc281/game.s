	.file	1 "upstream/projects/demo-n64/original/game.c"
gcc2_compiled.:
__gnu_compiled_c:
	.text
	.align	2
	.globl	clamp_s32
	.text
	.ent	clamp_s32
clamp_s32:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	slt	$2,$4,$5
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L5
	move	$2,$5
	.set	macro
	.set	reorder

	move	$2,$6
	slt	$3,$2,$4
	bne	$3,$0,$L5
	.set	noreorder
	.set	nomacro
	j	$31
	move	$2,$4
	.set	macro
	.set	reorder

$L5:
	j	$31
	.end	clamp_s32
	.align	2
	.globl	abs_s32
	.text
	.ent	abs_s32
abs_s32:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	move	$2,$4
	bgez	$2,$L8
	subu	$2,$0,$2
$L8:
	j	$31
	.end	abs_s32
	.align	2
	.globl	player_take_damage
	.text
	.ent	player_take_damage
player_take_damage:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	lui	$2,%hi(g_player) # high
	addiu	$3,$2,%lo(g_player) # low
	lh	$2,32($3)
	#nop
	bgtz	$2,$L12
	lw	$2,28($3)
	#nop
	subu	$2,$2,$4
	.set	noreorder
	.set	nomacro
	bgtz	$2,$L11
	sw	$2,28($3)
	.set	macro
	.set	reorder

	li	$2,3			# 0x00000003
	sw	$0,28($3)
	sh	$2,34($3)
$L11:
	li	$2,60			# 0x0000003c
	sh	$2,32($3)
$L12:
	j	$31
	.end	player_take_damage
	.align	2
	.globl	rng_next
	.text
	.ent	rng_next
rng_next:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	li	$3,1103495168			# 0x41c60000
	lw	$2,g_rng_state
	ori	$3,$3,0x4e6d
	mult	$2,$3
	mflo	$4
	#nop
	#nop
	addu	$2,$4,12345
	sw	$2,g_rng_state
	srl	$2,$2,16
	.set	noreorder
	.set	nomacro
	j	$31
	andi	$2,$2,0x7fff
	.set	macro
	.set	reorder

	.end	rng_next
	.align	2
	.globl	count_alive_entities
	.text
	.ent	count_alive_entities
count_alive_entities:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	move	$5,$0
	move	$4,$5
	lui	$2,%hi(g_entities) # high
	addiu	$3,$2,%lo(g_entities) # low
$L18:
	lhu	$2,2($3)
	#nop
	andi	$2,$2,0x0001
	beq	$2,$0,$L17
	addu	$5,$5,1
$L17:
	addu	$4,$4,1
	slt	$2,$4,32
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L18
	addu	$3,$3,28
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	j	$31
	move	$2,$5
	.set	macro
	.set	reorder

	.end	count_alive_entities
	.align	2
	.globl	entity_update_physics
	.text
	.ent	entity_update_physics
entity_update_physics:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	move	$6,$4
	lw	$2,16($6)
	#nop
	addu	$2,$2,2
	sw	$2,16($6)
	slt	$2,$2,25
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L22
	li	$2,24			# 0x00000018
	.set	macro
	.set	reorder

	sw	$2,16($6)
$L22:
	lw	$3,4($6)
	lw	$4,12($6)
	lw	$2,8($6)
	lw	$5,16($6)
	addu	$3,$3,$4
	addu	$2,$2,$5
	sw	$2,8($6)
	slt	$2,$2,449
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L24
	sw	$3,4($6)
	.set	macro
	.set	reorder

	lhu	$3,2($6)
	li	$2,448			# 0x000001c0
	sw	$2,8($6)
	sw	$0,16($6)
	ori	$3,$3,0x0002
	sh	$3,2($6)
$L24:
	j	$31
	.end	entity_update_physics
	.align	2
	.globl	entity_default_hp
	.text
	.ent	entity_default_hp
entity_default_hp:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	addu	$4,$4,-1
	sll	$4,$4,16
	sra	$3,$4,16
	sltu	$2,$3,5
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L32
	lui	$2,%hi($L33) # high
	.set	macro
	.set	reorder

	addiu	$2,$2,%lo($L33) # low
	sll	$3,$3,2
	addu	$3,$3,$2
	lw	$2,0($3)
	#nop
	j	$2
	.rdata
	.align	3
$L33:
	.word	$L27
	.word	$L28
	.word	$L29
	.word	$L30
	.word	$L31
	.text
$L27:
	.set	noreorder
	.set	nomacro
	j	$31
	li	$2,3			# 0x00000003
	.set	macro
	.set	reorder

$L28:
	.set	noreorder
	.set	nomacro
	j	$31
	li	$2,2			# 0x00000002
	.set	macro
	.set	reorder

$L29:
	.set	noreorder
	.set	nomacro
	j	$31
	li	$2,10			# 0x0000000a
	.set	macro
	.set	reorder

$L30:
	.set	noreorder
	.set	nomacro
	j	$31
	li	$2,50			# 0x00000032
	.set	macro
	.set	reorder

$L31:
	.set	noreorder
	.set	nomacro
	j	$31
	li	$2,1			# 0x00000001
	.set	macro
	.set	reorder

$L32:
	.set	noreorder
	.set	nomacro
	j	$31
	move	$2,$0
	.set	macro
	.set	reorder

	.end	entity_default_hp
	.align	2
	.globl	entity_spawn
	.text
	.ent	entity_spawn
entity_spawn:
	.frame	$sp,24,$31		# vars= 0, regs= 2/0, args= 16, extra= 0
	.mask	0x80010000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,24
	move	$3,$0
	lui	$2,%hi(g_entities) # high
	sw	$16,16($sp)
	addiu	$16,$2,%lo(g_entities) # low
	sw	$31,20($sp)
$L39:
	lhu	$2,2($16)
	#nop
	andi	$2,$2,0x0001
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L38
	addu	$3,$3,1
	.set	macro
	.set	reorder

	li	$2,1			# 0x00000001
	sh	$4,0($16)
	sll	$4,$4,16
	sra	$4,$4,16
	sw	$5,4($16)
	sw	$6,8($16)
	sw	$0,12($16)
	sw	$0,16($16)
	.set	noreorder
	.set	nomacro
	jal	entity_default_hp
	sh	$2,2($16)
	.set	macro
	.set	reorder

	sw	$2,24($16)
	.set	noreorder
	.set	nomacro
	j	$L42
	move	$2,$16
	.set	macro
	.set	reorder

$L38:
	slt	$2,$3,32
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L39
	addu	$16,$16,28
	.set	macro
	.set	reorder

	move	$2,$0
$L42:
	lw	$31,20($sp)
	lw	$16,16($sp)
	#nop
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$sp,$sp,24
	.set	macro
	.set	reorder

	.end	entity_spawn
	.align	2
	.globl	add_score
	.text
	.ent	add_score
add_score:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	lui	$2,%hi(g_player+36) # high
	lw	$2,%lo(g_player+36)($2)
	#nop
	addu	$2,$2,1
	mult	$4,$2
	li	$3,983040			# 0x000f0000
	ori	$3,$3,0x423f
	lw	$2,g_score
	mflo	$5
	#nop
	#nop
	addu	$2,$2,$5
	sw	$2,g_score
	slt	$2,$3,$2
	beq	$2,$0,$L45
	sw	$3,g_score
$L45:
	j	$31
	.end	add_score
	.align	2
	.globl	lerp
	.text
	.ent	lerp
lerp:
	.frame	$sp,32,$31		# vars= 0, regs= 3/0, args= 16, extra= 0
	.mask	0x80030000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,32
	sw	$17,20($sp)
	move	$17,$4
	move	$4,$5
	sw	$16,16($sp)
	move	$16,$6
	sw	$31,24($sp)
	.set	noreorder
	.set	nomacro
	jal	__subsf3
	move	$5,$17
	.set	macro
	.set	reorder

	move	$4,$2
	.set	noreorder
	.set	nomacro
	jal	__mulsf3
	move	$5,$16
	.set	macro
	.set	reorder

	move	$4,$17
	.set	noreorder
	.set	nomacro
	jal	__addsf3
	move	$5,$2
	.set	macro
	.set	reorder

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

	.end	lerp
	.align	2
	.globl	checksum_save
	.text
	.ent	checksum_save
checksum_save:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	li	$7,4660			# 0x00001234
	.set	noreorder
	.set	nomacro
	blez	$5,$L49
	move	$6,$0
	.set	macro
	.set	reorder

	addu	$3,$4,$6
$L53:
	addu	$6,$6,1
	sll	$2,$7,5
	lbu	$3,0($3)
	addu	$2,$2,$7
	addu	$7,$2,$3
	slt	$2,$6,$5
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L53
	addu	$3,$4,$6
	.set	macro
	.set	reorder

$L49:
	.set	noreorder
	.set	nomacro
	j	$31
	move	$2,$7
	.set	macro
	.set	reorder

	.end	checksum_save
	.align	2
	.globl	entity_collides
	.text
	.ent	entity_collides
entity_collides:
	.frame	$sp,32,$31		# vars= 0, regs= 4/0, args= 16, extra= 0
	.mask	0x80070000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,32
	sw	$17,20($sp)
	move	$17,$4
	sw	$18,24($sp)
	move	$18,$5
	sw	$31,28($sp)
	sw	$16,16($sp)
	lw	$2,4($17)
	lw	$4,4($18)
	.set	noreorder
	.set	nomacro
	jal	abs_s32
	subu	$4,$2,$4
	.set	macro
	.set	reorder

	lh	$3,20($17)
	lh	$4,20($18)
	#nop
	addu	$3,$3,$4
	srl	$4,$3,31
	addu	$3,$3,$4
	sra	$3,$3,1
	slt	$2,$2,$3
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L55
	move	$16,$0
	.set	macro
	.set	reorder

	lw	$2,8($17)
	lw	$4,8($18)
	.set	noreorder
	.set	nomacro
	jal	abs_s32
	subu	$4,$2,$4
	.set	macro
	.set	reorder

	lh	$3,22($17)
	lh	$4,22($18)
	#nop
	addu	$3,$3,$4
	srl	$4,$3,31
	addu	$3,$3,$4
	sra	$3,$3,1
	slt	$16,$2,$3
$L55:
	move	$2,$16
	lw	$31,28($sp)
	lw	$18,24($sp)
	lw	$17,20($sp)
	lw	$16,16($sp)
	#nop
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$sp,$sp,32
	.set	macro
	.set	reorder

	.end	entity_collides
	.align	2
	.globl	game_tick
	.text
	.ent	game_tick
game_tick:
	.frame	$sp,32,$31		# vars= 0, regs= 3/0, args= 16, extra= 0
	.mask	0x80030000,-8
	.fmask	0x00000000,0
	lw	$2,g_frame_count
	subu	$sp,$sp,32
	sw	$31,24($sp)
	sw	$17,20($sp)
	sw	$16,16($sp)
	addu	$2,$2,1
	sw	$2,g_frame_count
	lui	$2,%hi(g_player) # high
	addiu	$4,$2,%lo(g_player) # low
	lh	$2,32($4)
	lhu	$3,32($4)
	.set	noreorder
	.set	nomacro
	blez	$2,$L57
	addu	$2,$3,-1
	.set	macro
	.set	reorder

	sh	$2,32($4)
$L57:
	move	$17,$0
	lui	$2,%hi(g_entities) # high
	addiu	$16,$2,%lo(g_entities) # low
$L61:
	lhu	$2,2($16)
	#nop
	andi	$2,$2,0x0001
	beq	$2,$0,$L60
	.set	noreorder
	.set	nomacro
	jal	entity_update_physics
	move	$4,$16
	.set	macro
	.set	reorder

	move	$4,$16
	lui	$5,%hi(g_player) # high
	.set	noreorder
	.set	nomacro
	jal	entity_collides
	addiu	$5,$5,%lo(g_player) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L60
	li	$2,5			# 0x00000005
	.set	macro
	.set	reorder

	lh	$3,0($16)
	#nop
	bne	$3,$2,$L64
	.set	noreorder
	.set	nomacro
	jal	add_score
	li	$4,10			# 0x0000000a
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	j	$L60
	sh	$0,2($16)
	.set	macro
	.set	reorder

$L64:
	.set	noreorder
	.set	nomacro
	jal	player_take_damage
	li	$4,1			# 0x00000001
	.set	macro
	.set	reorder

$L60:
	addu	$17,$17,1
	slt	$2,$17,32
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L61
	addu	$16,$16,28
	.set	macro
	.set	reorder

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

	.end	game_tick

	.comm	g_player,40

	.comm	g_entities,896

	.comm	g_score,4

	.comm	g_frame_count,4

	.comm	g_rng_state,4
