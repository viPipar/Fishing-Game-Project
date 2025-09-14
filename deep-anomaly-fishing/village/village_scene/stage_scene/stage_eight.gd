extends Node2D
@onready var music: AudioStreamPlayer = $Music

var resource = preload("res://dialogue/stage_8.dialogue")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$quest_guide/Panel/quest_text.play("entity")
	music.stream.loop = true
	music.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_patung_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "MC":
		$area_patung.queue_free()
		$area_rumah.visible = true
		$blink_rumah.visible=true
		$blink_patung.visible=false
		DialogueManager.show_dialogue_balloon(resource,"stage_8_1")
		await global_village.dialogue_finished
		$animation.visible=true
		$animation/blood_pact.play("animated")
		$quest_guide/Panel/quest_text.play("home")
	else : pass

func _on_area_rumah_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "MC":
		DialogueManager.show_dialogue_balloon(resource,"stage_8_2")
		await global_village.dialogue_finished
		SceneTransition.change_scene("res://village/village_scene/stage_scene/stage_nine.tscn")
	else : pass


func _on_blood_pact_animation_finished() -> void:
	await get_tree().create_timer(3.0).timeout
	$animation.visible = false
	DialogueManager.show_dialogue_balloon(resource,"stage_8_1_1")
	await global_village.dialogue_finished
	$quest_guide/Panel/quest_text.play("home")
