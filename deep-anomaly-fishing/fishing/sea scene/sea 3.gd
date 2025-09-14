extends Node2D

func _process(delta: float) -> void:
	if global_fishing.hooking == true:
		$MinigameLayer.visible = true
		
	if global_fishing.hooking == false:
		$MinigameLayer.visible = false
	
	
	if global_fishing.coin >= 10:
		global_fishing.coin -= 10
		SceneTransition.change_scene("res://fishing/sea scene/sea merah.tscn")
		
	if global_fishing.caught == true:
		$"Fish Success".play()
		pass
		
	if Input.is_action_pressed("debug"):
		global_fishing.coin += 10

func _ready() -> void:
	$Sea.play()
	
