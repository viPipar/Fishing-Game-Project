extends Node2D

var movement_speed: float = 4.0
var movement_time: float = 1.0

var min_distance: float = 100.0
var max_distance: float = 200.0

var min_position: float = 20.0
var max_position: float = 290.0

func _ready() -> void:
	plan_move()

func plan_move() -> void:
	var target_y: float = randf_range(min_position, max_position)

	while abs(position.y - target_y) < min_distance or abs(position.y - target_y) > max_distance:
		target_y = randf_range(min_position, max_position)

	move_to(Vector2(position.x, target_y))

func move_to(target: Vector2) -> void:
	# Buat tween baru setiap kali kita mau gerak
	var tween := create_tween()
	tween.tween_property(self, "position", target, movement_speed) \
		.set_trans(Tween.TRANS_QUINT) \
		.set_ease(Tween.EASE_OUT)

	$MoveTimer.wait_time = movement_time
	$MoveTimer.start()

func destroy() -> void:
	queue_free()

func timeout() -> void:
	plan_move()
