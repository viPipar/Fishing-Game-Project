extends CharacterBody2D

@export var speed: float = 400.0
@export var N: float = 1000.0
@export var M: float = 0
var O: float = 2 * N

@onready var Sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var MouthArea: Area2D = $AnimatedSprite2D/MouthArea
@onready var death_area: Area2D = $AnimatedSprite2D/DeathArea

var patrol_points: Array[Vector2] = []
var current_point_index: int = 0
var start_position: Vector2
var target_position: Vector2

# arah ikan: 1 = kanan, -1 = kiri
var facing_dir: int = 1

# --- hook system ---
var hooked: bool = false
# sekarang hook_ref menyimpan referensi ke Area2D (HookArea)
var hook_ref: Area2D = null
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

	# connect signal ke MouthArea -> gunakan area_entered/area_exited
	if MouthArea:
		MouthArea.area_entered.connect(_on_MouthArea_area_entered)
		MouthArea.area_exited.connect(_on_MouthArea_area_exited)


func _physics_process(delta: float) -> void:
	# kalau hooked → ikuti hook (Area2D)
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
	if x_dir < 0 and facing_dir != -1:
		facing_dir = -1
		_apply_facing()
	elif x_dir > 0 and facing_dir != 1:
		facing_dir = 1
		_apply_facing()

func _apply_facing() -> void:
	if facing_dir == 1:
		Sprite.scale.x = abs(Sprite.scale.x)   # hadap kanan
	else:
		Sprite.scale.x = -abs(Sprite.scale.x)  # hadap kiri


# --- helpers untuk MouthArea collision on/off ---
func _disable_mouth_collision_deferred() -> void:
	# nonaktifkan monitoring dan semua CollisionShape2D direct child (deferred karena dipanggil dari signal)
	if MouthArea:
		MouthArea.set_deferred("monitoring", false)
		for child in MouthArea.get_children():
			if child is CollisionShape2D:
				child.set_deferred("disabled", true)

func _enable_mouth_collision_deferred() -> void:
	if MouthArea:
		MouthArea.set_deferred("monitoring", true)
		for child in MouthArea.get_children():
			if child is CollisionShape2D:
				child.set_deferred("disabled", false)


# --- HOOK LOGIC (Area2D "HookArea") ---
func _on_MouthArea_area_entered(area: Area2D) -> void:
	# cek apakah yang memasuki mulut adalah HookArea
	if area is Area2D and area.name == "HookArea" and not hooked:
		hook_ref = area

		# hitung offset: posisi ikan relatif ke mulutA
		var mouth_to_center: Vector2 = global_position - MouthArea.global_position
		var adjust: Vector2 = Vector2(40, -10) # bisa diatur manual biar pas
		attach_offset = mouth_to_center + adjust

		hooked = true

		# **DISABLE** MouthArea collision (deferred agar aman)
		_disable_mouth_collision_deferred()

func _on_MouthArea_area_exited(area: Area2D) -> void:
	# kalau persistent_hook true, jangan detach saat area keluar (selama masih hooked)
	if persistent_hook and hooked and area == hook_ref:
		return
	if area == hook_ref:
		_hook_detach()

func _hook_detach() -> void:
	hooked = false
	hook_ref = null
	attach_offset = Vector2.ZERO
	# re-enable MouthArea collision
	_enable_mouth_collision_deferred()

func force_unhook() -> void:
	_hook_detach()
