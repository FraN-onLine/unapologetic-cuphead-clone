extends Node2D

var dead = false
@export var PinkPony: PackedScene
var hazardscd = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	hazardscd -= delta
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
