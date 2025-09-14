extends Node2D
@onready var ikan_nemo: CharacterBody2D = $ikan_nemo
@onready var ikan_dori: CharacterBody2D = $ikan_dori

func _process(delta: float) -> void:
	if global_fishing.hooking == true:
		$MinigameLayer.visible = true
		
	if global_fishing.hooking == false:
		$MinigameLayer.visible = false
	

func _ready() -> void:
	pass
