extends Node2D

@onready var inner_area = $InnerArea
@onready var inner_area_shape = $InnerArea/CollisionShape2D

signal loaded

var is_loaded: bool = false
const SIZE_THRESHOLD = 15 # in pixels

func get_is_loaded() -> bool:
	return is_loaded

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_border_area_body_exited(body: Node2D) -> void:
	if inner_area.overlaps_body(body):
		var body_rid = (body as RigidBody2D).get_rid()
		var shape_rid = PhysicsServer2D.body_get_shape(body_rid, 0)
		var shape_extents = PhysicsServer2D.shape_get_data(shape_rid) * 2
		var is_shape_valid = abs(inner_area_shape.shape.get_rect().size.x - shape_extents.x) <= SIZE_THRESHOLD and \
			abs(inner_area_shape.shape.get_rect().size.y - shape_extents.y) <= SIZE_THRESHOLD
		if is_shape_valid:
			is_loaded = true
			print("zone loaded")
			loaded.emit()
	else:
		print("zone unloaded")
		is_loaded = false


func _on_border_area_body_entered(body: Node2D) -> void:
	print("zone unloaded")
	is_loaded = false
