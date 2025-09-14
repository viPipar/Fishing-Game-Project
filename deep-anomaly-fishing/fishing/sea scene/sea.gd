extends Node2D

func _process(delta: float) -> void:
	if global_fishing.hooking == true:
		$MinigameLayer.visible = true
	else:
		$MinigameLayer.visible = false
		

func _ready() -> void:
	pass
