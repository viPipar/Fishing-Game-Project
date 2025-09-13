extends CharacterBody2D

# ======= PARAM =======
const PULL_FORCE := -200.0
const MAX_PULL_FORCE := -10.0
const MAX_DOWN_FORCE := 400.0
const MOVE_SPEED := 300.0

@export var deactivate_delay: float = 0.03  # jeda sebelum disable (detik). tweak jika perlu

# ======= STATE =======
var is_input := false
var hooking: bool = false
var start_pos: Vector2   # posisi awal kail (anchor tetap)

# ======= NODE REFS =======
@onready var hook_area: Area2D = $HookArea
@onready var hook_shape: CollisionShape2D = $HookArea/CollisionShape2D

# ======= LIFE CYCLE =======
func _ready() -> void:
	start_pos = global_position
	if hook_area:
		hook_area.area_entered.connect(_on_HookArea_area_entered)
	# pastikan shape awal aktif (atau sesuai kebutuhan)
	if is_instance_valid(hook_shape):
		hook_shape.disabled = false

func _process(delta: float) -> void:
	is_input = false

	# ===== input movement =====
	if Input.is_action_pressed("down"):
		velocity.y = min(velocity.y + 50, MAX_DOWN_FORCE)
		is_input = true
	elif Input.is_action_pressed("right"):
		velocity.x = MOVE_SPEED
		is_input = true
	elif Input.is_action_pressed("left"):
		velocity.x = -MOVE_SPEED
		is_input = true

	if not is_input:
		velocity.y = min(velocity.y + PULL_FORCE * delta, MAX_PULL_FORCE)
		velocity.x = 0

	# ===== debug input: re-activate hook on debug action =====
	# pastikan kamu sudah mendaftarkan action "debug" di Project Settings -> Input Map
	if Input.is_action_just_pressed("debug"):
		reactivate_hook()

	move_and_slide()
	queue_redraw()  # update garis setiap frame

func _draw() -> void:
	# gambar garis dari anchor awal ke posisi sekarang
	draw_line(
		to_local(start_pos),
		to_local(global_position),
		Color.WHITE,
		2.0
	)

# ======= HOOK HANDLER =======
func _on_HookArea_area_entered(area: Area2D) -> void:
	# ketika HookArea bertemu MouthArea
	if not (area is Area2D and area.name == "MouthArea"):
		return

	# segera set hooking state supaya ikan punya kesempatan untuk attach
	hooking = true

	# tunda non-aktifkan hook, beri kesempatan ikan menempel
	_deactivate_hook_after_delay()

# gunakan deferred await supaya tidak blocking dan aman
func _deactivate_hook_after_delay() -> void:
	# jika sudah ada coroutine yang berjalan, biarkan saja (atau kita bisa cancel, tapi ini sederhana)
	_call_deferred_deactivate()

# helper untuk memanggil async function lewat deferred (menghindari call stack reentrancy)
func _call_deferred_deactivate() -> void:
	call_deferred("_async_deactivate_hook")

# fungsi async yang menunggu timer lalu menonaktifkan hook
func _async_deactivate_hook() -> void:
	# tunggu sejumlah detik agar MouthArea sempat memproses area_entered
	await get_tree().create_timer(deactivate_delay).timeout

	# nonaktifkan shape dan monitoring jika masih valid
	if is_instance_valid(hook_shape):
		hook_shape.disabled = true
	if is_instance_valid(hook_area):
		hook_area.monitoring = false
		# opsional: sembunyikan node visual
		hook_area.visible = false

	# hooking state bisa dipertahankan jika kail menempel objek lain; sesuaikan logika di tempat lain
	# contoh: kamu bisa reset hooking di sini jika mau:
	# hooking = false

# ======= UTIL: re-enable hook (dipanggil oleh game logic saat perlu) =======
func reactivate_hook() -> void:
	if not is_instance_valid(hook_area):
		return
	# aktifkan kembali (gunakan deferred untuk safety jika dipanggil dari signal)
	hook_area.set_deferred("monitoring", true)
	hook_area.set_deferred("visible", true)
	if is_instance_valid(hook_shape):
		hook_shape.set_deferred("disabled", false)
	hooking = false
