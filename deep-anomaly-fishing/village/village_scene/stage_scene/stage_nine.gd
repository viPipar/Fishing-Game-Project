extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$home/sister.visible=false
	global_village.mcfreeze()
	await get_tree().create_timer(2.0)
	
	$sister_character.move_to(1632,1014)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
