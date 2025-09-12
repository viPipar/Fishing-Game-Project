extends CharacterBody2D

@export var speed: float = 150.0
@export var N: float = 200.0   
@export var M: float = 200.0   
var O: float = 2 * N

@onready var MouthArea: Area2D = $MouthArea
@onready var Sprite: AnimatedSprite2D = $AnimatedSprite2D


var patrol_points: Array[Vector2] = []
var current_point_index: int = 0
var start_position: Vector2
var target_position: Vector2

func _ready() -> void:
	start_position = global_position
	# Titik patrol silang (bentuk angka 8 miring)
	patrol_points = [
		start_position + Vector2(-N,  M),  # kiri bawah
		start_position + Vector2(-O, -M),  # kiri atas (nyilang)
		start_position + Vector2( N,  M),  # kanan bawah
		start_position + Vector2( O, -M),  # kanan atas (nyilang)
	]
	target_position = patrol_points[current_point_index]
	
func _physics_process(delta: float) -> void:
	if patrol_points.is_empty():
		return

	var direction: Vector2 = target_position - global_position
	var distance: float = direction.length()

	if distance < 5.0: 
		# sampai -> ganti target
		current_point_index = (current_point_index + 1) % patrol_points.size()
		target_position = patrol_points[current_point_index]

	# SELALU update velocity
	velocity = (target_position - global_position).normalized() * speed
	
	if velocity.x < 0 :
		Sprite.flip_h = true
	elif velocity.x > 0 :
		Sprite.flip_h = false

	# Flip berdasarkan arah
	move_and_slide()
