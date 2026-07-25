extends AudioStreamPlayer
## SFX that can be "floated" to the scene root, and then will remove itself after playing.
class_name FloatingSfx

@export var play_when_paused: bool = true

func _ready() -> void:
	if play_when_paused: process_mode = Node.PROCESS_MODE_ALWAYS

func play_floating() -> void:
	reparent(get_tree().root)
	play()
	await finished
	queue_free()
