	.file	1 "/home/z/my-project/work/upstream/projects/demo-n64/original/game.c"

 # GNU C 2.7.2 [AL 1.1, MM 40] Sony Playstation compiled by GNU C

 # Cc1 defaults:
 # -mgas -msoft-float

 # Cc1 arguments (-G value = 8, Cpu = R3000, ISA = 1):
 # -quiet -O2 -o

gcc2_compiled.:
__gnu_compiled_c:
	.text
	.align	2
	.globl	clamp_s32
	.align	2
	.globl	abs_s32
	.align	2
	.globl	player_take_damage
	.align	2
	.globl	rng_next
	.align	2
	.globl	count_alive_entities
	.align	2
	.globl	entity_update_physics
	.align	2
	.globl	entity_default_hp
	.align	2
	.globl	entity_spawn
	.align	2
	.globl	add_score
	.align	2
	.globl	lerp
	.align	2
	.globl	checksum_save
	.align	2
	.globl	entity_collides
	.align	2
	.globl	game_tick

	.comm	g_player,40

	.comm	g_entities,896

	.comm	g_score,4

	.comm	g_frame_count,4

	.comm	g_rng_state,4

	.text
	.text
	.ent	clamp_s32
clamp_s32:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	slt	$2,$4,$5
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L4
	move	$2,$5
	.set	macro
	.set	reorder

	move	$2,$6
	slt	$3,$2,$4
	bne	$3,$0,$L4
	move	$2,$4
$L4:
	j	$31
	.end	clamp_s32
	.text
	.ent	abs_s32
abs_s32:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	move	$2,$4
	bgez	$2,$L6
	subu	$2,$0,$2
$L6:
	j	$31
	.end	abs_s32
	.text
	.ent	player_take_damage
player_take_damage:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	la	$3,g_player+32
	lh	$2,0($3)
	#nop
	bgtz	$2,$L7
	lw	$2,g_player+28
	#nop
	subu	$2,$2,$4
	sw	$2,g_player+28
	.set	noreorder
	.set	nomacro
	bgtz	$2,$L10
	li	$2,0x0000003c		# 60
	.set	macro
	.set	reorder

	li	$2,0x00000003		# 3
	sw	$0,g_player+28
	sh	$2,g_player+34
	li	$2,0x0000003c		# 60
$L10:
	sh	$2,0($3)
$L7:
	j	$31
	.end	player_take_damage
	.text
	.ent	rng_next
rng_next:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	li	$3,0x41c60000		# 1103495168
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
	.text
	.ent	count_alive_entities
count_alive_entities:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	move	$5,$0
	move	$4,$0
	move	$3,$0
$L16:
	lhu	$2,g_entities+2($3)
	#nop
	andi	$2,$2,0x0001
	beq	$2,$0,$L15
	addu	$5,$5,1
$L15:
	addu	$4,$4,1
	slt	$2,$4,32
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L16
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
	bne	$2,$0,$L20
	li	$2,0x00000018		# 24
	.set	macro
	.set	reorder

	sw	$2,16($6)
$L20:
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
	bne	$2,$0,$L21
	sw	$3,4($6)
	.set	macro
	.set	reorder

	lhu	$3,2($6)
	li	$2,0x000001c0		# 448
	sw	$2,8($6)
	sw	$0,16($6)
	ori	$3,$3,0x0002
	sh	$3,2($6)
$L21:
	j	$31
	.end	entity_update_physics
	.text
	.ent	entity_default_hp
entity_default_hp:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	addu	$4,$4,-1
	sll	$4,$4,16
	sra	$4,$4,16
	sltu	$2,$4,5
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L29
	sll	$2,$4,2
	.set	macro
	.set	reorder

	lw	$2,$L30($2)
	#nop
	j	$2
	.rdata
	.align	3
$L30:
	.word	$L24
	.word	$L25
	.word	$L26
	.word	$L27
	.word	$L28
	.text
$L24:
	.set	noreorder
	.set	nomacro
	j	$L31
	li	$2,0x00000003		# 3
	.set	macro
	.set	reorder

$L25:
	.set	noreorder
	.set	nomacro
	j	$L31
	li	$2,0x00000002		# 2
	.set	macro
	.set	reorder

$L26:
	.set	noreorder
	.set	nomacro
	j	$L31
	li	$2,0x0000000a		# 10
	.set	macro
	.set	reorder

$L27:
	.set	noreorder
	.set	nomacro
	j	$L31
	li	$2,0x00000032		# 50
	.set	macro
	.set	reorder

$L28:
	.set	noreorder
	.set	nomacro
	j	$L31
	li	$2,0x00000001		# 1
	.set	macro
	.set	reorder

$L29:
	move	$2,$0
$L31:
	j	$31
	.end	entity_default_hp
	.text
	.ent	entity_spawn
entity_spawn:
	.frame	$sp,24,$31		# vars= 0, regs= 2/0, args= 16, extra= 0
	.mask	0x80010000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,24
	move	$3,$0
	sw	$16,16($sp)
	la	$16,g_entities
	sw	$31,20($sp)
$L36:
	lhu	$2,2($16)
	#nop
	andi	$2,$2,0x0001
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L35
	addu	$3,$3,1
	.set	macro
	.set	reorder

	li	$2,0x00000001		# 1
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
	j	$L39
	move	$2,$16
	.set	macro
	.set	reorder

$L35:
	slt	$2,$3,32
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L36
	addu	$16,$16,28
	.set	macro
	.set	reorder

	move	$2,$0
$L39:
	lw	$31,20($sp)
	lw	$16,16($sp)
	addu	$sp,$sp,24
	j	$31
	.end	entity_spawn
	.text
	.ent	add_score
add_score:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	lw	$2,g_player+36
	#nop
	addu	$2,$2,1
	mult	$4,$2
	li	$3,0x000f0000		# 983040
	ori	$3,$3,0x423f
	lw	$2,g_score
	mflo	$5
	#nop
	#nop
	addu	$2,$2,$5
	sw	$2,g_score
	slt	$2,$3,$2
	beq	$2,$0,$L41
	sw	$3,g_score
$L41:
	j	$31
	.end	add_score
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
	addu	$sp,$sp,32
	j	$31
	.end	lerp
	.text
	.ent	checksum_save
checksum_save:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	blez	$5,$L45
	li	$6,0x00001234		# 4660
	.set	macro
	.set	reorder

	addu	$5,$5,$4
$L47:
	lbu	$2,0($4)
	addu	$4,$4,1
	sll	$3,$6,5
	addu	$3,$3,$6
	addu	$6,$3,$2
	slt	$2,$4,$5
	bne	$2,$0,$L47
$L45:
	.set	noreorder
	.set	nomacro
	j	$31
	move	$2,$6
	.set	macro
	.set	reorder

	.end	checksum_save
	.text
	.ent	entity_collides
entity_collides:
	.frame	$sp,32,$31		# vars= 0, regs= 4/0, args= 16, extra= 0
	.mask	0x80070000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,32
	sw	$16,16($sp)
	move	$16,$4
	sw	$17,20($sp)
	move	$17,$5
	lw	$2,4($16)
	lw	$4,4($17)
	sw	$31,28($sp)
	sw	$18,24($sp)
	.set	noreorder
	.set	nomacro
	jal	abs_s32
	subu	$4,$2,$4
	.set	macro
	.set	reorder

	lh	$3,20($16)
	lh	$4,20($17)
	#nop
	addu	$3,$3,$4
	srl	$4,$3,31
	addu	$3,$3,$4
	sra	$3,$3,1
	slt	$2,$2,$3
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L50
	move	$18,$0
	.set	macro
	.set	reorder

	lw	$2,8($16)
	lw	$4,8($17)
	.set	noreorder
	.set	nomacro
	jal	abs_s32
	subu	$4,$2,$4
	.set	macro
	.set	reorder

	lh	$3,22($16)
	lh	$4,22($17)
	#nop
	addu	$3,$3,$4
	srl	$4,$3,31
	addu	$3,$3,$4
	sra	$3,$3,1
	slt	$18,$2,$3
$L50:
	move	$2,$18
	lw	$31,28($sp)
	lw	$18,24($sp)
	lw	$17,20($sp)
	lw	$16,16($sp)
	addu	$sp,$sp,32
	j	$31
	.end	entity_collides
	.text
	.ent	game_tick
game_tick:
	.frame	$sp,40,$31		# vars= 8, regs= 4/0, args= 16, extra= 0
	.mask	0x80070000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,40
	lw	$2,g_frame_count
	la	$4,g_player+32
	sw	$31,36($sp)
	sw	$18,32($sp)
	sw	$17,28($sp)
	sw	$16,24($sp)
	lh	$3,0($4)
	addu	$2,$2,1
	sw	$2,g_frame_count
	.set	noreorder
	.set	nomacro
	blez	$3,$L52
	move	$2,$3
	.set	macro
	.set	reorder

	addu	$2,$2,-1
	sh	$2,0($4)
$L52:
	move	$18,$0
	move	$17,$0
$L56:
	la	$2,g_entities
	addu	$16,$17,$2
	lhu	$2,2($16)
	#nop
	andi	$2,$2,0x0001
	beq	$2,$0,$L55
	.set	noreorder
	.set	nomacro
	jal	entity_update_physics
	move	$4,$16
	.set	macro
	.set	reorder

	la	$5,g_player
	.set	noreorder
	.set	nomacro
	jal	entity_collides
	move	$4,$16
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L55
	li	$2,0x00000005		# 5
	.set	macro
	.set	reorder

	lh	$3,0($16)
	#nop
	bne	$3,$2,$L59
	.set	noreorder
	.set	nomacro
	jal	add_score
	li	$4,0x0000000a		# 10
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	j	$L55
	sh	$0,2($16)
	.set	macro
	.set	reorder

$L59:
	.set	noreorder
	.set	nomacro
	jal	player_take_damage
	li	$4,0x00000001		# 1
	.set	macro
	.set	reorder

$L55:
	addu	$18,$18,1
	slt	$2,$18,32
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L56
	addu	$17,$17,28
	.set	macro
	.set	reorder

	lw	$31,36($sp)
	lw	$18,32($sp)
	lw	$17,28($sp)
	lw	$16,24($sp)
	addu	$sp,$sp,40
	j	$31
	.end	game_tick
