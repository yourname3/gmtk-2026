extends Button
class_name UndoButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(func():
		if not Card.card_playing:
			Card.card_playing = true # To keep things from doing stuff
			await Board.instance.undo()
			Card.card_playing = false
	)

func _process(delta: float) -> void:
	visible = (not Card.card_playing and Board.instance.undo_stacks > 0)
