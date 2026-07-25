extends Control
class_name OptionsBase

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%FullscreenButton.pressed.connect(func():
		Global.toggle_fullscreen()
	)
