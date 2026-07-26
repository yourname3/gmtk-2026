extends AudioStreamPlayer
## SFX that can be "floated" to the scene root, and then will remove itself after playing.
class_name FloatingSfx

@export var play_when_paused: bool = true

func _ready() -> void:
	if play_when_paused: process_mode = Node.PROCESS_MODE_ALWAYS

func play_floating(delay: float = 0.0) -> void:
	reparent(get_tree().root)
	if delay > 0:
		# always process because sounds fire fast i guess
		await get_tree().create_timer(delay, true).timeout
	play()
	await finished
	queue_free()
