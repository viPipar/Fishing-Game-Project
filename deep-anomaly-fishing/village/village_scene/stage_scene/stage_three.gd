extends Node2D

var resource = preload("res://dialogue/stage_3.dialogue")
var resource1 = preload("res://dialogue/stage_interlude_5.dialogue")
var resource2 = preload("res://dialogue/stage_interlude_7.dialogue")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$quest_guide/Panel/quest_text.play("null")
	if global_village.fishing_day==1 :
		DialogueManager.show_dialogue_balloon(resource,"stage_3_1")
	elif global_village.fishing_day==2 :
		DialogueManager.show_dialogue_balloon(resource1,"stage_interlude_5_1")
	elif global_village.fishing_day==3:
		DialogueManager.show_dialogue_balloon(resource2,"stage_interlude_7_1")
	await global_village.dialogue_finished
	$quest_guide/Panel/quest_text.play("harbour")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_pelabuhan_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "MC":
		print("masuk")
		global_village.mcfreeze() #berhentiin player
		if global_village.fishing_day == 1 :
			print ("1")
			DialogueManager.show_dialogue_balloon(resource,"stage_3_2")
		elif global_village.fishing_day == 2 :
			print ("2")
			DialogueManager.show_dialogue_balloon(resource1,"stage_interlude_5_2")
		elif global_village.fishing_day == 3 :
			print ("3")
			DialogueManager.show_dialogue_balloon(resource2,"stage_interlude_7_2")
		global_village.mcfreeze() #gerakin player
		print(global_village.fishing_day)
		$area_pelabuhan.queue_free()


func _on_area_kapal_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "MC":
		if global_village.fishing_day == 1 :
			SceneTransition.change_scene("res://village/village_scene/stage_scene/stage_four.tscn")
			print("fishing day 1")
		elif global_village.fishing_day == 2 :
			SceneTransition.change_scene("res://village/village_scene/stage_scene/stage_six.tscn")
			print("fishing day 2")
		elif global_village.fishing_day >= 3:
			SceneTransition.change_scene("res://village/village_scene/stage_scene/stage_eight.tscn")
			print("fishing day 3")
	else : pass
