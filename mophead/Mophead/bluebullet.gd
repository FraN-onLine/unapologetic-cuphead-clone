extends Area2D

var direction = Vector2.RIGHT

const SPEED = 450.0
const DAMAGE = 5

const fire_rate = 0.35


func _process(delta):

	position += direction * SPEED * delta

	rotation = direction.angle()
