extends Node2D
class_name BoardHighlighter

static var instance: BoardHighlighter = null

enum SelectState {
	NONE,
	PIECE,
	PIECE_ONLY,
	LOCATION,
	LOCATION_ONLY,
}

static var select_state := SelectState.NONE
static var select_filter: CardData.PieceFilter = CardData.PieceFilter.SAME_SIDE
# Integer id to determine if we're on the same select or not
static var select_id := 0

const MOVE_NULL: Vector2i = Vector2i(-99999999,-99999999)

var highlight_map: Dictionary[Vector2i, BoardHighlight]

# Async: shows highlights on the board and selects a move. 
static func select_move(piece: Piece, location_only: bool = false) -> Vector2i:
	if instance != null:
		return await instance._select_move(piece, location_only)
	return Vector2i.ZERO
	
static func is_tile_highlighted(tile: Vector2i) -> bool:
	if instance != null:
		return instance.highlight_map.has(tile)
	return false

func _add_highlight(x: int, y: int) -> void:
	var highlight := preload("res://board_highlighter/board_highlight.tscn").instantiate()
	highlight.position = Vector2(x, y) * 256
	add_child(highlight)
	
	highlight_map[Vector2i(x, y)] = highlight
	
func _clear_highlights() -> void:
	for child in get_children():
		child.queue_free()
	highlight_map.clear()

func _select_move(piece: Piece, location_only: bool) -> Vector2i:
	select_state = SelectState.LOCATION_ONLY if location_only else SelectState.LOCATION
	select_id += 1
	
	var moves = MoveCalculator.new()
	# By default, set the capture rules normally...
	moves.capture_black = not piece.is_black
	moves.capture_white = piece.is_black
	piece.calculate_moves(moves)
	
	for move in moves.moves:
		_add_highlight(move.x, move.y)
			
	var bh: BoardHighlight = null
			
	if not (location_only and moves.moves.is_empty()):
		bh = await SignalBus.move_selected
	var pos := MOVE_NULL
	if bh != null:
		pos = Vector2i(bh.position / 256)
	
	_clear_highlights()
		
	select_state = SelectState.NONE if select_state == SelectState.LOCATION_ONLY else SelectState.PIECE
	return pos
	
func _ready() -> void:
	instance = self
	
func _unhandled_input(event: InputEvent) -> void:
	if select_state == SelectState.LOCATION:
		var id = select_id
		await get_tree().process_frame # Let the Area2D's have a turn
		if select_state == SelectState.LOCATION and id == select_id: # Make sure a new selection didn't start inbetween
			if event is InputEventMouseButton:
				if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.is_pressed():
					SignalBus.move_selected.emit(null) # Deselect
		
					
