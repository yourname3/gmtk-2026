@tool
extends Button
class_name LevelSelectButton

@export var number: int = 0

func tile() -> Vector2i:
	return Vector2i(position / 256)

func _ready() -> void:
	text = str(number + 1)
	if Engine.is_editor_hint(): return
	
	

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		text = str(number + 1)
