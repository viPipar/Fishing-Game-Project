extends Node2D

var medicine = 0
var resource = preload("res://dialogue/stage_1.dialogue")
signal ramuan_animation_done

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$quest_guide/Panel/quest_text.play("null")
	$area_kamar.monitoring = false
	$area_keluar_kamar.monitoring = false
	$leave.monitoring = false
	$control/Panel.visible=false
	$control/medicine_panel.visible=false
	DialogueManager.show_dialogue_balloon(resource, "stage_1_1")
	await global_village.dialogue_finished
	$quest_guide/Panel/quest_text.play("medicine")
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
	$ramuan.visible=true
	$ramuan/ramuan_sprite.play("animation")
	await ramuan_animation_done
	$ramuan.queue_free()
	$quest_guide/Panel/quest_text.play("givemed")
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
		DialogueManager.show_dialogue_balloon(resource, "stage_1_2")
		await global_village.dialogue_finished
		$quest_guide/Panel/quest_text.play("outside") 
	else : pass

#exit kamar
func _on_area_keluar_kamar_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if medicine == 2 :
		$area_keluar_kamar.queue_free()
		DialogueManager.show_dialogue_balloon(resource, "stage_1_3")
		$leave.monitoring = true
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


func _on_ramuan_sprite_animation_finished() -> void:
	emit_signal("ramuan_animation_done")
