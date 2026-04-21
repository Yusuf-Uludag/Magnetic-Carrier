extends RigidBody2D

@onready var shape_cast = $ShapeCast2D

#crane
@onready var shoulder_joint = $Crane/CraneJoint
@onready var elbow_joint = $Crane/UpperArm/ElbowJoint
@onready var upper_arm = $Crane/UpperArm
@onready var lower_arm = $Crane/LowerArm

const SPEED = 380.0
const JUMP_VELOCITY = -600.0

# crane
@export var length_upper_arm: float = 100.0
@export var length_lower_arm: float = 120.0
@export var motor_speed: float = 10.0

func _ready() -> void:
	pass

func process_crane():
	var mouse_pos = get_global_mouse_position()
	
	var target_pos_relative = mouse_pos - shoulder_joint.global_position
	var D = target_pos_relative.length()
	
	# Clamp distance so the math doesn't crash if the mouse is out of reach!
	var max_reach = length_upper_arm + length_lower_arm - 0.1
	D = clamp(D, 0.1, max_reach)
	
	var elbow_cos = (D * D - length_upper_arm * length_upper_arm - length_lower_arm * length_lower_arm) / (2 * length_upper_arm * length_lower_arm)
	var elbow_angle = acos(clamp(elbow_cos, -1.0, 1.0)) 
	elbow_angle = -elbow_angle
	
	# shoulder directly rotates to target rotation
	var base_angle = atan2(target_pos_relative.y, target_pos_relative.x)
	var shoulder_offset = atan2(length_lower_arm * sin(elbow_angle), length_upper_arm + length_lower_arm * cos(elbow_angle))
	var shoulder_angle = base_angle - shoulder_offset + (PI / 2.0)
	
	var current_shoulder_angle = upper_arm.global_rotation
	var shoulder_diff = wrapf(shoulder_angle - current_shoulder_angle, -PI, PI)
	shoulder_joint.motor_target_velocity = shoulder_diff * motor_speed
	
	var current_elbow_angle = lower_arm.global_rotation - upper_arm.global_rotation
	var elbow_diff = wrapf(elbow_angle - current_elbow_angle, -PI, PI)
	elbow_joint.motor_target_velocity = elbow_diff * motor_speed
	
	# for debugging:
	#print("Target: ", rad_to_deg(shoulder_angle), " | Current: ", rad_to_deg(upper_arm.global_rotation))


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

	process_crane()
