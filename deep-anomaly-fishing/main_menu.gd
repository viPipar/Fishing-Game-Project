extends Node2D


func _on_new_game_pressed() -> void:
	SceneTransition.change_scene("res://village/village_scene/stage_scene/stage_one.tscn")

func _on_exit_game_pressed() -> void:
	get_tree().quit()
