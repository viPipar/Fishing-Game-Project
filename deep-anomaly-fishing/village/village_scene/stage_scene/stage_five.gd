extends Node2D

var resource = preload("res://dialogue/stage_5.dialogue")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$quest_guide/Panel/quest_text.play("bed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_kamar_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "MC":
		$blink_kamar.visible=false
		DialogueManager.show_dialogue_balloon(resource,"stage_5_1")
		await global_village.dialogue_finished
		global_village.fishing_day=2
		SceneTransition.change_scene("res://village/village_scene/stage_scene/stage_three.tscn")
	else : pass
