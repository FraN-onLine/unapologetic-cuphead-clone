extends Area2D

var direction = Vector2.RIGHT

const SPEED = 950.0
const DAMAGE = 1

const fire_rate = 0.12


func _process(delta):

	position += direction * SPEED * delta

	rotation = direction.angle()
