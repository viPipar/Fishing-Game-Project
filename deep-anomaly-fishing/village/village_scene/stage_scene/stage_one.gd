extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_leave_body_entered(body: Node2D) -> void:
	if body.name == "MC":
		$control/Panel.visible=true
	else : pass
	
func _on_leave_body_exited(body: Node2D) -> void:
	if body.name == "MC":
		$control/Panel.visible=false
	else : pass


func _on_button_pressed() -> void:
	SceneTransition.change_scene("res://village/village_scene/stage_scene/stage_two.tscn")
