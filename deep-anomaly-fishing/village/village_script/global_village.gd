extends Node

var mc_movement=true
var fishing_day = 1
signal dialogue_finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogueManager.connect("dialogue_ended", Callable(self, "_on_dialogue_ended"))
	DialogueManager.connect("bridge_dialogue_started", Callable(self, "_on_dialogue_started"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func mcfreeze() :
	mc_movement = not mc_movement
	
func _on_dialogue_started(resource: DialogueResource):
	mc_movement = false
func _on_dialogue_ended(resource: DialogueResource):
	mc_movement = true
	emit_signal("dialogue_finished")
