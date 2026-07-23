@tool
extends Area2D
class_name Piece

const COLOR_WHITE: Color = Color("f5ece0")
const COLOR_BLACK: Color = Color("1e130f")

enum Type {
	PAWN,
	ROOK,
	KNIGHT,
	BISHOP,
	QUEEN,
	KING,
}

@onready var sprite := %Sprite

@export var type: Type = Type.PAWN
@export var is_black: bool = true

func update_appearance() -> void:
	sprite.region_rect.position.x = (256 * 5) - int(type) * 256
	sprite.modulate = COLOR_BLACK if is_black else COLOR_WHITE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_appearance()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		update_appearance()
		return
		
	# TODO: Not this.
	if BoardHighlighter.select_state == BoardHighlighter.SelectState.NONE:
		BoardHighlighter.select_state = BoardHighlighter.SelectState.PIECE

func _rook_moves(out: MoveCalculator) -> void:
	var b := Board.instance # Should be non-null cause we should only call this from calculate_moves
	var pos := tile_pos()
	b.get_move_beam(pos, Vector2i(-1, 0), out)
	b.get_move_beam(pos, Vector2i( 1, 0), out)
	b.get_move_beam(pos, Vector2i(0, -1), out)
	b.get_move_beam(pos, Vector2i(0,  1), out)
	
func _bishop_moves(out: MoveCalculator) -> void:
	var b := Board.instance # Should be non-null cause we should only call this from calculate_moves
	var pos := tile_pos()
	b.get_move_beam(pos, Vector2i(-1, -1), out)
	b.get_move_beam(pos, Vector2i(-1,  1), out)
	b.get_move_beam(pos, Vector2i( 1, -1), out)
	b.get_move_beam(pos, Vector2i( 1,  1), out)

func calculate_moves(out: MoveCalculator) -> void:
	var b := Board.instance
	var pos := tile_pos()
	if not b: return
	match type:
		Type.PAWN: # Black pawns move up, white pawns move down
			var up: int = -1 if is_black else 1
			b.add_if_on_board(pos + Vector2i(0, up), out)
			b.add_if_captureable(pos + Vector2i(-1, up), out)
			b.add_if_captureable(pos + Vector2i( 1, up), out)
		Type.ROOK:
			_rook_moves(out)
		Type.KNIGHT:
			b.add_if_on_board(pos + Vector2i(-1, -2), out)
			b.add_if_on_board(pos + Vector2i( 1, -2), out)
			b.add_if_on_board(pos + Vector2i(-1,  2), out)
			b.add_if_on_board(pos + Vector2i( 1,  2), out)
			b.add_if_on_board(pos + Vector2i(-2, -1), out)
			b.add_if_on_board(pos + Vector2i( 2, -1), out)
			b.add_if_on_board(pos + Vector2i(-2,  1), out)
			b.add_if_on_board(pos + Vector2i( 2,  1), out)
		Type.BISHOP:
			_bishop_moves(out)
		Type.QUEEN:
			_rook_moves(out)
			_bishop_moves(out)
		Type.KING:
			b.add_if_on_board(pos + Vector2i(-1, -1), out)
			b.add_if_on_board(pos + Vector2i( 0, -1), out)
			b.add_if_on_board(pos + Vector2i( 1, -1), out)
			b.add_if_on_board(pos + Vector2i(-1,  1), out)
			b.add_if_on_board(pos + Vector2i( 0,  1), out)
			b.add_if_on_board(pos + Vector2i( 1,  1), out)
			b.add_if_on_board(pos + Vector2i(-1,  0), out)
			b.add_if_on_board(pos + Vector2i( 1,  0), out)

var _is_move_selector: bool = false

# Performs the UI for moving the piece.
func move_this() -> void:
	_is_move_selector = true
	var target = await BoardHighlighter.select_move(self)
	_is_move_selector = false
	if target != BoardHighlighter.MOVE_NULL:
		Board.move(self, target)
		BoardHighlighter.select_state = BoardHighlighter.SelectState.NONE
	
# Actually moves a piece.
func move(target: Vector2i) -> void:
	position = target * 256
	
func tile_pos() -> Vector2i:
	return Vector2i(position / 256)
	
func kill() -> void:
	queue_free()

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.is_pressed():
			if BoardHighlighter.select_state == BoardHighlighter.SelectState.PIECE:
				move_this()
			elif BoardHighlighter.select_state == BoardHighlighter.SelectState.LOCATION:
				var is_selector = _is_move_selector
				# If we are not ourselves highlighted, we are allowed to steal the selection state.
				if not BoardHighlighter.is_tile_highlighted(tile_pos()):
					# First, remove the existing highlights...
					SignalBus.move_selected.emit(null)
					# Then invoke ourselves, unless we were already selected (in that case deselect)
					if not is_selector: move_this()
	
