extends RigidBody2D

@onready var shape_cast = $ShapeCast2D

const SPEED = 380.0
const JUMP_VELOCITY = -600.0

func _physics_process(delta: float) -> void:

	# Handle jump.
	if Input.is_action_just_pressed("jump") and shape_cast.is_colliding():
		var jump_vector = Vector2(0, JUMP_VELOCITY * 200) * delta * 60
		apply_force(jump_vector, Vector2(0, 0))
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		var pos = 100
		if direction < 0:
			pos = -100
		var move_vector = Vector2(direction * SPEED * 5, -5_000) * delta * 60
		apply_force(move_vector, Vector2(pos, 0))
