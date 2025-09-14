extends CharacterBody2D

# ======= PARAM =======
const PULL_FORCE := -200.0
const MAX_PULL_FORCE := -10.0
const MAX_DOWN_FORCE := 400.0
const MOVE_SPEED := 300.0

@export var deactivate_delay: float = 0.03  # jeda sebelum hook nonaktif
@export var detach_duration: float = 1.0    # durasi DetachArea aktif dan HookArea nonaktif (detik)

# ======= STATE =======
var is_input := false
var start_pos: Vector2   # posisi awal kail (anchor tetap)
var hook_time: float = 0.0
var _detach_in_progress: bool = false

# ======= NODE REFS =======
@onready var hook_area: Area2D = $HookArea
@onready var hook_shape: CollisionShape2D = $HookArea/CollisionShape2D
@onready var detect_area: Area2D = $DetectArea
# Detach area (di-activate / di-activate lewat input "detach")
@onready var detach_area: Area2D = $DetachArea
@onready var detach_shape: CollisionShape2D = $DetachArea/CollisionShape2D

# ======= LIFE CYCLE =======
func _ready() -> void:
	start_pos = global_position
	if hook_area:
		hook_area.area_entered.connect(_on_HookArea_area_entered)
	# pastikan hook shape aktif
	if is_instance_valid(hook_shape):
		hook_shape.disabled = false
	# pastikan detach area dalam kondisi non-aktif awal
	if is_instance_valid(detach_area):
		detach_area.monitoring = false
		detach_area.visible = false
	if is_instance_valid(detach_shape):
		detach_shape.disabled = true

func _process(delta: float) -> void:
	is_input = false
	if global_fishing.hooking == true:
		velocity.x = 0.0
		velocity.y = 0.0
	else:
	# ===== input movement normal =====
		if Input.is_action_pressed("up"):
			velocity.y = PULL_FORCE * 3
			is_input = true
		if Input.is_action_pressed("down"):
			velocity.y = min(velocity.y + 50, MAX_DOWN_FORCE)
			is_input = true
		if Input.is_action_pressed("right"):
			velocity.x = MOVE_SPEED
			is_input = true
		if Input.is_action_pressed("left"):
			velocity.x = -MOVE_SPEED
			is_input = true

	# ===== gerakan otomatis saat kail menempel ikan =====
		if is_instance_valid(detect_area):
			var overlapping := detect_area.get_overlapping_areas()
			var touching_ikan := false
			for area in overlapping:
				if area.is_in_group("Ikan"):
					touching_ikan = true
					break

			if touching_ikan:
				hook_time += delta

				var auto_x = MOVE_SPEED * 0.5 * sin(hook_time * 5.0)
				var auto_y = -50

				var input_x = 0
				var input_y = 0
				if Input.is_action_pressed("up"):
					input_y -= 200
				if Input.is_action_pressed("right"):
					input_x += MOVE_SPEED
				if Input.is_action_pressed("left"):
					input_x -= MOVE_SPEED
				if Input.is_action_pressed("down"):
					input_y += 200

				velocity.x = auto_x + input_x
				velocity.y = auto_y + input_y
			else:
				hook_time = 0.0
				if not is_input:
					velocity.x = 0
					velocity.y = min(velocity.y + PULL_FORCE * delta, MAX_PULL_FORCE)

	# ===== debug input: re-activate hook =====
	if Input.is_action_just_pressed("debug"):
		reactivate_hook()
	if global_fishing.release == true:
		reactivate_hook()

	# ===== new input: aktifkan DetachArea sementara dan nonaktifkan HookArea sementara =====
	if Input.is_action_just_pressed("detach"):
		# jangan izinkan overlapping detach action jika sudah berjalan
		if not _detach_in_progress:
			start_detach_sequence()

	move_and_slide()
	queue_redraw()  # update garis setiap frame

func _draw() -> void:
	# gambar garis dari anchor awal ke posisi sekarang
	draw_line(to_local(start_pos), to_local(global_position), Color.WHITE, 2.0)

# ======= HOOK HANDLER =======
func _on_HookArea_area_entered(area: Area2D) -> void:
	# ketika HookArea bertemu MouthArea
	if not (area is Area2D and area.name == "MouthArea"):
		return

	global_fishing.hooking = true
	_deactivate_hook_after_delay()

# gunakan deferred untuk menunggu sebelum hook nonaktif
func _deactivate_hook_after_delay() -> void:
	call_deferred("_async_deactivate_hook")

func _async_deactivate_hook() -> void:
	await get_tree().create_timer(deactivate_delay).timeout

	if is_instance_valid(hook_shape):
		hook_shape.disabled = true
	if is_instance_valid(hook_area):
		hook_area.monitoring = false
		hook_area.visible = false

# ======= UTIL: re-enable hook =======
func reactivate_hook() -> void:
	if not is_instance_valid(hook_area):
		return
	hook_area.set_deferred("monitoring", true)
	hook_area.set_deferred("visible", true)
	if is_instance_valid(hook_shape):
		hook_shape.set_deferred("disabled", false)
	
	hook_time = 0.0

# ======= UTIL: Detach Area control =======
func _activate_detach_area() -> void:
	if not is_instance_valid(detach_area):
		return
	# aktifkan secara deferred agar aman pada frame ini
	detach_area.set_deferred("monitoring", true)
	detach_area.set_deferred("visible", true)
	if is_instance_valid(detach_shape):
		detach_shape.set_deferred("disabled", false)

func deactivate_detach_area() -> void:
	if not is_instance_valid(detach_area):
		return
	detach_area.set_deferred("monitoring", false)
	detach_area.set_deferred("visible", false)
	if is_instance_valid(detach_shape):
		detach_shape.set_deferred("disabled", true)

# ======= NEW: sequence to detach fish =======
func start_detach_sequence() -> void:
	# start detach sequence (aktifkan DetachArea dan nonaktifkan HookArea sementara)
	_detach_in_progress = true

	# aktifkan DetachArea
	if is_instance_valid(detach_area):
		detach_area.set_deferred("monitoring", true)
		detach_area.set_deferred("visible", true)
	if is_instance_valid(detach_shape):
		detach_shape.set_deferred("disabled", false)

	# nonaktifkan HookArea dan shape
	if is_instance_valid(hook_area):
		hook_area.set_deferred("monitoring", false)
		hook_area.set_deferred("visible", false)
	if is_instance_valid(hook_shape):
		hook_shape.set_deferred("disabled", true)

	# biarkan dalam kondisi ini selama detach_duration detik
	await get_tree().create_timer(detach_duration).timeout

	# kembalikan keadaan: Deactivate DetachArea dan re-enable HookArea
	if is_instance_valid(detach_area):
		detach_area.set_deferred("monitoring", false)
		detach_area.set_deferred("visible", false)
	if is_instance_valid(detach_shape):
		detach_shape.set_deferred("disabled", true)

	if is_instance_valid(hook_area):
		hook_area.set_deferred("monitoring", true)
		hook_area.set_deferred("visible", true)
	if is_instance_valid(hook_shape):
		hook_shape.set_deferred("disabled", false)

	# reset state
	_detach_in_progress = false
