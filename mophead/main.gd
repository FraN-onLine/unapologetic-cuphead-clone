extends Node2D

var dead = false
@export var PinkPony: PackedScene
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
			$Mophead.queue_free()
			dead = true
	if hazardscd < 0:
		hazardscd = 7.5
		if $SexyBucket.hp < 951 and $SexyBucket.hp > 700:
			spawn_pony()
	

func spawn_pony():
	print("spawn pony")
	var pp = PinkPony.instantiate()

	add_child(pp)

	pp.global_position = $Marker2D.position

func drop_mop():
	$Mop.play("default")
	await wait_for_frame($Mop, 5)
	$MopArea.monitoring = true
	await wait_for_frame($Mop, 7)
	$MopArea.monitoring = false
	
func _on_mop_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):

		body.take_hit($MopArea.global_position)

		print("Mop hit Mophead")

func wait_for_frame(sprite: AnimatedSprite2D, target_frame: int):

	while sprite.frame != target_frame:
		await get_tree().process_frame

func switch_weapon(type):
	if type == "blue":
		$CanvasLayer/Weapon.texture = load("res://Assets/Mophead/Mophead Blue Bullets.png")
	else:
		$CanvasLayer/Weapon.texture = load("res://Assets/Mophead/Mophead Pink Bullets.png")
