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

var preview_nodes: Array[BoardHighlight] = []

@onready var tink := %Tink

static var select_state := SelectState.NONE
static var select_filter: CardData.PieceFilter = CardData.PieceFilter.SAME_SIDE
static var select_rank_filter: CardData.RankFilter = CardData.RankFilter.NONE
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

func _add_highlight(x: int, y: int, in_map: bool = true) -> BoardHighlight:
	var highlight := preload("res://board_highlighter/board_highlight.tscn").instantiate()
	highlight.position = Vector2(x, y) * 256
	add_child(highlight)
	
	if in_map:
		highlight_map[Vector2i(x, y)] = highlight
	return highlight
	
func _clear_highlights(fun: bool) -> void:
	clear_preview()
	for child in get_children():
		if child is BoardHighlight:
			child.die(fun)
	highlight_map.clear()
	
func clear_preview() -> void:
	for node in preview_nodes:
		node.queue_free()
	preview_nodes.clear()
	SignalBus.preview_cleared.emit()
	
func preview_move(location: Vector2i) -> void:
	clear_preview()
	
	tink.pitch_scale = 1.0
	tink.play()
	
	preview_nodes.append(_add_highlight(location.x, location.y, false))
func preview_moves_red(locations: Array[Vector2i]) -> void:
	clear_preview()
	
	tink.pitch_scale = 1.0
	tink.play()
	
	for loc in locations:
		var h := _add_highlight(loc.x, loc.y, false)
		h.redify()
		preview_nodes.append(h)

func _select_move(piece: Piece, location_only: bool) -> Vector2i:
	select_state = SelectState.LOCATION_ONLY if location_only else SelectState.LOCATION
	select_id += 1
	
	var moves = MoveCalculator.new()
	# By default, set the capture rules normally...
	moves.capture_black = not piece.is_black
	moves.capture_white = piece.is_black
	piece.calculate_moves(moves)
	
	moves.moves.shuffle() # shuffle for ring appearance
	
	var timer = 0.1 / moves.moves.size()
	timer = min(timer, 0.02)
	
	var time := Time.get_ticks_msec()
	
	var _prev_db = tink.volume_db
	tink.pitch_scale = 1.0
	for move in moves.moves:
		tink.play()
		
		var h := _add_highlight(move.x, move.y)
		h.die_pitch = tink.pitch_scale
		h.die_time = (Time.get_ticks_msec() - time) / 1000.0
		h.move_rel = move - piece.tile_pos()
		
		tink.pitch_scale *= 1.04
		tink.volume_db -= 0.2
		await get_tree().create_timer(timer, true).timeout
		#total_time += timer
	tink.volume_db = _prev_db
			
	var bh: BoardHighlight = null
			
	if not (location_only and moves.moves.is_empty()):
		bh = await SignalBus.move_selected
	var pos := MOVE_NULL
	if bh != null:
		pos = Vector2i(bh.position / 256)
	
	_clear_highlights(bh != null)
		
	select_state = SelectState.NONE if select_state == SelectState.LOCATION_ONLY else SelectState.PIECE
	return pos
	
func _ready() -> void:
	instance = self
	
	SignalBus.undo.connect(func():
		if select_state != SelectState.NONE:
			SignalBus.move_selected.emit(null)
	)
	
func _unhandled_input(event: InputEvent) -> void:
	if select_state == SelectState.LOCATION:
		var id = select_id
		await get_tree().physics_frame # Let the Area2D's have a turn
		await get_tree().process_frame
		if select_state == SelectState.LOCATION and id == select_id: # Make sure a new selection didn't start inbetween
			if event is InputEventMouseButton:
				if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.is_pressed():
					SignalBus.move_selected.emit(null) # Deselect
		
					
