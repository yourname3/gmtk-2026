extends Button
class_name ButtonWithSFX

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(func(): ButtonSFX.click.play())
	mouse_entered.connect(func(): ButtonSFX.hover.play())
