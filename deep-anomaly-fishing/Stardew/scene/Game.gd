extends Node2D

var _overlap_count := 0
var hookVelocity: float = 0.0
var hookAcceleration: float = 0.1
var hookDeceleration: float = 0.2
var maxVelocity: float = 6.0
var bounce: float = 0.6
const LAYER_VAL := 20 

var fishable: bool = true
var fish: PackedScene = preload("res://Stardew/scene/Fish.tscn")
@onready var hooking: AudioStreamPlayer = $Hooking

func _ready() -> void:
	$Hook/Area2D.area_entered.connect(func(a):
		if a.is_in_group("fish_target"): _overlap_count += 1)
	$Hook/Area2D.area_exited.connect(func(a):
		if a.is_in_group("fish_target"): _overlap_count -= 1)
	
func _process(delta: float) -> void:
	# Tombol clicker
	if Input.is_action_pressed("minigame"):
		# play hooking sound while minigame pressed (only start if not already playing)
		if is_instance_valid(hooking) and not hooking.playing:
			hooking.play()
		if hookVelocity > -maxVelocity:
			hookVelocity -= hookAcceleration
	else:
		# stop hooking sound when released
		if is_instance_valid(hooking) and hooking.playing:
			hooking.stop()
		if hookVelocity < maxVelocity:
			hookVelocity += hookDeceleration

	if Input.is_action_just_pressed("ui_accept"):
		hookVelocity -= 0.5

	var target: float = $Hook.position.y + hookVelocity

	# Cek batas atas bawah
	if target >= 348.0:
		hookVelocity *= -bounce
	elif target <= -325.0:
		hookVelocity = 0.0
		$Hook.position.y = -325.0
	else:
		$Hook.position.y = target

	# Progress bar saat sedang memancing
	if not fishable:
		var overlap_fish := false
		for area in $Hook/Area2D.get_overlapping_areas():
			if _overlap_count > 0 and area.is_in_group("fish_target"):
				overlap_fish = true
				break
			else:
				overlap_fish = false

		if overlap_fish:
			$Progress.value += 125.0 * delta
			if $Progress.value >= 999.0:
				caught_fish()
		else:
			$Progress.value -= 100.0 * delta
			if $Progress.value <= 0.0:
				lost_fish()
	if global_fishing.hooking == true:
		spawn_impossible()

func caught_fish() -> void:
	if has_node("Fish"):
		get_node("Fish").queue_free()
	$Progress.value = 0.0
	fishable = true
	global_fishing.hooking = false

	# kirim signal ke global_fishing
	var payload := {
		"fish_id": "unknown",   # isi kalau kamu punya id
		"size": 0,              # isi ukuran kalau ada
		"difficulty": "seriously"
	}
	global_fishing.emit_signal("fishing_result", true, payload)
	global_fishing.coin += 4
	global_fishing.caught = true
	global_fishing.release = true


func lost_fish() -> void:
	if has_node("Fish"):
		get_node("Fish").queue_free()
	$Progress.value = 0.0
	fishable = true

	# kirim signal kalah
	global_fishing.emit_signal("fishing_result", false, {})
	global_fishing.hooking = false
	global_fishing.release = true
	
func add_fish(min_d: float, max_d: float, move_speed: float, move_time: float) -> void:
	var hook_area: Area2D = $Hook/Area2D
	hook_area.set_deferred("monitoring", false)
	
	var f: Node2D = fish.instantiate()

	await get_tree().process_frame
	hook_area.set_deferred("monitoring", true)

	# Pastikan posisi awal di dalam area
	f.position = Vector2(
		$Hook.position.x,
		clamp($Hook.position.y, -325.0, 348.0)
	)

	# Isi parameter yang sudah kamu definisikan di Fish.gd
	f.min_distance = min_d
	f.max_distance = max_d
	f.movement_speed = move_speed
	f.movement_time = move_time
	f.min_y = -325.0
	f.max_y = 348.0
	
	
	add_child(f)

	var target_area := f.get_node("Area2D") as Area2D   # ganti path sesuai punyamu
	target_area.add_to_group("fish_target")
	for i in range(1, 33):
		target_area.set_collision_layer_value(i, i == LAYER_VAL)
		target_area.set_collision_mask_value(i,  i == LAYER_VAL)
	
	$Progress.value = 200.0
	fishable = false


# Spawning ikan
func spawn_easy() -> void:
	if fishable:
		add_fish(10, 80, 8, 3)

func spawn_medium() -> void:
	if fishable:
		add_fish(30, 100, 4, 2)

func spawn_hard() -> void:
	if fishable:
		add_fish(60, 200, 4, 1.5)

func spawn_impossible() -> void:
	if fishable:
		add_fish(80, 300, 3, 1)

func spawn_seriously() -> void:
	if fishable:
		add_fish(100, 600, 0.5, 1)
