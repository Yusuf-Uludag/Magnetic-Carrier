extends CharacterBody2D

const SPEED = 380.0
const JUMP_VELOCITY = -600.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump"):# and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, SPEED/3)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED/15)
	print(velocity.x)

	move_and_slide()
