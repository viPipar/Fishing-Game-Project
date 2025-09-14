extends CharacterBody2D

@export var speed: float = 200.0
@onready var anim = $AnimatedSprite2D

var target_position: Vector2
var moving: bool = false

# Call this to make her walk to a coordinate
func move_to(x: float, y: float) -> void:
	target_position = Vector2(x, y)
	moving = true

func _physics_process(delta: float) -> void:
	if moving:
		var direction = (target_position - global_position).normalized()
		velocity = direction * speed

		# Choose animation
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				anim.play("move_right")
			else:
				anim.play("move_left")
		else:
			if direction.y > 0:
				anim.play("move_down")
			else:
				anim.play("move_up")

		move_and_slide()

		# Stop near target
		if global_position.distance_to(target_position) < 5:
			moving = false
			velocity = Vector2.ZERO
			anim.play("idle")
	else:
		velocity = Vector2.ZERO
