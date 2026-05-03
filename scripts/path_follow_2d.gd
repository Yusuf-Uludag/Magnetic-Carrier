extends PathFollow2D

#	button press signal function
#	func _on_button_pressed():
#		progress_ratio = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
#	 signal = button triggering progress 0.0 -> 1.0
#		if signal:
#			_on_button_pressed()
	progress_ratio += 0.015
