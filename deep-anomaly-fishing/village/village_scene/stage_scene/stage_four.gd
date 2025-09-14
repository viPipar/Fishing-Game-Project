extends Node2D
@onready var music: AudioStreamPlayer = $Music

var resource = preload("res://dialogue/stage_4.dialogue")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$quest_guide/Panel/quest_text.play("entity")
	$area_rumah.monitoring = false
	$home_panel.visible=false
	music.stream.loop = true
	music.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_patung_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "MC":
		$blink_patung.visible=false
		$area_patung.queue_free()
		DialogueManager.show_dialogue_balloon(resource,"stage_4_1")
		await global_village.dialogue_finished
		$quest_guide/Panel/quest_text.play("home")
		$area_rumah.monitoring = true
	else : pass


func _on_area_rumah_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "MC":
		$home_panel.visible=true
	else : pass
func _on_area_rumah_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "MC":
		$home_panel.visible=false
	else : pass
	
func _on_home_in_yes_button_pressed() -> void:
	SceneTransition.change_scene("res://village/village_scene/stage_scene/stage_five.tscn")
