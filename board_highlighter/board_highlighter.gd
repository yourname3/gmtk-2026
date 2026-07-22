extends Node2D
class_name BoardHighlighter

static var instance: BoardHighlighter = null

# Async: shows highlights on the board and selects a move. 
static func select_move(piece: Piece) -> Vector2i:
	if instance != null:
		return await instance._select_move(piece)
	return Vector2i.ZERO

func _add_highlight(x: int, y: int) -> void:
	var highlight := preload("res://board_highlighter/board_highlight.tscn").instantiate()
	highlight.position = Vector2(x, y) * 256
	add_child(highlight)

func _select_move(piece: Piece) -> Vector2i:
	for i in range(0, 5):
		for j in range(0, 5):
			_add_highlight(i, j)
			
	var bh: BoardHighlight = await SignalBus.move_selected
	var pos = Vector2i(bh.position / 256)
	
	for child in get_children():
		child.queue_free()
	
	return pos
	
func _ready() -> void:
	instance = self
