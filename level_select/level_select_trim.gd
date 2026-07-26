extends TileMapLayer
class_name LevelSelectTrim

const CORN_CIRCLE := 0
const WALL := 1
const CORN_INNER := 2
const LOOP := 3
const U := 4

func kind(cell: Vector2i) -> int:
	match get_cell_atlas_coords(cell):
		Vector2i(0, 0): return CORN_CIRCLE
		Vector2i(0, 2): return CORN_CIRCLE
		Vector2i(2, 0): return CORN_CIRCLE
		Vector2i(2, 2): return CORN_CIRCLE
		Vector2i(1, 0): return WALL
		Vector2i(0, 1): return WALL
		Vector2i(2, 1): return WALL
		Vector2i(1, 2): return WALL
		Vector2i(0 + 3, 0): return CORN_INNER
		Vector2i(0 + 3, 2): return CORN_INNER
		Vector2i(2 + 3, 0): return CORN_INNER
		Vector2i(2 + 3, 2): return CORN_INNER
		Vector2i(1, 1): return LOOP
		Vector2i(4, 1): return U
	return WALL
	
func unlocked(cell: Vector2i) -> bool:
	var c: LevelSelectButton = map.get(cell)
	if c == null: return false
	return c.unlocked
	
func corn_circle(cell: Vector2i) -> void:
	var dir = Vector2i.ZERO
	match get_cell_atlas_coords(cell):
		Vector2i(0, 0): dir = Vector2i(1, 1)
		Vector2i(0, 2): dir = Vector2i(1, -1)
		Vector2i(2, 0): dir = Vector2i(-1, 1)
		Vector2i(2, 2): dir = Vector2i(-1, -1)
		
	if not unlocked(cell + dir):
		set_cell(cell, -1)
		
func wall(cell: Vector2i) -> void:
	var dir = Vector2i.ZERO
	match get_cell_atlas_coords(cell):
		Vector2i(1, 0): dir = Vector2i(0, 1)
		Vector2i(0, 1): dir = Vector2i(1, 0)
		Vector2i(2, 1): dir = Vector2i(-1, 0)
		Vector2i(1, 2): dir = Vector2i(0, -1)
		
	if not unlocked(cell + dir):
		set_cell(cell, -1)
		
func corn_inner(cell: Vector2i) -> void:
	var dir = Vector2i.ZERO
	match get_cell_atlas_coords(cell):
		Vector2i(0 + 3, 0): dir = Vector2i(1, 1)
		Vector2i(0 + 3, 2): dir = Vector2i(1, -1)
		Vector2i(2 + 3, 0): dir = Vector2i(-1, 1)
		Vector2i(2 + 3, 2): dir = Vector2i(-1, -1)
		
	if not unlocked(cell + Vector2i(0, -dir.y)) and not unlocked(cell + Vector2i(-dir.x, 0)):
		set_cell(cell, -1)
	#if not unlocked(cell + Vector2i(0, -dir.y)) or not unlocked(cell + Vector2i(-dir.x, 0)):
		#if unlocked(cell + Vector2i(0, -dir.y)):
			#set_cell(cell, 0, Vector2i(0, 1) if dir.y > 1 else Vector2i(2, 1))
		#elif unlocked(cell + Vector2i(-dir.x, 0)):
			#set_cell(cell, 0, Vector2i(0, 1) if dir.y > 1 else Vector2i(2, 1))
		#else:
			#set_cell(cell, -1)
			
func loop(cell: Vector2i) -> void:
	var count = 0;
	if unlocked(cell + Vector2i(0, -1)): count += 1
	if unlocked(cell + Vector2i(0,  1)): count += 1
	if unlocked(cell + Vector2i(-1, 0)): count += 1
	if unlocked(cell + Vector2i( 1, 0)): count += 1
	
	if count < 2:
		set_cell(cell, -1)
		
func u(cell: Vector2i) -> void:
	var count = 0;
	if unlocked(cell + Vector2i(0, -1)): count += 1
	if unlocked(cell + Vector2i(0,  1)): count += 1
	#if unlocked(cell + Vector2i(-1, 0)): count += 1
	if unlocked(cell + Vector2i( 1, 0)): count += 1
	
	if count < 2:
		set_cell(cell, -1)

var map: Dictionary[Vector2i, LevelSelectButton] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	
	map = get_parent().button_map
	for cell in get_used_cells():
		match kind(cell):
			CORN_CIRCLE: corn_circle(cell)
			CORN_INNER: corn_inner(cell)
			WALL: wall(cell)
			LOOP: loop(cell)
			U: u(cell)
