extends Area2D

var direction = Vector2.RIGHT

const SPEED = 800.0


func _process(delta):

	position += direction * SPEED * delta

	rotation = direction.angle()
