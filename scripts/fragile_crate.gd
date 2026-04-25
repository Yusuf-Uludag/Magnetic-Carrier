extends RigidBody2D

@onready var sprite = $Sprite2D

const BREAK_THRESHOLD : float = 600_000

var last_linear_velocity_squared : float = 0
var is_broken : bool = false

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	last_linear_velocity_squared = get_linear_velocity().length_squared()


func _on_body_entered(body: Node) -> void:
	if last_linear_velocity_squared > BREAK_THRESHOLD:
		var pos = sprite.region_rect.position
		sprite.region_rect.position = Vector2(pos.x + 20, pos.y)
		is_broken = true
