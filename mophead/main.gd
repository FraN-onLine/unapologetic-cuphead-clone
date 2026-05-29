extends Node2D

var dead = false
@export var PinkPony: PackedScene
@export var Ring: PackedScene
@export var Tear: PackedScene
var hazardscd = 0
var instructions_on = true
var timer_ins = 0
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	hazardscd -= delta
	if instructions_on:
		timer_ins += delta
		if timer_ins > 5:
			instructions_on = false
			$CanvasLayer/Instructions.visible = false
			$CanvasLayer/Instructions2.visible = false
	if not dead:
		if $Mophead.HP > 0:
			$CanvasLayer/HPLabel.text = "HP: " + str($Mophead.HP)
		else:
			$CanvasLayer/HPLabel.text = "HP: " + str($Mophead.HP)
			dead = true
	if hazardscd < 0:
		hazardscd = 7.5
		if $SexyBucket.hp < 951 and $SexyBucket.hp > 700:
			spawn_pony()
		elif $SexyBucket.hp < 501 and $SexyBucket.hp > 250:
			alleygator()	
		elif $SexyBucket.hp < 200:
			#random between alligator or mop
			if randi() % 2 == 0:
				alleygator()
			else:
				drop_mop()

func spawn_pony():
	print("spawn pony")
	var pp = PinkPony.instantiate()

	add_child(pp)

	pp.global_position = $Marker2D.position
	
func spawn_ring():
	print("spawn pony")
	for i in range(3):
		var ring = Ring.instantiate()
		add_child(ring)
		ring.global_position = $Marker2D2.position
		await get_tree().create_timer(1).timeout
		
func drop_tears():

	print("spawn tears")

	var markers = [
		$Marker2D3,
		$Marker2D4,
		$Marker2D5
	]

	for i in range(6):

		var tear = Tear.instantiate()

		add_child(tear)

		# pick random marker
		var random_marker = markers.pick_random()

		tear.global_position = random_marker.global_position

		await get_tree().create_timer(0.6).timeout

func drop_mop():
	$Mop.play("default")
	await wait_for_frame($Mop, 5)
	$MopArea.monitoring = true
	await wait_for_frame($Mop, 7)
	$MopArea.monitoring = false
	
func alleygator():
	$Alleygator.play("default")
	await wait_for_frame($Alleygator, 6)
	$AlleygatorArea.monitoring = true
	await wait_for_frame($Alleygator, 10)
	$AlleygatorArea.monitoring = false
	
func _on_mop_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):

		body.take_hit($MopArea.global_position)

		print("Mop hit Mophead")

func wait_for_frame(sprite: AnimatedSprite2D, target_frame: int):
	while sprite.frame != target_frame:
		if not get_tree():
			return
		await get_tree().process_frame
		

func switch_weapon(type):
	if type == "blue":
		$CanvasLayer/Weapon.texture = load("res://Assets/Mophead/Mophead Blue Bullets.png")
	else:
		$CanvasLayer/Weapon.texture = load("res://Assets/Mophead/Mophead Pink Bullets.png")


func _on_alleygator_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):

		body.take_hit($AlleygatorArea.global_position)

		print("Mop hit Mophead")
