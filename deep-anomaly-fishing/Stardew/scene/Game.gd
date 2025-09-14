extends Node2D

var hookVelocity: float = 0.0
var hookAcceleration: float = 0.1
var hookDeceleration: float = 0.2
var maxVelocity: float = 6.0
var bounce: float = 0.6

var fishable: bool = true
var fish: PackedScene = preload("res://Stardew/scene/Fish.tscn")

func _ready() -> void:
	spawn_seriously()

func _process(delta: float) -> void:
	# Tombol clicker
	if Input.is_action_pressed("minigame"):
		if hookVelocity > -maxVelocity:
			hookVelocity -= hookAcceleration
	else:
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
		# Godot 4: get_overlapping_areas() return Array<Node2D>
		if $Hook/Area2D.get_overlapping_areas().size() > 0:
			$Progress.value += 125.0 * delta
			if $Progress.value >= 999.0:
				caught_fish()
		else:
			$Progress.value -= 100.0 * delta
			if $Progress.value <= 0.0:
				lost_fish()

func caught_fish() -> void:
	# Jika node Fish anak Node2D ini
	if has_node("Fish"):
		get_node("Fish").queue_free()
	$Progress.value = 0.0
	fishable = true

func lost_fish() -> void:
	if has_node("Fish"):
		get_node("Fish").queue_free()
	$Progress.value = 0.0
	fishable = true
	
func add_fish(min_y: float, max_y: float, move_speed: float, move_time: float) -> void:
	var f = fish.instantiate()
	
	if min_y > max_y:
		var tmp = min_y
		min_y = max_y
		max_y = tmp

	f.position = Vector2($Hook.position.x, clamp($Hook.position.y, min_y, max_y))
	f.min_y = min_y
	f.max_y = max_y
	f.movement_speed = move_speed
	f.movement_time = move_time

	add_child(f)
	$Progress.value = 200.0
	fishable = false

# Spawning ikan
func spawn_easy() -> void:
	if fishable:
		add_fish(10, 40, 8, 3)

func spawn_medium() -> void:
	if fishable:
		add_fish(30, 80, 4, 2)

func spawn_hard() -> void:
	if fishable:
		add_fish(40, 100, 4, 1.5)

func spawn_impossible() -> void:
	if fishable:
		add_fish(60, 140, 3, 1)

func spawn_seriously() -> void:
	if fishable:
		add_fish(-325, 348, 0.5, 1)

func _on_Clicker_button_down() -> void:
	hookVelocity -= 0.5
