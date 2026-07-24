extends TileMap
class_name Board

static var instance: Board = null

var piece_map: Dictionary[Vector2i, Piece] = {}

static func move(piece: Piece, position: Vector2i) -> void:
	if instance != null:
		await instance._move(piece, position)
	
# TODO: Also handle other kinds of borders...?
func build_rectangle_border() -> void:
	var trim := %Trim
	
	var rect: Rect2i = get_used_rect()
	for x in range(0, rect.size.x):
		trim.set_cell(Vector2i(x,          -1), 0, Vector2i(1, 0)) # top trim
		trim.set_cell(Vector2i(x, rect.size.y), 0, Vector2i(1, 2)) # bottom trim
	for y in range(0, rect.size.y):
		trim.set_cell(Vector2i(         -1, y), 0, Vector2i(0, 1)) # left trim
		trim.set_cell(Vector2i(rect.size.x, y), 0, Vector2i(2, 1)) # right trim
		
	trim.set_cell(Vector2i(-1, -1),                   0, Vector2i(0, 0))
	trim.set_cell(Vector2i(-1, rect.size.y),          0, Vector2i(0, 2))
	trim.set_cell(Vector2i(rect.size.x, -1),          0, Vector2i(2, 0))
	trim.set_cell(Vector2i(rect.size.x, rect.size.y), 0, Vector2i(2, 2))
		
		
# For now, clamps moves like so:
# - Any move with directionality is clamped based on repeating it as many times
#   as possible in that direction. Moves always terminate if they hit a chess piece
#   as well, even if it was an unintended capture.
# - Knight moves are clamped to not move at all if the target square isn't available.
# 
# We could store some state to also allow beam moves to be hops, which might be necessary
# at some point, but for now, the directionality of a move determines whether it is
# 'continuous' or a 'hop'.
func _clamp_move(from: Vector2i, to: Vector2i) -> Vector2i:
	var direction := to - from
	var continuous: bool = true
	if direction.x != 0 and direction.y != 0:
		if absi(direction.x) != absi(direction.y): # knight move
			continuous = false
	
	if continuous:
		# normalize these. WILL NEED TO CHANGE IF WE ADD WEIRD MOVES!!!!!
		direction.x = signi(direction.x)
		direction.y = signi(direction.y)
			
	var pos := from
			
	if continuous:
		while pos != to:
			var candidate := pos + direction
			var tile = get_cell_source_id(0, candidate)
			if tile == -1:
				# Can't move any further, breka
				break
			# We can at least make the move.
			pos += direction
			if piece_map.get(pos) != null:
				break # hit a piece, call it
	else:
		if get_cell_source_id(0, to) == -1: # can't move off board
			return from # stay where you were
		else:
			return to # ok you can hop
				
	return pos

func _move(piece: Piece, position: Vector2i) -> void:
	SignalBus.piece_started_moving.emit()
	#if not Card.card_playing:
		#await Card.
	position = _clamp_move(piece.tile_pos(), position)
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
	
func add_if_not_captureable(pos: Vector2i, out: MoveCalculator) -> bool:
	var tile = get_cell_source_id(0, pos)
	if tile != -1:
		return out.add(pos, piece_map.get(pos), false, true)
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
		var next_tile_undo_pos = node.get_undo_pos()
		var next_tile_undo_alive = node.get_undo_alive()
		node.pop_undo_state()
		outstanding_undos += 1
		if next_tile_undo_alive:
			piece_map[next_tile_undo_pos] = node
			
	while true:
		if outstanding_undos <= 0: break
		await get_tree().process_frame

func _ready() -> void:
	instance = self
	for node: Piece in get_tree().get_nodes_in_group(&"Piece"):
		piece_map[node.tile_pos()] = node
		
	build_rectangle_border()
	
	var iter0 = 0
	var iter1 = 0
	
	for tile in get_used_cells(0):
		var coord = get_cell_atlas_coords(0, tile)
		var variation: int = 0
		var alt_id: int = 0
		if coord.x == 0:
			variation = iter0 % 16
			iter0 += 1
			alt_id |= TileSetAtlasSource.TRANSFORM_TRANSPOSE
		else:
			variation = iter1 % 16
			iter1 += 1
		coord.x += (variation / 4) * 2
		coord.y = variation % 4
		#print("variation = ", variation, " : ", (variation / 4), " ", variation % 4)
		set_cell(0, tile, 0, coord, alt_id)
		
	SignalBus.card_played.connect(func(card: Card):
		undo_stacks += 1
		for node: Piece in get_tree().get_nodes_in_group(&"Piece"):
			node.push_undo_state()
	)
	
