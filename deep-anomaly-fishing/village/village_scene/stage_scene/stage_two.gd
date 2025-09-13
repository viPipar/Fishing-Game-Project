extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$area_patung.monitoring = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_kuburan_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "MC":
		$area_kuburan.queue_free()
		$blink_kuburan.visible=false
		global_village.mcfreeze() #berhentiin player
		
		await get_tree().create_timer(3).timeout #ganti dengan dialog
		
		global_village.mcfreeze() #gerakin player
		$blink_patung.visible=true
		$area_patung.monitoring = true

	else : pass

func _on_area_patung_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "MC":
		$area_patung.queue_free()
		$blink_patung.visible=false
		global_village.mcfreeze() #berhentiin player
		
		await get_tree().create_timer(3).timeout #ganti dengan dialog
		
		global_village.mcfreeze() #gerakin player
		global_village.fishing_day = 1
		SceneTransition.change_scene("res://village/village_scene/stage_scene/stage_three.tscn")
	else : pass
