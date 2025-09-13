extends CharacterBody2D

@export var speed: float = 250.0
@export var N: float = 200.0
@export var M: float = 200.0
var O: float = 2 * N

@onready var Sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var MouthArea: Area2D = $AnimatedSprite2D/MouthArea

var patrol_points: Array[Vector2] = []
var current_point_index: int = 0
var start_position: Vector2
var target_position: Vector2

# arah ikan: 1 = kanan, -1 = kiri
var facing_dir: int = 1

# --- hook system ---
var hooked: bool = false
var hook_ref: CharacterBody2D = null
var attach_offset: Vector2 = Vector2.ZERO
@export var persistent_hook: bool = true

func _ready() -> void:
	start_position = global_position

	# titik patrol (pola silang)
	patrol_points = [
		start_position + Vector2(-N,  M),
		start_position + Vector2(-O, -M),
		start_position + Vector2( N,  M),
		start_position + Vector2( O, -M),
	]
	target_position = patrol_points[current_point_index]

	# connect signal ke MouthArea
	if MouthArea:
		MouthArea.body_entered.connect(_on_MouthArea_body_entered)
		MouthArea.body_exited.connect(_on_MouthArea_body_exited)


func _physics_process(delta: float) -> void:
	# kalau hooked → ikuti kail
	if hooked and is_instance_valid(hook_ref):
		global_position = hook_ref.global_position + attach_offset
		return

	# --- patrol normal ---
	if patrol_points.is_empty():
		return

	var direction: Vector2 = target_position - global_position
	var distance: float = direction.length()

	if distance < 5.0:
		current_point_index = (current_point_index + 1) % patrol_points.size()
		target_position = patrol_points[current_point_index]

	velocity = direction.normalized() * speed
	_update_facing(velocity.x)
	move_and_slide()


func _update_facing(x_dir: float) -> void:
	if x_dir > 0 and facing_dir != 1:
		facing_dir = 1
		_apply_facing()
	elif x_dir < 0 and facing_dir != -1:
		facing_dir = -1
		_apply_facing()

func _apply_facing() -> void:
	if facing_dir == 1:
		Sprite.scale.x = abs(Sprite.scale.x)   # hadap kanan
	else:
		Sprite.scale.x = -abs(Sprite.scale.x)  # hadap kiri


# --- HOOK LOGIC ---
func _on_MouthArea_body_entered(body: Node) -> void:
	if body is CharacterBody2D and body.name == "KailPancing" and not hooked:
		hook_ref = body

		# hitung offset: posisi ikan relatif ke mulut
		var mouth_to_center: Vector2 = global_position - MouthArea.global_position
		var adjust: Vector2 = Vector2(40, -10) # bisa diatur manual biar pas
		attach_offset = mouth_to_center + adjust

		hooked = true
		MouthArea.monitoring = false

func _on_MouthArea_body_exited(body: Node) -> void:
	if persistent_hook and hooked and body == hook_ref:
		return
	if body == hook_ref:
		_hook_detach()

func _hook_detach() -> void:
	hooked = false
	hook_ref = null
	attach_offset = Vector2.ZERO
	if MouthArea:
		MouthArea.monitoring = true

func force_unhook() -> void:
	_hook_detach()
