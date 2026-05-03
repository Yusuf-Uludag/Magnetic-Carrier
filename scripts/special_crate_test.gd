extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass
	#print("my gravity is", get_gravity())
	#gravity_scale = 1
	#var bodies: Array[Node2D] = get_colliding_bodies()
	#for body in bodies:
		## TODO: check if its in [upperarm, lowerarm, magnet]
		#if body is RigidBody2D:
			#print("gravity zeroed")
	##		gravity_scale = 0
