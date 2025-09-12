extends CharacterBody2D

const PULL_FORCE := -200.0
const MAX_PULL_FORCE := -10.0
const MAX_DOWN_FORCE := 400.0
const MOVE_SPEED := 300.0

var is_input := false
var start_pos: Vector2   # posisi awal kail (anchor tetap)

func _ready() -> void:
	# simpan posisi global saat pertama kali muncul (anchor)
	start_pos = global_position

func _process(delta: float) -> void:
	is_input = false

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

	move_and_slide()

	queue_redraw()  # biar garis diupdate setiap frame

func _draw() -> void:
	# gambar garis dari titik awal ke posisi sekarang
	draw_line(
		to_local(start_pos),        # anchor awal (tetap diam)
		to_local(global_position),  # posisi sekarang
		Color.WHITE,
		2.0
	)
