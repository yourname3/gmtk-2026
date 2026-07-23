extends Button
class_name UndoButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(func(): Board.instance.undo())
