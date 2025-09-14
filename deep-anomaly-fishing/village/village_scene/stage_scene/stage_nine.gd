extends Node2D
var resource = preload("res://dialogue/stage_9.dialogue")
signal loop_finished
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$home/sister.visible=false
	global_village.mcfreeze()
	await get_tree().create_timer(2.0)
	loop_walk()
	DialogueManager.show_dialogue_balloon(resource,"stage_9_1")
	await global_village.dialogue_finished
	await get_tree().create_timer(3.0).timeout
	SceneTransition.change_scene("res://ui/ui_scene/jantung.tscn")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
		
func loop_walk():
		$sister_character.move_to(1632,1014)
		await get_tree().create_timer(4.0).timeout
		$sister_character.move_to(1436,1014)
		await get_tree().create_timer(1.5).timeout
		$sister_character.move_to(1436,800)
		await get_tree().create_timer(1.5).timeout
		$sister_character.move_to(1830,800)
		await get_tree().create_timer(2).timeout
		$sister_character.move_to(1830,1014)
		await get_tree().create_timer(1.5).timeout
		$sister_character.move_to(1632,1014)
		loop_walk()
