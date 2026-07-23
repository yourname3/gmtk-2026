extends TileMap
class_name Board

static var instance: Board = null

var piece_map: Dictionary[Vector2i, Piece] = {}

static func move(piece: Piece, position: Vector2i) -> void:
	if instance != null:
		await instance._move(piece, position)

func _move(piece: Piece, position: Vector2i) -> void:
	piece_map.erase(piece.tile_pos())
	var existing = piece_map.get(position)
	piece_map[position] = piece
	if existing:
		existing.will_be_captured()
	await piece.move(position, existing)
	if existing:
		existing.kill()
		
func kill_piece(piece: Piece) -> void:
	piece_map.erase(piece.tile_pos())
	piece.will_be_captured()
	piece.kill()
	
	
func add_if_on_board(pos: Vector2i, out: MoveCalculator) -> bool:
	var tile = get_cell_source_id(0, pos)
	if tile != -1:
		return out.add(pos, piece_map.get(pos))
	return false

func add_if_captureable(pos: Vector2i, out: MoveCalculator) -> bool:
	var tile = get_cell_source_id(0, pos)
	if tile != -1:
		return out.add(pos, piece_map.get(pos), true)
	return false

#func get_single_move(desired_pos: Vector2i, out: MoveCalculator) -> void:
	#add_if_on_board(desired_pos, out)
	
func get_move_beam(start: Vector2i, increment: Vector2i, out: MoveCalculator) -> void:
	var tile = start + increment
	while add_if_on_board(tile, out):
		tile += increment
		
var undo_stacks: int = 0

var outstanding_undos: int = 0
		
func undo() -> void:
	if undo_stacks == 0: return
	
	undo_stacks -= 1
	SignalBus.undo.emit()
	
	piece_map.clear()
	for node: Piece in get_tree().get_nodes_in_group(&"Piece"):
		node.pop_undo_state()
		outstanding_undos += 1
		if node.alive:
			piece_map[node.tile_pos()] = node
			
	while true:
		if outstanding_undos <= 0: break
		await get_tree().process_frame

func _ready() -> void:
	instance = self
	for node: Piece in get_tree().get_nodes_in_group(&"Piece"):
		piece_map[node.tile_pos()] = node
		
	SignalBus.card_played.connect(func(card: Card):
		undo_stacks += 1
		for node: Piece in get_tree().get_nodes_in_group(&"Piece"):
			node.push_undo_state()
	)
	
