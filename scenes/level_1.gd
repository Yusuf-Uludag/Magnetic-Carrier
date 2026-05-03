extends Node2D

@onready var loading_zones = $LoadingZones

func _ready() -> void:
	for zone in loading_zones.get_children():
		zone.loaded.connect(check_all_loading_zones)
	pass

func _physics_process(delta: float) -> void:
	pass


func check_all_loading_zones() -> void:
	for zone: Node2D in loading_zones.get_children():
		if !zone.get_is_loaded():
			return
	
	print("All loading zones loaded. Level completed!")
