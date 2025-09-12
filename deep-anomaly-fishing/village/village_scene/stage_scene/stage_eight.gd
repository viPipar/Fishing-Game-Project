extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_patung_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "MC":
		$area_rumah.visible = true
		$blink_rumah.visible=true
		#masukkan dialogue
		$blink_patung.visible=false
		#text cerita
	else : pass

func _on_area_rumah_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "MC":
		#masukkan dialogue
		$blink_patung.visible=false
		SceneTransition.change_scene("res://village/village_scene/stage_scene/stage_nine.tscn")
	else : pass
