extends Node2D

var medicine = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$area_kamar.monitoring = false
	$area_keluar_kamar.monitoring = false
	$leave.monitoring = false
	
	$control/Panel.visible=false
	$control/medicine_panel.visible=false


#Buat obat
func _on_area_medicine_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "MC":
		$control/medicine_panel.visible=true
	else : pass
func _on_area_medicine_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "MC":
		$control/medicine_panel.visible=false
	else : pass
func _on_medicine_yes_button_pressed() -> void:
	medicine = 1
	#dialog
	#pop up medicine
	print("medicine")
	$blink_kamar.visible=true
	$area_kamar.monitoring = true
	$area_keluar_kamar.monitoring = true
	$area_medicine.queue_free()

#kamar
func _on_area_kamar_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "MC":
		$area_kamar.queue_free()
		$blink_kamar.visible=false
		medicine = 2
		#percakapan
	else : pass

#exit kamar
func _on_area_keluar_kamar_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if medicine == 2 :
		$area_keluar_kamar.queue_free()
		global_village.mcfreeze() #stop character
		#masukin dialogue
		await get_tree().create_timer(5.0).timeout #diapus kalau udah ada dialogue
		$leave.monitoring = true
		global_village.mcfreeze() #walk character
	else : pass 


#exit house
func _on_leave_body_entered(body: Node2D) -> void:
	if body.name == "MC" && medicine == 2:
		$control/Panel.visible=true
	else : pass
func _on_leave_body_exited(body: Node2D) -> void:
	if body.name == "MC":
		$control/Panel.visible=false
	else : pass
func _on_button_pressed() -> void:
	SceneTransition.change_scene("res://village/village_scene/stage_scene/stage_two.tscn")
