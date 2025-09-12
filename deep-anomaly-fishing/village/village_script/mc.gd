extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@export var speed = 200

func _physics_process(_delta):
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

	move_and_slide()
