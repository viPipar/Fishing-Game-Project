extends Node2D

func _process(delta: float) -> void:
	if global_fishing.hooking == true:
		$MinigameLayer.visible = true
		
	if global_fishing.hooking == false:
		$MinigameLayer.visible = false
	
