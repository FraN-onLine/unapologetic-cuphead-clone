extends Node2D

func _process(delta: float) -> void:

	if Input.is_action_just_pressed("shoot"):
		start_game()


func _on_button_pressed() -> void:
	start_game()


func start_game() -> void:
	get_tree().change_scene_to_file("res://main.tscn")