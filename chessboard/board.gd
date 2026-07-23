extends TileMap
class_name Board

static var instance: Board = null

var piece_map: Dictionary[Vector2i, Piece] = {}

static func move(piece: Piece, position: Vector2i) -> void:
	if instance != null:
		instance._move(piece, position)

func _move(piece: Piece, position: Vector2i) -> void:
	piece_map.erase(piece.tile_pos())
	var existing = piece_map.get(position)
	if existing:
		existing.kill()
	piece_map[position] = piece
	piece.move(position)

func _ready() -> void:
	instance = self
	for node: Piece in get_tree().get_nodes_in_group(&"Piece"):
		piece_map[node.tile_pos()] = node
	
