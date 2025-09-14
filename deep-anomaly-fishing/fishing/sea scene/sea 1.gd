extends Node2D

func _process(delta: float) -> void:
	if global_fishing.hooking == true:
		$MinigameLayer.visible = true
		
	if global_fishing.hooking == false:
		$MinigameLayer.visible = false
	
	if global_fishing.coin >= 10:
		global_fishing.coin -= 10
		SceneTransition.change_scene("res://village/village_scene/stage_scene/stage_three.tscn")
		
	if Input.is_action_pressed("debug"):
		global_fishing.hooking = true
