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

#timer
@onready var attack_cooldown_timer = $AttackCooldownTimer

# =====================================
# READY
# =====================================

func _ready():

	update_phase()

	start_attack_cycle()


func take_damage(amount: int):

	#brief white flash on damage

	$SBSprite.modulate = Color(1, 1, 1, 0.8)
	await get_tree().create_timer(0.1).timeout
	$SBSprite.modulate = Color(1, 1, 1, 1)
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

		BossPhase.PHASE_3:
			print("Entered Phase 3")

func start_attack_cycle():

	if hp <= 0:
		return

	if is_attacking:
		return

	is_attacking = true

	select_attack()


func select_attack():

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
		attack_phase1_c
	]

	current_attack = randi() % attacks.size()

	attacks[current_attack].call()


func phase_2_attack_selection():

	var attacks = [
		attack_phase2_a,
		attack_phase2_b,
		attack_phase2_c
	]

	current_attack = randi() % attacks.size()

	attacks[current_attack].call()

func phase_3_attack_selection():

	var attacks = [
		attack_phase3_a,
		attack_phase3_b,
		attack_phase3_c
	]

	current_attack = randi() % attacks.size()

	attacks[current_attack].call()

func attack_phase1_a():

	$SBSprite.play("stomp_phase1")
	await $SBSprite.animation_finished
	$SBSprite.play("idle_phase1")
	attack_finished()

func attack_phase1_b():

	$SBSprite.play("mop_phase1")
	await $SBSprite.animation_finished
	$SBSprite.play("idle_phase1")
	attack_finished()


func attack_phase1_c():

	print("Phase 1 - Attack C")

	attack_finished()

func attack_phase2_a():

	print("Phase 2 - Attack A")

	attack_finished()


func attack_phase2_b():

	print("Phase 2 - Attack B")

	attack_finished()


func attack_phase2_c():

	print("Phase 2 - Attack C")

	attack_finished()

func attack_phase3_a():

	$SBSprite.play("stomp_phase1")

	attack_finished()


func attack_phase3_b():

	print("Phase 3 - Attack B")

	attack_finished()


func attack_phase3_c():

	print("Phase 3 - Attack C")

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
