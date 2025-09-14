extends CharacterBody2D

@onready var walk: AudioStreamPlayer = $Walk
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var speed: float = 1000.0

func _physics_process(_delta: float) -> void:
	velocity = Vector2.ZERO
	var anim = "idle"

	# Gerakan horizontal
	if Input.is_action_pressed("right"):
		velocity.x = speed
		anim = "move_right"
	elif Input.is_action_pressed("left"):
		velocity.x = -speed
		anim = "move_left"

	# Gerakan vertikal
	if Input.is_action_pressed("up"):
		velocity.y = -speed
		anim = "move_up"
	elif Input.is_action_pressed("down"):
		velocity.y = speed
		anim = "move_down"

	# Kalau diam
	if velocity == Vector2.ZERO:
		anim = "idle"

	# Mainkan animasi sesuai arah
	sprite.play(anim)

	# ======== WALK SOUND LOGIC ========
	if velocity != Vector2.ZERO:
		if not walk.playing:
			walk.play()
	else:
		if walk.playing:
			walk.stop()
	# ==================================

	if global_village.mc_movement:
		move_and_slide()
