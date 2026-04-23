extends RigidBody2D

@onready var shape_cast = $ShapeCast2D
@onready var left_wheel = $Joint/LeftWheel
@onready var right_wheel = $Joint/RightWheel

#crane
@onready var shoulder_joint = $Crane/CraneJoint
@onready var elbow_joint = $Crane/UpperArm/ElbowJoint
@onready var upper_arm = $Crane/UpperArm
@onready var lower_arm = $Crane/LowerArm
@onready var magnet_joint = $Crane/LowerArm/MagnetJoint
@onready var magnet = $Crane/LowerArm/Magnet
@onready var magnet_attract_area = $Crane/LowerArm/Magnet/ShapeCast2D
@onready var magnet_crate_joint = $Crane/LowerArm/Magnet/MagnetCrateJoint
@onready var magnet_stick_detector = $Crane/LowerArm/Magnet/StickDetector
@onready var crate_placement_area = $Crane/LowerArm/Magnet/CratePlacementArea
@onready var crate_collision_simulator = $Crane/LowerArm/Magnet/CrateCollisionSimulator
@onready var magnet_gravity_area = $Crane/LowerArm/Magnet/MagnetGravityArea

const SPEED = 800.0
const JUMP_VELOCITY = -600.0

# crane
@export var length_upper_arm: float = 140.0
@export var length_lower_arm: float = 120.0
@export var motor_speed: float = 200.0
var grabbed_crate: RigidBody2D = null
var magnet_strength: float = 4_000.0
var is_crate_sticked: bool = false
var last_colliding_crate: RigidBody2D = null

func _ready() -> void:
	pass
	
	
func grab_crate(delta: float):
	if magnet_attract_area.is_colliding():
		var colliding_crate : RigidBody2D = magnet_attract_area.collision_result[0]["collider"]
		if is_crate_sticked:
			pass
		else:
			if magnet_stick_detector.overlaps_body(colliding_crate):
				colliding_crate.angular_velocity = 0.0
				colliding_crate.linear_velocity = Vector2(0.0, 0.0)
				#colliding_crate.gravity_scale = 0.0
				
				var angle_diff = wrapf(colliding_crate.global_rotation - magnet_crate_joint.global_rotation, -PI, PI)
				var snapped_diff = snapped(angle_diff, PI / 2.0)
				#colliding_crate.global_rotation = magnet_crate_joint.global_rotation + snapped_diff
				colliding_crate.global_rotation = magnet_crate_joint.global_rotation
				
				var crate_half_size: float = 50.0
				var safe_distance = crate_half_size + 2.0
				var outward_dir = magnet_crate_joint.global_transform.y
				colliding_crate.global_position = crate_placement_area.global_position# + (outward_dir * safe_distance)
				
				
				lower_arm.add_collision_exception_with(colliding_crate)
				
				crate_collision_simulator.disabled = false
				magnet_crate_joint.node_b = colliding_crate.get_path()
				grabbed_crate = colliding_crate
				is_crate_sticked = true
				print("sticking")
			else:
				print("pulling")
				#var pull_direction = (magnet_crate_joint.global_position - colliding_crate.global_position).normalized()
				var pull_direction = colliding_crate.global_position.direction_to(magnet_crate_joint.global_position)
				var force = pull_direction * magnet_strength
				colliding_crate.apply_central_force(force * delta)
				
				var pull_rotation = (magnet_crate_joint.global_rotation - colliding_crate.global_rotation)
				var rotation_torque = pull_rotation
				print("rotation torque",rotation_torque)
				colliding_crate.apply_torque(rotation_torque * delta)
				is_crate_sticked = false
	
func drop_crate():
	magnet_crate_joint.node_b = NodePath("")
	grabbed_crate.gravity_scale = 1.0
	#grabbed_crate.linear_velocity = Vector2.ZERO
	lower_arm.remove_collision_exception_with(grabbed_crate)
	grabbed_crate = null
	is_crate_sticked = false
	crate_collision_simulator.disabled = true
	upper_arm.linear_velocity = Vector2.ZERO
	lower_arm.linear_velocity = Vector2.ZERO
	magnet.linear_velocity = Vector2.ZERO

func process_crane(delta: float):
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
	
	#var base_speed = 15.0 
	#var stiffness = 200.0 
	
	
	var current_shoulder_angle = upper_arm.global_rotation
	var shoulder_diff = wrapf(shoulder_angle - current_shoulder_angle, -PI, PI)
	shoulder_joint.motor_target_velocity = shoulder_diff * motor_speed
	
	var current_elbow_angle = lower_arm.global_rotation - upper_arm.global_rotation
	var elbow_diff = wrapf(elbow_angle - current_elbow_angle, -PI, PI)
	elbow_joint.motor_target_velocity = elbow_diff * motor_speed
	
	
	#var shoulder_anti_sag = sign(shoulder_diff) * pow(abs(shoulder_diff), 1.5) * stiffness
	#var elbow_anti_sag = sign(elbow_diff) * pow(abs(elbow_diff), 1.5) * stiffness
#
	#shoulder_joint.motor_target_velocity = (shoulder_diff * base_speed) + shoulder_anti_sag
	#elbow_joint.motor_target_velocity = (elbow_diff * base_speed) + elbow_anti_sag
	
	var current_magnet_angle = magnet.global_rotation
	var magnet_diff = wrapf(lower_arm.global_rotation - current_magnet_angle, -PI, PI)
	magnet_joint.motor_target_velocity = magnet_diff * motor_speed * 0.5
	
	# for debugging:
	#print("Target: ", rad_to_deg(shoulder_angle), " | Current: ", rad_to_deg(upper_arm.global_rotation))

	if magnet_attract_area.is_colliding():
		last_colliding_crate = magnet_attract_area.collision_result[0]["collider"]
		#magnet.add_collision_exception_with(last_colliding_crate)
		#lower_arm.add_collision_exception_with(last_colliding_crate)
	else:
		if last_colliding_crate != null:
			pass
		#	magnet.remove_collision_exception_with(last_colliding_crate)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		magnet_gravity_area.gravity_space_override = 3 # REPLACE
		magnet_gravity_area.gravity = 0
		if grabbed_crate == null:
			grab_crate(delta)
		else:
			var magnet_crate_diff = wrapf(magnet_crate_joint.global_rotation - grabbed_crate.global_rotation, -PI, PI)
			magnet_crate_joint.motor_target_velocity = magnet_crate_diff * motor_speed
			grabbed_crate.global_rotation = magnet_crate_joint.global_rotation
	else:
		magnet_gravity_area.gravity_space_override = 0 # DISABLE
		magnet_gravity_area.gravity = 980.0
		if grabbed_crate != null:
			drop_crate()


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

	process_crane(delta)
