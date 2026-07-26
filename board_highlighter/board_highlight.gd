extends Area2D
class_name BoardHighlight

var die_pitch: float = 1.0
var die_time: float = 0.0

func die(fun: bool) -> void:
	if fun:
		%Tink.pitch_scale = die_pitch
		%Tink.play_floating(die_time)
	queue_free()

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.is_pressed():
			SignalBus.move_selected.emit(self)
