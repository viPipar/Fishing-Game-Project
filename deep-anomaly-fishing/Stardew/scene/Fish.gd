extends Node2D

var movement_speed: float = 4.0
var movement_time: float = 1.0

@export var min_distance: float = 100.0
@export var max_distance: float = 200.0

@export var min_y: float = -325.0
@export var max_y: float = 348.0

func _ready() -> void:
	position.y = clamp(position.y, min_y, max_y)
	add_to_group("fish_target")
	plan_move()

func plan_move() -> void:
	var target_y: float = _pick_target_y()
	move(Vector2(position.x, target_y))

func move(target: Vector2) -> void:
	# Godot 4: buat tween baru, jangan pakai $Tween.interpolate_property
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "position", target, movement_time)  # durasi pindah = movement_time

	# jalanin timer untuk gerakan berikutnya
	$MoveTimer.wait_time = movement_time
	$MoveTimer.start()

func destroy() -> void:
	queue_free()

func timeout() -> void:
	plan_move()

func _pick_target_y() -> float:
	var y: float = position.y

	var up_room: float = y - min_y
	var down_room: float = max_y - y

	var max_allow: float = max(up_room, down_room)
	if max_allow <= 0.0:
		return clamp(y, min_y, max_y)

	var eff_max: float = min(max_distance, max_allow)
	var eff_min: float = min(min_distance, eff_max)

	var ranges: Array[Vector2] = []

	# range ke atas (menuju min_y)
	var up_a: float = max(y - eff_max, min_y)
	var up_b: float = max(y - eff_min, min_y)
	if up_a <= up_b and up_b < y:
		ranges.append(Vector2(up_a, up_b))

	# range ke bawah (menuju max_y)
	var down_a: float = min(y + eff_min, max_y)
	var down_b: float = min(y + eff_max, max_y)
	if down_a <= down_b and down_a > y:
		ranges.append(Vector2(down_a, down_b))

	if ranges.size() > 0:
		var idx: int = randi() % ranges.size()
		var chosen: Vector2 = ranges[idx]
		return randf_range(chosen.x, chosen.y)

	return clamp(y, min_y, max_y)
