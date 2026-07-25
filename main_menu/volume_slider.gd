extends HSlider
class_name VolumeSlider

@export var bus_name: StringName = &"Master"
var bus_idx: int = 0

func _ready() -> void:
	min_value = 0.0
	max_value = 2.0
	bus_idx = AudioServer.get_bus_index(bus_name)
	value = AudioServer.get_bus_volume_linear(bus_idx)
	
	value_changed.connect(func(v: float): AudioServer.set_bus_volume_linear(bus_idx, v))
	
