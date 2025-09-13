extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_kamar_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "MC":
		$blink_kamar.visible=false
		global_village.mcfreeze()
		await get_tree().create_timer(5.0).timeout #masukkan dialogue
		global_village.mcfreeze()
		global_village.fishing_day=2
		SceneTransition.change_scene("res://village/village_scene/stage_scene/stage_three.tscn")
	else : pass
