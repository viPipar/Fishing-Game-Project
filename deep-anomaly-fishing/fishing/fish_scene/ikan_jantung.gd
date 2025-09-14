extends CharacterBody2D

@export var speed: float = 700.0
@export var N: float = 1000.0
@export var M: float = 1000.0
@export var adjust:Vector2 = Vector2(0, 0)
var O: float = 2 * N

@onready var Sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var MouthArea: Area2D = $AnimatedSprite2D/MouthArea
@onready var DetectionArea: Area2D = $DetectionArea  # child Area2D untuk deteksi Death & Detach

var patrol_points: Array[Vector2] = []
var current_point_index: int = 0
var start_position: Vector2
var target_position: Vector2

var facing_dir: int = 1

# --- hook system ---
var hooked: bool = false
var hook_ref: Area2D = null
var attach_offset: Vector2 = Vector2.ZERO
@export var persistent_hook: bool = true

# --- rotasi ---
var default_rotation_degrees: float = 0.0  # simpan rotasi awal
@export var hooked_rotation_degrees: float = 0.0  # rotasi saat hooked

# --- efek getaran saat hooked ---
@export var shake_intensity: float = 5.0   # besar goyang dalam derajat
@export var shake_speed: float = 25.0      # frekuensi getar
var shake_timer: float = 0.0               # internal timer getar

# --- reattach / detach control ---
@export var reattach_cooldown: float = 1.0  # detik sebelum bisa attach lagi setelah detach oleh Detach area
var _reattach_timer: float = 0.0

func _ready() -> void:
	start_position = global_position

	# simpan rotasi awal
	default_rotation_degrees = rotation_degrees

	# titik patrol
	patrol_points = [
		start_position + Vector2(-N,  M),
		start_position + Vector2(-O, -M),
		start_position + Vector2( N,  M),
		start_position + Vector2( O, -M),
	]
	target_position = patrol_points[current_point_index]

	# connect MouthArea
	if MouthArea:
		MouthArea.area_entered.connect(_on_MouthArea_area_entered)
		MouthArea.area_exited.connect(_on_MouthArea_area_exited)

func _physics_process(delta: float) -> void:
	# update reattach timer (mengurangi cooldown)
	if _reattach_timer > 0.0:
		_reattach_timer = max(0.0, _reattach_timer - delta)
		# jika cooldown habis dan MouthArea non-aktif, aktifkan kembali
		if _reattach_timer == 0.0 and MouthArea and not MouthArea.monitoring:
			_enable_mouth_collision_deferred()

	if hooked and is_instance_valid(hook_ref):
		global_position = hook_ref.global_position + attach_offset

		# Tambahkan efek getar
		shake_timer += delta * shake_speed
		var shake_offset = sin(shake_timer) * shake_intensity
		rotation_degrees = hooked_rotation_degrees + shake_offset
	else:
		# reset rotasi dan timer saat tidak hooked
		rotation_degrees = default_rotation_degrees
		shake_timer = 0.0

		# patrol normal
		if patrol_points.is_empty():
			return
		var direction = target_position - global_position
		if direction.length() < 5.0:
			current_point_index = (current_point_index + 1) % patrol_points.size()
			target_position = patrol_points[current_point_index]

		velocity = direction.normalized() * speed
		_update_facing(velocity.x)
		move_and_slide()

	# ==== cek DeathArea & DetachArea ====
	if hooked and is_instance_valid(DetectionArea):
		for area in DetectionArea.get_overlapping_areas():
			if area.is_in_group("Detach"):
				# lakukan detach hanya jika sedang hooked
				if hooked:
					_hook_detach()
					# disable MouthArea sementara supaya tidak re-attach
					_disable_mouth_collision_deferred()
					# set cooldown agar tidak bisa attach kembali dalam jangka waktu
					_reattach_timer = reattach_cooldown
					# keluar loop, karena sudah detach
					break

func _update_facing(x_dir: float) -> void:
	if x_dir < 0 and facing_dir != -1:
		facing_dir = -1
		_apply_facing()
	elif x_dir > 0 and facing_dir != 1:
		facing_dir = 1
		_apply_facing()

func _apply_facing() -> void:
	Sprite.scale.x = abs(Sprite.scale.x) * facing_dir

# --- helpers MouthArea collision ---
func _disable_mouth_collision_deferred() -> void:
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

# --- HOOK LOGIC ---
func _on_MouthArea_area_entered(area: Area2D) -> void:
	# jika masih di cooldown, abaikan supaya tidak langsung attach
	if _reattach_timer > 0.0:
		return

	# hanya terima HookArea jika belum hooked
	if area is Area2D and area.name == "HookArea" and not hooked:
		hook_ref = area
		var mouth_to_center = global_position - MouthArea.global_position
		attach_offset = mouth_to_center + adjust
		hooked = true
		_disable_mouth_collision_deferred()

		# Langsung set posisi dan timer awal goyang
		global_position = hook_ref.global_position + attach_offset
		shake_timer = 0.0

func _on_MouthArea_area_exited(area: Area2D) -> void:
	if persistent_hook and hooked and area == hook_ref:
		return
	if area == hook_ref:
		_hook_detach()

func _hook_detach() -> void:
	hooked = false
	hook_ref = null
	attach_offset = Vector2.ZERO
	# note: jangan langsung enable mouth collision di sini,
	# caller (mis. Detach handler) bisa mengontrol kapan re-enable via _reattach_timer.
	_enable_mouth_collision_deferred()
	if global_fishing.caught == true:
		queue_free()
		global_fishing.caught = false
		global_fishing.coin +=999
	shake_timer = 0.0

func force_unhook() -> void:
	_hook_detach()
