extends CollisionPolygon2D

@onready var polygon_2d: Polygon2D = $"../Polygon2D"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	polygon = polygon_2d.polygon
	position = polygon_2d.position + polygon_2d.offset


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
