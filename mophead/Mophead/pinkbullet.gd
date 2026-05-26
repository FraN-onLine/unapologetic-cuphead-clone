extends Area2D

var direction = Vector2.RIGHT

const SPEED = 550.0
const DAMAGE = 1

const fire_rate = 0.28


func _process(delta):

	position += direction * SPEED * delta

	rotation = direction.angle()
