extends Area2D

const SPEED = 150.0

var direction = Vector2.DOWN


func _process(delta):

	position += direction * SPEED * delta


func _on_body_entered(body):

	if body.has_method("take_hit"):

		body.take_hit(global_position)
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():

	queue_free()
