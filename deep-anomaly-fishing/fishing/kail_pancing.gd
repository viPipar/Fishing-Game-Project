extends CharacterBody2D
const pullForce = -200.0
const maxPullForce = -50.0

const maxDownForce = 400.0

#Ngecek apakah ada input dari player ya ini anjeng
var is_input = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	is_input = false
	
	if Input.is_action_pressed("down"):
		velocity.y += 50 
		if velocity.y > maxDownForce :
			velocity.y = maxDownForce
		is_input = true
	
	if not is_input :
		velocity.y += pullForce * delta
		if velocity.y > maxPullForce :
			velocity.y = maxPullForce
			
	move_and_slide()
