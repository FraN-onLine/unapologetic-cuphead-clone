extends Node2D

const MAX_HP = 1000
const PHASE_1_THRESHOLD = 701
const PHASE_2_THRESHOLD = 301

var hp = MAX_HP

enum BossPhase {
	PHASE_1,
	PHASE_2,
	PHASE_3
}

var current_phase = BossPhase.PHASE_1

var is_attacking = false
var current_attack = -1
var take_no_damage = false

var last_attack = -1
var same_attack_count = 0

@onready var attack_cooldown_timer = $AttackCooldownTimer


func _ready():
	take_no_damage = true
	$SBSprite.play("enter_phase1")
	await $SBSprite.animation_finished
	take_no_damage = false
	$SBSprite.play("idle_phase1")
	await get_tree().create_timer(0.5).timeout
	update_phase()

	start_attack_cycle()


func take_damage(amount: int):

	if take_no_damage:
		return

	$SBSprite.modulate = Color(1, 1, 1, 0.8)
	$SFSprite.modulate = Color(1, 1, 1, 0.8)

	await get_tree().create_timer(0.1).timeout

	$SBSprite.modulate = Color(1, 1, 1, 1)
	$SFSprite.modulate = Color(1, 1, 1, 1)

	hp -= amount

	hp = clamp(hp, 0, MAX_HP)

	print("Boss HP: ", hp)

	update_phase()

	if hp <= 0:
		die()


func update_phase():

	var previous_phase = current_phase

	if hp >= PHASE_1_THRESHOLD:
		current_phase = BossPhase.PHASE_1

	elif hp >= PHASE_2_THRESHOLD:
		current_phase = BossPhase.PHASE_2

	else:
		current_phase = BossPhase.PHASE_3

	if previous_phase != current_phase:
		on_phase_changed()


func on_phase_changed():

	match current_phase:

		BossPhase.PHASE_1:
			print("Entered Phase 1")

		BossPhase.PHASE_2:
			print("Entered Phase 2")

			take_no_damage = true
			$Hitbox1.monitoring = false
			$SBSprite.play("exit_phase1")

			await $SBSprite.animation_finished

			attack_cooldown_timer.wait_time = 2.2

	
			$Hitbox2.monitoring = true

			$SBSprite.visible = false
			$SFSprite.visible = true

			$SFSprite.play("enter_phase2")

			await $SFSprite.animation_finished

			take_no_damage = false

			$SFSprite.play("idle_phase2")

		BossPhase.PHASE_3:
			print("Entered Phase 3")

			take_no_damage = true

			$SFSprite.play("exit_phase2")

			await $SBSprite.animation_finished

			attack_cooldown_timer.wait_time = 2.2

			$Hitbox1.monitoring = false
			$Hitbox2.monitoring = true

			$SBSprite.visible = false
			$SFSprite.visible = true

			$SFSprite.play("enter_phase2")

			await $SFSprite.animation_finished

			take_no_damage = false

			$SFSprite.play("idle_phase2")

func start_attack_cycle():

	if hp <= 0:
		return

	if is_attacking:
		return

	is_attacking = true

	select_attack()


func select_attack():

	if take_no_damage:
		is_attacking = false
		attack_cooldown_timer.start()
		return

	match current_phase:

		BossPhase.PHASE_1:
			phase_1_attack_selection()

		BossPhase.PHASE_2:
			phase_2_attack_selection()

		BossPhase.PHASE_3:
			phase_3_attack_selection()


func phase_1_attack_selection():

	var attacks = [
		attack_phase1_a,
		attack_phase1_b,
	]

	var attack_index = randi() % attacks.size()

	while attack_index == last_attack and same_attack_count >= 2:
		attack_index = randi() % attacks.size()

	current_attack = attack_index

	if current_attack == last_attack:
		same_attack_count += 1
	else:
		same_attack_count = 1

	last_attack = current_attack

	attacks[current_attack].call()


func phase_2_attack_selection():

	var attacks = [
		attack_phase2_a,
		attack_phase2_b,
	]

	var attack_index = randi() % attacks.size()

	while attack_index == last_attack and same_attack_count >= 2:
		attack_index = randi() % attacks.size()

	current_attack = attack_index

	if current_attack == last_attack:
		same_attack_count += 1
	else:
		same_attack_count = 1

	last_attack = current_attack

	attacks[current_attack].call()


func phase_3_attack_selection():

	var attacks = [
		attack_phase3_a,
		attack_phase3_b
	]

	var attack_index = randi() % attacks.size()

	while attack_index == last_attack and same_attack_count >= 2:
		attack_index = randi() % attacks.size()

	current_attack = attack_index

	if current_attack == last_attack:
		same_attack_count += 1
	else:
		same_attack_count = 1

	last_attack = current_attack

	attacks[current_attack].call()


func attack_phase1_a():

	$SBSprite.play("stomp_phase1")

	await wait_for_frame($SBSprite, 6)

	$StompArea.monitoring = true

	await wait_for_frame($SBSprite, 8)

	$StompArea.monitoring = false

	await $SBSprite.animation_finished

	$SBSprite.play("idle_phase1")

	attack_finished()


func attack_phase1_b():

	$SBSprite.play("mop_phase1")

	await $SBSprite.animation_finished

	get_parent().drop_mop()

	$SBSprite.play("idle_phase1")

	attack_finished()


func attack_phase2_a():

	$SFSprite.play("cry_phase2")

	get_parent().drop_tears()

	await $SFSprite.animation_finished

	$SFSprite.play("idle_phase2")

	attack_finished()


func attack_phase2_b():

	$SFSprite.play("ring_phase2")

	await $SFSprite.animation_finished

	get_parent().spawn_ring()

	$SFSprite.play("idle_phase2")

	attack_finished()


func attack_phase3_a():

	$SBSprite.play("stomp_phase1")

	attack_finished()


func attack_phase3_b():

	print("Phase 3 - Attack B")

	attack_finished()


func attack_finished():

	is_attacking = false

	attack_cooldown_timer.start()


func _on_attack_cooldown_timer_timeout():

	start_attack_cycle()


func die():

	print("Boss Defeated")

	queue_free()


func _on_hitbox_area_entered(area: Area2D) -> void:

	if area.is_in_group("bullet"):
		take_damage(area.DAMAGE)
		area.queue_free()

	if area.is_in_group("player"):
		area.take_hit()


func _on_hitbox_body_entered(body: Node2D) -> void:

	if body.is_in_group("player"):
		body.take_hit(global_position)


func wait_for_frame(sprite: AnimatedSprite2D, target_frame: int):

	while sprite.frame != target_frame:
		if not get_tree():
			return 
		await get_tree().process_frame


func _on_stomp_area_body_entered(body: Node2D) -> void:

	if body.is_in_group("player"):
		body.take_hit(global_position)
