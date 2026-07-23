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
	await piece.move(position)
	if existing:
		existing.kill()
	
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

func _ready() -> void:
	instance = self
	for node: Piece in get_tree().get_nodes_in_group(&"Piece"):
		piece_map[node.tile_pos()] = node
	
