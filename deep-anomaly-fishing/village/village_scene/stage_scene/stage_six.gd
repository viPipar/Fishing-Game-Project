extends Node2D

var resource = preload("res://dialogue/stage_6.dialogue")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogueManager.show_dialogue_balloon(resource,"stage_6_1")
	await global_village.dialogue_finished
	$quest_guide/Panel/quest_text.play("home")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_rumah_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "MC":
		#masukkan dialogue
		$blink_rumah.visible=false
		SceneTransition.change_scene("res://village/village_scene/stage_scene/stage_seven.tscn")
	else : pass
